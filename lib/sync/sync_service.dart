import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import 'collection_payload.dart';
import 'conflicts.dart';
import 'device_identity.dart';
import 'entities.dart';
import 'item_payload.dart';
import 'pending_change.dart';
import 'sync_protocol.dart';
import 'universe_payload.dart';

/// mDNS/Bonjour service type this app advertises and looks for.
/// Syntax: _ServiceType._tcp — see the bonsoir package docs.
const String kServiceType = '_collectionsync._tcp';

/// Bumped if the wire format ever changes in a backwards-incompatible way.
const int kSchemaVersion = 3;

/// One profile advertised by a discovered device — see [DiscoveredPeer].
class DiscoveredProfile {
  final String id;
  final String name;
  const DiscoveredProfile({required this.id, required this.name});
}

class DiscoveredPeer {
  final String deviceId;
  final String deviceName;
  final String host;
  final int port;

  /// The local, fully-editable profiles that device is currently hosting —
  /// parsed from its mDNS announcement (see _startBroadcast). A device can
  /// host several (docs/spec-universes-collections.md); this is what lets
  /// the sync screen offer "which profile do you want to sync" rather than
  /// just "which device".
  final List<DiscoveredProfile> profiles;

  const DiscoveredPeer({
    required this.deviceId,
    required this.deviceName,
    required this.host,
    required this.port,
    this.profiles = const [],
  });
}

enum SyncStatus { idle, connecting, syncing, done, error }

/// Owns local-network discovery (via mDNS/Bonjour, through the `bonsoir`
/// package) and the sync sessions themselves (plain TCP sockets, no server
/// involved anywhere). Each session syncs Universes, then Collections, then
/// Items, in that order — see _runSyncSession.
class SyncService extends ChangeNotifier {
  final AppDatabase db;
  final DeviceIdentity identity;

  ServerSocket? _server;
  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;

  final Map<String, DiscoveredPeer> _peers = {};

  List<DiscoveredPeer> get peers => _peers.values.toList(growable: false);

  /// Whether the given *profile* — not device — is currently reachable on
  /// the network, i.e. some discovered device is advertising it right now.
  bool isOnline(String profileId) =>
      _peers.values.any((peer) => peer.profiles.any((p) => p.id == profileId));

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

  SyncService({required this.db, required this.identity});

  Future<void> start() async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    _server!.listen(_acceptIncoming);

    await _startBroadcast();

