/// ============================================================================
/// KGiTON Example App - GetX State Management
/// ============================================================================
/// 
/// File: main.dart
/// Deskripsi: Entry point aplikasi menggunakan GetX
/// 
/// GetX Features yang digunakan:
/// 1. State Management (GetxController, Obx)
/// 2. Route Management (GetMaterialApp, Get.to)
/// 3. Dependency Injection (Get.put, Get.find)
/// 4. Reactive Programming (.obs, Obx)
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

import 'src/config/theme.dart';
import 'src/config/routes.dart';
import 'src/bindings/initial_binding.dart';

/// Entry point aplikasi
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage untuk local storage
  await GetStorage.init();
  
  // Initialize KGiTON SDK
  final apiService = KgitonApiService(baseUrl: 'https://api.kgiton.com');
  final scaleService = KGiTONScaleService();
  
  // Register SDK services sebagai singleton
  Get.put(apiService, permanent: true);
  Get.put(scaleService, permanent: true);
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const KGiTONApp());
}

/// Root widget aplikasi menggunakan GetMaterialApp
/// 
/// GetMaterialApp menyediakan:
/// - Navigation tanpa context (Get.to, Get.back)
/// - Named routes dengan arguments
/// - Binding untuk lazy loading controller
class KGiTONApp extends StatelessWidget {
  const KGiTONApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KGiTON Scale',
      debugShowCheckedModeBanner: false,
      
      // ====================================================================
      // Theme
      // ====================================================================
      theme: KGiTONTheme.lightTheme,
      darkTheme: KGiTONTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // ====================================================================
      // Initial Binding
      // Inject dependencies yang dibutuhkan saat app start
      // ====================================================================
      initialBinding: InitialBinding(),
      
      // ====================================================================
      // Routes
      // Named routes dengan binding masing-masing
      // ====================================================================
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      
      // ====================================================================
      // Default Transition
      // ====================================================================
      defaultTransition: Transition.cupertino,
    );
  }
}
