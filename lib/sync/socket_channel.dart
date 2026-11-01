import 'dart:convert';
import 'dart:io';

import 'sync_protocol.dart';

/// [MessageChannel] over a raw TCP [Socket]. Messages are framed as
/// newline-delimited JSON ("ndjson") — `jsonEncode` always escapes literal
/// newlines inside string values, so splitting on '\n' is safe.
class SocketMessageChannel implements MessageChannel {
  final Socket _socket;
  @override
  late final Stream<SyncMessage> messages;

  SocketMessageChannel(this._socket) {
    messages = _socket
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .where((line) => line.trim().isNotEmpty)
        .map((line) => SyncMessage.fromJson(
            jsonDecode(line) as Map<String, dynamic>))
        .asBroadcastStream();
  }

  @override
  void send(SyncMessage message) {
    _socket.add(utf8.encode('${jsonEncode(message.toJson())}\n'));
  }

  @override
  Future<void> close() async {
    await _socket.close();
  }
}
