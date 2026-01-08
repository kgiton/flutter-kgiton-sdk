/// ============================================================================
/// Device Page
/// ============================================================================
///
/// File: src/presentation/pages/device/device_page.dart
/// Deskripsi: Halaman untuk scan, connect, dan monitor device
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/theme.dart';
import '../../../domain/entities/scale_device_entity.dart';
import '../../bloc/scale/scale_bloc.dart';
import '../../bloc/scale/scale_event.dart';
import '../../bloc/scale/scale_state.dart';

class DevicePage extends StatefulWidget {
  final String licenseKey;

  const DevicePage({
    super.key,
    required this.licenseKey,
  });

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  late TextEditingController _licenseController;

  @override
  void initState() {
    super.initState();
    _licenseController = TextEditingController(text: widget.licenseKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start scanning automatically
      context.read<ScaleBloc>().add(const StartScanEvent());
    });
  }

  @override
  void dispose() {
    _licenseController.dispose();
    context.read<ScaleBloc>().add(const StopScanEvent());
    super.dispose();
  }

  String get _currentLicenseKey => _licenseController.text.trim();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScaleBloc, ScaleState>(
      listener: (context, state) {
        if (state is ScaleConnected) {
          Navigator.pop(context);
          _showSnackBar('Berhasil terhubung!', KGiTONColors.success);
        } else if (state is ScaleError) {
          _showSnackBar(state.message, KGiTONColors.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connect Device'),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _scanQRCode,
              tooltip: 'Scan QR License',
            ),
            BlocBuilder<ScaleBloc, ScaleState>(
              builder: (context, state) {
                if (state is ScaleConnected) {
                  return IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () {
                      context.read<ScaleBloc>().add(const TriggerBuzzerEvent());
                    },
                    tooltip: 'Trigger Buzzer',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // License Key Input
            _buildLicenseInput(),
            // Main Content
            Expanded(
              child: BlocBuilder<ScaleBloc, ScaleState>(
                builder: (context, state) {
                  return _buildStateContent(context, state);
                },
              ),
            ),
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

  Future<void> _scanQRCode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _QRScannerScreen()),
    );
    if (result != null) {
      setState(() {
        _licenseController.text = result;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Widget _buildStateContent(BuildContext context, ScaleState state) {
    // Initial state - show start scan button
    if (state is ScaleInitial || state is ScaleDisconnected) {
      return _buildInitialState(context);
    }

    // Scanning state - show device list
    if (state is ScaleScanning) {
      return _buildScanningState(context, state);
    }

    // Connecting state - show loading
    if (state is ScaleConnecting) {
      return _buildConnectingState(state);
    }

    // Connected state - show weight monitor
    if (state is ScaleConnected) {
      return _buildConnectedState(context, state);
    }

    // Error state
    if (state is ScaleError) {
      return _buildErrorState(context, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildInitialState(BuildContext context) {
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
            onPressed: () {
              context.read<ScaleBloc>().add(const StartScanEvent());
            },
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

  Widget _buildScanningState(BuildContext context, ScaleScanning state) {
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
                onPressed: () {
                  context.read<ScaleBloc>().add(const StopScanEvent());
                },
                child: const Text('Stop'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Device list
        Expanded(
          child: state.devices.isEmpty
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
                  itemCount: state.devices.length,
                  itemBuilder: (context, index) {
                    final device = state.devices[index];
                    return _buildDeviceItem(context, device);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDeviceItem(BuildContext context, ScaleDeviceEntity device) {
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
              color: _getSignalColor(device.signalQuality),
            ),
            const SizedBox(width: 4),
            Text(
              '${device.rssi} dBm',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            if (_currentLicenseKey.isEmpty) {
              _showSnackBar('Masukkan license key terlebih dahulu', KGiTONColors.error);
              return;
            }
            context.read<ScaleBloc>().add(ConnectDeviceEvent(
                  deviceId: device.id,
                  licenseKey: _currentLicenseKey,
                ));
          },
          child: const Text('Connect'),
        ),
      ),
    );
  }

  Color _getSignalColor(SignalQuality quality) {
    switch (quality) {
      case SignalQuality.excellent:
        return KGiTONColors.success;
      case SignalQuality.good:
        return KGiTONColors.primaryLight;
      case SignalQuality.fair:
        return KGiTONColors.warning;
      case SignalQuality.poor:
        return KGiTONColors.error;
    }
  }

  Widget _buildConnectingState(ScaleConnecting state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Connecting to ${state.device.name}...',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedState(BuildContext context, ScaleConnected state) {
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
                          state.device.name,
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
                Text(
                  state.currentWeight.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
              onPressed: () {
                context.read<ScaleBloc>().add(DisconnectDeviceEvent(
                      licenseKey: _currentLicenseKey,
                    ));
              },
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

  Widget _buildErrorState(BuildContext context, ScaleError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            onPressed: () {
              context.read<ScaleBloc>().add(const StartScanEvent());
            },
          ),
        ],
      ),
    );
  }
}

/// QR Scanner Screen for scanning license key
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
