/// ============================================================================
/// Home Page
/// ============================================================================
///
/// File: src/presentation/pages/home/home_page.dart
/// Deskripsi: Halaman home dengan user info dan license list
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/theme.dart';
import '../../../domain/entities/license_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
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
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthAuthenticated state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AuthBloc>().add(const LoadLicensesEvent());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Card
          _buildUserCard(state),
          const SizedBox(height: 24),

          // Licenses Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'License Keys',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR'),
                onPressed: () => _openQRScanner(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // License List
          if (state.licenses.isEmpty) _buildEmptyLicenses() else ...state.licenses.map((l) => _buildLicenseCard(context, l)),
        ],
      ),
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

  Widget _buildEmptyLicenses() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.key_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada license key',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan QR code untuk menambahkan license',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseCard(BuildContext context, LicenseEntity license) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: license.isActive ? KGiTONColors.success.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.vpn_key,
            color: license.isActive ? KGiTONColors.success : Colors.grey,
          ),
        ),
        title: Text(
          license.key,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          license.deviceName ?? 'No device assigned',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: license.isActive
            ? ElevatedButton(
                onPressed: () => _navigateToDevice(context, license),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Connect'),
              )
            : const Chip(
                label: Text('Inactive'),
                backgroundColor: Colors.grey,
                labelStyle: TextStyle(color: Colors.white, fontSize: 12),
              ),
      ),
    );
  }

  void _navigateToDevice(BuildContext context, LicenseEntity license) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DevicePage(licenseKey: license.key),
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

    // Navigate ke device page dengan license key dari QR
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DevicePage(licenseKey: data),
      ),
    );
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }
}
