/// Device Binding

import 'package:get/get.dart';
import '../controllers/scale_controller.dart';

class DeviceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ScaleController());
  }
}
