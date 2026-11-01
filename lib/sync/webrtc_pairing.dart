import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'sync_protocol.dart';
import 'webrtc_signal.dart';

/// Serverless pairing of two devices over WebRTC — the one way a browser
/// can talk directly to another device. WebRTC needs both sides to swap a
/// description of themselves (SDP: crypto fingerprint + network addresses)
/// before connecting; instead of a signaling server, they go through the
/// screen and camera:
///
///  1. the device starting the sync calls [createOffer] and shows the code
///     as a QR code;
///  2. the other device scans it, calls [answerOffer] and shows its own QR
///     code in return;
///  3. the first device scans that one and calls [acceptAnswer].
///
/// Both then get a [MessageChannel] from [channel] once the data channel
/// opens. No ICE (STUN/TURN) servers are configured: only local network
/// addresses are exchanged, so both devices must be on the same Wi-Fi —
/// the same rule as the mDNS/TCP sync.
class WebRtcPairing {
  RTCPeerConnection? _pc;
  WebRtcMessageChannel? _channel;
  final Completer<void> _gathered = Completer<void>();
  final Completer<MessageChannel> _opened = Completer<MessageChannel>();

  /// Completes once the data channel is open, or errors if the connection
  /// fails first. Whoever gets the channel owns it (and closes it).
  Future<MessageChannel> get channel => _opened.future;

  Future<RTCPeerConnection> _newPeerConnection() async {
    final pc = await createPeerConnection({'iceServers': <Map<String, dynamic>>[]});
    pc.onIceGatheringState = (state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete && !_gathered.isCompleted) {
        _gathered.complete();
      }
    };
    pc.onIceCandidate = (candidate) {
      // Some implementations signal the end of gathering with an empty
      // candidate rather than (or before) the state change.
      if ((candidate.candidate ?? '').isEmpty && !_gathered.isCompleted) _gathered.complete();
    };
    pc.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _channel?._connectionLost('Connexion perdue avec l’autre appareil.');
        _fail('Connexion impossible : les deux appareils doivent être sur le même Wi-Fi.');
      }
    };
    _pc = pc;
    return pc;
  }

  /// Step 1 (device starting the sync). Returns the code to show as a QR.
  Future<String> createOffer() async {
    final pc = await _newPeerConnection();
    final dc = await pc.createDataChannel('sync', RTCDataChannelInit()..ordered = true);
    _attach(pc, dc);
    await pc.setLocalDescription(await pc.createOffer());
    return encodeSignal(SignalKind.offer, await _localSdpWithCandidates(pc));
  }

  /// Step 2 (the other device), from the scanned offer. Returns the answer
  /// code to show as a QR in return.
  Future<String> answerOffer(String offerCode) async {
    final sdp = decodeSignal(offerCode, SignalKind.offer);
    final pc = await _newPeerConnection();
    pc.onDataChannel = (dc) => _attach(pc, dc);
    await pc.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));
    await pc.setLocalDescription(await pc.createAnswer());
    return encodeSignal(SignalKind.answer, await _localSdpWithCandidates(pc));
  }

  /// Step 3 (device starting the sync), from the scanned answer.
  Future<void> acceptAnswer(String answerCode) async {
    final sdp = decodeSignal(answerCode, SignalKind.answer);
    await _pc!.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
  }

  /// The QR code is a one-shot exchange (no trickle ICE), so wait until
  /// every local candidate is in the description before encoding it. With
  /// no STUN server, gathering only lists local interfaces and is quick;
  /// the timeout just guards against an implementation that never reports
  /// "complete".
  Future<String> _localSdpWithCandidates(RTCPeerConnection pc) async {
    await _gathered.future.timeout(const Duration(seconds: 5), onTimeout: () {});
    final description = await pc.getLocalDescription();
    return description!.sdp!;
  }

  void _attach(RTCPeerConnection pc, RTCDataChannel dc) {
    final channel = WebRtcMessageChannel._(pc, dc);
    _channel = channel;
    channel._opened.future.then((_) {
      if (!_opened.isCompleted) _opened.complete(channel);
    }, onError: (Object e) => _fail(e.toString()));
  }

  void _fail(String message) {
    if (!_opened.isCompleted) _opened.completeError(Exception(message));
  }

  /// Abandons the pairing if it never produced a channel (screen closed,
  /// timeout…). Once [channel] has completed, its owner closes it instead.
  Future<void> dispose() async {
    if (_opened.isCompleted) return;
    _fail('Appairage annulé.');
    await _pc?.close();
  }
}

/// [MessageChannel] over a WebRTC data channel. Each message is JSON, cut
/// into frames (see [encodeFrames]) to stay under the per-message size
/// limit, and sending waits whenever the channel's send buffer gets full —
/// browsers abort a data channel whose buffer overflows.
class WebRtcMessageChannel implements MessageChannel {
  final RTCPeerConnection _pc;
  final RTCDataChannel _dc;
  final FrameAssembler _assembler = FrameAssembler();
  final StreamController<SyncMessage> _incoming = StreamController<SyncMessage>();
  final Completer<void> _opened = Completer<void>();
  Future<void> _sending = Future.value();
  bool _closing = false;

  static const int _maxBufferedBytes = 1024 * 1024;

  @override
  late final Stream<SyncMessage> messages = _incoming.stream.asBroadcastStream();

  WebRtcMessageChannel._(this._pc, this._dc) {
    // Hooked up right away: the peer starts sending as soon as its side is
    // open, and _incoming buffers until the session starts listening.
    _dc.onMessage = (message) {
      if (message.isBinary) return;
      try {
        final full = _assembler.add(message.text);
        if (full != null) {
          _incoming.add(SyncMessage.fromJson(jsonDecode(full) as Map<String, dynamic>));
        }
      } catch (e) {
        _connectionLost('Message illisible reçu : $e');
      }
    };
    _dc.onDataChannelState = _onState;
    if (_dc.state != null) _onState(_dc.state!);
  }

  void _onState(RTCDataChannelState state) {
    if (state == RTCDataChannelState.RTCDataChannelOpen) {
      if (!_opened.isCompleted) _opened.complete();
    } else if (state == RTCDataChannelState.RTCDataChannelClosed) {
      if (!_opened.isCompleted) {
        _opened.completeError(Exception('Canal fermé avant d’être ouvert.'));
      }
      _connectionLost('L’autre appareil a fermé la connexion.');
    }
  }

  void _connectionLost(String reason) {
    if (_closing || _incoming.isClosed) return;
    _incoming.addError(Exception(reason));
    _incoming.close();
  }

  @override
  void send(SyncMessage message) {
    final frames = encodeFrames(jsonEncode(message.toJson()));
    _sending = _sending.then((_) async {
      for (final frame in frames) {
        while (await _dc.getBufferedAmount() > _maxBufferedBytes) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        await _dc.send(RTCDataChannelMessage(frame));
      }
    }).catchError((Object e) => _connectionLost('Envoi impossible : $e'));
  }

  @override
  Future<void> close() async {
    if (_closing) return;
    try {
      await _sending;
      // Let the last frames actually leave before tearing the connection
      // down — the peer may still be waiting on them (e.g. 'done').
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (await _dc.getBufferedAmount() > 0 && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('WebRTC channel: flush before close failed: $e');
    }
    _closing = true;
    await _incoming.close();
    await _dc.close();
    await _pc.close();
  }
}
