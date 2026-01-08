/// ============================================================================
/// QR Scanner View
/// ============================================================================
///
/// File: src/views/qr_scanner/qr_scanner_view.dart
/// Deskripsi: Screen untuk scan QR code license
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/theme.dart';
import '../../config/routes.dart';

class QRScannerView extends StatefulWidget {
  const QRScannerView({super.key});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  // MobileScannerController dari package mobile_scanner
  // final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan License QR'),
      ),
      body: Stack(
        children: [
          // Placeholder untuk MobileScanner
          // Uncomment dan gunakan MobileScanner dari package mobile_scanner
          /*
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (!_isProcessing && barcode.rawValue != null) {
                  _processQR(barcode.rawValue!);
                }
              }
            },
          ),
          */

          // Demo view - ganti dengan MobileScanner
          Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 120,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'QR Scanner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Arahkan kamera ke QR code license',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Demo button untuk simulasi scan
                  ElevatedButton(
                    onPressed: () => _processQR('DEMO-LICENSE-KEY-12345'),
                    child: const Text('Demo: Scan QR'),
                  ),
                ],
              ),
            ),
          ),

          // Scan overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: KGiTONColors.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processQR(String data) {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    // Navigate ke device screen dengan GetX
    // Menggunakan Get.offNamed untuk replace current route
    Get.offNamed(
      AppRoutes.device,
      arguments: {'licenseKey': data},
    );
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }
}
