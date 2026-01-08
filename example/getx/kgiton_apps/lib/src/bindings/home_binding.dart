/// Home Binding

import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/scale_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    // ScaleController permanent agar state tetap saat navigasi
    if (!Get.isRegistered<ScaleController>()) {
      Get.put(ScaleController(), permanent: true);
    }
  }
}
