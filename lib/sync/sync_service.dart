export 'lan/lan_discovery.dart' show DiscoveredPeer, DiscoveredProfile;

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import 'collection_payload.dart';
import 'conflicts.dart';
import 'device_identity.dart';
import 'entities.dart';
import 'item_payload.dart';
import 'lan/lan_discovery.dart';
import 'pending_change.dart';
import 'sync_protocol.dart';
import 'universe_payload.dart';

/// Bumped if the wire format ever changes in a backwards-incompatible way.
const int kSchemaVersion = 3;

enum SyncStatus { idle, connecting, syncing, done, error }

/// Owns the sync sessions themselves, whatever carries them: devices found
/// automatically on the local network ([lan] — mDNS + TCP, native only) or
/// paired by QR code over WebRTC (see webrtc_pairing.dart, the only option
/// in a browser). No server involved anywhere. Each session syncs
/// Universes, then Collections, then Items, in that order — see
/// _runSyncSession.
class SyncService extends ChangeNotifier {
  final AppDatabase db;
  final DeviceIdentity identity;
  final LanDiscovery lan;

  List<DiscoveredPeer> get peers => lan.peers;

  /// Whether the given *profile* — not device — is currently reachable on
  /// the network, i.e. some discovered device is advertising it right now.
  bool isOnline(String profileId) =>
      peers.any((peer) => peer.profiles.any((p) => p.id == profileId));

  SyncStatus status = SyncStatus.idle;
  String? statusMessage;

  final List<UniverseConflict> universeConflicts = [];
  final List<CollectionConflict> collectionConflicts = [];
  final List<ItemConflict> itemConflicts = [];
  int get totalConflicts =>
      universeConflicts.length + collectionConflicts.length + itemConflicts.length;

  /// Changes to a peer's content, proposed by the last sync(s) *you*
  /// initiated, waiting for you to accept or ignore them — see
  /// docs/spec-universes-collections.md and PendingChange's doc comment.
  final List<PendingChange> pendingChanges = [];

  SyncService({required this.db, required this.identity}) : lan = LanDiscovery(identity);

  Future<void> start() async {
    await lan.start(
      localProfiles: () async => (await db.select(db.profiles).get())
          .map((p) => DiscoveredProfile(id: p.id, name: p.name))
          .toList(),
      onIncoming: acceptIncoming,
      onPeersChanged: notifyListeners,
    );
  }

  Future<void> refreshBroadcast() => lan.refreshBroadcast();

  /// Switches which local profile owns whatever you create from now on, and
  /// re-announces so peers see the change — see DeviceIdentity's doc comment.
  Future<void> switchActiveProfile(Profile profile) async {
    await identity.setActiveProfile(profile);
    await refreshBroadcast();
    notifyListeners();
  }

  Future<void> stop() => lan.stop();

  /// A device that didn't ask for this sync just gets it — everything the
  /// peer sends applies automatically. Reviewing proposed changes (see
  /// [pendingChanges]) is only for the initiating side.
  Future<void> acceptIncoming(MessageChannel channel) async {
    try {
      await _runSyncSession(channel, isInitiator: false);
      notifyListeners();
    } catch (e) {
      debugPrint('Sync (incoming) failed: $e');
      rethrow;
    } finally {
      await channel.close();
    }
  }

  /// [focusProfileId] is which of the *peer's* profiles you want to pull
  /// from — pass the id of one of `peer.profiles`, or leave it null to sync
  /// without that filter (accepts fast-forwards from every profile the peer
  /// hosts). Your own content always goes out regardless — see
  /// docs/spec-universes-collections.md.
  Future<void> syncWith(DiscoveredPeer peer, {String? focusProfileId}) async {
    final focusName = focusProfileId == null
        ? null
        : peer.profiles.firstWhere((p) => p.id == focusProfileId, orElse: () => const DiscoveredProfile(id: '', name: '')).name;
    final label = focusName?.isNotEmpty == true ? focusName! : peer.deviceName;
    status = SyncStatus.connecting;
    statusMessage = 'Connexion à $label...';
    notifyListeners();

    MessageChannel channel;
    try {
      channel = await lan.connect(peer);
    } catch (e) {
      status = SyncStatus.error;
      statusMessage = 'Connexion impossible : $e';
      notifyListeners();
      return;
    }
    await syncOverChannel(channel, peerLabel: label, focusProfileId: focusProfileId);
  }

