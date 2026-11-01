import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Scans one barcode and pops with its raw value — the caller (item edit
/// screen, QR pairing screen) is the one that knows what to do with it.
class BarcodeScannerScreen extends StatefulWidget {
  final String title;
  final String hint;

  /// Square viewfinder for QR codes, wide one for product barcodes.
  final bool square;

  const BarcodeScannerScreen({
    super.key,
    this.title = 'Scanner un code-barres',
    this.hint = 'Visez le code-barres de l’objet',
    this.square = false,
  });

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled || capture.barcodes.isEmpty) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null) return;
    _handled = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(onDetect: _onDetect),
          Container(
            width: 260,
            height: widget.square ? 260 : 140,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Positioned(
            bottom: 40,
            child: Text(widget.hint, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
