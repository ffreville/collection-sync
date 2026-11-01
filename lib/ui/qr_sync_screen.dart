import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../sync/sync_service.dart';
import '../sync/webrtc_pairing.dart';
import 'barcode_scanner_screen.dart';
import 'conflict_resolution_screen.dart';
import 'review_changes_screen.dart';

/// Which side of the QR exchange this device plays — see [WebRtcPairing].
enum QrSyncRole {
  /// Shows the first code, then scans the answer. Like tapping "Synchroniser"
  /// on a discovered device: changes to other people's content are only
  /// *proposed* for review.
  start,

  /// Scans the first code, then shows its answer. Like receiving an incoming
  /// sync: what the other device sends applies automatically.
  join,
}

enum _Step { preparing, waitingForScan, showingCode, connecting, syncing, done, error }

/// Device-to-device sync paired by QR code over WebRTC — works between any
/// two of: the iOS/Android app and the web version (which can't use the
/// automatic Wi-Fi discovery). Both devices must be on the same Wi-Fi.
class QrSyncScreen extends StatefulWidget {
  final QrSyncRole role;
  const QrSyncScreen({super.key, required this.role});

  @override
  State<QrSyncScreen> createState() => _QrSyncScreenState();
}

class _QrSyncScreenState extends State<QrSyncScreen> {
  final WebRtcPairing _pairing = WebRtcPairing();
  final TextEditingController _pasted = TextEditingController();
  _Step _step = _Step.preparing;
  String? _code;
  String? _message;

  bool get _starting => widget.role == QrSyncRole.start;

  @override
  void initState() {
    super.initState();
    if (_starting) {
      _createOffer();
    } else {
      _step = _Step.waitingForScan;
    }
  }

  @override
  void dispose() {
    _pairing.dispose();
    _pasted.dispose();
    super.dispose();
  }

  Future<void> _createOffer() async {
    try {
      final code = await _pairing.createOffer();
      if (!mounted) return;
      setState(() {
        _code = code;
        _step = _Step.showingCode;
      });
    } catch (e) {
      _showError('Impossible de préparer la connexion : $e');
    }
  }

