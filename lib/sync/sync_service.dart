import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import 'device_identity.dart';
import 'item_payload.dart';
import 'sync_protocol.dart';

/// mDNS/Bonjour service type this app advertises and looks for.
/// Syntax: _ServiceType._tcp — see the bonsoir package docs.
const String kServiceType = '_collectionsync._tcp';

/// Bumped if the wire format ever changes in a backwards-incompatible way.
const int kSchemaVersion = 1;

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

/// A pair of item versions that diverged (both were edited independently
/// since they last agreed) and that the user must pick between.
class SyncConflict {
  final ItemPayload local;
  final ItemPayload remote;

  const SyncConflict({required this.local, required this.remote});
}

enum SyncStatus { idle, connecting, syncing, done, error }

/// Owns local-network discovery (via mDNS/Bonjour, through the `bonsoir`
/// package) and the sync sessions themselves (plain TCP sockets, no server
/// involved anywhere). See _runSyncSession for the actual protocol.
class SyncService extends ChangeNotifier {
  final AppDatabase db;
  final DeviceIdentity identity;

  ServerSocket? _server;
  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;

  final Map<String, DiscoveredPeer> _peers = {};

  List<DiscoveredPeer> get peers => _peers.values.toList(growable: false);

  SyncStatus status = SyncStatus.idle;
  String? statusMessage;
  List<SyncConflict> lastConflicts = [];

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
      final conflicts = await _runSyncSession(channel);
      if (conflicts.isNotEmpty) {
        lastConflicts = [...lastConflicts, ...conflicts];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Sync (incoming) failed: $e');
    } finally {
      await channel.close();
    }
  }

  Future<void> syncWith(DiscoveredPeer peer) async {
    status = SyncStatus.connecting;
    statusMessage = 'Connexion à ${peer.deviceName}...';
    lastConflicts = [];
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
      final conflicts = await _runSyncSession(channel);
      lastConflicts = [...lastConflicts, ...conflicts];
      status = SyncStatus.done;
      statusMessage = conflicts.isEmpty
          ? 'Synchronisation terminée.'
          : '${conflicts.length} conflit(s) à résoudre.';
    } catch (e) {
      status = SyncStatus.error;
      statusMessage = 'Échec de la synchronisation : $e';
    } finally {
      await channel.close();
      notifyListeners();
    }
  }

  /// The actual protocol. Both sides of the connection run this exact same
  /// sequence (whoever dialed in vs. whoever accepted the connection don't
  /// need different roles — each step is symmetric):
  ///
  ///  1. hello    — exchange device id/name
  ///  2. manifest — exchange {id, versionId} for every local item
  ///  3. request  — each side asks for the full payload of ids where the
  ///                other side's versionId differs from its own
  ///  4. items    — the actual item payloads are sent back
  ///  5. merge    — each incoming item is fast-forwarded or, if both sides
  ///                changed it independently, recorded as a conflict for
  ///                the user to resolve by hand (see resolveConflict)
  ///  6. done     — small handshake so neither side closes the socket
  ///                while the other is still writing
  Future<List<SyncConflict>> _runSyncSession(MessageChannel channel) async {
    final queue = StreamQueue<SyncMessage>(channel.messages);

    channel.send(SyncMessage('hello', {
      'deviceId': identity.id,
      'deviceName': identity.name,
      'schemaVersion': kSchemaVersion,
    }));
    await queue.next; // peer's hello — nothing to act on yet

    final localItems = await db.select(db.items).get();
    final localById = {
      for (final row in localItems) row.id: ItemPayload.fromRow(row),
    };
    channel.send(SyncMessage('manifest', {
      'entries': localItems
          .map((r) => {'id': r.id, 'versionId': r.versionId})
          .toList(),
    }));
    final manifestMsg = await queue.next;
    final remoteEntries =
        (manifestMsg.payload['entries'] as List).cast<Map<String, dynamic>>();

    final wanted = <String>[];
    for (final entry in remoteEntries) {
      final id = entry['id'] as String;
      final versionId = entry['versionId'] as String;
      final local = localById[id];
      if (local == null || local.versionId != versionId) {
        wanted.add(id);
      }
    }

    channel.send(SyncMessage('request', {'ids': wanted}));
    final requestMsg = await queue.next;
    final requestedIds = (requestMsg.payload['ids'] as List).cast<String>();
    channel.send(SyncMessage('items', {
      'items': requestedIds
          .where(localById.containsKey)
          .map((id) => localById[id]!.toJson())
          .toList(),
    }));
    final itemsMsg = await queue.next;
    final incoming = (itemsMsg.payload['items'] as List)
        .cast<Map<String, dynamic>>()
        .map(ItemPayload.fromJson)
        .toList();

    final conflicts = <SyncConflict>[];
    for (final remote in incoming) {
      final conflict = await _applyIncoming(remote, localById[remote.id]);
      if (conflict != null) conflicts.add(conflict);
    }

    channel.send(SyncMessage('done', {}));
    await queue.next;
    await queue.cancel(immediate: true);

    return conflicts;
  }

  Future<SyncConflict?> _applyIncoming(
      ItemPayload remote, ItemPayload? local) async {
    if (local == null) {
      await db.into(db.items).insertOnConflictUpdate(remote.toCompanion());
      return null;
    }
    if (local.versionId == remote.versionId) {
      return null; // already in sync
    }
    if (remote.isDirectSuccessorOf(local)) {
      await db.into(db.items).insertOnConflictUpdate(remote.toCompanion());
      return null; // fast-forward: remote is simply ahead of us
    }
    if (local.isDirectSuccessorOf(remote)) {
      return null; // we're already ahead; our version will reach them
    }
    return SyncConflict(local: local, remote: remote); // diverged
  }

  /// Resolves a conflict by keeping one side's content and recording a
  /// "merge" version whose two parents are the two versions the user chose
  /// between — that way, whichever peer(s) sent either version will
  /// recognize this new version as a direct descendant of what they already
  /// have, and won't re-flag the same conflict on the next sync.
  Future<void> resolveConflict(SyncConflict conflict,
      {required bool keepLocal}) async {
    final chosen = keepLocal ? conflict.local : conflict.remote;
    final merged = ItemPayload(
      id: chosen.id,
      name: chosen.name,
      category: chosen.category,
      notes: chosen.notes,
      quantity: chosen.quantity,
      versionId: const Uuid().v4(),
      parentVersionId: conflict.local.versionId,
      parentVersionId2: conflict.remote.versionId,
      updatedByDevice: identity.id,
      updatedAt: DateTime.now().toUtc(),
      deleted: chosen.deleted,
    );
    await db.into(db.items).insertOnConflictUpdate(merged.toCompanion());
    lastConflicts =
        lastConflicts.where((c) => c.local.id != conflict.local.id).toList();
    notifyListeners();
  }
}
