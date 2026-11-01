import '../device_identity.dart';
import '../sync_protocol.dart';
import 'lan_discovery.dart';

LanDiscovery createLanDiscovery(DeviceIdentity identity) => _UnsupportedLanDiscovery();

class _UnsupportedLanDiscovery implements LanDiscovery {
  @override
  bool get isSupported => false;

  @override
  List<DiscoveredPeer> get peers => const [];

  @override
  Future<void> start({
    required Future<List<DiscoveredProfile>> Function() localProfiles,
    required Future<void> Function(MessageChannel channel) onIncoming,
    required void Function() onPeersChanged,
  }) async {}

  @override
  Future<void> refreshBroadcast() async {}

  @override
  Future<MessageChannel> connect(DiscoveredPeer peer) =>
      throw UnsupportedError('Pas de découverte réseau dans un navigateur');

  @override
  Future<void> stop() async {}
}