  /// Runs a sync *you* asked for over an already-open [channel] (TCP from
  /// [syncWith], or WebRTC once QR pairing is done), reporting progress
  /// through [status]/[statusMessage]. Closes [channel] when done.
  Future<void> syncOverChannel(
    MessageChannel channel, {
    required String peerLabel,
    String? focusProfileId,
  }) async {
    status = SyncStatus.syncing;
    statusMessage = 'Synchronisation avec $peerLabel...';
    notifyListeners();

    try {
      final result =
          await _runSyncSession(channel, isInitiator: true, focusOwnerId: focusProfileId);
      status = SyncStatus.done;
      final parts = [
        if (result.newPendingChanges > 0) '${result.newPendingChanges} modification(s) proposée(s)',
        if (result.newConflicts > 0) '${result.newConflicts} conflit(s) à résoudre',
      ];
      statusMessage = parts.isEmpty ? 'Synchronisation terminée.' : parts.join(', ');
    } catch (e) {
      status = SyncStatus.error;
      statusMessage = 'Échec de la synchronisation : $e';
    } finally {
      await channel.close();
      notifyListeners();
    }
  }

  /// The actual protocol. Both sides of the connection run this exact same
  /// network sequence:
  ///
  ///  1. hello        — exchange device id/name, remember the peer as a
  ///                     known user
  ///  2. universes     — manifest/request/items round-trip (see _syncKind)
  ///  3. collections   — same, once universes have settled
  ///  4. items         — same, once collections have settled
  ///  5. done          — small handshake so neither side closes the socket
  ///                      while the other is still writing
  ///
  /// What differs is [isInitiator]: content you don't own that would
  /// fast-forward is applied immediately when you *accepted* this
  /// connection, but only *proposed* (added to [pendingChanges], not written
  /// to the db) when you're the one who asked for this sync — see
  /// PendingChange's doc comment for why. [focusOwnerId], initiator-only,
  /// additionally limits *which* foreign profile's changes are even
  /// requested — see [syncWith].
  Future<_SyncSessionResult> _runSyncSession(
    MessageChannel channel, {
    required bool isInitiator,
    String? focusOwnerId,
  }) async {
    final queue = StreamQueue<SyncMessage>(channel.messages);

    final localProfiles = await db.select(db.profiles).get();
    channel.send(SyncMessage('hello', {
      'deviceId': identity.deviceId,
      'profiles': localProfiles.map((p) => {'id': p.id, 'name': p.name}).toList(),
      'schemaVersion': kSchemaVersion,
    }));
    final hello = await queue.next;
    final remoteProfiles = (hello.payload['profiles'] as List).cast<Map<String, dynamic>>();
    for (final p in remoteProfiles) {
      await db.into(db.knownUsers).insertOnConflictUpdate(KnownUsersCompanion.insert(
            id: p['id'] as String,
            name: p['name'] as String,
            lastSyncedAt: DateTime.now().toUtc(),
          ));
    }

    var newConflicts = 0;
    var newPendingChanges = 0;
    var appliedCount = 0;

    final universeResult = await _syncKind<UniversePayload>(
      channel: channel,
      queue: queue,
      kind: 'universe',
      focusOwnerId: isInitiator ? focusOwnerId : null,
      loadLocal: () async =>
          (await db.select(db.universes).get()).map(UniversePayload.fromRow).toList(),
      decode: UniversePayload.fromJson,
    );
    final universeNames = <String, String>{
      for (final u in universeResult.localById.values) u.id: u.name,
      for (final u in universeResult.incoming) u.id: u.name,
    };
    for (final remote in universeResult.incoming) {
      final local = universeResult.localById[remote.id];
      if (local == null && remote.deleted) continue; // nothing to show or apply
      switch (decideMerge(local, remote)) {
        case MergeAction.applied:
          Future<void> apply() => db.into(db.universes).insertOnConflictUpdate(remote.toCompanion());
          if (isInitiator && remote.ownerId != identity.id) {
            pendingChanges.add(PendingChange(
              kind: 'universe',
              action: _classify(local == null, remote.deleted),
              title: remote.name,
              applyChange: apply,
            ));
            newPendingChanges++;
          } else {
            await apply();
            appliedCount++;
          }
        case MergeAction.conflict:
          universeConflicts.add(UniverseConflict(local: local!, remote: remote));
          newConflicts++;
        case MergeAction.upToDate:
          break;
      }
    }

    final collectionResult = await _syncKind<CollectionPayload>(
      channel: channel,
      queue: queue,
      kind: 'collection',
      focusOwnerId: isInitiator ? focusOwnerId : null,
      loadLocal: () async =>
          (await db.select(db.collections).get()).map(CollectionPayload.fromRow).toList(),
      decode: CollectionPayload.fromJson,
    );
    final collectionNames = <String, String>{
      for (final c in collectionResult.localById.values) c.id: c.name,
      for (final c in collectionResult.incoming) c.id: c.name,
    };
    final collectionUniverseId = <String, String>{
      for (final c in collectionResult.localById.values) c.id: c.universeId,
      for (final c in collectionResult.incoming) c.id: c.universeId,
    };
    for (final remote in collectionResult.incoming) {
      final local = collectionResult.localById[remote.id];
      if (local == null && remote.deleted) continue;
      switch (decideMerge(local, remote)) {
        case MergeAction.applied:
          Future<void> apply() => db.into(db.collections).insertOnConflictUpdate(remote.toCompanion());
          if (isInitiator && remote.ownerId != identity.id) {
            pendingChanges.add(PendingChange(
              kind: 'collection',
              action: _classify(local == null, remote.deleted),
              title: remote.name,
              parentLabel: universeNames[remote.universeId],
              applyChange: apply,
            ));
            newPendingChanges++;
          } else {
            await apply();
            appliedCount++;
          }
        case MergeAction.conflict:
          collectionConflicts.add(CollectionConflict(local: local!, remote: remote));
          newConflicts++;
        case MergeAction.upToDate:
          break;
      }
    }

    final itemResult = await _syncKind<ItemPayload>(
      channel: channel,
      queue: queue,
      kind: 'item',
      focusOwnerId: isInitiator ? focusOwnerId : null,
      loadLocal: () async => (await db.select(db.items).get()).map(ItemPayload.fromRow).toList(),
      decode: ItemPayload.fromJson,
    );
    for (final remote in itemResult.incoming) {
      final local = itemResult.localById[remote.id];
      if (local == null && remote.deleted) continue;
      switch (decideMerge(local, remote)) {
        case MergeAction.applied:
          Future<void> apply() => db.into(db.items).insertOnConflictUpdate(remote.toCompanion());
          if (isInitiator && remote.ownerId != identity.id) {
            final collectionName = collectionNames[remote.collectionId];
            final universeName = universeNames[collectionUniverseId[remote.collectionId]];
            pendingChanges.add(PendingChange(
              kind: 'item',
              action: _classify(local == null, remote.deleted),
              title: remote.name,
              parentLabel: [?universeName, ?collectionName].join(' / '),
              applyChange: apply,
            ));
            newPendingChanges++;
          } else {
            await apply();
            appliedCount++;
          }
        case MergeAction.conflict:
          itemConflicts.add(ItemConflict(local: local!, remote: remote));
          newConflicts++;
        case MergeAction.upToDate:
          break;
      }
    }

    channel.send(SyncMessage('done', {}));
    await queue.next;
    await queue.cancel(immediate: true);

    final peerName = remoteProfiles.isNotEmpty
        ? remoteProfiles.map((p) => p['name'] as String).join(', ')
        : 'Appareil';
    await db.logSyncSession(
      peerName: peerName,
      direction: isInitiator ? 'outgoing' : 'incoming',
      appliedCount: appliedCount,
      pendingCount: newPendingChanges,
      conflictCount: newConflicts,
    );

    return _SyncSessionResult(newConflicts: newConflicts, newPendingChanges: newPendingChanges);
  }

