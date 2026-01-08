/// ============================================================================
/// Initial Binding
/// ============================================================================
/// 
/// File: src/bindings/initial_binding.dart
/// Deskripsi: Binding yang dijalankan saat app pertama kali start
/// 
/// Binding digunakan untuk:
/// - Lazy loading controller
/// - Memisahkan dependency creation dari view
/// ============================================================================

import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

/// Initial Binding
/// 
/// Dijalankan saat app start, sebelum build widget tree.
/// Inject controller yang dibutuhkan secara global.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // =========================================================================
    // AuthController - Global controller untuk authentication
    // Menggunakan permanent: true agar tidak di-dispose
    // =========================================================================
    Get.put<AuthController>(
      AuthController(),
      permanent: true,
    );
  }
}
