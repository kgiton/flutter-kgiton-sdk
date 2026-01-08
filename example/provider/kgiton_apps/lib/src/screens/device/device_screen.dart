/// ============================================================================
/// Device Screen - Scan & Connect BLE Device
/// ============================================================================
///
/// File: src/screens/device/device_screen.dart
/// Deskripsi: Screen untuk scan dan connect ke device BLE KGiTON
///
/// Fitur:
/// - Scan device dengan progress indicator
/// - List device yang ditemukan
/// - Connect dengan license key
/// - Scan QR untuk license key
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../providers/auth_provider.dart';
import '../../providers/scale_provider.dart';
import '../../config/theme.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final _licenseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-fill dengan primary license key jika ada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final licenseKey = context.read<AuthProvider>().primaryLicenseKey;
      if (licenseKey != null) {
        _licenseController.text = licenseKey;
      }
      // Auto start scan
      context.read<ScaleProvider>().startScan();
    });
  }

  @override
  void dispose() {
    _licenseController.dispose();
    // Stop scan saat keluar dari screen
    context.read<ScaleProvider>().stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Cari Device'),
        actions: [
          // QR Scan button
          IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanQRCode, tooltip: 'Scan QR License'),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            // ================================================================
            // License Key Input
            // ================================================================
            SliverToBoxAdapter(child: _buildLicenseInput()),

            // ================================================================
            // Scan Status
            // ================================================================
            SliverToBoxAdapter(child: _buildScanStatus()),

            // ================================================================
            // Device List
            // ================================================================
            SliverFillRemaining(
              hasScrollBody: true,
              child: _buildDeviceList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build license key input section
  Widget _buildLicenseInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: KGiTONColors.primary.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('License Key', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _licenseController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    hintText: 'XXXX-XXXX-XXXX-XXXX',
                    prefixIcon: const Icon(Icons.vpn_key),
                    suffixIcon: IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanQRCode),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build scan status section
  Widget _buildScanStatus() {
    return Consumer<ScaleProvider>(
      builder: (context, scaleProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Status icon
              if (scaleProvider.isScanning)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Icon(
                  scaleProvider.devices.isEmpty ? Icons.bluetooth_searching : Icons.check_circle,
                  color: scaleProvider.devices.isEmpty ? KGiTONColors.textSecondaryLight : KGiTONColors.success,
                ),

              const SizedBox(width: 12),

              // Status text
              Expanded(
                child: Text(
                  scaleProvider.isScanning
                      ? 'Mencari device KGiTON...'
                      : scaleProvider.devices.isEmpty
                          ? 'Tidak ada device ditemukan'
                          : '${scaleProvider.devices.length} device ditemukan',
                ),
              ),

              // Scan button
              TextButton.icon(
                onPressed: scaleProvider.isScanning ? () => scaleProvider.stopScan() : () => scaleProvider.startScan(),
                icon: Icon(scaleProvider.isScanning ? Icons.stop : Icons.refresh),
                label: Text(scaleProvider.isScanning ? 'Stop' : 'Scan Ulang'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build device list
  Widget _buildDeviceList() {
    return Consumer<ScaleProvider>(
      builder: (context, scaleProvider, child) {
        final devices = scaleProvider.devices;

        if (devices.isEmpty && !scaleProvider.isScanning) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            return _buildDeviceItem(devices[index]);
          },
        );
      },
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Icon(Icons.bluetooth_searching, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Tidak ada device ditemukan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              'Pastikan device KGiTON sudah menyala dan\nBluetooth perangkat Anda aktif',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<ScaleProvider>().startScan(),
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Ulang'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build device item
  Widget _buildDeviceItem(device) {
    return Consumer<ScaleProvider>(
      builder: (context, scaleProvider, child) {
        final isConnecting = scaleProvider.connectionStatus == ConnectionStatus.connecting;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: KGiTONColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.scale, color: KGiTONColors.primary),
            ),
            title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${device.id.substring(0, 17)}...', style: const TextStyle(fontSize: 12)),
                Row(
                  children: [
                    // Signal strength
                    Icon(_getSignalIcon(device.rssi), size: 14, color: _getSignalColor(device.rssi)),
                    const SizedBox(width: 4),
                    Text('${device.rssi} dBm', style: TextStyle(fontSize: 12, color: _getSignalColor(device.rssi))),
                    if (device.licenseKey != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.key, size: 14, color: KGiTONColors.success),
                      const SizedBox(width: 4),
                      const Text('Tersimpan', style: TextStyle(fontSize: 12, color: KGiTONColors.success)),
                    ],
                  ],
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: isConnecting ? null : () => _connectToDevice(device),
              child: isConnecting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Connect'),
            ),
          ),
        );
      },
    );
  }

  /// Get signal icon based on RSSI
  IconData _getSignalIcon(int rssi) {
    if (rssi >= -60) return Icons.signal_cellular_4_bar;
    if (rssi >= -70) return Icons.signal_cellular_alt;
    if (rssi >= -80) return Icons.signal_cellular_alt_2_bar;
    return Icons.signal_cellular_alt_1_bar;
  }

  /// Get signal color based on RSSI
  Color _getSignalColor(int rssi) {
    if (rssi >= -60) return KGiTONColors.success;
    if (rssi >= -70) return KGiTONColors.primaryLight;
    if (rssi >= -80) return KGiTONColors.warning;
    return KGiTONColors.error;
  }

  /// Connect to device
  Future<void> _connectToDevice(device) async {
    final licenseKey = _licenseController.text.trim();

    if (licenseKey.isEmpty) {
      _showError('Masukkan license key terlebih dahulu');
      return;
    }

    final scaleProvider = context.read<ScaleProvider>();

    final success = await scaleProvider.connectDevice(deviceId: device.id, licenseKey: licenseKey);

    if (success && mounted) {
      // Kembali ke home screen
      Navigator.pop(context);
      _showSuccess('Berhasil terhubung ke ${device.name}');
    } else if (mounted) {
      _showError(scaleProvider.errorMessage ?? 'Gagal terhubung');
    }
  }

  /// Scan QR code untuk license key
  Future<void> _scanQRCode() async {
    final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const _QRScannerScreen()));

    if (result != null) {
      _licenseController.text = result;
    }
  }

  /// Show error snackbar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: KGiTONColors.error));
  }

  /// Show success snackbar
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: KGiTONColors.success));
  }
}

/// QR Scanner screen
class _QRScannerScreen extends StatefulWidget {
  const _QRScannerScreen();

  @override
  State<_QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<_QRScannerScreen> {
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan License Key')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_hasScanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _hasScanned = true;
                  Navigator.pop(context, barcode.rawValue);
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
                shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
