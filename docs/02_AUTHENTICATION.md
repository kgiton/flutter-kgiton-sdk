# 🔐 Authentication

Panduan lengkap untuk autentikasi pengguna dengan KGiTON SDK.

---

## 📋 Overview

Sistem autentikasi KGiTON menggunakan:
- **JWT Token** - Access token untuk API calls (berlaku 24 jam)
- **API Key** - Untuk device-to-device communication
- **License Key** - Diperlukan saat registrasi

---

## 🆕 Register (Daftar Akun Baru)

Untuk mendaftar, pengguna harus memiliki license key yang valid.

### Menggunakan API Service

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

Future<void> registerUser() async {
  final api = KgitonApiService(baseUrl: 'https://api.example.com');
  
  try {
    final authData = await api.auth.register(
      email: 'user@example.com',
      password: 'SecurePassword123!',
      confirmPassword: 'SecurePassword123!',
      licenseKey: 'XXXX-XXXX-XXXX-XXXX',
      referralCode: 'REFCODE123', // Optional
    );
    
    print('✅ Register berhasil!');
    print('User ID: ${authData.user.id}');
    print('Email: ${authData.user.email}');
    print('Token: ${authData.accessToken}');
    print('API Key: ${authData.user.apiKey}');
    print('Expires at: ${authData.expiresAt}');
    
    // Token sudah otomatis di-inject ke client
    // Bisa langsung gunakan api untuk request berikutnya
    
  } on KgitonApiException catch (e) {
    print('❌ Register gagal: ${e.message}');
  }
}
```

### Menggunakan Helper (Recommended)

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

Future<void> registerWithHelper() async {
  final prefs = await SharedPreferences.getInstance();
  final auth = KgitonAuthHelper(prefs, baseUrl: 'https://api.kgiton.com');
  
  final result = await auth.register(
    email: 'user@example.com',
    password: 'SecurePassword123!',
    confirmPassword: 'SecurePassword123!',
    licenseKey: 'XXXX-XXXX-XXXX-XXXX',
  );
  
  if (result['success']) {
    print('✅ Register berhasil!');
    final authData = result['data'] as AuthData;
    
    // Token dan API key otomatis disimpan ke SharedPreferences
    // Session otomatis ter-restore saat app restart
    
  } else {
    print('❌ Register gagal: ${result['message']}');
  }
}
```

---

## 🔑 Login

### Menggunakan API Service

```dart
Future<void> loginUser() async {
  final api = KgitonApiService(baseUrl: 'https://api.example.com');
  
  try {
    final authData = await api.auth.login(
      email: 'user@example.com',
      password: 'SecurePassword123!',
    );
    
    print('✅ Login berhasil!');
    print('Token: ${authData.accessToken}');
    print('API Key: ${authData.user.apiKey}');
    
    // Simpan token untuk digunakan nanti
    // api.setAccessToken(authData.accessToken);
    // api.setApiKey(authData.user.apiKey);
    
  } on KgitonApiException catch (e) {
    print('❌ Login gagal: ${e.message}');
  }
}
```

### Menggunakan Helper (Recommended)

```dart
Future<void> loginWithHelper() async {
  final prefs = await SharedPreferences.getInstance();
  final auth = KgitonAuthHelper(prefs, baseUrl: 'https://api.example.com');
  
  final result = await auth.login('user@example.com', 'SecurePassword123!');
  
  if (result['success']) {
    print('✅ Login berhasil!');
    
    // Token otomatis disimpan
    print('User: ${auth.getUserEmail()}');
    print('API Key: ${auth.getApiKey()}');
    
  } else {
    print('❌ Login gagal: ${result['message']}');
  }
}
```

---

## 🚪 Logout

### Menggunakan API Service

```dart
Future<void> logoutUser() async {
  try {
    await api.auth.logout();
    print('✅ Logout berhasil');
    
    // Clear local tokens
    api.clearCredentials();
    
  } catch (e) {
    print('❌ Logout error: $e');
  }
}
```

