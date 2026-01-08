/// ============================================================================
/// Home View - GetX UI
/// ============================================================================
///
/// File: src/views/home/home_view.dart
/// Deskripsi: Home screen dengan user info dan license list
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final homeController = Get.find<HomeController>();

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
