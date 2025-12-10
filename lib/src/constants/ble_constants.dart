/// BLE Constants untuk KGiTON Scale
///
/// UUID dan konfigurasi yang sesuai dengan firmware ESP32
class BLEConstants {
  BLEConstants._();

  // Device Configuration
  static const String deviceName = "KGiTON";

  // Service UUID
  static const String serviceUUID = "12345678-1234-1234-1234-123456789abc";

  // Characteristic UUIDs
  static const String txCharacteristicUUID = "abcd1234-1234-1234-1234-123456789abc"; // Data berat
  static const String controlCharacteristicUUID = "abcd0002-1234-1234-1234-123456789abc"; // Kontrol koneksi
  static const String buzzerCharacteristicUUID = "abcd9999-1234-1234-1234-123456789abc"; // Kontrol buzzer

  // Timeouts
  static const Duration scanTimeout = Duration(seconds: 5);
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration commandTimeout = Duration(seconds: 2);

  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
}