### Menggunakan Helper

```dart
Future<void> logoutWithHelper() async {
  final result = await auth.logout();
  
  if (result['success']) {
    print('✅ ${result['message']}');
    // Tokens otomatis dihapus dari storage
  }
}
```

---

## 🔄 Session Management

### Check Login Status

```dart
// Dengan Helper
Future<bool> isLoggedIn() async {
  return await auth.isLoggedIn();
}
```

### Restore Session

Panggil ini saat app startup untuk restore session sebelumnya:

```dart
Future<void> restoreSession() async {
  final prefs = await SharedPreferences.getInstance();
  final auth = KgitonAuthHelper(prefs, baseUrl: 'https://api.example.com');
  
  final restored = await auth.restoreSession();
  
  if (restored) {
    print('✅ Session restored');
    print('User: ${auth.getUserEmail()}');
    
    // Dapatkan authenticated API service
    final api = auth.getAuthenticatedApiService()!;
    
  } else {
    print('⚠️ No session found, need to login');
  }
}
```

### Token Expiration

```dart
// Check token expiration
final expiresAt = auth.getTokenExpiresAt();

if (expiresAt != null) {
  final now = DateTime.now();
  
  if (now.isAfter(expiresAt)) {
    print('⚠️ Token expired, please login again');
  } else {
    final remaining = expiresAt.difference(now);
    print('Token valid for: ${remaining.inHours} hours');
  }
}
```

---

## 🔑 Password Reset

### Request Reset Email

```dart
Future<void> forgotPassword() async {
  final result = await auth.forgotPassword('user@example.com');
  
  if (result['success']) {
    print('✅ ${result['message']}');
    // Email reset password telah dikirim
  } else {
    print('❌ ${result['message']}');
  }
}
```

### Reset Password with Token

```dart
Future<void> resetPassword(String token) async {
  final result = await auth.resetPassword(
    token: token,
    password: 'NewSecurePassword123!',
    confirmPassword: 'NewSecurePassword123!',
  );
  
  if (result['success']) {
    print('✅ Password berhasil direset');
    // Redirect ke login page
  } else {
    print('❌ ${result['message']}');
  }
}
```

---

## 🔐 API Key Management

API Key digunakan untuk autentikasi device tanpa login.

### Regenerate API Key

```dart
Future<void> regenerateApiKey() async {
  final result = await auth.regenerateApiKey();
  
  if (result['success']) {
    print('✅ New API Key: ${result['apiKey']}');
    // API key baru otomatis disimpan
  } else {
    print('❌ ${result['message']}');
  }
}
```

### Revoke API Key

```dart
Future<void> revokeApiKey() async {
  final result = await auth.revokeApiKey();
  
  if (result['success']) {
    print('✅ API Key telah direvoke');
    // Semua device yang pakai API key ini akan logout
  }
}
```

---

## 📝 Auth Data Model

```dart
class AuthData {
  final User user;
  final String accessToken;
  final DateTime expiresAt;
}

class User {
  final String id;
  final String email;
  final String? apiKey;
  final String? referralCode;
  final DateTime createdAt;
}
```

---

## ⚠️ Error Handling

```dart
try {
  await api.auth.login(email: email, password: password);
  
} on KgitonApiException catch (e) {
  switch (e.statusCode) {
    case 400:
      print('Invalid request: ${e.message}');
      break;
    case 401:
      print('Invalid credentials');
      break;
    case 404:
      print('User not found');
      break;
    case 429:
      print('Too many attempts, please wait');
      break;
    default:
      print('Error: ${e.message}');
  }
}
```

---

## 🔗 Next Steps

- [License & Token](03_LICENSE_TOKEN.md) - Kelola license dan token
- [Top-up & Payment](04_TOPUP_PAYMENT.md) - Top-up token
- [BLE Integration](05_BLE_INTEGRATION.md) - Koneksi ke timbangan
