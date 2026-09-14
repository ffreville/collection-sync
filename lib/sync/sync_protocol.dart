import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// One message of the sync protocol: a `type` tag plus a JSON payload.
/// Messages are framed as newline-delimited JSON ("ndjson") over the raw
/// TCP socket — `jsonEncode` always escapes literal newlines inside string
/// values, so splitting on '\n' is safe.
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

/// Wraps a raw [Socket] to send/receive [SyncMessage]s.
class MessageChannel {
  final Socket _socket;
  late final Stream<SyncMessage> messages;

  MessageChannel(this._socket) {
    messages = _socket
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .where((line) => line.trim().isNotEmpty)
        .map((line) => SyncMessage.fromJson(
            jsonDecode(line) as Map<String, dynamic>))
        .asBroadcastStream();
  }

  void send(SyncMessage message) {
    _socket.add(utf8.encode('${jsonEncode(message.toJson())}\n'));
  }

  Future<void> close() async {
    await _socket.close();
  }
}
