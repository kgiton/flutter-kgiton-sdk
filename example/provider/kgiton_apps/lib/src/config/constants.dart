/// ============================================================================
/// API Configuration Constants
/// ============================================================================
///
/// File: src/config/constants.dart
/// Deskripsi: Konstanta konfigurasi API dan aplikasi
/// ============================================================================

class AppConstants {
  AppConstants._();

  // =========================================================================
  // API Configuration
  // =========================================================================

  /// Base URL untuk API KGiTON
  /// Ganti dengan URL production Anda
  static const String apiBaseUrl = 'https://api.kgiton.com';

  /// Sandbox URL untuk testing
  static const String apiSandboxUrl = 'https://sandbox-api.kgiton.com';

  // =========================================================================
  // App Configuration
  // =========================================================================

  /// Nama aplikasi
  static const String appName = 'KGiTON Scale';

  /// Versi aplikasi
  static const String appVersion = '1.0.0';

  // =========================================================================
  // Timeouts
  // =========================================================================

  /// Connection timeout dalam detik
  static const int connectionTimeout = 30;

  /// BLE scan timeout dalam detik
  static const int bleScanTimeout = 10;

  // =========================================================================
  // Storage Keys
  // =========================================================================

  /// Key untuk menyimpan access token
  static const String tokenKey = 'kgiton_access_token';

  /// Key untuk menyimpan API key
  static const String apiKeyKey = 'kgiton_api_key';

  /// Key untuk menyimpan user data
  static const String userDataKey = 'kgiton_user_data';

  /// Key untuk menyimpan license key yang terhubung
  static const String connectedLicenseKey = 'kgiton_connected_license';
}
