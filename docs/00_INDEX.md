# KGiTON SDK - Flutter Integration

SDK untuk integrasi timbangan KGiTON dengan aplikasi Flutter. 

## 🚀 Quick Start

### 1. Install
```yaml
# pubspec.yaml
dependencies:
  kgiton_sdk:
    git:
      url: https://github.com/kgiton/flutter-kgiton-sdk.git
```

### 2. Configure Platform
**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Need wireless access for scale connection</string>
```

### 3. Use
```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// Scale Device
final scale = KGiTONScaleService();
await scale.scanForDevices();
await scale.connectWithLicenseKey(deviceId: 'xxx', licenseKey: 'yyy');
scale.weightStream.listen((weight) => print(weight));

// API
final api = KgitonApiService(prefs);
await api.authService.login(email: 'x', password: 'y');
await api.itemService.createItem(name: 'Apel', price: 15000);
```

---

## 📖 Documentation

### [Getting Started](01_GETTING_STARTED.md)
Installation, configuration, setup.

### [Device Integration](02_DEVICE_INTEGRATION.md)
Scan, connect, read weight, control buzzer.

### [API Integration](03_API_INTEGRATION.md)
Auth, license, items, cart, transaction.

### [Cart & Transaction](04_CART_TRANSACTION.md)
Session cart, checkout, payment.

### [Troubleshooting](05_TROUBLESHOOTING.md)
Common issues & solutions.

---

## 💬 Support

- 📧 support@kgiton.com
- 📄 [AUTHORIZATION.md](../AUTHORIZATION.md) - Get license
- 🔒 [SECURITY.md](../SECURITY.md) - Report vulnerabilities
- 📝 [CHANGELOG.md](../CHANGELOG.md) - Version history


---

## ⚠️ Penting!

### Lisensi
SDK ini adalah **proprietary software** milik PT KGiTON. Penggunaan memerlukan lisensi resmi.

📧 **Kontak**: support@kgiton.com

---

**Copyright © 2025 PT KGiTON. All Rights Reserved.**
