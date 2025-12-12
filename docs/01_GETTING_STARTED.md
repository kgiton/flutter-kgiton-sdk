# Getting Started with KGiTON SDK

**Complete installation and setup guide for integrating KGiTON SDK into your Flutter application.**

> **Prerequisites**: Basic knowledge of Flutter development, Dart programming, and mobile app deployment.

---

## Table of Contents

- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Platform Configuration](#platform-configuration)
- [Initialization](#initialization)
- [Verification](#verification)
- [Next Steps](#next-steps)

---

## System Requirements

### Development Tools
| Tool | Minimum Version | Recommended | Purpose |
|------|----------------|-------------|---------|
| Flutter SDK | 3.0.0 | 3.24.0+ | Framework |
| Dart SDK | 3.10.0 | Latest | Programming language |
| Android Studio | 2022.1.1+ | Latest | Android development |
| Xcode | 14.0+ | 15.0+ | iOS development (Mac only) |
| VS Code | 1.80+ | Latest | Alternative IDE |

### Target Platforms
| Platform | Minimum OS | Notes |
|----------|-----------|-------|
| **Android** | 5.0 (Lollipop) - API 21+ | BLE support required |
| **iOS** | 12.0+ | BLE central role required |

### Device Requirements
- ✅ **Bluetooth 4.0+ (BLE)**: Hardware support mandatory
- ✅ **Internet Connection**: Required for API operations
- ✅ **Location Services**: Android 10-11 only (for BLE scanning)
- ✅ **Storage**: Minimum 10 MB available

### License Requirements
- **Valid License Key**: Required for device authentication
- **Backend Access**: API credentials for cloud operations
- **Contact**: support@kgiton.com for licensing

---

## Installation

### Step 1: Add SDK Dependency

Add KGiTON SDK to your project's `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # KGiTON SDK
  kgiton_sdk:
    git:
      url: https://github.com/kgiton/flutter-kgiton-sdk.git
      # Optional: specify branch or tag
      # ref: main
  
  # Required peer dependencies
  shared_preferences: ^2.3.4
  permission_handler: ^11.3.1
```

### Step 2: Install Dependencies

Run the following command in your project directory:

```bash
# Get all dependencies
flutter pub get

# Clean and rebuild (recommended)
flutter clean
flutter pub get
```

### Step 3: Import SDK

Import the SDK in your Dart files:

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
```


---

## Platform Configuration

### Android Setup

#### 1. AndroidManifest.xml Configuration

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- ============================================== -->
    <!-- BLUETOOTH PERMISSIONS (Required for BLE)      -->
    <!-- ============================================== -->
    
    <!-- Legacy Bluetooth (API < 31) -->
    <uses-permission android:name="android.permission.BLUETOOTH" 
        android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" 
        android:maxSdkVersion="30" />
    
    <!-- Modern Bluetooth (API >= 31) -->
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
        android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    
    <!-- ============================================== -->
    <!-- LOCATION PERMISSIONS (Android 10-11 ONLY)     -->
    <!-- ============================================== -->
    <!-- Required for BLE device discovery on API 29-30 -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- ============================================== -->
    <!-- INTERNET PERMISSION (Required for API)        -->
    <!-- ============================================== -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <!-- ============================================== -->
    <!-- BLUETOOTH HARDWARE FEATURE                    -->
    <!-- ============================================== -->
    <uses-feature 
        android:name="android.hardware.bluetooth_le" 
        android:required="true" />
    
    <application
        android:label="Your App Name"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Your activities here -->
        
    </application>
</manifest>
```

#### 2. build.gradle Configuration

**App-level** `android/app/build.gradle`:

```gradle
android {
    namespace "com.yourcompany.yourapp"
    compileSdk 34
    
    defaultConfig {
        applicationId "com.yourcompany.yourapp"
        minSdk 21        // Minimum Android 5.0
        targetSdk 34     // Target latest
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}

dependencies {
    // Your dependencies
}
```

**Project-level** `android/build.gradle`:

```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
```

#### 3. Important Notes for Android

| Android Version | Special Requirements |
|----------------|---------------------|
| **API 21-28** | No location permission needed for BLE |
| **API 29-30** | ⚠️ Location permission + Location Service ON required |
| **API 31+** | Use BLUETOOTH_SCAN/CONNECT, location optional |

---

### iOS Setup

#### 1. Info.plist Configuration

Edit `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ============================================== -->
    <!-- BLUETOOTH PERMISSIONS                         -->
    <!-- ============================================== -->
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>This app requires Bluetooth to connect to KGiTON scale devices for real-time weight measurements.</string>
    
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>This app uses Bluetooth to discover and connect to nearby scale devices.</string>
    
    <!-- ============================================== -->
    <!-- LOCATION PERMISSIONS (Optional)               -->
    <!-- ============================================== -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Location access is required for Bluetooth device scanning on some iOS versions.</string>
    
    <!-- ============================================== -->
    <!-- BACKGROUND MODES (Optional)                   -->
    <!-- ============================================== -->
    <key>UIBackgroundModes</key>
    <array>
        <string>bluetooth-central</string>
    </array>
    
    <!-- Your other keys -->
</dict>
</plist>
```

#### 2. Podfile Configuration

Edit `ios/Podfile`:

```ruby
# Minimum iOS version
platform :ios, '12.0'

# CocoaPods configuration
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

#### 3. Install iOS Dependencies

```bash
cd ios
pod install
cd ..
```


---

## Initialization

### Basic Initialization

Create a basic Flutter app with KGiTON SDK:

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KGiTON SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late KGiTONScaleService scaleService;
  late KgitonApiService apiService;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize Scale Service
    scaleService = KGiTONScaleService();
    
    // Initialize API Service with base URL
    apiService = KgitonApiService(
      baseUrl: 'https://api.example.com/api',
    );
    
    // Optional: Load saved tokens from storage
    // apiService.loadConfiguration();
  }
  
  @override
  void dispose() {
    // Clean up resources
    scaleService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KGiTON SDK'),
        elevation: 2,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.scale, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'KGiTON SDK Ready',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.bluetooth_searching),
              label: const Text('Scan Devices'),
              onPressed: () {
                // Navigate to device scanning page
                // See Device Integration guide
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### Advanced Initialization with Dependency Injection

For larger apps, consider using dependency injection:

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final scaleService = KGiTONScaleService();
  final apiService = KgitonApiService(
    baseUrl: 'https://api.example.com/api',
  );
  
  // Load saved configuration (tokens) from storage
  await apiService.loadConfiguration();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<KGiTONScaleService>.value(value: scaleService),
        Provider<KgitonApiService>.value(value: apiService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KGiTON SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaleService = Provider.of<KGiTONScaleService>(context, listen: false);
    final apiService = Provider.of<KgitonApiService>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Text('Services initialized successfully'),
      ),
    );
  }
}
```

### Environment Configuration

For different environments (dev, staging, production):

```dart
enum Environment {
  development,
  staging,
  production,
}

class Config {
  static Environment _environment = Environment.development;
  
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://localhost:3000/api';
      case Environment.staging:
        return 'https://staging-api.example.com/api';
      case Environment.production:
        return 'https://api.example.com/api';
    }
  }
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }
}

