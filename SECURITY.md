# 🛡️ Security Policy

Kebijakan keamanan untuk KGiTON Flutter SDK.

---

## 🔒 Security Overview

KGiTON SDK menerapkan praktik keamanan berikut:

| Layer | Security Measure |
|-------|------------------|
| Transport | HTTPS/TLS 1.3 |
| Authentication | JWT + API Key |
| Authorization | License-based access |
| Data Storage | Encrypted local storage |
| BLE | License key authentication |

---

## 🔐 Authentication Security

### JWT Token

- **Expiration**: 24 jam
- **Algorithm**: HS256
- **Storage**: SharedPreferences (encrypted on supported platforms)

### API Key

- **Usage**: Device-to-device communication
- **Regeneration**: Dapat di-generate ulang kapan saja
- **Revocation**: Dapat di-revoke untuk invalidasi

### Best Practices

```dart
// ✅ DO: Store tokens securely
final prefs = await SharedPreferences.getInstance();
await prefs.setString('token', authData.accessToken);

// ❌ DON'T: Log tokens
print('Token: ${authData.accessToken}'); // NEVER do this in production

// ✅ DO: Clear on logout
await authHelper.logout(); // Clears all stored credentials

// ✅ DO: Check expiration
if (await authHelper.isLoggedIn()) {
  // Token still valid
}
```

---

## 📡 Network Security

### HTTPS Only

SDK hanya berkomunikasi melalui HTTPS:

```dart
// ✅ Correct
final api = KgitonApiService(baseUrl: 'https://api.example.com');

// ❌ Wrong - HTTP not supported
final api = KgitonApiService(baseUrl: 'http://api.example.com');
```

### Certificate Pinning

Untuk keamanan tambahan, implementasikan certificate pinning:

```dart
// Example with dio
final dio = Dio();
(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
  client.badCertificateCallback = (cert, host, port) {
    // Verify certificate
    return cert.sha256.toString() == 'YOUR_CERT_SHA256';
  };
  return client;
};
```

---

## 🔵 BLE Security

### License Authentication

Koneksi BLE memerlukan license key yang valid:

```dart
// Device akan menolak koneksi tanpa license key yang benar
await scaleService.connect(licenseKey: 'VALID-LICENSE-KEY');
```

### Data Encryption

- Data berat dikirim terenkripsi via BLE
- Hanya device dengan license key yang cocok yang dapat membaca data

---

## 💾 Data Storage

### Sensitive Data

| Data | Storage | Encryption |
|------|---------|------------|
| Access Token | SharedPreferences | Platform-dependent |
| API Key | SharedPreferences | Platform-dependent |
| User Email | SharedPreferences | No |
| License Key | Not stored locally | N/A |

### Secure Storage Recommendation

Untuk keamanan maksimal, gunakan `flutter_secure_storage`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Store token
await storage.write(key: 'access_token', value: token);

// Read token
final token = await storage.read(key: 'access_token');

// Delete on logout
await storage.deleteAll();
```

---

## 🚨 Vulnerability Reporting

### Reporting Process

Jika Anda menemukan kerentanan keamanan:

1. **Jangan** publish secara publik
2. **Email** ke: support@kgiton.com
3. **Sertakan**:
   - Deskripsi detail kerentanan
   - Langkah reproduksi
   - Potensi dampak
   - Saran perbaikan (jika ada)

### Response Timeline

| Stage | Timeline |
|-------|----------|
| Acknowledgment | 24-48 jam |
| Initial Assessment | 3-5 hari kerja |
| Fix Development | Tergantung severity |
| Notification | Setelah fix released |

### Severity Levels

| Level | Description | Response |
|-------|-------------|----------|
| Critical | RCE, data breach | Immediate |
| High | Auth bypass, injection | 24-48 jam |
| Medium | Information disclosure | 1 minggu |
| Low | Minor issues | Next release |

---

## ✅ Security Checklist

### Development

- [ ] Gunakan HTTPS untuk semua API calls
- [ ] Jangan log sensitive data (tokens, passwords)
- [ ] Implementasikan token expiration handling
- [ ] Clear credentials on logout
- [ ] Validasi input sebelum kirim ke API

### Production

- [ ] Enable ProGuard/R8 (Android)
- [ ] Enable code obfuscation
- [ ] Remove debug logs
- [ ] Implement certificate pinning
- [ ] Use secure storage for tokens

### Code Review

- [ ] No hardcoded credentials
- [ ] No sensitive data in source control
- [ ] Proper error handling (no stack traces to user)
- [ ] Input validation

---

## 🔄 Security Updates

SDK akan di-update untuk patch keamanan. Pastikan selalu menggunakan versi terbaru:

```yaml
dependencies:
  kgiton_sdk:
    git:
      url: https://github.com/kgiton/flutter-kgiton-sdk.git
      ref: main  # Always use latest
```

---

## 📞 Security Contact

| Purpose | Contact |
|---------|---------|
| Vulnerability Report | support@kgiton.com |
| Security Questions | support@kgiton.com |

---

<p align="center">
  <strong>PT KGiTON</strong> - Security First
</p>
