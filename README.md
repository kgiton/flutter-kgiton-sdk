<p align="center">
  <img src="logo/kgiton-logo.png" alt="KGiTON Logo" width="300"/>
</p>

<h1 align="center">KGiTON Flutter SDK (Client Edition)</h1>

<p align="center">
  <strong>Official Flutter SDK for KGiTON Scale Devices & API Integration</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#support">Support</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue" alt="Platform"/>
  <img src="https://img.shields.io/badge/Dart-%3E%3D3.0.0-blue" alt="Dart"/>
  <img src="https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue" alt="Flutter"/>
  <img src="https://img.shields.io/badge/License-Proprietary-red" alt="License"/>
</p>

---

## 📋 Overview

KGiTON Flutter SDK menyediakan integrasi lengkap untuk:

1. **BLE Scale Integration** - Koneksi ke timbangan KGiTON via Bluetooth Low Energy
2. **REST API Client** - Komunikasi dengan backend KGiTON untuk autentikasi, license, dan token

### Sistem Token

KGiTON menggunakan sistem token untuk penggunaan timbangan:
- **1 Token = 1 Sesi Penimbangan**
- Token dapat dibeli (top-up) melalui berbagai metode pembayaran
- Setiap license key memiliki saldo token tersendiri

---

## ✨ Features

### 🔵 BLE Scale Integration
| Feature | Description |
|---------|-------------|
| Device Discovery | Scan perangkat KGiTON dengan filter RSSI |
| Real-time Weight | Streaming data berat @ 10Hz |
| License Auth | Autentikasi perangkat dengan license key |
| Buzzer Control | Kontrol buzzer (BEEP, BUZZ, LONG, OFF) |
| Auto-reconnect | Reconnect otomatis saat koneksi terputus |

### 🌐 API Integration
| Feature | Description |
|---------|-------------|
| Authentication | Register, login, logout, reset password |
| User Management | Profile, API key management |
| License Management | Validasi license, assign license |
| Token System | Cek saldo, gunakan token, top-up |
| Payment Gateway | Winpay (VA, QRIS, Checkout Page) |

---

## 📦 Installation

### 1. Add Dependency

```yaml
# pubspec.yaml
dependencies:
  kgiton_sdk:
    git:
      url: https://github.com/kgiton/flutter-kgiton-sdk.git
      ref: main
```

### 2. Android Configuration

**`android/app/src/main/AndroidManifest.xml`:**
```xml
<manifest>
    <!-- Bluetooth Permissions -->
    <uses-permission android:name="android.permission.BLUETOOTH"/>
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
        android:usesPermissionFlags="neverForLocation"/>
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
    
    <!-- Location (required for BLE scanning on Android 10-11) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <!-- Internet -->
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

**`android/app/build.gradle`:**
```groovy
android {
    defaultConfig {
        minSdkVersion 21  // Android 5.0+
    }
}
```

### 3. iOS Configuration

**`ios/Runner/Info.plist`:**
```xml
<dict>
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>Aplikasi memerlukan Bluetooth untuk terhubung ke timbangan</string>
    
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>Aplikasi memerlukan Bluetooth untuk terhubung ke timbangan</string>
    
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Lokasi diperlukan untuk menemukan perangkat Bluetooth terdekat</string>
</dict>
```

**`ios/Podfile`:**
```ruby
platform :ios, '12.0'
```

---

## 🚀 Quick Start

### Import SDK

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';
```

### 1. Authentication

```dart
// Initialize API service
final api = KgitonApiService(baseUrl: 'https://api.example.com');

// Register new user (requires license key)
final authData = await api.auth.register(
  email: 'user@example.com',
  password: 'securePassword123',
  confirmPassword: 'securePassword123',
  licenseKey: 'XXXX-XXXX-XXXX-XXXX',
);

// Login
final authData = await api.auth.login(
  email: 'user@example.com',
  password: 'securePassword123',
);

print('Token: ${authData.accessToken}');
print('API Key: ${authData.user.apiKey}');
```

### 2. Check Token Balance

```dart
// Get token balance for all licenses
final balance = await api.user.getTokenBalance();

print('Total Tokens: ${balance.totalRemainingBalance}');
for (var license in balance.licenses) {
  print('${license.licenseKey}: ${license.remainingBalance} tokens');
}
```

### 3. Use Token (for weighing session)

```dart
// Use 1 token before starting weighing session
final result = await api.user.useToken('XXXX-XXXX-XXXX-XXXX');

if (result.success) {
  print('Token used! Remaining: ${result.remainingBalance}');
  // Start BLE connection to scale
} else {
  print('Error: ${result.message}');
}
```

