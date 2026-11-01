import 'package:collection_sync/sync/webrtc_signal.dart';
import 'package:flutter_test/flutter_test.dart';

const _sampleSdp = '''v=0
o=- 4611731400430051336 2 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE 0
a=msid-semantic: WMS
m=application 9 UDP/DTLS/SCTP webrtc-datachannel
c=IN IP4 0.0.0.0
a=candidate:1467250027 1 udp 2122260223 192.168.1.23 54321 typ host generation 0
a=candidate:3a1f 1 udp 2122194687 4b8e2f1c-5d6a-4c1e-9f3b-2a7d8e6c1b0f.local 61234 typ host generation 0
a=ice-ufrag:Kx8f
a=ice-pwd:9Fq2bLx0mN3vR7tY1wZ5cD8e
a=ice-options:trickle
a=fingerprint:sha-256 7B:8B:F0:65:5F:78:E2:51:3B:AC:6F:F3:3F:46:1B:35:DC:B8:5F:64:1A:24:C2:43:F0:A1:58:D0:A1:2C:19:08
a=setup:actpass
a=mid:0
a=sctp-port:5000
a=max-message-size:262144
''';

void main() {
  group('pairing codes', () {
    test('round-trip an offer and an answer', () {
      final offer = encodeSignal(SignalKind.offer, _sampleSdp);
      final answer = encodeSignal(SignalKind.answer, _sampleSdp);
      expect(decodeSignal(offer, SignalKind.offer), _sampleSdp);
      expect(decodeSignal(answer, SignalKind.answer), _sampleSdp);
    });

    test('are short enough for a comfortable QR code', () {
      expect(encodeSignal(SignalKind.offer, _sampleSdp).length, lessThan(_sampleSdp.length));
    });

    test('tolerate surrounding whitespace from copy/paste', () {
      final offer = encodeSignal(SignalKind.offer, _sampleSdp);
      expect(decodeSignal('  $offer\n', SignalKind.offer), _sampleSdp);
    });

    test('reject the wrong kind with a helpful message', () {
      final answer = encodeSignal(SignalKind.answer, _sampleSdp);
      expect(() => decodeSignal(answer, SignalKind.offer), throwsA(isA<InvalidSignalException>()));
    });

    test('reject unrelated and truncated codes', () {
      expect(() => decodeSignal('https://example.com', SignalKind.offer),
          throwsA(isA<InvalidSignalException>()));
      final offer = encodeSignal(SignalKind.offer, _sampleSdp);
      expect(() => decodeSignal(offer.substring(0, offer.length ~/ 2), SignalKind.offer),
          throwsA(isA<InvalidSignalException>()));
    });
  });

  group('frames', () {
    String roundTrip(String message, int maxChars) {
      final assembler = FrameAssembler();
      final frames = encodeFrames(message, maxChars: maxChars);
      String? result;
      for (final (i, frame) in frames.indexed) {
        expect(frame.length, lessThanOrEqualTo(maxChars + 1));
        result = assembler.add(frame);
        expect(result == null, i < frames.length - 1);
      }
      return result!;
    }

    test('short message is a single frame', () {
      expect(encodeFrames('{"a":1}'), ['.{"a":1}']);
    });

    test('long message round-trips, including an exact multiple of the frame size', () {
      final message = 'x' * 100;
      expect(roundTrip(message, 10), message);
      expect(roundTrip(message, 7), message);
      expect(roundTrip('', 7), '');
    });

    test('never splits a surrogate pair', () {
      final message = 'ab😀cd😀😀ef' * 5;
      for (final size in [2, 3, 4, 5]) {
        for (final frame in encodeFrames(message, maxChars: size)) {
          final last = frame.codeUnitAt(frame.length - 1);
          expect(last >= 0xD800 && last <= 0xDBFF, isFalse);
        }
        expect(roundTrip(message, size), message);
      }
    });

    test('assembler handles consecutive messages', () {
      final assembler = FrameAssembler();
      final out = [
        for (final frame in [...encodeFrames('first' * 4, maxChars: 6), ...encodeFrames('2nd')])
          assembler.add(frame),
      ].whereType<String>().toList();
      expect(out, ['first' * 4, '2nd']);
    });
  });
}
