import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// Helper class untuk menangani BLE permissions di berbagai versi Android dan iOS
class PermissionHelper {
  /// Request semua BLE permissions yang diperlukan
  ///
  /// Returns true jika semua permissions granted
  static Future<bool> requestBLEPermissions() async {
    if (Platform.isAndroid) {
      return _requestAndroidBLEPermissions();
    } else if (Platform.isIOS) {
      return _requestIOSBLEPermissions();
    }
    return false;
  }

  /// Request BLE permissions untuk Android dengan handling berbagai versi
  static Future<bool> _requestAndroidBLEPermissions() async {
    try {
      final androidVersion = await _getAndroidVersion();

      Map<Permission, PermissionStatus> statuses;

      if (androidVersion >= 31) {
        // Android 12+ (API 31+)
        statuses = await [Permission.bluetoothScan, Permission.bluetoothConnect].request();

        final allGranted = statuses.values.every((status) => status.isGranted);
        return allGranted;
      } else if (androidVersion >= 29) {
        // Android 10-11 (API 29-30) - CRITICAL: Memerlukan FINE_LOCATION
        // NOTE: Permission.bluetooth tidak tersedia di permission_handler untuk Android < 12
        // Bluetooth permissions (BLUETOOTH, BLUETOOTH_ADMIN) di-granted otomatis via manifest
        statuses = await [Permission.location].request();

        // Check if location service is enabled
        final locationServiceEnabled = await Permission.location.serviceStatus.isEnabled;
        if (!locationServiceEnabled) {
          return false;
        }

        final allGranted = statuses.values.every((status) => status.isGranted);
        return allGranted && locationServiceEnabled;
      } else {
        // Android 9 and below (API 28-)
        statuses = await [Permission.location].request();

        final allGranted = statuses.values.every((status) => status.isGranted);
        return allGranted;
      }
    } catch (e) {
      return false;
    }
  }

  /// Request BLE permissions untuk iOS
  static Future<bool> _requestIOSBLEPermissions() async {
    try {
      final status = await Permission.bluetooth.request();
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Check apakah semua BLE permissions sudah granted
  static Future<bool> checkBLEPermissions() async {
    if (Platform.isAndroid) {
      return _checkAndroidBLEPermissions();
    } else if (Platform.isIOS) {
      return _checkIOSBLEPermissions();
    }
    return false;
  }

  /// Check BLE permissions untuk Android
  static Future<bool> _checkAndroidBLEPermissions() async {
    try {
      final androidVersion = await _getAndroidVersion();

      if (androidVersion >= 31) {
        // Android 12+ (API 31+)
        final hasScan = await Permission.bluetoothScan.isGranted;
        final hasConnect = await Permission.bluetoothConnect.isGranted;
        return hasScan && hasConnect;
      } else if (androidVersion >= 29) {
        // Android 10-11 (API 29-30) - Memerlukan location
        // NOTE: Permission.bluetooth tidak tersedia, Bluetooth permissions granted otomatis via manifest
        final hasLocation = await Permission.location.isGranted;
        final locationServiceEnabled = await Permission.location.serviceStatus.isEnabled;
        return hasLocation && locationServiceEnabled;
      } else {
        // Android 9 and below (API 28-)
        // NOTE: Permission.bluetooth tidak tersedia, Bluetooth permissions granted otomatis via manifest
        final hasLocation = await Permission.location.isGranted;
        return hasLocation;
      }
    } catch (e) {
      return false;
    }
  }

  /// Check BLE permissions untuk iOS
  static Future<bool> _checkIOSBLEPermissions() async {
    try {
      return await Permission.bluetooth.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Get Android SDK version
  ///
  /// Returns:
  /// - 33: Android 13
  /// - 31: Android 12
  /// - 30: Android 11
  /// - 29: Android 10
  /// - 28: Android 9
  static Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      // Coba detect dari permission availability - Android 12+ memiliki bluetoothScan
      final scanStatus = await Permission.bluetoothScan.status;
      // Jika status bukan restricted/limited, berarti API 31+
      if (scanStatus != PermissionStatus.restricted && scanStatus != PermissionStatus.limited) {
        return 31; // Android 12+
      }
    } catch (e) {
      // If bluetoothScan throws error, it means API < 31
    }

    // Default ke Android 10 untuk testing purposes
    // Pada production, bisa gunakan platform channel untuk get exact API level
    return 29;
  }

  /// Check apakah location service aktif (untuk Android 10-11)
  static Future<bool> isLocationServiceEnabled() async {
    if (!Platform.isAndroid) return true;

    try {
      return await Permission.location.serviceStatus.isEnabled;
    } catch (e) {
      return false;
    }
  }

  /// Get permission status dengan info detail
  static Future<Map<String, dynamic>> getPermissionStatus() async {
    final result = <String, dynamic>{'platform': Platform.isAndroid ? 'android' : 'ios', 'allGranted': false};

    if (Platform.isAndroid) {
      final androidVersion = await _getAndroidVersion();
      result['androidVersion'] = androidVersion;

      if (androidVersion >= 31) {
        result['bluetoothScan'] = (await Permission.bluetoothScan.status).toString();
        result['bluetoothConnect'] = (await Permission.bluetoothConnect.status).toString();
      } else {
        // Permission.bluetooth tidak tersedia untuk Android < 12
        result['location'] = (await Permission.location.status).toString();
        result['locationServiceEnabled'] = await isLocationServiceEnabled();
      }

      result['allGranted'] = await checkBLEPermissions();
    } else if (Platform.isIOS) {
      result['bluetooth'] = (await Permission.bluetooth.status).toString();
      result['allGranted'] = await checkBLEPermissions();
    }

    return result;
  }

  /// Get pesan error yang jelas untuk user berdasarkan status permissions
  static Future<String> getPermissionErrorMessage() async {
    if (Platform.isAndroid) {
      final androidVersion = await _getAndroidVersion();

      if (androidVersion >= 31) {
        // Android 12+
        final hasScan = await Permission.bluetoothScan.isGranted;
        final hasConnect = await Permission.bluetoothConnect.isGranted;

        if (!hasScan || !hasConnect) {
          return 'Aplikasi memerlukan izin Bluetooth untuk scan dan koneksi perangkat. '
              'Silakan berikan izin di Settings.';
        }
      } else if (androidVersion >= 29) {
        // Android 10-11
        final hasLocation = await Permission.location.isGranted;
        final locationServiceEnabled = await isLocationServiceEnabled();

        if (!hasLocation) {
          return 'Aplikasi memerlukan izin Lokasi untuk scan perangkat Bluetooth pada Android 10/11. '
              'Silakan berikan izin di Settings.';
        }
        if (!locationServiceEnabled) {
          return 'Layanan Lokasi harus diaktifkan untuk scan perangkat Bluetooth pada Android 10/11. '
              'Silakan aktifkan Lokasi di Settings perangkat Anda.';
        }
      }
    } else if (Platform.isIOS) {
      final hasBluetooth = await Permission.bluetooth.isGranted;
      if (!hasBluetooth) {
        return 'Aplikasi memerlukan izin Bluetooth. Silakan berikan izin di Settings.';
      }
    }

    return 'Izin diperlukan untuk menggunakan fitur ini.';
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
