# KGiTON SDK - Flutter Integration Guide

**Official Flutter SDK for KGiTON Smart Scale Integration**

> **Version:** 1.0.0  
> **Last Updated:** December 2025  
> **Minimum Requirements:** Flutter 3.0.0+ | Dart 3.10.0+ | iOS 12.0+ | Android 5.0+ (API 21+)

---

## 📖 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Key Features](#key-features)
- [Quick Start](#quick-start)
- [Documentation Index](#documentation-index)
- [System Requirements](#system-requirements)
- [License & Support](#license--support)

---

## Overview

The **KGiTON SDK** is a comprehensive Flutter package that enables seamless integration with KGiTON smart scale hardware devices and backend API services. Designed for retail, warehouse, and commercial weighing applications, this SDK provides:

- **Real-time BLE Communication**: Connect to KGiTON scale devices wirelessly
- **High-Frequency Weight Streaming**: Receive weight data at ~10 Hz with automatic formatting
- **Secure Authentication**: License key-based device authentication and user management
- **Complete API Integration**: Full REST API client for items, cart, and transactions
- **Session-Based Cart System**: Multi-device support with persistent shopping cart
- **Dual Pricing Support**: Handle per-kg and per-piece pricing simultaneously
- **Cross-Platform**: Native iOS and Android support with platform-specific optimizations

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Application                      │
├─────────────────────────────────────────────────────────────┤
│                      KGiTON SDK                             │
│  ┌───────────────────────┐  ┌──────────────────────────┐  │
│  │  Scale Service Layer  │  │   API Service Layer      │  │
│  ├───────────────────────┤  ├──────────────────────────┤  │
│  │ • Device Scanning     │  │ • Authentication         │  │
│  │ • BLE Connection      │  │ • Item Management        │  │
│  │ • License Auth        │  │ • Cart Operations        │  │
│  │ • Weight Streaming    │  │ • Transaction Processing │  │
│  │ • Device Control      │  │ • License Management     │  │
│  └───────────────────────┘  └──────────────────────────┘  │
│              │                         │                    │
│  ┌───────────▼─────────────────────────▼────────────────┐ │
│  │            Helper & Utility Layer                     │ │
│  │  • Permission Helper  • Auth Helper  • Cart Helper   │ │
│  │  • License Helper     • Exception Handling           │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┴─────────────────┐
        │                                   │
┌───────▼────────┐                 ┌────────▼────────┐
│  KGiTON Scale  │                 │  KGiTON Backend │
│    Hardware    │                 │      API        │
│  (BLE Device)  │                 │  (REST API)     │
└────────────────┘                 └─────────────────┘
```

---

## Key Features

### 🔵 Device Integration
- **Smart Device Scanning**: RSSI-filtered scanning with auto-stop on device found
- **Wireless Connection**: Bluetooth Low Energy (BLE) connectivity
- **License Authentication**: Secure device pairing with license key validation
- **Real-time Weight Data**: High-frequency streaming (~10 Hz) with automatic unit conversion
- **Device Control**: Buzzer control (BEEP, BUZZ, LONG, OFF)
- **Connection State Management**: Real-time connection status tracking
- **Auto-Recovery**: Automatic reconnection when Bluetooth is re-enabled
- **Error Handling**: Comprehensive exception handling with user-friendly messages

### 🌐 API Integration
- **User Authentication**: Register, login, logout with token management
- **Item/Product Management**: Full CRUD operations for scale items
- **License Management**: Assign and manage device licenses
- **Session-Based Cart**: Multi-device cart support with unique session IDs
- **Transaction Processing**: Complete checkout and payment workflows
- **Payment Methods**: QRIS, Cash, Bank Transfer support
- **Data Persistence**: Automatic token and configuration storage
- **Type-Safe Models**: Strongly-typed Dart models with JSON serialization

### 🛠️ Developer Experience
- **Helper Classes**: Simplified wrappers for common operations
- **Permission Management**: Automated BLE and location permission handling
- **Reactive Streams**: Real-time data updates via Dart Streams
- **Comprehensive Logging**: Built-in logger for debugging
- **Error Recovery**: Graceful error handling with retry mechanisms
- **Example App**: Complete reference implementation with Material Design 3

---

## Quick Start

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
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Need wireless access for scale connection</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Required for device scanning</string>
```

### 3. Basic Usage
```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// Initialize services
final scale = KGiTONScaleService();
final api = KgitonApiService(
  baseUrl: 'https://api.example.com/api',
);

// Load saved tokens from storage
await api.loadConfiguration();

// Device: Scan & Connect
await scale.scanForDevices();
final response = await scale.connectWithLicenseKey(
  deviceId: 'KGITON_ABC123',
  licenseKey: 'YOUR-LICENSE-KEY',
);

// Device: Stream weight data
scale.weightStream.listen((weight) {
  print('Weight: ${weight.value} ${weight.unit}');
});

// API: Authenticate
await api.auth.login(
  email: 'user@example.com',
  password: 'password123',
);

// API: Manage items
await api.owner.createItem(
  name: 'Apple',
  unit: 'kg',
  price: 15000,
);
```


---

## Documentation Index

### 📘 [1. Getting Started](01_GETTING_STARTED.md)
**Complete installation and setup guide**
- System requirements and prerequisites
- Step-by-step installation instructions
- Platform-specific configuration (Android/iOS)
- Dependency management
- Initial project setup
- Verification steps

### 🔵 [2. Device Integration](02_DEVICE_INTEGRATION.md)
**BLE scale device integration guide**
- Permission management (Bluetooth, Location)
- Device scanning and discovery
- Connection establishment
- License-based authentication
- Real-time weight streaming
- Device control (buzzer commands)
- Connection state management
- Error handling and recovery

### 🌐 [3. API Integration](03_API_INTEGRATION.md)
**Complete REST API reference**
- API initialization and configuration
- Authentication (register, login, logout)
- User management
- License operations
- Item/Product CRUD operations
- Request/Response specifications
- Error handling and status codes
- Best practices

### 🛒 [4. Cart & Transaction](04_CART_TRANSACTION.md)
**Shopping cart and payment workflows**
- Session-based cart system
- Cart operations (add, update, remove)
- Cart ID generation
- Checkout process
- Payment methods (QRIS, Cash, Bank Transfer)
- Transaction history
- Receipt generation
- Multi-device cart support

### ⚠️ [5. Troubleshooting](05_TROUBLESHOOTING.md)
**Common issues and solutions**
- Error code reference
- HTTP status codes
- Permission issues
- Connection problems
- Android 10-11 specific issues
- API errors
- Weight reading issues
- Debug logs and diagnostics

---

## System Requirements

### Development Environment
| Component | Minimum Version | Recommended |
|-----------|----------------|-------------|
| Flutter | 3.0.0 | 3.24.0+ |
| Dart | 3.10.0 | Latest |
| Android Studio | 2022.1.1+ | Latest |
| Xcode | 14.0+ | 15.0+ |

### Runtime Requirements
| Platform | Minimum OS | API Level |
|----------|-----------|-----------|
| Android | 5.0 (Lollipop) | API 21+ |
| iOS | 12.0 | - |

### Device Requirements
- **Bluetooth**: BLE 4.0+ support required
- **Location**: GPS/Location services (Android 10-11 only)
- **Internet**: Required for API operations
- **Storage**: Minimum 10 MB free space

### Dependencies
```yaml
dependencies:
  flutter: ">=3.0.0"
  kgiton_ble_sdk: ^1.0.0  # BLE communication
  http: ^1.2.0            # HTTP client
  logger: ^2.5.0          # Logging
  shared_preferences: ^2.3.4  # Local storage
  permission_handler: ^11.3.1 # Permissions
```

---

## License & Support

### 📧 Contact Information
- **Email**: support@kgiton.com
- **Website**: https://www.kgiton.com
- **GitHub Issues**: https://github.com/kgiton/flutter-kgiton-sdk/issues

### 📄 Documentation Links
- [Authorization Guide](../AUTHORIZATION.md) - How to obtain license
- [Security Policy](../SECURITY.md) - Report vulnerabilities
- [Changelog](../CHANGELOG.md) - Version history
- [Security Checklist](../SECURITY_CHECKLIST.md) - Security best practices

### ⚖️ Licensing
This SDK is **proprietary software** owned by PT KGiTON. 

**Usage Requirements:**
- Valid license key required for device authentication
- Commercial use requires enterprise license
- Contact support@kgiton.com for licensing information

**Restrictions:**
- ❌ No redistribution without permission
- ❌ No reverse engineering
- ❌ No unauthorized commercial use
- ✅ Evaluation for authorized partners

---

## Support Channels

### 🐛 Bug Reports
For bug reports, please include:
1. SDK version
2. Flutter/Dart version
3. Platform (iOS/Android) and OS version
4. Complete error logs
5. Steps to reproduce
6. Expected vs actual behavior

### 💬 Feature Requests
Submit feature requests via GitHub Issues with:
- Clear use case description
- Expected behavior
- Business justification
- Proposed API design (optional)

### 📚 Additional Resources
- [Example App Source Code](../example/kgiton_apps/)
- [API Postman Collection](#) *(Coming Soon)*
- [Video Tutorials](#) *(Coming Soon)*
- [Integration Webinars](#) *(Contact Support)*

---

## Quick Reference

### Common Code Snippets

**Request BLE Permissions:**
```dart
final granted = await PermissionHelper.requestBLEPermissions();
if (!granted) await PermissionHelper.openAppSettings();
```

**Scan for Devices:**
```dart
final scale = KGiTONScaleService();
await scale.scanForDevices(timeout: Duration(seconds: 10));
scale.devicesStream.listen((devices) => print(devices));
```

**Connect to Device:**
```dart
final response = await scale.connectWithLicenseKey(
  deviceId: 'KGITON_ABC123',
  licenseKey: 'YOUR-LICENSE-KEY',
);
```

**Get Weight Data:**
```dart
scale.weightStream.listen((weight) {
  print('${weight.value} ${weight.unit}');
});
```

**API Login:**
```dart
final api = KgitonApiService(
  baseUrl: 'https://api.example.com/api',
);
await api.loadConfiguration();

final authData = await api.auth.login(
  email: 'user@example.com',
  password: 'password',
);
```

**Add Item to Cart:**
```dart
await api.cart.addItemToCart(
  AddCartRequest(
    cartId: 'device-12345',
    licenseKey: 'YOUR-LICENSE-KEY',
    itemId: 'item-uuid',
    quantity: 2.5,
  ),
);
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | Dec 2025 | Initial release with BLE and API integration |

For detailed version history, see [CHANGELOG.md](../CHANGELOG.md).

---

## Next Steps

1. **New Users**: Start with [Getting Started Guide](01_GETTING_STARTED.md)
2. **Device Integration**: Follow [Device Integration Guide](02_DEVICE_INTEGRATION.md)
3. **API Integration**: Read [API Integration Guide](03_API_INTEGRATION.md)
4. **Full Example**: Explore [Example App](../example/kgiton_apps/)

---

**Copyright © 2025 PT KGiTON. All Rights Reserved.**