  ChangeAction _classify(bool isCreate, bool isDelete) =>
      isCreate ? ChangeAction.created : (isDelete ? ChangeAction.deleted : ChangeAction.updated);

  /// One manifest/request/items round-trip for a given entity kind. Kept
  /// generic so Universes/Collections/Items don't each need their own copy
  /// of this network exchange — only how to load/decode them differs.
  ///
  /// [focusOwnerId], when set, only requests entries owned by *you* or by
  /// that profile — everything else the peer's manifest lists is left
  /// alone this session. This only ever narrows what *this side* asks for;
  /// the peer's own request (their side of this same exchange) is
  /// unaffected — see [syncWith].
  Future<_SyncKindResult<T>> _syncKind<T extends SyncEntity>({
    required MessageChannel channel,
    required StreamQueue<SyncMessage> queue,
    required String kind,
    required Future<List<T>> Function() loadLocal,
    required T Function(Map<String, dynamic>) decode,
    String? focusOwnerId,
  }) async {
    final localList = await loadLocal();
    final localById = {for (final e in localList) e.id: e};

    channel.send(SyncMessage('${kind}_manifest', {
      'entries': localList
          .map((e) => {'id': e.id, 'versionId': e.versionId, 'ownerId': e.ownerId})
          .toList(),
    }));
    final manifestMsg = await queue.next;
    final remoteEntries =
        (manifestMsg.payload['entries'] as List).cast<Map<String, dynamic>>();

    final wanted = <String>[];
    for (final entry in remoteEntries) {
      final id = entry['id'] as String;
      final versionId = entry['versionId'] as String;
      final ownerId = entry['ownerId'] as String;
      if (focusOwnerId != null && ownerId != identity.id && ownerId != focusOwnerId) {
        continue; // not interested in this profile's changes this session
      }
      final local = localById[id];
      if (local == null || local.versionId != versionId) wanted.add(id);
    }

    channel.send(SyncMessage('${kind}_request', {'ids': wanted}));
    final requestMsg = await queue.next;
    final requestedIds = (requestMsg.payload['ids'] as List).cast<String>();
    channel.send(SyncMessage('${kind}_items', {
      'items': requestedIds
          .where(localById.containsKey)
          .map((id) => localById[id]!.toJson())
          .toList(),
    }));
    final itemsMsg = await queue.next;
    final incoming =
        (itemsMsg.payload['items'] as List).cast<Map<String, dynamic>>().map(decode).toList();

    return _SyncKindResult(localById: localById, incoming: incoming);
  }

