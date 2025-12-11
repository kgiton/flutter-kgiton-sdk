import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../../../auth/presentation/pages/qr_scanner_page.dart';

/// Scale weighing page - main page for weighing items
class ScaleWeighingPage extends StatefulWidget {
  const ScaleWeighingPage({super.key});

  @override
  State<ScaleWeighingPage> createState() => _ScaleWeighingPageState();
}

class _ScaleWeighingPageState extends State<ScaleWeighingPage> {
  final KGiTONScaleService _scaleService = KGiTONScaleService();

  WeightData? _currentWeight;
  ScaleConnectionState _connectionState = ScaleConnectionState.disconnected;
  List<ScaleDevice> _availableDevices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initializeScale();
  }

  void _initializeScale() {
    // Listen to weight stream
    _scaleService.weightStream.listen((weight) {
      setState(() {
        _currentWeight = weight;
      });
    });

    // Listen to connection state
    _scaleService.connectionStateStream.listen((state) {
      setState(() {
        _connectionState = state;
      });
    });

    // Listen to available devices
    _scaleService.devicesStream.listen((devices) {
      setState(() {
        _availableDevices = devices;
      });
    });
  }

  Future<void> _startScanning() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Check permissions first
      final hasPermissions = await PermissionHelper.checkBLEPermissions();
      if (!hasPermissions) {
        final granted = await PermissionHelper.requestBLEPermissions();
        if (!granted) {
          if (mounted) {
            _showBluetoothPermissionDialog();
          }
          setState(() {
            _isScanning = false;
          });
          return;
        }
      }

      // Start scanning
      await _scaleService.scanForDevices(timeout: const Duration(seconds: 10), autoStopOnFound: true);
    } catch (e) {
      // Handle Bluetooth not enabled error
      if (mounted) {
        final errorMsg = e.toString();
        if (errorMsg.contains('Bluetooth tidak tersedia') || errorMsg.contains('Bluetooth is not enabled')) {
          _showBluetoothDisabledDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scan error: $e'), backgroundColor: KgitonThemeColors.errorRed));
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  void _showBluetoothDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: KgitonThemeColors.cardBackground,
        title: const Row(
          children: [
            Icon(Icons.bluetooth_disabled, color: KgitonThemeColors.errorRed),
            SizedBox(width: 12),
            Text('Bluetooth Disabled', style: TextStyle(color: KgitonThemeColors.textPrimary)),
          ],
        ),
        content: const Text('Please enable Bluetooth on your device to scan for scales.', style: TextStyle(color: KgitonThemeColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: KgitonThemeColors.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showBluetoothPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: KgitonThemeColors.cardBackground,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: KgitonThemeColors.warningYellow),
            SizedBox(width: 12),
            Text('Permission Required', style: TextStyle(color: KgitonThemeColors.textPrimary)),
          ],
        ),
        content: const Text(
          'Bluetooth permission is required to scan for scale devices. Please grant the permission in Settings.',
          style: TextStyle(color: KgitonThemeColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: KgitonThemeColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              PermissionHelper.openAppSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: KgitonThemeColors.primaryGreen),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToDevice(ScaleDevice device) async {
    // Show dialog to input license key
    final licenseKey = await _showLicenseKeyDialog();
    if (licenseKey == null || licenseKey.isEmpty) return;

    try {
      final response = await _scaleService.connectWithLicenseKey(deviceId: device.id, licenseKey: licenseKey);

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Connected successfully!'), backgroundColor: KgitonThemeColors.successGreen));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Connection failed: ${response.message}'), backgroundColor: KgitonThemeColors.errorRed));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connection error: $e'), backgroundColor: KgitonThemeColors.errorRed));
      }
    }
  }

  Future<String?> _showLicenseKeyDialog() async {
    final controller = TextEditingController();
    final licenseKeyFormatter = MaskTextInputFormatter(mask: '#####-#####-#####-#####-#####', filter: {'#': RegExp(r'[A-Za-z0-9]')});

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: KgitonThemeColors.cardBackground,
          title: const Text('Enter License Key', style: TextStyle(color: KgitonThemeColors.textPrimary)),
          content: TextField(
            controller: controller,
            inputFormatters: [licenseKeyFormatter],
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.text,
            autofocus: true,
            style: const TextStyle(color: KgitonThemeColors.textPrimary, fontSize: 16, letterSpacing: 1.2, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: 'License Key',
              labelStyle: const TextStyle(color: KgitonThemeColors.textSecondary),
              hintText: 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX',
              hintStyle: const TextStyle(color: KgitonThemeColors.textPlaceholder, letterSpacing: 1.0),
              filled: true,
              fillColor: KgitonThemeColors.backgroundDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: KgitonThemeColors.borderDefault),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: KgitonThemeColors.borderDefault),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: KgitonThemeColors.primaryGreen, width: 2),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: KgitonThemeColors.primaryGreen),
                onPressed: () async {
                  final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const QRScannerPage()));

                  if (result != null && result.isNotEmpty) {
                    // Format the scanned result to match XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
                    String formattedKey = result.toUpperCase().replaceAll('-', '');

                    // Add hyphens at correct positions if not present
                    if (formattedKey.length == 25) {
                      formattedKey =
                          '${formattedKey.substring(0, 5)}-'
                          '${formattedKey.substring(5, 10)}-'
                          '${formattedKey.substring(10, 15)}-'
                          '${formattedKey.substring(15, 20)}-'
                          '${formattedKey.substring(20, 25)}';
                    }

                    // Auto-close dialog and return the formatted key (auto-connect)
                    if (context.mounted) {
                      Navigator.of(context).pop(formattedKey);
                    }
                  }
                },
                tooltip: 'Scan QR Code',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: KgitonThemeColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(backgroundColor: KgitonThemeColors.primaryGreen, foregroundColor: Colors.white),
              child: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _disconnect() async {
    await _scaleService.disconnect();
  }

  @override
  void dispose() {
    _scaleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgitonThemeColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Scale Weighing'),
        backgroundColor: KgitonThemeColors.cardBackground,
        foregroundColor: KgitonThemeColors.textPrimary,
        actions: [
          if (_connectionState == ScaleConnectionState.authenticated)
            IconButton(icon: const Icon(Icons.bluetooth_disabled), onPressed: _disconnect, tooltip: 'Disconnect'),
        ],
      ),
      body: Column(
        children: [
          // Connection Status Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KgitonThemeColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getStatusColor(), width: 2),
            ),
            child: Row(
              children: [
                Icon(_getStatusIcon(), color: _getStatusColor(), size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusText(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                      if (_scaleService.connectedDevice != null)
                        Text(
                          _scaleService.connectedDevice!.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: KgitonThemeColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Weight Display
          if (_connectionState == ScaleConnectionState.authenticated)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: KgitonThemeColors.cardBackground,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _currentWeight?.weight.toStringAsFixed(3) ?? '0.000',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: _currentWeight != null && _currentWeight!.weight > 0
                                  ? KgitonThemeColors.primaryGreen
                                  : KgitonThemeColors.textSecondary,
                            ),
                          ),
                          Text(
                            _currentWeight?.unit ?? 'kg',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(color: KgitonThemeColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Buzzer controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _BuzzerButton(label: 'Beep', icon: Icons.notifications_outlined, onPressed: () => _scaleService.triggerBuzzer('BEEP')),
                        const SizedBox(width: 12),
                        _BuzzerButton(label: 'Buzz', icon: Icons.vibration, onPressed: () => _scaleService.triggerBuzzer('BUZZ')),
                        const SizedBox(width: 12),
                        _BuzzerButton(label: 'Long', icon: Icons.notifications_active, onPressed: () => _scaleService.triggerBuzzer('LONG')),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            // Device List or Scan Button
            Expanded(
              child: _availableDevices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bluetooth_searching, size: 80, color: KgitonThemeColors.textSecondary.withValues(alpha: 0.5)),
                          const SizedBox(height: 24),
                          Text('No devices found', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: KgitonThemeColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the button below to scan',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _isScanning ? null : _startScanning,
                            icon: _isScanning
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                                  )
                                : const Icon(Icons.search),
                            label: Text(_isScanning ? 'Scanning...' : 'Scan Devices'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KgitonThemeColors.primaryGreen,
                              foregroundColor: KgitonThemeColors.backgroundDark,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _availableDevices.length,
                      itemBuilder: (context, index) {
                        final device = _availableDevices[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: KgitonThemeColors.cardBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: KgitonThemeColors.borderDefault, width: 1),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.scale, color: KgitonThemeColors.primaryGreen, size: 32),
                            title: Text(
                              device.name,
                              style: const TextStyle(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text('RSSI: ${device.rssi} dBm', style: const TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 12)),
                            trailing: ElevatedButton(
                              onPressed: () => _connectToDevice(device),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: KgitonThemeColors.primaryGreen,
                                foregroundColor: KgitonThemeColors.backgroundDark,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Connect'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
      floatingActionButton: _connectionState != ScaleConnectionState.authenticated && _availableDevices.isNotEmpty
          ? FloatingActionButton(
              onPressed: _isScanning ? null : _startScanning,
              backgroundColor: KgitonThemeColors.primaryGreen,
              child: _isScanning
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                  : const Icon(Icons.refresh, color: KgitonThemeColors.backgroundDark),
            )
          : null,
    );
  }

  IconData _getStatusIcon() {
    switch (_connectionState) {
      case ScaleConnectionState.disconnected:
        return Icons.bluetooth_disabled;
      case ScaleConnectionState.scanning:
        return Icons.bluetooth_searching;
      case ScaleConnectionState.connecting:
        return Icons.bluetooth_connected;
      case ScaleConnectionState.connected:
        return Icons.bluetooth_connected;
      case ScaleConnectionState.authenticated:
        return Icons.bluetooth_connected;
      case ScaleConnectionState.error:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor() {
    switch (_connectionState) {
      case ScaleConnectionState.disconnected:
        return KgitonThemeColors.textSecondary;
      case ScaleConnectionState.scanning:
        return KgitonThemeColors.warningYellow;
      case ScaleConnectionState.connecting:
        return KgitonThemeColors.warningYellow;
      case ScaleConnectionState.connected:
        return KgitonThemeColors.warningYellow;
      case ScaleConnectionState.authenticated:
        return KgitonThemeColors.successGreen;
      case ScaleConnectionState.error:
        return KgitonThemeColors.errorRed;
    }
  }

  String _getStatusText() {
    switch (_connectionState) {
      case ScaleConnectionState.disconnected:
        return 'Disconnected';
      case ScaleConnectionState.scanning:
        return 'Scanning...';
      case ScaleConnectionState.connecting:
        return 'Connecting...';
      case ScaleConnectionState.connected:
        return 'Connected';
      case ScaleConnectionState.authenticated:
        return 'Connected & Ready';
      case ScaleConnectionState.error:
        return 'Connection Error';
    }
  }
}

class _BuzzerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _BuzzerButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: KgitonThemeColors.cardBackground,
        foregroundColor: KgitonThemeColors.primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: KgitonThemeColors.primaryGreen, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
