/// Base exception untuk KGiTON SDK
abstract class KGiTONException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  KGiTONException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'KGiTONException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception untuk error koneksi BLE
class BLEConnectionException extends KGiTONException {
  BLEConnectionException(String message, {String? code, dynamic originalError}) : super(message, code: code, originalError: originalError);
}

/// Exception untuk error autentikasi
class AuthenticationException extends KGiTONException {
  AuthenticationException(String message, {String? code, dynamic originalError}) : super(message, code: code, originalError: originalError);
}

/// Exception untuk error device tidak ditemukan
class DeviceNotFoundException extends KGiTONException {
  DeviceNotFoundException(String message, {String? code, dynamic originalError}) : super(message, code: code, originalError: originalError);
}

/// Exception untuk error timeout
class TimeoutException extends KGiTONException {
  TimeoutException(String message, {String? code, dynamic originalError}) : super(message, code: code, originalError: originalError);
}

/// Exception untuk error license key
class LicenseKeyException extends KGiTONException {
  LicenseKeyException(String message, {String? code, dynamic originalError}) : super(message, code: code, originalError: originalError);
}
