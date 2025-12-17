/// App Configuration
///
/// Central configuration file for the KGiTON app.
/// Contains API endpoints, keys, and other app settings.
class AppConfig {
  // Prevent instantiation
  AppConfig._();

  /// API Configuration
  /// TODO: Update with actual API base URL and version
  static const String apiBaseUrl = 'https://api.example.com';
  static const String apiVersion = 'v1.0.0';

  /// App Information
  static const String appName = 'KGiTON Apps';
  static const String appVersion = '1.0.0';

  /// Timeout Configuration (in seconds)
  static const int apiTimeout = 30;
  static const int connectionTimeout = 15;

  /// Feature Flags
  static const bool enableDebugMode = true;
  static const bool enableLogging = true;

  /// Storage Keys
  static const String keyUser = 'CACHED_USER';
  static const String keyToken = 'CACHED_TOKEN';
  static const String keyIsAuthenticated = 'IS_AUTHENTICATED';
}