### 4. Top-up Tokens

```dart
// Get available payment methods
final methods = await api.topup.getPaymentMethods();
for (var method in methods) {
  print('${method.displayName} - Fee: ${method.feeFormatted}');
}

// Request top-up with checkout page
final topup = await api.topup.requestTopup(
  tokenCount: 100,
  licenseKey: 'XXXX-XXXX-XXXX-XXXX',
  paymentMethod: 'checkout_page',
);

print('Payment URL: ${topup.checkoutPageUrl}');
// Open URL in browser for user to complete payment
```

### 5. Connect to Scale (BLE)

```dart
// Request permissions first
final granted = await PermissionHelper.requestBLEPermissions();
if (!granted) return;

// Initialize scale service
final scale = KgitonScaleService();

// Listen to discovered devices
scale.devicesStream.listen((devices) {
  for (var device in devices) {
    print('Found: ${device.name} (${device.licenseKey})');
  }
});

// Start scanning
await scale.startScan();

// Connect to device
await scale.connect(licenseKey: 'XXXX-XXXX-XXXX-XXXX');

// Listen to weight data
scale.weightStream.listen((weight) {
  print('Weight: ${weight.value} ${weight.unit}');
});

// Control buzzer
await scale.buzzer(BuzzerCommand.beep);
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [Getting Started](docs/01_GETTING_STARTED.md) | Instalasi dan setup awal |
| [Authentication](docs/02_AUTHENTICATION.md) | Login, register, session management |
| [License & Token](docs/03_LICENSE_TOKEN.md) | License validation, token usage |
| [Top-up & Payment](docs/04_TOPUP_PAYMENT.md) | Top-up tokens, payment integration |
| [BLE Integration](docs/05_BLE_INTEGRATION.md) | Koneksi ke timbangan BLE |
| [API Reference](docs/06_API_REFERENCE.md) | Complete API reference |
| [Troubleshooting](docs/07_TROUBLESHOOTING.md) | Common issues & solutions |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Your Flutter App                       │
├─────────────────────────────────────────────────────────────┤
│                       KGiTON SDK                            │
│  ┌─────────────────────┐    ┌─────────────────────────────┐ │
│  │   BLE Integration   │    │      API Integration        │ │
│  │                     │    │                             │ │
│  │ • KgitonScaleService│    │ • KgitonApiService          │ │
│  │ • Weight Streaming  │    │   ├─ auth                   │ │
│  │ • Buzzer Control    │    │   ├─ user                   │ │
│  │ • Device Discovery  │    │   ├─ license                │ │
│  │                     │    │   ├─ topup                  │ │
│  │                     │    │   └─ licenseTransaction     │ │
│  └─────────────────────┘    └─────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                        Helpers                              │
│  • KgitonAuthHelper     (auth + session management)         │
│  • KgitonLicenseHelper  (license + token operations)        │
│  • KgitonTopupHelper    (top-up + payment operations)       │
└─────────────────────────────────────────────────────────────┘
         │                              │
         ▼                              ▼
┌─────────────────┐          ┌─────────────────────┐
│  KGiTON Scale   │          │   KGiTON API        │
│  (ESP32 BLE)    │          │   (Backend Server)  │
└─────────────────┘          └─────────────────────┘
```

---

## 📱 Minimum Requirements

| Platform | Version |
|----------|---------|
| Android | 5.0+ (API 21) |
| iOS | 12.0+ |
| Dart | 3.0.0+ |
| Flutter | 3.0.0+ |

---

## 🔐 Security

- Semua komunikasi API menggunakan HTTPS
- Token JWT dengan expiration time
- API Key untuk device-to-device communication
- License key tied to specific device

Lihat [SECURITY.md](SECURITY.md) untuk detail lebih lanjut.

---

## 📄 License

**PROPRIETARY SOFTWARE** - © PT KGiTON

SDK ini adalah perangkat lunak komersial milik PT KGiTON.
Penggunaan memerlukan otorisasi resmi.

Lihat [LICENSE](LICENSE) dan [AUTHORIZATION.md](AUTHORIZATION.md) untuk informasi lisensi.

---

## 📞 Support

| Channel | Contact |
|---------|---------|
| Email | support@kgiton.com |
| Website | https://www.kgiton.com |

---

<p align="center">
  Made with ❤️ by <strong>PT KGiTON</strong>
</p>
