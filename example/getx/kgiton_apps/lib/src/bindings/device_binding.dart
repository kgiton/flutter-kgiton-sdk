/// Device Binding

import 'package:get/get.dart';
import '../controllers/scale_controller.dart';

class DeviceBinding extends Bindings {
  @override
  void dependencies() {
    // ScaleController sudah di-register permanent di HomeBinding
    // Jika belum ada, buat baru
    if (!Get.isRegistered<ScaleController>()) {
      Get.put(ScaleController(), permanent: true);
    }
  }
}
