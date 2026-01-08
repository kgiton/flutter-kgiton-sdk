/// ============================================================================
/// App Routes - GetX Navigation
/// ============================================================================
/// 
/// File: src/config/routes.dart
/// Deskripsi: Konfigurasi named routes dengan GetX
/// 
/// Keuntungan GetX Routes:
/// 1. Named navigation tanpa context
/// 2. Passing arguments dengan type safety
/// 3. Lazy binding per route
/// ============================================================================

import 'package:get/get.dart';

import '../bindings/auth_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/device_binding.dart';
import '../views/splash_view.dart';
import '../views/auth/auth_view.dart';
import '../views/home/home_view.dart';
import '../views/device/device_view.dart';
import '../views/qr_scanner/qr_scanner_view.dart';

/// Route names
abstract class AppRoutes {
  static const splash = '/splash';
  static const auth = '/auth';
  static const home = '/home';
  static const device = '/device';
  static const qrScanner = '/qr-scanner';
  
  /// Daftar semua routes
  static final routes = [
    // =========================================================================
    // Splash Screen
    // Tidak perlu binding karena menggunakan controller dari InitialBinding
    // =========================================================================
    GetPage(
      name: splash,
      page: () => const SplashView(),
    ),
    
    // =========================================================================
    // Auth Screen (Login/Register)
    // AuthBinding akan inject AuthController
    // =========================================================================
    GetPage(
      name: auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    
    // =========================================================================
    // Home Screen
    // HomeBinding akan inject HomeController
    // =========================================================================
    GetPage(
      name: home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    
    // =========================================================================
    // Device Screen (Scan & Connect)
    // DeviceBinding akan inject ScaleController
    // =========================================================================
    GetPage(
      name: device,
      page: () => const DeviceView(),
      binding: DeviceBinding(),
    ),
    
    // =========================================================================
    // QR Scanner
    // =========================================================================
    GetPage(
      name: qrScanner,
      page: () => const QRScannerView(),
    ),
  ];
}
