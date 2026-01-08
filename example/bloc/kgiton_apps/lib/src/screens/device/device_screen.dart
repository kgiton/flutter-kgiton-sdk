/// ============================================================================
/// Device Screen - BLoC Version
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/scale/scale_bloc.dart';
import '../../bloc/scale/scale_event.dart';
import '../../bloc/scale/scale_state.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Auto-fill license key
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.primaryLicenseKey != null) {
        _licenseController.text = authState.primaryLicenseKey!;
      }
      // Start scanning
      context.read<ScaleBloc>().add(const StartScanEvent());
    });
  }

  @override
  void dispose() {
    _licenseController.dispose();
    context.read<ScaleBloc>().add(StopScanEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScaleBloc, ScaleState>(
      listener: (context, state) {
        if (state is ScaleConnected) {
          Navigator.pop(context);
          _showSnackBar('Berhasil terhubung!', KGiTONColors.success);
        } else if (state is ScaleError && state.errorMessage != null) {
          _showSnackBar(state.errorMessage!, KGiTONColors.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cari Device'),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _scanQRCode,
            ),
          ],
        ),
        body: Column(
          children: [
            _buildLicenseInput(),
            _buildScanStatus(),
            Expanded(child: _buildDeviceList()),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseInput() {
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
            decoration: InputDecoration(
              hintText: 'XXXX-XXXX-XXXX-XXXX',
              prefixIcon: const Icon(Icons.vpn_key),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanQRCode,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanStatus() {
    return BlocBuilder<ScaleBloc, ScaleState>(
      builder: (context, state) {
        final isScanning = state is ScaleScanning;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (isScanning)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  state.devices.isEmpty ? Icons.bluetooth_searching : Icons.check_circle,
                  color: state.devices.isEmpty ? KGiTONColors.textSecondaryLight : KGiTONColors.success,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isScanning
                    ? 'Mencari device KGiTON...'
                    : state.devices.isEmpty
                      ? 'Tidak ada device ditemukan'
                      : '${state.devices.length} device ditemukan',
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  if (isScanning) {
                    context.read<ScaleBloc>().add(StopScanEvent());
                  } else {
                    context.read<ScaleBloc>().add(const StartScanEvent());
                  }
                },
                icon: Icon(isScanning ? Icons.stop : Icons.refresh),
                label: Text(isScanning ? 'Stop' : 'Scan Ulang'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeviceList() {
    return BlocBuilder<ScaleBloc, ScaleState>(
      builder: (context, state) {
        final devices = state.devices;
        
        if (devices.isEmpty && state is! ScaleScanning) {
          return _buildEmptyState();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: devices.length,
          itemBuilder: (context, index) => _buildDeviceItem(devices[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bluetooth_searching, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada device ditemukan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<ScaleBloc>().add(const StartScanEvent()),
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Ulang'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(ScaleDevice device) {
    return BlocBuilder<ScaleBloc, ScaleState>(
      builder: (context, state) {
        final isConnecting = state is ScaleConnecting;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: KGiTONColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.scale, color: KGiTONColors.primary),
            ),
            title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${device.id.substring(0, 17)}...', style: const TextStyle(fontSize: 12)),
                Row(
                  children: [
                    Icon(_getSignalIcon(device.rssi), size: 14, color: _getSignalColor(device.rssi)),
                    const SizedBox(width: 4),
                    Text('${device.rssi} dBm', style: TextStyle(fontSize: 12, color: _getSignalColor(device.rssi))),
                  ],
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: isConnecting ? null : () => _connectToDevice(device),
              child: isConnecting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Connect'),
            ),
          ),
        );
      },
    );
  }

  IconData _getSignalIcon(int rssi) {
    if (rssi >= -60) return Icons.signal_cellular_4_bar;
    if (rssi >= -70) return Icons.signal_cellular_alt;
    if (rssi >= -80) return Icons.signal_cellular_alt_2_bar;
    return Icons.signal_cellular_alt_1_bar;
  }

  Color _getSignalColor(int rssi) {
    if (rssi >= -60) return KGiTONColors.success;
    if (rssi >= -70) return KGiTONColors.primaryLight;
    if (rssi >= -80) return KGiTONColors.warning;
    return KGiTONColors.error;
  }

  void _connectToDevice(ScaleDevice device) {
    final licenseKey = _licenseController.text.trim();
    if (licenseKey.isEmpty) {
      _showSnackBar('Masukkan license key terlebih dahulu', KGiTONColors.error);
      return;
    }
    
    context.read<ScaleBloc>().add(ConnectDeviceEvent(
      deviceId: device.id,
      licenseKey: licenseKey,
    ));
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _QRScannerScreen()),
    );
    if (result != null) {
      _licenseController.text = result;
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}

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
              for (final barcode in capture.barcodes) {
                if (barcode.rawValue != null) {
                  _hasScanned = true;
                  Navigator.pop(context, barcode.rawValue);
                  return;
                }
              }
            },
          ),
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
        ],
      ),
    );
  }
}
