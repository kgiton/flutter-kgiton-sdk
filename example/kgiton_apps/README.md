# KGiTON Apps

Flutter application integrated with KGiTON SDK for scale device management and authentication.

## ⭐ New: Ownership Verification

**Version 1.1.0** includes enhanced security with **Ownership Verification** feature:

- 🔒 **Secure Connections**: Only legitimate license owners can connect to their devices
- ✅ **Auto Verification**: Automatically enabled after login
- 🛡️ **Multi-tenant Safe**: Prevents unauthorized access even if license key is known
- 📝 **Audit Trail**: All connections verified with user identity

See [OWNERSHIP_VERIFICATION_IMPLEMENTATION.md](OWNERSHIP_VERIFICATION_IMPLEMENTATION.md) for details.

## Features

- 🔐 **Authentication System**: Login and Registration with license key
- 🔒 **Ownership Verification**: Secure device access with user authentication (NEW)
- 📱 **Bluetooth Integration**: Connect to KGiTON scale devices via QR scan
- ⚖️ **Real-time Weight**: Stream weight data from connected scales
- 🛒 **Shopping Cart**: Add items to cart and manage transactions
- 📦 **Item Management**: Create and manage weighing items
- 💰 **Transaction History**: View and track all transactions
- 👤 **User Profile**: Manage account and settings
- 🎨 **Modern UI**: Material Design 3 with KGiTON branding
- 🌍 **Clean Architecture**: Domain/Data/Presentation separation

## App Structure

### Main Navigation (Bottom Nav Bar)
1. **Weighing** - Scale device connection and real-time weight display
2. **Cart** - Shopping cart management
3. **Items** - Item catalog and management
4. **Transaction** - Transaction history with filter (All/Paid/Pending)
5. **Profile** - User profile and settings

## Tech Stack

- **Framework**: Flutter 3.0+, Dart 3.10+
- **State Management**: flutter_bloc ^8.1.6
- **Routing**: go_router ^14.7.0
- **DI**: get_it ^8.0.3
- **SDK**: KGiTON Flutter SDK (from GitHub)
- **QR Scanner**: mobile_scanner ^5.2.3
- **Input Formatter**: mask_text_input_formatter ^2.9.0
- **Architecture**: Clean Architecture with BLoC pattern

## Setup

### 1. Prerequisites

- Flutter SDK ≥3.0.0
- Dart SDK ≥3.10.0
- Android Studio / Xcode
- KGiTON SDK access (contact support@kgiton.com)

### 2. Installation

```bash
# Clone repository
git clone <repository-url>
cd kgiton_apps

# Install dependencies
flutter pub get

# Run app
flutter run
```

### 3. Configuration

#### Android (`android/app/src/main/AndroidManifest.xml`)

Permissions sudah ditambahkan:
```xml
<!-- Bluetooth Permissions -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- Location Permissions (Required for Android 10-11) -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Internet -->
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS (`ios/Runner/Info.plist`)

Usage descriptions sudah ditambahkan:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app requires wireless access to connect to the KGiTON scale device</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location permission is required to discover nearby Bluetooth devices</string>
```

### 4. App Configuration

Edit `lib/core/config/app_config.dart` untuk API configuration:

```dart
class AppConfig {
  static const String apiBaseUrl = 'https://api.example.com';
  static const String apiVersion = 'v1.0.0';
  // ... other configs
}
```

## Permissions

### Runtime Permissions

Aplikasi akan otomatis meminta permission saat pertama kali dibuka:

1. **Bluetooth Permission** - Untuk connect ke scale device
2. **Location Permission** - Required untuk BLE scan di Android 10-11
3. **Internet Permission** - Untuk API calls

Permission diminta di `SplashPage` menggunakan `PermissionHelper` dari KGiTON SDK.

### Android Platform Specific

- **Android 12+**: Memerlukan `BLUETOOTH_SCAN` dan `BLUETOOTH_CONNECT`
- **Android 10-11**: Memerlukan `ACCESS_FINE_LOCATION` + Location Service **HARUS AKTIF**
- **Android 9-**: Memerlukan `ACCESS_FINE_LOCATION`

### iOS Platform Specific

- **iOS 12+**: Memerlukan Bluetooth permission
- Location permission untuk device discovery

## Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── di/              # Dependency injection
│   ├── error/           # Error handling
│   ├── network/         # Network utilities
│   ├── routes/          # App routing
│   ├── theme/           # Theme & colors
│   └── usecases/        # Base use case
├── features/
│   ├── auth/            # Authentication feature
│   │   ├── data/        # Data layer (models, datasources, repos)
│   │   ├── domain/      # Domain layer (entities, usecases)
│   │   └── presentation/# UI (BLoC, pages, widgets)
│   ├── home/            # Home feature
│   └── splash/          # Splash screen
└── main.dart            # App entry point
```

## License

KGiTON Apps menggunakan KGiTON SDK yang merupakan proprietary software.
License diperlukan dari PT KGiTON.

Contact: support@kgiton.com

## Support

- 📧 Email: support@kgiton.com
- 🌐 Website: https://www.kgiton.com

---

© 2025 PT KGiTON. All Rights Reserved.
