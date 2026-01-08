/// ============================================================================
/// Home Page
/// ============================================================================
///
/// File: src/presentation/pages/home/home_page.dart
/// Deskripsi: Halaman home dengan user info dan license list
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/theme.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/scale/scale_bloc.dart';
import '../../bloc/scale/scale_event.dart';
import '../../bloc/scale/scale_state.dart';
import '../auth/auth_page.dart';
import '../device/device_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthPage()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('KGiTON Scale'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return _buildContent(context, state);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        floatingActionButton: _buildFAB(context),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return BlocBuilder<ScaleBloc, ScaleState>(
      builder: (context, state) {
        if (state is ScaleConnected) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => _navigateToDevicePage(context),
          icon: const Icon(Icons.bluetooth_searching),
          label: const Text('Scan Device'),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, AuthAuthenticated state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AuthBloc>().add(const LoadLicensesEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Info Card
            _buildUserCard(state),
            const SizedBox(height: 16),

            // Weight Card
            _buildWeightCard(context, state),
            const SizedBox(height: 16),

            // License Card
            _buildLicenseSummaryCard(context, state),
            const SizedBox(height: 16),

            // Device Control Card
            _buildDeviceControlCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightCard(BuildContext context, AuthAuthenticated authState) {
    return BlocBuilder<ScaleBloc, ScaleState>(
      builder: (context, state) {
        final isConnected = state is ScaleConnected;
        final double weight;
        final String deviceName;
        if (state is ScaleConnected) {
          weight = state.currentWeight;
          deviceName = state.device.name;
        } else {
          weight = 0.0;
          deviceName = '';
        }

        return Card(
          color: isConnected ? KGiTONColors.primary : null,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      color: isConnected ? Colors.white : KGiTONColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConnected ? 'Terhubung: $deviceName' : 'Tidak Terhubung',
                      style: TextStyle(
                        color: isConnected ? Colors.white : KGiTONColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '${weight.toStringAsFixed(2)} kg',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isConnected ? Colors.white : KGiTONColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                if (!isConnected)
                  OutlinedButton.icon(
                    onPressed: () => _navigateToDevicePage(context),
                    icon: const Icon(Icons.search),
                    label: const Text('Cari Device'),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () {
                      final licenseKey = authState.licenses.isNotEmpty ? authState.licenses.first.key : '';
                      context.read<ScaleBloc>().add(DisconnectDeviceEvent(licenseKey: licenseKey));
                    },
                    icon: const Icon(Icons.link_off, color: Colors.white),
                    label: const Text('Disconnect', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLicenseSummaryCard(BuildContext context, AuthAuthenticated state) {
    if (state.licenses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.warning_amber, size: 48, color: KGiTONColors.warning),
              const SizedBox(height: 8),
              const Text('Belum ada license key'),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code'),
                onPressed: () => _openQRScanner(context),
              ),
            ],
          ),
        ),
      );
    }

    final license = state.licenses.first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.vpn_key, color: KGiTONColors.primary),
                const SizedBox(width: 8),
                Text('License Key', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: license.isActive ? KGiTONColors.success.withValues(alpha: 0.2) : KGiTONColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    license.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: license.isActive ? KGiTONColors.success : KGiTONColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              license.key,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.token, size: 16, color: KGiTONColors.secondary),
                const SizedBox(width: 4),
                Text('Token Balance: ${license.tokenBalance}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceControlCard(BuildContext context) {
    return BlocBuilder<ScaleBloc, ScaleState>(
      builder: (context, state) {
        if (state is! ScaleConnected) return const SizedBox.shrink();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune, color: KGiTONColors.primary),
                    const SizedBox(width: 8),
                    Text('Device Control', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.read<ScaleBloc>().add(const TriggerBuzzerEvent()),
                      icon: const Icon(Icons.notifications_active, size: 18),
                      label: const Text('BEEP'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(AuthAuthenticated state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: KGiTONColors.primary,
              child: Text(
                state.user.name.isNotEmpty ? state.user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.user.email,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: KGiTONColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      state.user.role,
                      style: const TextStyle(
                        fontSize: 12,
                        color: KGiTONColors.primary,
                      ),
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

  void _navigateToDevicePage(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String? licenseKey;
    if (authState is AuthAuthenticated && authState.licenses.isNotEmpty) {
      licenseKey = authState.licenses.first.key;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DevicePage(licenseKey: licenseKey ?? ''),
      ),
    );
  }

  void _openQRScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _QRScannerPage(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: KGiTONColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

/// QR Scanner Page - Menggunakan mobile_scanner
class _QRScannerPage extends StatefulWidget {
  const _QRScannerPage();

  @override
  State<_QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<_QRScannerPage> {
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan License QR'),
      ),
      body: Stack(
        children: [
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
    // Navigate ke device page dengan license key dari QR
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DevicePage(licenseKey: data),
      ),
    );
  }
}
