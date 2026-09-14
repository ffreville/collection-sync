import 'dart:async';
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
import 'sync_protocol.dart';
import 'universe_payload.dart';

/// mDNS/Bonjour service type this app advertises and looks for.
/// Syntax: _ServiceType._tcp — see the bonsoir package docs.
const String kServiceType = '_collectionsync._tcp';

/// Bumped if the wire format ever changes in a backwards-incompatible way.
const int kSchemaVersion = 2;

class DiscoveredPeer {
  final String deviceId;
  final String deviceName;
  final String host;
  final int port;

  const DiscoveredPeer({
    required this.deviceId,
    required this.deviceName,
    required this.host,
    required this.port,
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
  bool isOnline(String userId) => _peers.containsKey(userId);

  SyncStatus status = SyncStatus.idle;
  String? statusMessage;

  final List<UniverseConflict> universeConflicts = [];
  final List<CollectionConflict> collectionConflicts = [];
  final List<ItemConflict> itemConflicts = [];
  int get totalConflicts =>
      universeConflicts.length + collectionConflicts.length + itemConflicts.length;

  SyncService({required this.db, required this.identity});

  Future<void> start() async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    _server!.listen(_acceptIncoming);

    final service = BonsoirService(
      name: '${identity.name}-${identity.id.substring(0, 8)}',
      type: kServiceType,
      port: _server!.port,
      attributes: {'deviceId': identity.id, 'deviceName': identity.name},
    );
    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast!.initialize();
    await _broadcast!.start();

    _discovery = BonsoirDiscovery(type: kServiceType);
    await _discovery!.initialize();
    _discovery!.eventStream!.listen(_onDiscoveryEvent);
    await _discovery!.start();
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
        if (service.attributes['deviceId'] == identity.id) {
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
    final deviceName = service.attributes['deviceName'] ?? 'Appareil';
    if (deviceId == null || deviceId == identity.id) return;
    final host = _pickAddress(service.hostAddresses);
    if (host == null) return;
    _peers[deviceId] = DiscoveredPeer(
      deviceId: deviceId,
      deviceName: deviceName,
      host: host,
      port: service.port,
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

  Future<void> _acceptIncoming(Socket socket) async {
    final channel = MessageChannel(socket);
    try {
      await _runSyncSession(channel);
      notifyListeners();
    } catch (e) {
      debugPrint('Sync (incoming) failed: $e');
    } finally {
      await channel.close();
    }
  }

  Future<void> syncWith(DiscoveredPeer peer) async {
    status = SyncStatus.connecting;
    statusMessage = 'Connexion à ${peer.deviceName}...';
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
    statusMessage = 'Synchronisation avec ${peer.deviceName}...';
    notifyListeners();

    try {
      final newConflicts = await _runSyncSession(channel);
      status = SyncStatus.done;
      statusMessage = newConflicts == 0
          ? 'Synchronisation terminée.'
          : '$newConflicts conflit(s) à résoudre.';
    } catch (e) {
      status = SyncStatus.error;
      statusMessage = 'Échec de la synchronisation : $e';
    } finally {
      await channel.close();
      notifyListeners();
    }
  }

  /// The actual protocol. Both sides of the connection run this exact same
  /// sequence:
  ///
  ///  1. hello        — exchange device id/name, remember the peer as a
  ///                     known user
  ///  2. universes     — manifest/request/items round-trip (see _syncKind)
  ///  3. collections   — same, once universes have settled
  ///  4. items         — same, once collections have settled
  ///  5. done          — small handshake so neither side closes the socket
  ///                      while the other is still writing
  ///
  /// Returns how many new conflicts this session produced.
  Future<int> _runSyncSession(MessageChannel channel) async {
    final queue = StreamQueue<SyncMessage>(channel.messages);

    channel.send(SyncMessage('hello', {
      'deviceId': identity.id,
      'deviceName': identity.name,
      'schemaVersion': kSchemaVersion,
    }));
    final hello = await queue.next;
    final peerId = hello.payload['deviceId'] as String;
    final peerName = hello.payload['deviceName'] as String? ?? 'Appareil';
    await db.into(db.knownUsers).insertOnConflictUpdate(KnownUsersCompanion.insert(
          id: peerId,
          name: peerName,
          lastSyncedAt: DateTime.now().toUtc(),
        ));

    var newConflicts = 0;

    final universeResult = await _syncKind<UniversePayload>(
      channel: channel,
      queue: queue,
      kind: 'universe',
      loadLocal: () async =>
          (await db.select(db.universes).get()).map(UniversePayload.fromRow).toList(),
      decode: UniversePayload.fromJson,
    );
    for (final remote in universeResult.incoming) {
      final local = universeResult.localById[remote.id];
      switch (decideMerge(local, remote)) {
        case MergeAction.applied:
          await db.into(db.universes).insertOnConflictUpdate(remote.toCompanion());
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
      loadLocal: () async =>
          (await db.select(db.collections).get()).map(CollectionPayload.fromRow).toList(),
      decode: CollectionPayload.fromJson,
    );
    for (final remote in collectionResult.incoming) {
      final local = collectionResult.localById[remote.id];
      switch (decideMerge(local, remote)) {
        case MergeAction.applied:
          await db.into(db.collections).insertOnConflictUpdate(remote.toCompanion());
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
      loadLocal: () async => (await db.select(db.items).get()).map(ItemPayload.fromRow).toList(),
      decode: ItemPayload.fromJson,
    );
    for (final remote in itemResult.incoming) {
      final local = itemResult.localById[remote.id];
      switch (decideMerge(local, remote)) {
        case MergeAction.applied:
          await db.into(db.items).insertOnConflictUpdate(remote.toCompanion());
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

    return newConflicts;
  }

  /// One manifest/request/items round-trip for a given entity kind. Kept
  /// generic so Universes/Collections/Items don't each need their own copy
  /// of this network exchange — only how to load/decode them differs.
  Future<_SyncKindResult<T>> _syncKind<T extends SyncEntity>({
    required MessageChannel channel,
    required StreamQueue<SyncMessage> queue,
    required String kind,
    required Future<List<T>> Function() loadLocal,
    required T Function(Map<String, dynamic>) decode,
  }) async {
    final localList = await loadLocal();
    final localById = {for (final e in localList) e.id: e};

    channel.send(SyncMessage('${kind}_manifest', {
      'entries': localList.map((e) => {'id': e.id, 'versionId': e.versionId}).toList(),
    }));
    final manifestMsg = await queue.next;
    final remoteEntries =
        (manifestMsg.payload['entries'] as List).cast<Map<String, dynamic>>();

    final wanted = <String>[];
    for (final entry in remoteEntries) {
      final id = entry['id'] as String;
      final versionId = entry['versionId'] as String;
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
}

class _SyncKindResult<T extends SyncEntity> {
  final Map<String, T> localById;
  final List<T> incoming;
  const _SyncKindResult({required this.localById, required this.incoming});
}
