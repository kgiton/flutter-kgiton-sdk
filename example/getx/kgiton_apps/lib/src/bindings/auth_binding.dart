/// Auth Binding

import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // AuthController sudah di-register di InitialBinding
    // Ini hanya memastikan controller tersedia
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
  }
}