    _discovery = BonsoirDiscovery(type: kServiceType);
    await _discovery!.initialize();
    _discovery!.eventStream!.listen(_onDiscoveryEvent);
    await _discovery!.start();
  }

  /// Announces this device *and every local profile it hosts* — a bare
  /// device name wouldn't be enough for peers to offer "choose which
  /// profile to sync" (see DiscoveredPeer.profiles). The list travels as a
  /// JSON blob in one mDNS TXT attribute, which keeps this to a handful of
  /// short-named profiles (each TXT string is capped at 255 bytes by the
  /// mDNS spec) — plenty for a family sharing a device, but a known limit.
  Future<void> _startBroadcast() async {
    final localProfiles = await db.select(db.profiles).get();
    final service = BonsoirService(
      name: '${identity.name}-${identity.deviceId.substring(0, 8)}',
      type: kServiceType,
      port: _server!.port,
      attributes: {
        'deviceId': identity.deviceId,
        'profiles': jsonEncode(
          localProfiles.map((p) => {'id': p.id, 'name': p.name}).toList(),
        ),
      },
    );
    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast!.initialize();
    await _broadcast!.start();
  }

  /// Re-announces this device with its current profile list. The broadcast
  /// is created once (in [start]) from whatever profiles existed then — if
  /// the active profile's name changes, or a profile is added, other
  /// devices keep seeing the old announcement until this runs, since
  /// Bonjour doesn't let us edit a live announcement's attributes in place.
  Future<void> refreshBroadcast() async {
    await _broadcast?.stop();
    await _startBroadcast();
  }

  /// Switches which local profile owns whatever you create from now on, and
  /// re-announces so peers see the change — see DeviceIdentity's doc comment.
  Future<void> switchActiveProfile(Profile profile) async {
    await identity.setActiveProfile(profile);
    await refreshBroadcast();
    notifyListeners();
  }

  Future<void> stop() async {
    await _discovery?.stop();
    await _broadcast?.stop();
    await _server?.close();
  }

  void _onDiscoveryEvent(BonsoirDiscoveryEvent event) {
    switch (event) {
      case BonsoirDiscoveryServiceFoundEvent():
        final service = event.service;
        if (service.attributes['deviceId'] == identity.deviceId) {
          return; // that's our own broadcast, ignore it
        }
        service.resolve(_discovery!.serviceResolver);
      case BonsoirDiscoveryServiceResolvedEvent():
        _registerResolvedService(event.service);
      case BonsoirDiscoveryServiceUpdatedEvent():
        _registerResolvedService(event.service);
      case BonsoirDiscoveryServiceLostEvent():
        final deviceId = event.service.attributes['deviceId'];
        if (deviceId != null) _peers.remove(deviceId);
        notifyListeners();
      default:
        break;
    }
  }

  void _registerResolvedService(BonsoirService service) {
    final deviceId = service.attributes['deviceId'];
    if (deviceId == null || deviceId == identity.deviceId) return;
    final host = _pickAddress(service.hostAddresses);
    if (host == null) return;

    final profiles = <DiscoveredProfile>[];
    final profilesJson = service.attributes['profiles'];
    if (profilesJson != null) {
      try {
        for (final entry in jsonDecode(profilesJson) as List) {
          profiles.add(DiscoveredProfile(id: entry['id'] as String, name: entry['name'] as String));
        }
      } catch (e) {
        debugPrint('Could not parse profiles from $deviceId\'s announcement: $e');
      }
    }

    _peers[deviceId] = DiscoveredPeer(
      deviceId: deviceId,
      deviceName: profiles.isNotEmpty ? profiles.map((p) => p.name).join(', ') : 'Appareil',
      host: host,
      port: service.port,
      profiles: profiles,
    );
    notifyListeners();
  }

  /// Prefer an IPv4 address (simple, no zone-id/bracket headaches); fall
  /// back to whatever was resolved otherwise.
  String? _pickAddress(List<String> addresses) {
    if (addresses.isEmpty) return null;
    final ipv4 = addresses.where((a) => !a.contains(':'));
    return ipv4.isNotEmpty ? ipv4.first : addresses.first;
  }

  /// A device that didn't ask for this sync just gets it — everything the
  /// peer sends applies automatically, exactly like before. Reviewing
  /// proposed changes (see [pendingChanges]) is only for the initiating side.
  Future<void> _acceptIncoming(Socket socket) async {
    final channel = MessageChannel(socket);
    try {
      await _runSyncSession(channel, isInitiator: false);
      notifyListeners();
    } catch (e) {
      debugPrint('Sync (incoming) failed: $e');
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
    status = SyncStatus.connecting;
    statusMessage = 'Connexion à ${focusName?.isNotEmpty == true ? focusName : peer.deviceName}...';
    notifyListeners();

    Socket socket;
    try {
      final address = peer.host.contains(':')
          ? InternetAddress(peer.host, type: InternetAddressType.IPv6)
          : InternetAddress(peer.host, type: InternetAddressType.IPv4);
      socket = await Socket.connect(
        address,
        peer.port,
        timeout: const Duration(seconds: 8),
      );
    } catch (e) {
      status = SyncStatus.error;
      statusMessage = 'Connexion impossible : $e';
      notifyListeners();
      return;
    }

    final channel = MessageChannel(socket);
    status = SyncStatus.syncing;
    statusMessage = 'Synchronisation avec ${focusName?.isNotEmpty == true ? focusName : peer.deviceName}...';
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
      photoBase64: chosen.photoBase64,
      quantity: chosen.quantity,
      estimatedValue: chosen.estimatedValue,
      state: chosen.state,
      notes: chosen.notes,
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
