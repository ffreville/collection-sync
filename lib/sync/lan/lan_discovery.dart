import 'package:flutter/foundation.dart';

import '../device_identity.dart';
import '../sync_protocol.dart';
import 'lan_discovery_io.dart'
    if (dart.library.js_interop) 'lan_discovery_web.dart' as platform;

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
  /// parsed from its mDNS announcement. A device can host several
  /// (docs/spec-universes-collections.md); this is what lets the sync screen
  /// offer "which profile do you want to sync" rather than just "which
  /// device".
  final List<DiscoveredProfile> profiles;

  const DiscoveredPeer({
    required this.deviceId,
    required this.deviceName,
    required this.host,
    required this.port,
    this.profiles = const [],
  });
}

/// Automatic discovery of, and connection to, other devices on the same
/// Wi-Fi: mDNS/Bonjour + raw TCP sockets on iOS/Android. A browser can do
/// neither, so on the web build [isSupported] is false and devices pair by
/// QR code instead (see webrtc_pairing.dart).
abstract class LanDiscovery {
  factory LanDiscovery(DeviceIdentity identity) => platform.createLanDiscovery(identity);

  bool get isSupported;

  List<DiscoveredPeer> get peers;

  /// Starts accepting connections and advertising/looking for peers.
  /// [localProfiles] is re-read on every (re)announcement; [onIncoming]
  /// runs for each connection another device opens to us.
  Future<void> start({
    required Future<List<DiscoveredProfile>> Function() localProfiles,
    required Future<void> Function(MessageChannel channel) onIncoming,
    required VoidCallback onPeersChanged,
  });

  /// Re-announces this device with its current profile list.
  Future<void> refreshBroadcast();

  Future<MessageChannel> connect(DiscoveredPeer peer);

  Future<void> stop();
}