// Usage in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set environment
  Config.setEnvironment(Environment.production);
  
  final apiService = KgitonApiService(
    baseUrl: Config.apiBaseUrl,
  );
  
  // Load saved tokens
  await apiService.loadConfiguration();
  
  runApp(MyApp(apiService: apiService));
}
```

---

## Verification

### Test Installation

Create a simple test to verify SDK installation:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('SDK initialization test', () async {
    // Test Scale Service
    final scaleService = KGiTONScaleService();
    expect(scaleService, isNotNull);
    
    // Test API Service
    final apiService = KgitonApiService(
      baseUrl: 'https://api.example.com/api',
    );
    expect(apiService, isNotNull);
    expect(apiService.auth, isNotNull);
    expect(apiService.owner, isNotNull);
    expect(apiService.cart, isNotNull);
    expect(apiService.transaction, isNotNull);
    
    // Cleanup
    scaleService.dispose();
  });
}
```

### Run Test

```bash
flutter test
```

### Verify Permissions Setup

Run your app and check permission requests:

```dart
// Add this to test permissions
Future<void> testPermissions() async {
  final granted = await PermissionHelper.requestBLEPermissions();
  
  if (granted) {
    print('✅ All BLE permissions granted');
  } else {
    print('❌ BLE permissions denied');
    await PermissionHelper.openAppSettings();
  }
}
```

### Build and Run

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Check for compilation errors
flutter analyze

# Check dependencies
flutter doctor -v
```

---

## Troubleshooting Installation

### Common Issues

#### Issue: "Package not found"
```
Error: Could not resolve package 'kgiton_sdk'
```
**Solution:**
1. Check internet connection
2. Verify Git repository access
3. Run `flutter pub cache clean`
4. Run `flutter pub get` again

#### Issue: "Version solving failed"
```
Because kgiton_sdk requires SDK version >=3.10.0
```
**Solution:**
1. Update Flutter: `flutter upgrade`
2. Check Flutter version: `flutter --version`
3. Ensure Dart SDK ≥ 3.10.0

#### Issue: "CocoaPods not installed" (iOS)
```
Error: CocoaPods not found
```
**Solution:**
```bash
# Install CocoaPods
sudo gem install cocoapods

# Update repository
pod repo update

# Install dependencies
cd ios && pod install
```

#### Issue: Android build fails
```
FAILURE: Build failed with an exception
```
**Solution:**
1. Update Gradle wrapper:
   ```bash
   cd android
   ./gradlew wrapper --gradle-version 8.1.0
   ```
2. Clean build:
   ```bash
   flutter clean
   cd android
   ./gradlew clean
   cd ..
   flutter pub get
   ```

---

## Next Steps

Now that your SDK is installed and configured, proceed to:

### 1. [Device Integration Guide](02_DEVICE_INTEGRATION.md)
Learn how to:
- Request BLE permissions
- Scan for scale devices
- Connect to devices
- Authenticate with license key
- Read real-time weight data
- Control device features

### 2. [API Integration Guide](03_API_INTEGRATION.md)
Learn how to:
- Authenticate users
- Manage items/products
- Handle licenses
- Make API requests
- Handle errors

### 3. [Cart & Transaction Guide](04_CART_TRANSACTION.md)
Learn how to:
- Manage shopping cart
- Process checkout
- Handle payments
- Generate transactions

### 4. [Example Application](../example/kgiton_apps/)
Explore the complete reference implementation with:
- Full UI implementation
- State management
- Error handling
- Best practices


---

**Copyright © 2025 PT KGiTON. All Rights Reserved.**

For support, contact: support@kgiton.com
