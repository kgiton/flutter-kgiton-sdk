/// ============================================================================
/// Home Screen - Dashboard Utama
/// ============================================================================
/// 
/// File: src/screens/home/home_screen.dart
/// Deskripsi: Dashboard utama setelah login
/// 
/// Fitur:
/// - Menampilkan status koneksi device
/// - Menampilkan berat realtime jika terhubung
/// - Navigation ke scan device
/// - Profile dan logout
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/scale_provider.dart';
import '../../config/theme.dart';
import '../auth/auth_screen.dart';
import '../device/device_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: _buildFAB(context),
    );
  }
  
  /// Build app bar dengan user info dan logout
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('KGiTON Scale'),
      actions: [
        // User menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle),
          onSelected: (value) async {
            if (value == 'logout') {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              }
            }
          },
          itemBuilder: (context) {
            final user = context.read<AuthProvider>().user;
            return [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: KGiTONColors.error),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }
  
  /// Build main body
  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AuthProvider>().refreshUserData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================================================================
            // Welcome Card
            // ================================================================
            _buildWelcomeCard(context),
            
            const SizedBox(height: 16),
            
            // ================================================================
            // Weight Display Card
            // Consumer digunakan untuk listen perubahan weight data
            // ================================================================
            _buildWeightCard(context),
            
            const SizedBox(height: 16),
            
            // ================================================================
            // License Info Card
            // ================================================================
            _buildLicenseCard(context),
            
            const SizedBox(height: 16),
            
            // ================================================================
            // Device Control Card (jika connected)
            // ================================================================
            _buildDeviceControlCard(context),
          ],
        ),
      ),
    );
  }
  
  /// Welcome card dengan user info
  Widget _buildWelcomeCard(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: KGiTONColors.primary,
                  child: Text(
                    authProvider.user?.name.isNotEmpty == true
                      ? authProvider.user!.name[0].toUpperCase()
                      : 'U',
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
                        'Selamat Datang,',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        authProvider.user?.name ?? 'User',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Weight display card
  Widget _buildWeightCard(BuildContext context) {
    return Consumer<ScaleProvider>(
      builder: (context, scaleProvider, child) {
        final isConnected = scaleProvider.isConnected;
        
        return Card(
          color: isConnected ? KGiTONColors.primary : null,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Connection status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      color: isConnected ? Colors.white : KGiTONColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConnected 
                        ? 'Terhubung: ${scaleProvider.connectedDevice?.name ?? "Device"}'
                        : 'Tidak Terhubung',
                      style: TextStyle(
                        color: isConnected ? Colors.white : KGiTONColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Weight display
                Text(
                  scaleProvider.weightDisplay,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isConnected ? Colors.white : KGiTONColors.textPrimaryLight,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Connect/Disconnect button
                if (!isConnected)
                  OutlinedButton.icon(
                    onPressed: () => _navigateToDeviceScreen(context),
                    icon: const Icon(Icons.search),
                    label: const Text('Cari Device'),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () async {
                      final licenseKey = context.read<AuthProvider>().primaryLicenseKey;
                      await scaleProvider.disconnect(licenseKey: licenseKey);
                    },
                    icon: const Icon(Icons.link_off, color: Colors.white),
                    label: const Text('Disconnect', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// License info card
  Widget _buildLicenseCard(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final licenses = authProvider.licenses;
        
        if (licenses.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    size: 48,
                    color: KGiTONColors.warning,
                  ),
                  const SizedBox(height: 8),
                  const Text('Belum ada license key'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to license purchase
                    },
                    child: const Text('Beli License Key'),
                  ),
                ],
              ),
            ),
          );
        }
        
        final license = licenses.first;
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
                    Text(
                      'License Key',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: license.isActive 
                          ? KGiTONColors.success.withValues(alpha: 0.2)
                          : KGiTONColors.warning.withValues(alpha: 0.2),
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
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.token, size: 16, color: KGiTONColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      'Token Balance: ${license.tokenBalance}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (license.deviceName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.devices, size: 16, color: KGiTONColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        'Device: ${license.deviceName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Device control card
  Widget _buildDeviceControlCard(BuildContext context) {
    return Consumer<ScaleProvider>(
      builder: (context, scaleProvider, child) {
        if (!scaleProvider.isAuthenticated) {
          return const SizedBox.shrink();
        }
        
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
                    Text(
                      'Device Control',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBuzzerButton(context, 'BEEP', Icons.notifications_active),
                    _buildBuzzerButton(context, 'BUZZ', Icons.vibration),
                    _buildBuzzerButton(context, 'LONG', Icons.timer),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Build buzzer control button
  Widget _buildBuzzerButton(BuildContext context, String command, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () async {
        await context.read<ScaleProvider>().triggerBuzzer(command);
      },
      icon: Icon(icon, size: 18),
      label: Text(command),
    );
  }
  
  /// Build FAB untuk scan device
  Widget _buildFAB(BuildContext context) {
    return Consumer<ScaleProvider>(
      builder: (context, scaleProvider, child) {
        if (scaleProvider.isConnected) {
          return const SizedBox.shrink();
        }
        
        return FloatingActionButton.extended(
          onPressed: () => _navigateToDeviceScreen(context),
          icon: const Icon(Icons.bluetooth_searching),
          label: const Text('Scan Device'),
        );
      },
    );
  }
  
  /// Navigate to device screen
  void _navigateToDeviceScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeviceScreen()),
    );
  }
}
