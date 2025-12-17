import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kgiton_apps/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../auth/presentation/pages/qr_scanner_page.dart';

/// Scale connection page - required connection before accessing home
class ScaleConnectionPage extends StatefulWidget {
  const ScaleConnectionPage({super.key});

  @override
  State<ScaleConnectionPage> createState() => _ScaleConnectionPageState();
}

class _ScaleConnectionPageState extends State<ScaleConnectionPage> {
  late final KGiTONScaleService _scaleService;

  ScaleConnectionState _connectionState = ScaleConnectionState.disconnected;
  List<ScaleDevice> _availableDevices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scaleService = sl<KGiTONScaleService>();
    _initializeScale();
    // Disconnect existing connection after initializing listeners
    Future.microtask(() => _disconnectExistingConnection());
  }

  /// Disconnect any existing connection when returning to this page
  Future<void> _disconnectExistingConnection() async {
    debugPrint('=== SCALE CONNECTION: Checking for existing connection ===');
    debugPrint('=== SCALE CONNECTION: Current connection state: $_connectionState ===');

    // Check if currently connected
    if (_connectionState == ScaleConnectionState.authenticated || _connectionState == ScaleConnectionState.connected) {
      debugPrint('=== SCALE CONNECTION: Existing connection found, disconnecting... ===');

      try {
        // Disconnect from device
        await _scaleService.disconnect();
        debugPrint('=== SCALE CONNECTION: Device disconnected successfully ===');

        // Clear cached license key
        await sl<AuthLocalDataSource>().clearCachedLicenseKey();
        debugPrint('=== SCALE CONNECTION: License key cleared from cache ===');
      } catch (e) {
        debugPrint('=== SCALE CONNECTION: Error during disconnect: $e ===');
      }
    } else {
      debugPrint('=== SCALE CONNECTION: No existing connection found ===');
    }
  }

  @override
  void dispose() {
    // Don't dispose singleton service
    super.dispose();
  }

  void _initializeScale() {
    // Listen to connection state
    _scaleService.connectionStateStream.listen((state) {
      if (!mounted) return;

      setState(() {
        _connectionState = state;
      });

      // Redirect to home when authenticated
      if (state == ScaleConnectionState.authenticated) {
        if (mounted) {
          debugPrint('Device authenticated, navigating to home');
          // Show success message and navigate immediately
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connected successfully!'), backgroundColor: KgitonThemeColors.successGreen, duration: Duration(seconds: 1)),
          );

          // Navigate to home immediately
          context.go('/home');
        }
      }
    });

    // Listen to available devices
    _scaleService.devicesStream.listen((devices) {
      if (!mounted) return;

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
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: KgitonThemeColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await PermissionHelper.openAppSettings();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              } catch (e) {
                debugPrint('Error opening app settings: $e');
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              }
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
      debugPrint('=== SCALE CONNECTION: Saving license key before connection ===');
      // Save license key FIRST, before connecting
      await sl<AuthLocalDataSource>().cacheLicenseKey(licenseKey);
      debugPrint('=== SCALE CONNECTION: License key saved: $licenseKey ===');

      // Verify it was saved
      final savedKey = await sl<AuthLocalDataSource>().getCachedLicenseKey();
      debugPrint('=== SCALE CONNECTION: Verify saved license key: $savedKey ===');

      if (savedKey == null || savedKey.isEmpty) {
        debugPrint('=== SCALE CONNECTION: ERROR - License key was not saved properly! ===');
      } else {
        debugPrint('=== SCALE CONNECTION: SUCCESS - License key saved and verified! ===');
      }

      // Now connect to device (SDK expects formatted key with dashes)
      // Note: Ownership verification akan otomatis dilakukan jika user sudah login
      debugPrint('=== SCALE CONNECTION: Connecting to device with license key... ===');
      final response = await _scaleService.connectWithLicenseKey(deviceId: device.id, licenseKey: licenseKey);

      if (mounted) {
        if (response.success) {
          debugPrint('=== SCALE CONNECTION: Connection successful! ===');
          // Success message will be shown by connection state listener
          // which will also redirect to home
        } else {
          debugPrint('=== SCALE CONNECTION: Connection failed: ${response.message} ===');

          // Check if this is an ownership verification error
          if (response.message.contains('pemilik sah')) {
            // Ownership verification failed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '🔒 Akses Ditolak\n${response.message}\n\nSilakan gunakan license key yang terdaftar atas nama Anda.',
                  style: const TextStyle(fontSize: 13),
                ),
                backgroundColor: KgitonThemeColors.errorRed,
                duration: const Duration(seconds: 5),
              ),
            );
          } else {
            // Other connection errors
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Connection failed: ${response.message}'), backgroundColor: KgitonThemeColors.errorRed));
          }
        }
      }
    } catch (e) {
      debugPrint('Connection exception: $e');
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // Navigate back to login when logged out
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: KgitonThemeColors.backgroundDark,
        appBar: AppBar(
          title: const Text('Connect to Scale'),
          backgroundColor: KgitonThemeColors.cardBackground,
          foregroundColor: KgitonThemeColors.textPrimary,
          automaticallyImplyLeading: false, // Remove back button
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout and Exit',
              onPressed: () {
                context.read<AuthBloc>().add(const LogoutRequested());
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: KgitonThemeColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.3), width: 2),
              ),
              child: Column(
                children: [
                  Icon(Icons.scale, size: 64, color: KgitonThemeColors.primaryGreen),
                  const SizedBox(height: 16),
                  Text(
                    'Setup Required',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please connect to a scale device to continue',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary),
                  ),
                ],
              ),
            ),

            // Connection Status
            if (_connectionState != ScaleConnectionState.disconnected)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KgitonThemeColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor(), width: 2),
                ),
                child: Row(
                  children: [
                    Icon(_getStatusIcon(), color: _getStatusColor(), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (_connectionState == ScaleConnectionState.connecting || _connectionState == ScaleConnectionState.connected)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(KgitonThemeColors.primaryGreen)),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Device List or Empty State
            Expanded(
              child: _availableDevices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bluetooth_searching, size: 100, color: KgitonThemeColors.textSecondary.withValues(alpha: 0.5)),
                          const SizedBox(height: 24),
                          Text('No devices found', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: KgitonThemeColors.textSecondary)),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Make sure your scale is powered on and Bluetooth is enabled',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary),
                            ),
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
                                : const Icon(Icons.search, size: 24),
                            label: Text(
                              _isScanning ? 'Scanning...' : 'Scan for Devices',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KgitonThemeColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Available Devices',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
                              ),
                              TextButton.icon(
                                onPressed: _isScanning ? null : _startScanning,
                                icon: _isScanning
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(KgitonThemeColors.primaryGreen),
                                        ),
                                      )
                                    : const Icon(Icons.refresh, size: 20),
                                label: Text(_isScanning ? 'Scanning...' : 'Refresh'),
                                style: TextButton.styleFrom(foregroundColor: KgitonThemeColors.primaryGreen),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _availableDevices.length,
                            itemBuilder: (context, index) {
                              final device = _availableDevices[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: KgitonThemeColors.cardBackground,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: KgitonThemeColors.borderDefault, width: 1),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.scale, color: KgitonThemeColors.primaryGreen, size: 32),
                                  ),
                                  title: Text(
                                    device.name,
                                    style: const TextStyle(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.signal_cellular_alt, size: 14, color: _getSignalColor(device.rssi)),
                                        const SizedBox(width: 4),
                                        Text('Signal: ${device.rssi} dBm', style: TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () => _connectToDevice(device),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: KgitonThemeColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Connect', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
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
        return Icons.check_circle;
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
        return 'Not Connected';
      case ScaleConnectionState.scanning:
        return 'Scanning for devices...';
      case ScaleConnectionState.connecting:
        return 'Connecting to device...';
      case ScaleConnectionState.connected:
        return 'Authenticating...';
      case ScaleConnectionState.authenticated:
        return 'Connection successful!';
      case ScaleConnectionState.error:
        return 'Connection failed';
    }
  }

  Color _getSignalColor(int rssi) {
    if (rssi >= -60) {
      return KgitonThemeColors.successGreen;
    } else if (rssi >= -80) {
      return KgitonThemeColors.warningYellow;
    } else {
      return KgitonThemeColors.errorRed;
    }
  }
}
