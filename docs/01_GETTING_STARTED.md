# Getting Started

## Requirements
- Flutter 3.0.0+
- Dart 3.10.0+
- Android 21+ (Android 5.0)
- iOS 12.0+
- **License required** → support@kgiton.com

---

## Installation

### 1. Add Dependency
```yaml
# pubspec.yaml
dependencies:
  kgiton_sdk:
    git:
      url: https://github.com/kgiton/flutter-kgiton-sdk.git
```

### 2. Install
```bash
flutter pub get
```

### 3. Import
```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';
```

---

## Android Configuration

**AndroidManifest.xml** (`android/app/src/main/`):
```xml
<manifest>
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />
</manifest>
```

**build.gradle** (`android/app/`):
```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
    compileSdkVersion 34
}
```

⚠️ **Android 10-11**: Location must be ON for device scan!

---

## iOS Configuration

**Info.plist** (`ios/Runner/`):
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Need wireless access for scale connection</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Required for device scan</string>
```

**Podfile** (`ios/`):
```ruby
platform :ios, '12.0'
```

---

## Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage(prefs: prefs));
  }
}

class HomePage extends StatefulWidget {
  final SharedPreferences prefs;
  const HomePage({required this.prefs});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late KGiTONScaleService scaleService;
  late KgitonApiService apiService;
  
  @override
  void initState() {
    super.initState();
    scaleService = KGiTONScaleService();
    apiService = KgitonApiService(widget.prefs);
  }
  
  @override
  void dispose() {
    scaleService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('KGiTON SDK')),
      body: Center(child: Text('Ready')),
    );
  }
}
```

---

## Next Steps

- [Device Integration](02_DEVICE_INTEGRATION.md) - Scan, connect, read weight
- [API Integration](03_API_INTEGRATION.md) - Login, items, API
- [Cart & Transaction](04_CART_TRANSACTION.md) - Cart, checkout
- [Example App](../example/timbangan/) - Full example

---

**Copyright © 2025 PT KGiTON. All Rights Reserved.**
