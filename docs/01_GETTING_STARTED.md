# 🚀 Getting Started (Client Edition)

Panduan lengkap untuk memulai menggunakan KGiTON Flutter SDK.

---

## 📋 Prerequisites

Sebelum memulai, pastikan Anda memiliki:

- ✅ Flutter SDK 3.0.0 atau lebih baru
- ✅ Dart SDK 3.0.0 atau lebih baru
- ✅ License key KGiTON (hubungi support@kgiton.com)
- ✅ Akun terdaftar di KGiTON

---

## 📦 Installation

### 1. Tambahkan Dependency

Tambahkan ke `pubspec.yaml`:

```yaml
dependencies:
  kgiton_sdk:
    git:
      url: https://github.com/kgiton/flutter-kgiton-sdk.git
      ref: main
```

Jalankan:
```bash
flutter pub get
```

### 2. Konfigurasi Android

#### AndroidManifest.xml

`android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- ==================== PERMISSIONS ==================== -->
    
    <!-- Bluetooth Permissions (Required for BLE) -->
    <uses-permission android:name="android.permission.BLUETOOTH"/>
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
    
    <!-- Android 12+ Bluetooth Permissions -->
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
        android:usesPermissionFlags="neverForLocation"/>
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
    
    <!-- Location Permissions (Required for BLE scanning on Android 10-11) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <!-- Internet Permission (Required for API calls) -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <!-- ==================== APPLICATION ==================== -->
    
    <application
        android:label="Your App"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
</manifest>
```

#### build.gradle

`android/app/build.gradle`:

```groovy
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21      // Android 5.0+
        targetSdkVersion 34   // Android 14
    }
}
```

### 3. Konfigurasi iOS

#### Info.plist

`ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Bluetooth Usage Description -->
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>Aplikasi ini memerlukan akses Bluetooth untuk terhubung ke timbangan KGiTON</string>
    
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>Aplikasi ini memerlukan akses Bluetooth untuk terhubung ke timbangan KGiTON</string>
    
    <!-- Location Usage Description (Required for BLE scanning) -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Akses lokasi diperlukan untuk menemukan perangkat Bluetooth terdekat</string>
    
    <!-- Background Modes (Optional - for background BLE) -->
    <key>UIBackgroundModes</key>
    <array>
        <string>bluetooth-central</string>
    </array>
</dict>
</plist>
```

#### Podfile

`ios/Podfile`:

```ruby
platform :ios, '12.0'

# ... rest of Podfile
```

---

## 🔧 Basic Setup

### Import SDK

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';
```

### Initialize API Service

```dart
// Dengan base URL
final api = KgitonApiService(baseUrl: 'https://api.example.com');

// Atau dengan token yang sudah ada
final api = KgitonApiService(
  baseUrl: 'https://api.example.com',
  accessToken: 'your-saved-token',
  apiKey: 'your-api-key',
);
```

### Menggunakan Helper (Recommended)

Untuk kemudahan penggunaan dengan session management:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

class AppInit {
  static late KgitonAuthHelper authHelper;
  static late KgitonLicenseHelper licenseHelper;
  static late KgitonTopupHelper topupHelper;
  
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Initialize auth helper (handles token storage)
    authHelper = KgitonAuthHelper(prefs, baseUrl: 'https://api.example.com');
    
    // Restore session if exists
    final isLoggedIn = await authHelper.restoreSession();
    
    if (isLoggedIn) {
      // Initialize other helpers with authenticated service
      final api = authHelper.getAuthenticatedApiService()!;
      licenseHelper = KgitonLicenseHelper(api);
      topupHelper = KgitonTopupHelper(api);
    }
  }
}

// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInit.initialize();
  runApp(MyApp());
}
```

---

## ✅ Verification

Untuk memverifikasi instalasi berhasil:

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

void verifyInstallation() {
  // Test API service
  final api = KgitonApiService(baseUrl: 'https://api.example.com');
  print('✅ API Service initialized');
  print('   Base URL: ${api.baseUrl}');
  
  // Test scale service
  final scale = KgitonScaleService();
  print('✅ Scale Service initialized');
  
  // Test permission helper
  PermissionHelper.requestBLEPermissions().then((granted) {
    print('✅ Permissions: ${granted ? "Granted" : "Denied"}');
  });
}
```

---

## 📁 Project Structure (Recommended)

```
lib/
├── main.dart
├── core/
│   ├── di/
│   │   └── injection.dart      # Dependency injection
│   ├── config/
│   │   └── api_config.dart     # API configuration
│   └── services/
│       └── kgiton_service.dart # KGiTON service wrapper
├── features/
│   ├── auth/
│   │   ├── pages/
│   │   └── providers/
│   ├── scale/
│   │   ├── pages/
│   │   └── providers/
│   └── topup/
│       ├── pages/
│       └── providers/
```

---

## 🔗 Next Steps

1. **[Authentication](02_AUTHENTICATION.md)** - Login dan register
2. **[License & Token](03_LICENSE_TOKEN.md)** - Validasi license dan token
3. **[BLE Integration](05_BLE_INTEGRATION.md)** - Koneksi ke timbangan

---

## ❓ Troubleshooting

Jika mengalami masalah saat instalasi:

1. Jalankan `flutter clean && flutter pub get`
2. Untuk iOS: `cd ios && pod install --repo-update`
3. Pastikan versi Flutter dan Dart sesuai requirement
4. Lihat [Troubleshooting Guide](07_TROUBLESHOOTING.md)
