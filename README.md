<div align="center">
  <img src="logo/kgiton-logo.png" alt="KGiTON Logo" width="400"/>
  
  # KGiTON Flutter Package SDK

  [![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey.svg)](https://github.com/kgiton/flutter-kgiton-sdk)
</div>

Official Flutter SDK for integrating with KGiTON scale devices and backend API.

> **⚠️ PROPRIETARY SOFTWARE**: This SDK is commercial software owned by PT KGiTON. Use requires explicit authorization. See [AUTHORIZATION.md](AUTHORIZATION.md) for licensing information.

## Key Features

- ✅ **Scale Device Integration**: Connect to KGiTON scale devices wirelessly
- ✅ **Real-time Weight Data**: Stream weight measurements at ~10 Hz with automatic formatting
- ✅ **License Authentication**: Secure device authentication with license key validation
- ✅ **REST API Client**: Complete backend integration for cart, transactions, and items
- ✅ **Dual Pricing System**: Support per kg, per pcs, or both simultaneously (v1.2.1+ - Fully Working)
- ✅ **Bluetooth Auto-Recovery**: Automatic retry when Bluetooth is enabled (v1.2.2+)
- ✅ **Helper Classes**: Simplified wrappers for auth, cart, and license operations (v1.3.0+)
- ✅ **Smart Scanning**: Auto-stop scan when device found (battery efficient)
- ✅ **Cross-Platform**: iOS and Android support with platform-specific optimizations
- ✅ **Type-Safe**: Comprehensive error handling and type-safe models

## 📖 Documentation

### Getting Started

- 📘 [Getting Started](docs/01_GETTING_STARTED.md) - Installation and setup guide
- 🔵 [Device Integration](docs/02_DEVICE_INTEGRATION.md) - Scale device integration
- 🌐 [API Integration](docs/03_API_INTEGRATION.md) - Backend API guide
- 🛒 [Cart & Transactions](docs/04_CART_TRANSACTION.md) - Cart and payment flow
- ⚠️ [Troubleshooting](docs/05_TROUBLESHOOTING.md) - Common issues and solutions

### Legal & Support

- 📗 [Authorization Guide](AUTHORIZATION.md) - How to obtain license
- 🛡️ [Security Policy](SECURITY.md) - Security and vulnerability reporting
- 📔 [Changelog](CHANGELOG.md) - Version history and updates
- 🔧 [Example App](example/) - Complete working example with Material Design 3 UI

## Technical Features

### Scale Device Integration
- **Device Discovery**: Wireless scanning with RSSI filtering and auto-stop
- **Real-time Streaming**: Weight data at ~10 Hz with automatic unit formatting
- **Authentication**: License key-based device authentication
- **Device Control**: Buzzer control (BEEP, BUZZ, LONG, OFF)
- **State Management**: Connection state tracking with reactive streams
- **Error Handling**: Comprehensive exception handling with user-friendly messages
- **Platform Support**: iOS 12.0+ and Android 5.0+ (API 21+)

### Backend API Integration
- **Authentication**: Login, register, logout with automatic token management
- **Item Management**: CRUD operations for scale items with pricing
- **Cart System**: Session-based cart with multiple entries support
- **Transaction Management**: Payment processing with QRIS, Cash, and Bank Transfer
- **Local Storage**: Token and configuration persistence
- **Type Safety**: Strongly-typed models with JSON serialization

## Quick Start

### ⚠️ Authorization Required

**This SDK requires explicit authorization from PT KGiTON.**

📋 **[Read Authorization Guide](AUTHORIZATION.md)** for licensing information.

To obtain a license:
1. Email: support@kgiton.com
2. Subject: "KGiTON SDK License Request"
3. Include: Company name, use case, contact information

### Installation (For Authorized Users)

Contact PT KGiTON for access credentials, then add to your `pubspec.yaml`:

```yaml
dependencies:
  kgiton_sdk:
    git:
      url: https://github.com/kgiton/flutter-kgiton-sdk.git
      # Use provided access token if private repository
```

### Platform Configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<!-- Device Communication Permissions -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
    android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- Location Permissions (Required for Android 10-11 device scanning) -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Internet Permission (Required for API calls) -->
<uses-permission android:name="android.permission.INTERNET" />
```

> **⚠️ Important for Android 10-11**: Location services must be enabled for device scanning. See [Troubleshooting Guide](docs/05_TROUBLESHOOTING.md) for details.

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app requires wireless access to connect to the scale device</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location permission is required to discover nearby devices</string>
```

**Minimum Requirements**:
```yaml
# Android
minSdkVersion: 21  # Android 5.0
targetSdkVersion: 34  # Android 14

# iOS
platform :ios, '12.0'
```

### Basic Usage - Scale Device

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// 1. Request device permissions
final granted = await PermissionHelper.requestBLEPermissions();
if (!granted) {
  final errorMsg = await PermissionHelper.getPermissionErrorMessage();
  print(errorMsg);
  return;
}

// 2. Initialize the scale service
final scaleService = KGiTONScaleService();

// 3. Listen to device discovery
scaleService.devicesStream.listen((devices) {
  print('Found ${devices.length} scale(s)');
  for (var device in devices) {
    print('- ${device.name} (RSSI: ${device.rssi})');
  }
});

// 4. Listen to real-time weight data
scaleService.weightStream.listen((weightData) {
  print('Weight: ${weightData.displayWeight}'); // e.g., "1.25 kg"
  print('Raw value: ${weightData.weight}');
  print('Unit: ${weightData.unit}');
});

// 5. Listen to connection state changes
scaleService.connectionStateStream.listen((state) {
  switch (state) {
    case ScaleConnectionState.disconnected:
      print('Disconnected from scale');
      break;
    case ScaleConnectionState.connecting:
      print('Connecting to scale...');
      break;
    case ScaleConnectionState.authenticating:
      print('Authenticating with license key...');
      break;
    case ScaleConnectionState.connected:
      print('Connected and ready!');
      break;
  }
});

// 6. Scan for devices
await scaleService.scanForDevices(
  timeout: Duration(seconds: 15),
  autoStopOnFound: true, // Stops scanning after finding a device
);

// 7. Connect to a device with license authentication
try {
  await scaleService.connectWithLicenseKey(
    deviceId: selectedDevice.id,
    licenseKey: 'YOUR-LICENSE-KEY',
  );
  print('Successfully connected!');
} catch (e) {
  print('Connection failed: $e');
}

// 8. Control the device buzzer
await scaleService.triggerBuzzer('BEEP'); // Options: BEEP, BUZZ, LONG, OFF

// 9. Disconnect when done
await scaleService.disconnect();
```



### Basic Usage - API Integration

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Initialize API service with SharedPreferences
final prefs = await SharedPreferences.getInstance();
final apiService = KgitonApiService(
  baseUrl: 'https://api.example.com',
  prefs: prefs,
);

// 2. User Authentication
try {
  final authData = await apiService.auth.login(
    email: 'owner@example.com',
    password: 'password123',
  );
  print('Welcome, ${authData.user.name}!');
  print('Role: ${authData.user.role}');
} catch (e) {
  print('Login failed: $e');
}

// 3. Item Management (Owner)
final itemsData = await apiService.owner.listAllItems();
print('Total items: ${itemsData.items.length}');

// Create new item
final newItem = await apiService.owner.createItem(
  licenseKey: 'YOUR-LICENSE-KEY',
  name: 'Apple',
  unit: 'kg',
  price: 15000,
);
print('Created item: ${newItem.name}');

// Update item
await apiService.owner.updateItem(
  itemId: newItem.id,
  name: 'Red Apple',
  price: 18000,
);

// Delete item
await apiService.owner.deleteItem(newItem.id);

// 4. Cart & Checkout Workflow

// Session-based cart using cart_id (e.g., device ID or user session)
final cartId = 'device-12345'; // Your session identifier

// Add items to cart (each call creates a new entry)

// Example 1: Per kg only
await apiService.cart.addItemToCart(
  AddCartRequest(
    cartId: cartId,
    licenseKey: 'YOUR-LICENSE-KEY',
    itemId: 'apple-item-id',
    quantity: 1.5,
    notes: 'First weighing',
  ),
);

// Example 2: Per pcs only
await apiService.cart.addItemToCart(
  AddCartRequest(
    cartId: cartId,
    licenseKey: 'YOUR-LICENSE-KEY',
    itemId: 'orange-item-id',
    quantityPcs: 10,
    notes: '10 pieces',
  ),
);

// Example 3: Dual pricing (kg + pcs)
await apiService.cart.addItemToCart(
  AddCartRequest(
    cartId: cartId,
    licenseKey: 'YOUR-LICENSE-KEY',
    itemId: 'banana-item-id',
    quantity: 2.5,
    quantityPcs: 15,
    notes: '2.5kg + 15 pieces',
  ),
);

// View cart items
final cartItems = await apiService.cart.getCartItems(cartId);
print('Cart has ${cartItems.length} entries');

// Get cart summary
final summary = await apiService.cart.getCartSummary(cartId);
print('Total: ${summary.totalItems} items, Rp ${summary.totalAmount}');

// Checkout cart (creates transaction and clears cart)
final transaction = await apiService.cart.checkoutCart(
  cartId,
  CheckoutCartRequest(
    paymentMethod: PaymentMethod.qris,
    paymentGateway: PaymentGateway.external,
    notes: 'Customer purchase',
  ),
);

print('Transaction #${transaction.transactionNumber}');
print('Total: Rp ${transaction.totalAmount}');

// Handle payment method
if (transaction.paymentMethod == PaymentMethod.qris && transaction.hasValidQris) {
  // Display QRIS code
  print('QRIS: ${transaction.qrisString}');
  print('Expires in ${transaction.remainingSeconds} seconds');
} else if (transaction.paymentMethod == PaymentMethod.cash) {
  print('Cash payment: Rp ${transaction.totalAmount}');
}

// 5. Transaction Management

// List transactions
final transactions = await apiService.transaction.listTransactions(
  page: 1,
  limit: 20,
  status: PaymentStatus.pending,
);

// Get statistics
final stats = await apiService.transaction.getTransactionStats();
print('Total Revenue: Rp ${stats.successAmount}');

// Cancel transaction
await apiService.transaction.cancelTransaction(transactionId);
```

### ⭐ Simplified Usage with Helper Classes (v1.3.0+)

The SDK now includes helper classes that reduce boilerplate code significantly:

#### Authentication Helper

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

final authHelper = KgitonAuthHelper(baseUrl: 'https://api.example.com');

// Login (automatically saves tokens)
final result = await authHelper.login(
  email: 'owner@example.com',
  password: 'password123',
);

if (result['success']) {
  print('Welcome, ${result['data']['user']['name']}!');
} else {
  print('Error: ${result['message']}');
}

// Get authenticated API service (tokens injected automatically)
final apiService = await authHelper.getAuthenticatedApiService();
if (apiService != null) {
  // Use apiService for API calls
}

// Logout (clears stored tokens)
await authHelper.logout();
```

#### Cart Helper

```dart
final cartHelper = KgitonCartHelper(apiService);
final cartId = 'device-12345';

// Add item (consistent return format)
final result = await cartHelper.addItem(
  cartId: cartId,
  licenseKey: 'YOUR-LICENSE-KEY',
  itemId: 'apple-id',
  quantity: 1.5,
);

if (result['success']) {
  print('Item added!');
}

// Get cart summary
final summary = await cartHelper.getSummary(cartId);
if (summary['success']) {
  final data = summary['data'];
  print('Total: ${data['totalItems']} items');
  print('Amount: Rp ${data['totalAmount']}');
}

// Checkout
final checkout = await cartHelper.checkout(
  cartId: cartId,
  paymentMethod: PaymentMethod.qris,
  notes: 'Purchase',
);
```

#### License Helper

```dart
final licenseHelper = KgitonLicenseHelper(apiService);

// Get all licenses
final result = await licenseHelper.getMyLicenses();
if (result['success']) {
  List licenses = result['data'];
  print('You have ${licenses.length} licenses');
}

// Validate license
final validation = await licenseHelper.validateLicense('YOUR-LICENSE-KEY');
if (validation['success'] && validation['data']['isValid']) {
  print('License is valid!');
}
```

**Benefits:**
- 70% less boilerplate code in your application
- Consistent return format: `{success: bool, message: String, data: dynamic}`
- Built-in error handling
- Automatic token management (auth helper)
- Simpler API surface for common operations

For migration examples, see [CHANGELOG.md](CHANGELOG.md#v130).

## API Reference

### Scale Device Service (`KGiTONScaleService`)

#### Streams
```dart
Stream<List<ScaleDevice>> devicesStream       // Discovered devices
Stream<WeightData> weightStream               // Real-time weight measurements
Stream<ScaleConnectionState> connectionStateStream  // Connection state changes
```

#### Methods
```dart
Future<void> scanForDevices({Duration timeout, bool autoStopOnFound})
Future<void> stopScan()
Future<void> connectWithLicenseKey(String deviceId, String licenseKey)
Future<void> disconnect()
Future<void> triggerBuzzer(String command)  // BEEP, BUZZ, LONG, OFF
```

#### Properties
```dart
ScaleConnectionState connectionState    // Current state
bool isConnected                        // Connection status
bool isAuthenticated                    // Authentication status
ScaleDevice? connectedDevice           // Currently connected device
List<ScaleDevice> availableDevices     // Discovered devices
```

### API Service (`KgitonApiService`)

#### Services
- **`auth`** - Authentication (login, register, logout, refresh token)
- **`owner`** - Item and license operations (Owner role)
- **`cart`** - Session-based cart with multiple entries support
- **`transaction`** - Transaction history and statistics

#### Features
- ✅ Automatic JWT token management
- ✅ Token refresh on expiry
- ✅ Local storage persistence (SharedPreferences)
- ✅ Comprehensive error handling
- ✅ Type-safe models with JSON serialization
- ✅ HTTP request/response interceptors

For detailed API documentation, see:
- [Device Integration Guide](docs/02_DEVICE_INTEGRATION.md)
- [API Integration Guide](docs/03_API_INTEGRATION.md)
- [Cart & Transaction Guide](docs/04_CART_TRANSACTION.md)

## Example Application

The SDK includes a complete example app demonstrating all features:

```bash
cd example/timbangan
flutter pub get
flutter run
```

**Example Features:**
- Device scanning and connection
- Real-time weight display
- License authentication
- Cart management with multiple items
- Checkout with QRIS/Cash payment
- Transaction history
- Material Design 3 UI

## Project Structure

```
kgiton_sdk/
├── lib/
│   ├── kgiton_sdk.dart              # Main export file
│   └── src/
│       ├── kgiton_scale_service.dart # Device service
│       ├── api/                      # API client
│       │   ├── kgiton_api_service.dart
│       │   ├── services/            # Auth, Cart, Transaction, etc.
│       │   └── models/              # Type-safe models
│       ├── models/                   # Device models
│       ├── constants/                # Device & API constants
│       ├── exceptions/               # Error handling
│       └── utils/                    # Helper utilities
├── docs/                             # Documentation
├── example/                          # Example app
└── test/                             # Unit tests
```

## Architecture

- **Design Pattern**: Stream-based reactive architecture
- **State Management**: Built-in streams for real-time updates
- **Device Stack**: Built on `kgiton_ble_sdk` (proprietary)
- **HTTP Client**: Dart `http` package with interceptors
- **Storage**: SharedPreferences for token persistence
- **Platform Support**: iOS 12.0+ and Android 21+ (API Level 21)
- **Language**: Pure Dart with platform channels
- **Code Size**: ~52KB source code (minified)

## Support

For authorized users:
- 🐛 [Report Issues](https://github.com/kgiton/flutter-kgiton-sdk/issues)
- 📧 Technical Support: support@kgiton.com
- 🔒 Security Issues: support@kgiton.com
- 🌐 Website: https://www.kgiton.com

## License

**PROPRIETARY SOFTWARE - ALL RIGHTS RESERVED**

This software is the proprietary property of PT KGiTON and is protected by copyright law.

### Usage Restrictions

- ❌ **NOT Open Source** - Source code is confidential
- ❌ **NOT Free to Use** - Requires explicit authorization from PT KGiTON
- ❌ **NO Redistribution** - Cannot be shared or distributed
- ❌ **NO Modifications** - Cannot be altered or reverse-engineered
- ✅ **Commercial License Available** - Contact PT KGiTON for licensing

### License Summary

Copyright (c) 2025 PT KGiTON. All Rights Reserved.

This SDK may only be used by individuals or organizations explicitly authorized 
by PT KGiTON. Unauthorized use, reproduction, or distribution is strictly 
prohibited and may result in legal action.

See [LICENSE](LICENSE) file for complete terms and conditions.

### How to Obtain a License

📋 **Read [AUTHORIZATION.md](AUTHORIZATION.md)** for complete licensing information.

**Contact Information**:
- 📧 Email: support@kgiton.com
- 🌐 Website: https://www.kgiton.com
- 🔒 Security: support@kgiton.com

---

<div align="center">

**SDK Version:** 1.2.0  
**License:** Proprietary - Commercial Use Only  
**Platform:** iOS 12.0+ | Android 21+  
**Flutter:** ≥3.0.0 | Dart ≥3.10.0  

**API Base URL:** `https://api.example.com`  
**API Version:** `v1.2.0` (Dual Pricing Support)

---

© 2025 PT KGiTON. All rights reserved.

Unauthorized use, reproduction, or distribution is strictly prohibited.

</div>
