/// ============================================================================
/// Home Controller
/// ============================================================================
/// 
/// File: src/controllers/home_controller.dart
/// Deskripsi: Controller untuk home screen
/// ============================================================================

import 'package:get/get.dart';
import 'auth_controller.dart';

class HomeController extends GetxController {
  // =========================================================================
  // Dependencies
  // =========================================================================
  late final AuthController _authController;
  
  // =========================================================================
  // Lifecycle
  // =========================================================================
  
  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
    _refreshLicenses();
  }
  
  // =========================================================================
  // Methods
  // =========================================================================
  
  Future<void> _refreshLicenses() async {
    await _authController.loadLicenses();
  }
  
  Future<void> onRefresh() async {
    await _authController.loadLicenses();
  }
}
