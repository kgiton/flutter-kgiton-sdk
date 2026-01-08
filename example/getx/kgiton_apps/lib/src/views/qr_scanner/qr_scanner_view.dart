/// ============================================================================
/// QR Scanner View
/// ============================================================================
///
/// File: src/views/qr_scanner/qr_scanner_view.dart
/// Deskripsi: Screen untuk scan QR code license
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../config/theme.dart';
import '../../config/routes.dart';

class QRScannerView extends StatefulWidget {
  const QRScannerView({super.key});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan License QR'),
      ),
      body: Stack(
        children: [
          // MobileScanner untuk scan QR code
          MobileScanner(
            onDetect: (capture) {
              if (_hasScanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _hasScanned = true;
                  _processQR(barcode.rawValue!);
                  return;
                }
              }
            },
          ),

          // Scan overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: KGiTONColors.primary, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'Arahkan kamera ke QR Code\nLicense Key',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processQR(String data) {
    // Navigate ke device screen dengan GetX
    // Menggunakan Get.offNamed untuk replace current route
    Get.offNamed(
      AppRoutes.device,
      arguments: {'licenseKey': data},
    );
  }
}
