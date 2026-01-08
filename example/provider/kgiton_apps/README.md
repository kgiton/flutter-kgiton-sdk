# KGiTON Example App - Provider State Management

Contoh aplikasi Flutter menggunakan **KGiTON SDK** dengan **Provider** sebagai state management.

## 📋 Fitur

- ✅ Register & Login dengan License Key
- ✅ Scan QR Code untuk License Key
- ✅ Scan & Connect device BLE
- ✅ Real-time weight monitoring
- ✅ Buzzer control
- ✅ Theme KGiTON (Light & Dark)

## 🏗️ Struktur Project

```
lib/
├── main.dart                    # Entry point & Provider setup
├── src/
│   ├── config/
│   │   ├── constants.dart       # Konfigurasi API & App
│   │   └── theme.dart           # Theme KGiTON
│   │
│   ├── providers/
│   │   ├── auth_provider.dart   # State autentikasi
│   │   └── scale_provider.dart  # State koneksi BLE
│   │
│   └── screens/
│       ├── splash_screen.dart   # Splash dengan auto-navigate
│       ├── auth/
│       │   ├── auth_screen.dart # Login/Register screen
│       │   └── widgets/
│       │       ├── login_form.dart
│       │       └── register_form.dart
│       ├── home/
│       │   └── home_screen.dart # Dashboard utama
│       └── device/
│           └── device_screen.dart # Scan & Connect device
```

## 🚀 Setup

### 1. Install Dependencies

```bash
cd example/provider/kgiton_apps
flutter pub get
```

### 2. Generate App Icon

```bash
flutter pub run flutter_launcher_icons
```

### 3. Run App

```bash
flutter run
```

## 📚 Cara Menggunakan Provider

### Setup Provider di main.dart

```dart
// MultiProvider membungkus seluruh app
MultiProvider(
  providers: [
    // Provider untuk autentikasi
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    
    // Provider dengan dependency ke provider lain
    ChangeNotifierProxyProvider<AuthProvider, ScaleProvider>(
      create: (_) => ScaleProvider(),
      update: (_, authProvider, scaleProvider) {
        scaleProvider?.updateApiService(authProvider.apiService);
        return scaleProvider ?? ScaleProvider();
      },
    ),
  ],
  child: MaterialApp(...),
)
```

### Mengakses Provider di Widget

```dart
// READ - untuk memanggil method (tidak listen perubahan)
context.read<AuthProvider>().login(email: email, password: password);

// WATCH - untuk listen perubahan (rebuild widget saat berubah)
final isLoading = context.watch<AuthProvider>().isLoading;

// SELECT - untuk listen property spesifik (optimal)
final userName = context.select<AuthProvider, String?>((auth) => auth.user?.name);

// CONSUMER - untuk rebuild sebagian widget
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return Text(authProvider.user?.name ?? 'Guest');
  },
)
```

### Membuat Provider

```dart
class AuthProvider extends ChangeNotifier {
  // Private state
  User? _user;
  AuthStatus _status = AuthStatus.initial;
  
  // Getters
  User? get user => _user;
  AuthStatus get status => _status;
  bool get isLoggedIn => _user != null;
  
  // Methods yang mengubah state
  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    notifyListeners(); // Notify UI untuk rebuild
    
    try {
      final result = await apiService.auth.login(email: email, password: password);
      _user = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }
}
```

## 🎨 Kustomisasi Theme

Edit `lib/src/config/theme.dart`:

```dart
class KGiTONColors {
  // Primary Colors
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF66BB6A);
  
  // Ubah warna sesuai kebutuhan...
}
```

## 🔧 Konfigurasi API

Edit `lib/src/config/constants.dart`:

```dart
class AppConstants {
  // Ganti dengan URL API production Anda
  static const String apiBaseUrl = 'https://api.kgiton.com';
}
```

## 📱 Screenshots

- Splash Screen dengan animasi logo
- Login/Register dengan tab
- Dashboard dengan weight display
- Scan device dengan signal strength

## 📝 Catatan Developer

1. **Provider vs Consumer**: Gunakan `Consumer` untuk rebuild parsial, `watch` untuk keseluruhan widget
2. **Read vs Watch**: `read` untuk method calls, `watch` untuk UI rebuild
3. **ProxyProvider**: Untuk provider yang bergantung pada provider lain
4. **notifyListeners()**: Panggil setelah mengubah state untuk trigger rebuild

## 🔗 Referensi

- [Provider Package](https://pub.dev/packages/provider)
- [KGiTON SDK Documentation](../../../docs/)
- [Flutter State Management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)
