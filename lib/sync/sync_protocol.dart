/// One message of the sync protocol: a `type` tag plus a JSON payload.
/// How messages travel is up to the [MessageChannel] implementation — the
/// protocol itself (SyncService._runSyncSession) doesn't care.
class SyncMessage {
  final String type;
  final Map<String, dynamic> payload;

  SyncMessage(this.type, this.payload);

  factory SyncMessage.fromJson(Map<String, dynamic> json) => SyncMessage(
        json['type'] as String,
        Map<String, dynamic>.from(json['payload'] as Map),
      );

  Map<String, dynamic> toJson() => {'type': type, 'payload': payload};
}

/// A bidirectional, ordered pipe of [SyncMessage]s between two devices.
/// Two transports implement it: a raw TCP socket between two native apps
/// found over mDNS (socket_channel.dart), and a WebRTC data channel paired
/// by QR code, which is the only option a browser has (webrtc_channel.dart).
abstract class MessageChannel {
  /// Every incoming message, in order. Errors (then closes) if the
  /// connection drops before [close] is called.
  Stream<SyncMessage> get messages;

  /// Queues [message] for sending; messages go out in call order.
  void send(SyncMessage message);

  /// Flushes whatever [send] still has queued, then closes the connection.
  Future<void> close();
}
