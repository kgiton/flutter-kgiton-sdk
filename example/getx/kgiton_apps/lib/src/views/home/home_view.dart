/// ============================================================================
/// Home View - GetX UI
/// ============================================================================
///
/// File: src/views/home/home_view.dart
/// Deskripsi: Home screen dengan user info, weight display, dan license list
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/scale_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final homeController = Get.find<HomeController>();
    final scaleController = Get.find<ScaleController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('KGiTON Scale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(authController),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: homeController.onRefresh,
        child: Obx(() => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // User Info Card
                _buildUserCard(authController),
                const SizedBox(height: 16),

                // Weight Display Card
                _buildWeightCard(scaleController, authController),
                const SizedBox(height: 16),

                // Device Control Card (jika connected)
                _buildDeviceControlCard(scaleController),
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
                      onPressed: () => Get.toNamed(AppRoutes.qrScanner),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // License List
                if (authController.licenses.isEmpty) _buildEmptyLicenses() else ...authController.licenses.map((l) => _buildLicenseCard(l)),
              ],
            )),
      ),
      floatingActionButton: _buildFAB(scaleController),
    );
  }

  Widget _buildUserCard(AuthController controller) {
    return Obx(() => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: KGiTONColors.primary,
                  child: Text(
                    controller.user.value?.name.isNotEmpty == true ? controller.user.value!.name[0].toUpperCase() : 'U',
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
                        controller.user.value?.name ?? 'User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.user.value?.email ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (controller.user.value != null) ...[
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
                            controller.user.value!.role,
                            style: const TextStyle(
                              fontSize: 12,
                              color: KGiTONColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
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

  Widget _buildLicenseCard(LicenseKey license) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: license.isActive == true ? KGiTONColors.success.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.vpn_key,
            color: license.isActive == true ? KGiTONColors.success : Colors.grey,
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
                onPressed: () => _navigateToDevice(license.key),
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

  /// Weight display card
  Widget _buildWeightCard(ScaleController scaleController, AuthController authController) {
    return Obx(() {
      final isConnected = scaleController.isConnected.value;

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
                    color: isConnected ? Colors.white : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'Terhubung: ${scaleController.connectedDevice.value?.name ?? "Device"}' : 'Tidak Terhubung',
                    style: TextStyle(
                      color: isConnected ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Weight display
              Text(
                isConnected ? scaleController.currentWeight.value.toStringAsFixed(2) : '0.00',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isConnected ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                'kg',
                style: TextStyle(
                  fontSize: 18,
                  color: isConnected ? Colors.white70 : Colors.grey,
                ),
              ),

              const SizedBox(height: 16),

              // Connect/Disconnect button
              if (!isConnected)
                OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.device),
                  icon: const Icon(Icons.search),
                  label: const Text('Cari Device'),
                )
              else
                OutlinedButton.icon(
                  onPressed: () => scaleController.disconnectDevice(),
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
    });
  }

  /// Device control card
  Widget _buildDeviceControlCard(ScaleController scaleController) {
    return Obx(() {
      if (!scaleController.isConnected.value) {
        return const SizedBox.shrink();
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune, color: KGiTONColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Device Control',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: scaleController.triggerBuzzer,
                    icon: const Icon(Icons.notifications_active, size: 18),
                    label: const Text('BEEP'),
                  ),
                  OutlinedButton.icon(
                    onPressed: scaleController.triggerBuzzer,
                    icon: const Icon(Icons.vibration, size: 18),
                    label: const Text('BUZZ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Build FAB untuk scan device
  Widget _buildFAB(ScaleController scaleController) {
    return Obx(() {
      if (scaleController.isConnected.value) {
        return const SizedBox.shrink();
      }

      return FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.device),
        icon: const Icon(Icons.bluetooth_searching),
        label: const Text('Scan Device'),
      );
    });
  }

  void _navigateToDevice(String licenseKey) {
    Get.toNamed(
      AppRoutes.device,
      arguments: {'licenseKey': licenseKey},
    );
  }

  void _showLogoutDialog(AuthController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
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
