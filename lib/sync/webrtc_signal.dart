import 'dart:convert';

import 'package:archive/archive.dart';

/// Pure helpers for the WebRTC transport, kept apart from flutter_webrtc so
/// they can be unit-tested: how SDP descriptions are packed into a QR code,
/// and how sync messages are cut into data-channel-sized frames.

enum SignalKind { offer, answer }

/// Prefix of every pairing code: app tag + format version. Lets a scan of
/// some unrelated QR code fail with a clear message instead of a decode
/// error, and leaves room for a future format.
const String _signalPrefix = 'CS1';

/// Packs an SDP description into a short text for a QR code: deflate, then
/// unpadded base64url. A data-channel-only SDP with its host candidates is
/// ~0.5–1 KB and compresses to roughly half — a QR code a phone camera
/// reads without trouble.
String encodeSignal(SignalKind kind, String sdp) {
  final packed = const ZLibEncoder().encodeBytes(utf8.encode(sdp), level: 9);
  final b64 = base64Url.encode(packed).replaceAll('=', '');
  return '$_signalPrefix${kind == SignalKind.offer ? 'o' : 'a'}$b64';
}

class InvalidSignalException implements Exception {
  final String message;
  const InvalidSignalException(this.message);
  @override
  String toString() => message;
}

/// Inverse of [encodeSignal]; throws [InvalidSignalException] if [code]
/// isn't a pairing code of the [expected] kind.
String decodeSignal(String code, SignalKind expected) {
  final trimmed = code.trim();
  if (!trimmed.startsWith(_signalPrefix) || trimmed.length < _signalPrefix.length + 2) {
    throw const InvalidSignalException("Ce n'est pas un code CollectionSync.");
  }
  final kindChar = trimmed[_signalPrefix.length];
  final kind = switch (kindChar) {
    'o' => SignalKind.offer,
    'a' => SignalKind.answer,
    _ => throw const InvalidSignalException("Ce n'est pas un code CollectionSync."),
  };
  if (kind != expected) {
    throw InvalidSignalException(expected == SignalKind.offer
        ? "C'est un code de réponse : scannez le code affiché par l'appareil qui démarre la synchro."
        : "C'est un code d'invitation : scannez le code de réponse affiché par l'autre appareil.");
  }
  try {
    final b64 = trimmed.substring(_signalPrefix.length + 1);
    final padded = b64.padRight((b64.length + 3) ~/ 4 * 4, '=');
    return utf8.decode(const ZLibDecoder().decodeBytes(base64Url.decode(padded)));
  } catch (_) {
    throw const InvalidSignalException('Code illisible ou incomplet.');
  }
}

/// Largest frame sent in one data-channel message, in UTF-16 code units —
/// at most 48 KiB once UTF-8 encoded, well under the 256 KiB that every
/// WebRTC implementation (browsers and libwebrtc) accepts per message. A
/// sync message carrying photos can be many megabytes, hence [encodeFrames].
const int kMaxFrameChars = 16 * 1024;

/// Cuts one serialized message into frames: every frame but the last starts
/// with '+', the last with '.'. The data channel is ordered and reliable,
/// so concatenating frames until a '.' one rebuilds the message.
List<String> encodeFrames(String message, {int maxChars = kMaxFrameChars}) {
  final frames = <String>[];
  var start = 0;
  while (message.length - start > maxChars) {
    var end = start + maxChars;
    // Don't split a surrogate pair across two frames.
    final unit = message.codeUnitAt(end - 1);
    if (unit >= 0xD800 && unit <= 0xDBFF) end--;
    frames.add('+${message.substring(start, end)}');
    start = end;
  }
  frames.add('.${message.substring(start)}');
  return frames;
}

/// Reassembles frames produced by [encodeFrames].
class FrameAssembler {
  final StringBuffer _buffer = StringBuffer();

  /// Returns the full message once [frame] completes one, null otherwise.
  String? add(String frame) {
    if (frame.isEmpty) throw const FormatException('Empty frame');
    final marker = frame[0];
    if (marker != '+' && marker != '.') {
      throw FormatException('Unknown frame marker "$marker"');
    }
    _buffer.write(frame.substring(1));
    if (marker == '+') return null;
    final message = _buffer.toString();
    _buffer.clear();
    return message;
  }
}
