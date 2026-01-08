/// ============================================================================
/// Device View - GetX UI
/// ============================================================================
///
/// File: src/views/device/device_view.dart
/// Deskripsi: Screen untuk scan dan connect ke BLE device
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../config/theme.dart';
import '../../controllers/scale_controller.dart';

class DeviceView extends StatefulWidget {
  const DeviceView({super.key});

  @override
  State<DeviceView> createState() => _DeviceViewState();
}

class _DeviceViewState extends State<DeviceView> {
  late TextEditingController _licenseController;

  @override
  void initState() {
    super.initState();
    _licenseController = TextEditingController();

    // Auto-fill dengan license key dari arguments atau dari controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<ScaleController>();

      // Prioritas: arguments > existing value in controller
      if (Get.arguments != null && Get.arguments['licenseKey'] != null) {
        final licenseKey = Get.arguments['licenseKey'] as String;
        controller.licenseKey.value = licenseKey;
        _licenseController.text = licenseKey;
      } else if (controller.licenseKey.value.isNotEmpty) {
        _licenseController.text = controller.licenseKey.value;
      }
    });
  }

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScaleController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Device'),
        actions: [
          // QR Scan button
          Obx(() {
            if (!controller.isConnected.value) {
              return IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanQRCode,
                tooltip: 'Scan QR License',
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            if (controller.isConnected.value) {
              return IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: controller.triggerBuzzer,
                tooltip: 'Trigger Buzzer',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // License Key Input
            Obx(() {
              if (!controller.isConnected.value) {
                return _buildLicenseInput(controller);
              }
              return _buildLicenseInfo(controller);
            }),

            // Main Content
            Expanded(
              child: Obx(() => _buildStateContent(controller)),
            ),
          ],
        ),
      ),
    );
  }

  /// Build license key input section
  Widget _buildLicenseInput(ScaleController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: KGiTONColors.primary.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('License Key', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextFormField(
            controller: _licenseController,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            onChanged: (value) => controller.licenseKey.value = value,
            decoration: InputDecoration(
              hintText: 'XXXX-XXXX-XXXX-XXXX',
              prefixIcon: const Icon(Icons.vpn_key),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanQRCode,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Build license key info (when connected)
  Widget _buildLicenseInfo(ScaleController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: KGiTONColors.primary.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.vpn_key, color: KGiTONColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'License Key',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  controller.licenseKey.value,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Scan QR code untuk license key
  Future<void> _scanQRCode() async {
    final result = await Get.to<String>(() => const _QRScannerScreen());

    if (result != null) {
      _licenseController.text = result;
      Get.find<ScaleController>().licenseKey.value = result;
    }
  }

  Widget _buildStateContent(ScaleController controller) {
    // Connected state
    if (controller.isConnected.value) {
      return _buildConnectedState(controller);
    }

    // Connecting state
    if (controller.isConnecting.value) {
      return _buildConnectingState(controller);
    }

    // Scanning state
    if (controller.isScanning.value) {
      return _buildScanningState(controller);
    }

    // Initial state
    return _buildInitialState(controller);
  }

  Widget _buildInitialState(ScaleController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: KGiTONColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bluetooth_searching,
              size: 64,
              color: KGiTONColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Siap untuk scan device',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan Bluetooth aktif dan\ndevice dalam jangkauan',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Mulai Scan'),
            onPressed: controller.startScan,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningState(ScaleController controller) {
    return Column(
      children: [
        // Scanning indicator
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              const Text('Scanning...'),
              const Spacer(),
              TextButton(
                onPressed: controller.stopScan,
                child: const Text('Stop'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Device list
        Expanded(
          child: controller.devices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bluetooth_searching, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Mencari device...',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: controller.devices.length,
                  itemBuilder: (context, index) {
                    final device = controller.devices[index];
                    return _buildDeviceItem(controller, device);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDeviceItem(ScaleController controller, ScaleDevice device) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: KGiTONColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.scale, color: KGiTONColors.primary),
        ),
        title: Text(device.name),
        subtitle: Row(
          children: [
            Icon(
              Icons.signal_cellular_alt,
              size: 14,
              color: _getSignalColor(device.rssi),
            ),
            const SizedBox(width: 4),
            Text(
              '${device.rssi} dBm',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => controller.connectDevice(device),
          child: const Text('Connect'),
        ),
      ),
    );
  }

  Color _getSignalColor(int? rssi) {
    if (rssi == null) return Colors.grey;
    if (rssi >= -50) return KGiTONColors.success;
    if (rssi >= -60) return KGiTONColors.primaryLight;
    if (rssi >= -70) return KGiTONColors.warning;
    return KGiTONColors.error;
  }

  Widget _buildConnectingState(ScaleController controller) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Connecting...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedState(ScaleController controller) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Connection status
          Card(
            color: KGiTONColors.success.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: KGiTONColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connected',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: KGiTONColors.success,
                          ),
                        ),
                        Text(
                          controller.connectedDevice.value?.name ?? 'Unknown',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Weight display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: KGiTONColors.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: KGiTONColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Current Weight',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                      controller.currentWeight.value.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                const Text(
                  'kg',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Disconnect button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.bluetooth_disabled),
              label: const Text('Disconnect'),
              onPressed: controller.disconnectDevice,
              style: OutlinedButton.styleFrom(
                foregroundColor: KGiTONColors.error,
                side: const BorderSide(color: KGiTONColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// QR Scanner screen untuk scan license key
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
                  Get.back(result: barcode.rawValue);
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
}
