import 'dart:convert';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';

import '../device_identity.dart';
import '../socket_channel.dart';
import '../sync_protocol.dart';
import 'lan_discovery.dart';

/// mDNS/Bonjour service type this app advertises and looks for.
/// Syntax: _ServiceType._tcp — see the bonsoir package docs.
const String kServiceType = '_collectionsync._tcp';

LanDiscovery createLanDiscovery(DeviceIdentity identity) => _BonsoirLanDiscovery(identity);

class _BonsoirLanDiscovery implements LanDiscovery {
  final DeviceIdentity identity;

  ServerSocket? _server;
  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  late Future<List<DiscoveredProfile>> Function() _localProfiles;
  late VoidCallback _onPeersChanged;

  final Map<String, DiscoveredPeer> _peers = {};

  _BonsoirLanDiscovery(this.identity);

  @override
  bool get isSupported => true;

  @override
  List<DiscoveredPeer> get peers => _peers.values.toList(growable: false);

  @override
  Future<void> start({
    required Future<List<DiscoveredProfile>> Function() localProfiles,
    required Future<void> Function(MessageChannel channel) onIncoming,
    required VoidCallback onPeersChanged,
  }) async {
    _localProfiles = localProfiles;
    _onPeersChanged = onPeersChanged;

    _server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    // Failures are already logged by onIncoming; nobody here to report to.
    _server!.listen((socket) => onIncoming(SocketMessageChannel(socket)).ignore());

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
    final localProfiles = await _localProfiles();
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

  /// The broadcast is created once (in [start]) from whatever profiles
  /// existed then — if the active profile's name changes, or a profile is
  /// added, other devices keep seeing the old announcement until this runs,
  /// since Bonjour doesn't let us edit a live announcement's attributes in
  /// place.
  @override
  Future<void> refreshBroadcast() async {
    await _broadcast?.stop();
    await _startBroadcast();
  }

  @override
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
        _onPeersChanged();
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
    _onPeersChanged();
  }

  /// Prefer an IPv4 address (simple, no zone-id/bracket headaches); fall
  /// back to whatever was resolved otherwise.
  String? _pickAddress(List<String> addresses) {
    if (addresses.isEmpty) return null;
    final ipv4 = addresses.where((a) => !a.contains(':'));
    return ipv4.isNotEmpty ? ipv4.first : addresses.first;
  }

  @override
  Future<MessageChannel> connect(DiscoveredPeer peer) async {
    final address = peer.host.contains(':')
        ? InternetAddress(peer.host, type: InternetAddressType.IPv6)
        : InternetAddress(peer.host, type: InternetAddressType.IPv4);
    final socket = await Socket.connect(
      address,
      peer.port,
      timeout: const Duration(seconds: 8),
    );
    return SocketMessageChannel(socket);
  }
}