  /// The code the *other* device shows: its answer when we started, its
  /// offer when we're joining.
  Future<void> _onPeerCode(String raw) async {
    final code = raw.trim();
    if (code.isEmpty) return;
    final sync = context.read<SyncService>();
    try {
      if (_starting) {
        setState(() => _step = _Step.connecting);
        await _pairing.acceptAnswer(code);
        final channel = await _pairing.channel.timeout(const Duration(seconds: 20));
        if (!mounted) {
          await channel.close();
          return;
        }
        setState(() => _step = _Step.syncing);
        await sync.syncOverChannel(channel, peerLabel: 'l’autre appareil');
        if (!mounted) return;
        setState(() {
          _step = sync.status == SyncStatus.error ? _Step.error : _Step.done;
          _message = sync.statusMessage;
        });
      } else {
        setState(() => _step = _Step.preparing);
        final answer = await _pairing.answerOffer(code);
        if (!mounted) return;
        setState(() {
          _code = answer;
          _step = _Step.showingCode;
        });
        // No timeout here: the other person may take a while to scan.
        final channel = await _pairing.channel;
        if (!mounted) {
          await channel.close();
          return;
        }
        setState(() => _step = _Step.syncing);
        await sync.acceptIncoming(channel);
        if (!mounted) return;
        setState(() {
          _step = _Step.done;
          _message = 'Synchronisation terminée.';
        });
      }
    } on TimeoutException {
      _showError('Impossible de joindre l’autre appareil. Vérifiez que les deux '
          'sont connectés au même Wi-Fi, puis réessayez.');
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _step = _Step.error;
      _message = message;
    });
  }

  Future<void> _scan() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => BarcodeScannerScreen(
          title: 'Scanner le QR code',
          hint: _starting
              ? 'Visez le QR code de réponse de l’autre appareil'
              : 'Visez le QR code affiché par l’autre appareil',
          square: true,
        ),
      ),
    );
    if (code != null) await _onPeerCode(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_starting ? 'Démarrer une synchro' : 'Rejoindre une synchro'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: _buildStep(context),
        ),
      ),
    );
  }

  List<Widget> _buildStep(BuildContext context) {
    switch (_step) {
      case _Step.preparing:
        return const [_Progress('Préparation de la connexion...')];
      case _Step.connecting:
        return const [_Progress('Connexion à l’autre appareil...')];
      case _Step.syncing:
        return const [_Progress('Synchronisation en cours...')];
      case _Step.waitingForScan:
        return [
          const Text(
            '1. Sur l’autre appareil, ouvrez « Synchroniser » puis « Démarrer '
            'une synchro » : un QR code s’affiche.\n'
            '2. Scannez-le ici.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _scan,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scanner le QR code'),
          ),
          const SizedBox(height: 24),
          _PasteField(controller: _pasted, onSubmit: _onPeerCode),
        ];
      case _Step.showingCode:
        return [
          Text(
            _starting
                ? '1. Sur l’autre appareil, ouvrez « Synchroniser » puis '
                    '« Rejoindre une synchro », et scannez ce QR code.\n'
                    '2. Il affichera à son tour un QR code : scannez-le ici.'
                : 'Montrez ce QR code à l’autre appareil pour qu’il le scanne. '
                    'La synchro démarre toute seule ensuite.',
          ),
          const SizedBox(height: 16),
          _CodeView(code: _code!),
          const SizedBox(height: 24),
          if (_starting) ...[
            FilledButton.icon(
              onPressed: _scan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scanner la réponse'),
            ),
            const SizedBox(height: 24),
            _PasteField(controller: _pasted, onSubmit: _onPeerCode),
          ] else
            const _Progress('En attente de l’autre appareil...'),
          const SizedBox(height: 16),
          Text(
            'Les deux appareils doivent être connectés au même Wi-Fi.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ];
      case _Step.done:
        final sync = context.watch<SyncService>();
        return [
          const Icon(Icons.check_circle_outline, size: 48),
          const SizedBox(height: 12),
          Text(_message ?? 'Synchronisation terminée.', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          if (sync.pendingChanges.isNotEmpty)
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ReviewChangesScreen()),
              ),
              child: Text('Voir ${sync.pendingChanges.length} modification(s) proposée(s)'),
            ),
          if (sync.totalConflicts > 0)
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ConflictResolutionScreen()),
              ),
              child: Text('Résoudre ${sync.totalConflicts} conflit(s)'),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ];
      case _Step.error:
        return [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Text(_message ?? 'Erreur inconnue.', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => QrSyncScreen(role: widget.role)),
            ),
            child: const Text('Réessayer'),
          ),
        ];
    }
  }
}

class _Progress extends StatelessWidget {
  final String label;
  const _Progress(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// The pairing code as a QR code, plus a copy button — handy between a
/// computer and a phone, or when a camera isn't available.
class _CodeView extends StatelessWidget {
  final String code;
  const _CodeView({required this.code});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            // Always dark-on-white, even in dark mode: scanners expect it.
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: QrImageView(
              data: code,
              size: 280,
              errorCorrectionLevel: QrErrorCorrectLevel.L,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () async {
            // Browsers can refuse clipboard access (permissions, unfocused
            // page…) — report it instead of failing silently.
            var copied = true;
            try {
              await Clipboard.setData(ClipboardData(text: code));
            } catch (_) {
              copied = false;
            }
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(copied ? 'Code copié' : 'Copie impossible sur ce navigateur')),
            );
          },
          icon: const Icon(Icons.copy),
          label: const Text('Copier le code'),
        ),
      ],
    );
  }
}

class _PasteField extends StatelessWidget {
  final TextEditingController controller;
  final Future<void> Function(String code) onSubmit;
  const _PasteField({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Pas de caméra ? Collez le code copié :',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'CS1…',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => onSubmit(controller.text),
          child: const Text('Valider le code'),
        ),
      ],
    );
  }
}
