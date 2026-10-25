import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


enum ScanMode { QR, BARCODE, DEFAULT }

class BarCodeService {

  /// Ouvre le scanner et renvoie le code lu, ou "-1" si l'utilisateur annule
  /// (même contrat que l'ancien flutter_barcode_scanner).
  static Future<String> scanBarCode(
      {required BuildContext context, ScanMode? scanType = ScanMode.BARCODE}) async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => _ScannerPage(scanType: scanType ?? ScanMode.DEFAULT)),
    );
    return code ?? "-1";
  }

}


class _ScannerPage extends StatefulWidget {
  final ScanMode scanType;

  const _ScannerPage({required this.scanType});

  @override
  State<_ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<_ScannerPage> {
  late final MobileScannerController _controller;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: widget.scanType == ScanMode.QR ? const [BarcodeFormat.qrCode] : const [],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        _done = true;
        Navigator.of(context).pop(value);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Scanner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 260,
              height: widget.scanType == ScanMode.QR ? 260 : 160,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00FF00), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