  /// Resolves a conflict by keeping one side's content and recording a
  /// "merge" version whose two parents are the two versions the user chose
  /// between — see docs/spec-universes-collections.md §4: whichever peer(s)
  /// sent either version will recognize this new version as a direct
  /// descendant of what they already have, and won't re-flag the same
  /// conflict on the next sync.
  Future<void> resolveUniverseConflict(UniverseConflict conflict, {required bool keepLocal}) async {
    final chosen = keepLocal ? conflict.local : conflict.remote;
    final merged = UniversePayload(
      id: chosen.id,
      ownerId: chosen.ownerId,
      name: chosen.name,
      versionId: const Uuid().v4(),
      parentVersionId: conflict.local.versionId,
      parentVersionId2: conflict.remote.versionId,
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: chosen.deleted,
    );
    await db.into(db.universes).insertOnConflictUpdate(merged.toCompanion());
    universeConflicts.removeWhere((c) => c.local.id == conflict.local.id);
    notifyListeners();
  }

  Future<void> resolveCollectionConflict(CollectionConflict conflict, {required bool keepLocal}) async {
    final chosen = keepLocal ? conflict.local : conflict.remote;
    final merged = CollectionPayload(
      id: chosen.id,
      universeId: chosen.universeId,
      ownerId: chosen.ownerId,
      name: chosen.name,
      schemaJson: chosen.schemaJson,
      versionId: const Uuid().v4(),
      parentVersionId: conflict.local.versionId,
      parentVersionId2: conflict.remote.versionId,
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: chosen.deleted,
    );
    await db.into(db.collections).insertOnConflictUpdate(merged.toCompanion());
    collectionConflicts.removeWhere((c) => c.local.id == conflict.local.id);
    notifyListeners();
  }

  Future<void> resolveItemConflict(ItemConflict conflict, {required bool keepLocal}) async {
    final chosen = keepLocal ? conflict.local : conflict.remote;
    final merged = ItemPayload(
      id: chosen.id,
      collectionId: chosen.collectionId,
      ownerId: chosen.ownerId,
      name: chosen.name,
      category: chosen.category,
      quantity: chosen.quantity,
      estimatedValue: chosen.estimatedValue,
      state: chosen.state,
      notes: chosen.notes,
      owned: chosen.owned,
      photosJson: chosen.photosJson,
      customValuesJson: chosen.customValuesJson,
      versionId: const Uuid().v4(),
      parentVersionId: conflict.local.versionId,
      parentVersionId2: conflict.remote.versionId,
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: chosen.deleted,
    );
    await db.into(db.items).insertOnConflictUpdate(merged.toCompanion());
    itemConflicts.removeWhere((c) => c.local.id == conflict.local.id);
    notifyListeners();
  }

  /// Applies every currently-selected pending change and drops the rest —
  /// call once the user has ticked/unticked what they want from the review
  /// screen. Anything left unselected simply isn't written: since the local
  /// version hasn't moved, the next sync with that peer offers it again.
  Future<void> applySelectedPendingChanges() async {
    for (final change in pendingChanges.where((c) => c.selected)) {
      await change.applyChange();
    }
    pendingChanges.clear();
    notifyListeners();
  }

  /// Drops every pending change without applying any of them.
  void discardPendingChanges() {
    pendingChanges.clear();
    notifyListeners();
  }
}

class _SyncKindResult<T extends SyncEntity> {
  final Map<String, T> localById;
  final List<T> incoming;
  const _SyncKindResult({required this.localById, required this.incoming});
}

class _SyncSessionResult {
  final int newConflicts;
  final int newPendingChanges;
  const _SyncSessionResult({required this.newConflicts, required this.newPendingChanges});
}
