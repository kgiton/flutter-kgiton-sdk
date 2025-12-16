# 🔐 Ownership Verification

## Overview

Fitur **Ownership Verification** memastikan bahwa hanya pemilik sah yang dapat terhubung ke perangkat timbangan mereka, bahkan jika orang lain memiliki akses ke license key.

### Masalah yang Diselesaikan

**Sebelumnya:**
```dart
// Siapa saja yang memiliki license key bisa connect
final response = await scale.connectWithLicenseKey(
  deviceId: 'KGITON_xxx',
  licenseKey: 'ABC-123-XYZ', // Jika bocor, siapa saja bisa pakai
);
```

**Sekarang:**
```dart
// Hanya pemilik sah yang tercatat di sistem yang bisa connect
final scale = KGiTONScaleService(apiService: apiService); // Authenticated API
final response = await scale.connectWithLicenseKey(
  deviceId: 'KGITON_xxx',
  licenseKey: 'ABC-123-XYZ', // Dicek: apakah user ini pemilik license ini?
);

if (!response.success) {
  print(response.message); // "Anda bukan pemilik sah dari license key ini"
}
```

---

## Cara Kerja

### 1. Alur Verifikasi

```
User Request Connect
       ↓
[SDK] Cek API service tersedia?
       ↓ (Ya)
[SDK] Panggil verifyLicenseOwnership()
       ↓
[API] GET /owner/licenses (daftar license milik user)
       ↓
[SDK] Cek: license_key ada di daftar?
       ↓
   ┌─────┴─────┐
   │           │
  Ya          Tidak
   │           │
   ↓           ↓
Connect    Reject dengan error
Allowed    "Anda bukan pemilik sah..."
```

### 2. Implementasi

#### Step 1: Inisialisasi dengan API Service

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// Setelah user login
final apiService = KgitonApiService(
  baseUrl: 'https://api.example.com',
  accessToken: authData.accessToken,
  refreshToken: authData.refreshToken,
);
```

#### Step 2: Buat Scale Service dengan Verifikasi

```dart
// Cara 1: Saat konstruksi
final scale = KGiTONScaleService(apiService: apiService);

// Cara 2: Set setelah login
final scale = KGiTONScaleService();
// ... user login ...
scale.setApiService(apiService);
```

#### Step 3: Connect (Otomatis Terverifikasi)

```dart
final response = await scale.connectWithLicenseKey(
  deviceId: device.id,
  licenseKey: licenseKey,
);

if (response.success) {
  // Koneksi berhasil & ownership terverifikasi
  print('Terhubung sebagai pemilik sah!');
} else {
  // Koneksi ditolak
  print('Ditolak: ${response.message}');
  // Kemungkinan pesan:
  // - "Anda bukan pemilik sah dari license key ini"
  // - "Gagal memverifikasi kepemilikan license"
  // - "License tidak valid"
}
```

---

## Contoh Lengkap

### Skenario: Aplikasi dengan Login

```dart
class ScaleConnectionService {
  KGiTONScaleService? _scaleService;
  KgitonApiService? _apiService;
  
  // 1. Saat user login
  Future<void> login(String email, String password) async {
    final api = KgitonApiService(baseUrl: 'https://api.example.com');
    
    final authData = await api.auth.login(
      email: email,
      password: password,
    );
    
    // Set tokens
    api.setTokens(
      accessToken: authData.accessToken,
      refreshToken: authData.refreshToken,
    );
    
    _apiService = api;
    
    // Initialize scale service dengan API (untuk verifikasi)
    _scaleService = KGiTONScaleService(apiService: api);
  }
  
  // 2. Saat user mau connect ke timbangan
  Future<bool> connectToScale(String deviceId, String licenseKey) async {
    if (_scaleService == null) {
      throw Exception('User belum login');
    }
    
    final response = await _scaleService!.connectWithLicenseKey(
      deviceId: deviceId,
      licenseKey: licenseKey,
    );
    
    if (!response.success) {
      // Log security event jika ada upaya akses tidak sah
      if (response.message.contains('pemilik sah')) {
        _logSecurityEvent('Unauthorized access attempt', {
          'deviceId': deviceId,
          'licenseKey': licenseKey,
        });
      }
    }
    
    return response.success;
  }
  
  // 3. Saat user logout
  Future<void> logout() async {
    await _scaleService?.disconnect();
    _scaleService?.clearApiService();
    await _apiService?.auth.logout();
    
    _scaleService = null;
    _apiService = null;
  }
  
  void _logSecurityEvent(String event, Map<String, dynamic> data) {
    // Log to analytics or security system
    print('SECURITY: $event - $data');
  }
}
```

---

## Error Handling

### Kemungkinan Error

1. **User bukan pemilik license**
   ```dart
   // Response: success = false
   // Message: "Anda bukan pemilik sah dari license key ini"
   ```

2. **Gagal mengambil data license (network error)**
   ```dart
   // Response: success = false
   // Message: "Gagal memverifikasi kepemilikan license: [network error]"
   ```

3. **User belum login (no API service)**
   ```dart
   // Jika API service tidak di-set, verifikasi di-skip
   // Backward compatible dengan mode lama
   ```

### Best Practices Error Handling

```dart
Future<void> connectWithErrorHandling(String deviceId, String licenseKey) async {
  try {
    final response = await scale.connectWithLicenseKey(
      deviceId: deviceId,
      licenseKey: licenseKey,
    );
    
    if (!response.success) {
      // Handle specific errors
      if (response.message.contains('pemilik sah')) {
        showDialog(
          title: 'Akses Ditolak',
          message: 'License key ini bukan milik Anda.\n'
                  'Silakan gunakan license key yang sah.',
        );
      } else if (response.message.contains('memverifikasi')) {
        showDialog(
          title: 'Koneksi Bermasalah',
          message: 'Tidak dapat memverifikasi kepemilikan.\n'
                  'Periksa koneksi internet Anda.',
        );
      } else {
        showDialog(
          title: 'Koneksi Gagal',
          message: response.message,
        );
      }
      return;
    }
    
    // Success
    showSnackBar('Terhubung ke timbangan!');
    
  } catch (e) {
    // Handle exceptions
    showDialog(
      title: 'Error',
      message: 'Terjadi kesalahan: $e',
    );
  }
}
```

---

## Keamanan

### ✅ Keuntungan

1. **Mencegah Akses Tidak Sah**
   - Orang lain tidak bisa pakai license key meskipun tahu

2. **Audit Trail**
   - Setiap koneksi terverifikasi dengan identitas user
   - Mudah tracking siapa yang connect

3. **Multi-Tenant Safe**
   - Owner yang berbeda tidak bisa akses timbangan satu sama lain
   - Bahkan dengan license key yang sama (jika ada kebocoran)

4. **Keamanan Berlapis**
   - Layer 1: Verifikasi kepemilikan di API
   - Layer 2: Autentikasi license key di device
   - Layer 3: BLE connection security

### 🔄 Backward Compatibility

Fitur ini **optional** dan backward compatible:

```dart
// Mode LAMA (tanpa verifikasi) - masih berfungsi
final scale1 = KGiTONScaleService(); // Tanpa apiService
await scale1.connectWithLicenseKey(...); // Verifikasi di-skip

// Mode BARU (dengan verifikasi) - lebih aman
final scale2 = KGiTONScaleService(apiService: api); // Dengan apiService
await scale2.connectWithLicenseKey(...); // Otomatis diverifikasi
```

---

## FAQ

### Q: Apakah wajib menggunakan ownership verification?

**A:** Tidak wajib, tetapi **sangat direkomendasikan** untuk keamanan. Tanpa verifikasi, siapa saja yang memiliki license key bisa connect.

### Q: Bagaimana jika tidak ada koneksi internet?

**A:** Verifikasi memerlukan internet. Jika API call gagal, koneksi akan ditolak. Untuk offline mode, jangan set `apiService`.

### Q: Apakah verifikasi dilakukan setiap kali connect?

**A:** Ya, setiap kali `connectWithLicenseKey` dipanggil dengan API service aktif.

### Q: Berapa lama proses verifikasi?

**A:** Biasanya < 1 detik (tergantung kecepatan internet). API call dilakukan sekali saat connect.

### Q: Bagaimana cara disable verifikasi untuk testing?

**A:** Jangan set API service atau gunakan `clearApiService()`:

```dart
final scale = KGiTONScaleService(); // No API = no verification
// atau
scale.clearApiService(); // Disable verifikasi
```

---

## Migration Guide

### Dari Versi Lama ke Versi Baru

#### Sebelum (tanpa verifikasi)

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final scale = KGiTONScaleService();
  
  Future<void> connect() async {
    await scale.connectWithLicenseKey(
      deviceId: 'KGITON_xxx',
      licenseKey: 'ABC-123',
    );
  }
}
```

#### Sesudah (dengan verifikasi)

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late KGiTONScaleService scale;
  KgitonApiService? apiService;
  
  @override
  void initState() {
    super.initState();
    // Initialize tanpa API dulu
    scale = KGiTONScaleService();
  }
  
  Future<void> login(String email, String password) async {
    // 1. Login
    apiService = KgitonApiService(baseUrl: 'https://api.example.com');
    final authData = await apiService!.auth.login(
      email: email,
      password: password,
    );
    
    apiService!.setTokens(
      accessToken: authData.accessToken,
      refreshToken: authData.refreshToken,
    );
    
    // 2. Enable verifikasi
    scale.setApiService(apiService!);
  }
  
  Future<void> connect() async {
    // Sekarang dengan verifikasi otomatis
    final response = await scale.connectWithLicenseKey(
      deviceId: 'KGITON_xxx',
      licenseKey: 'ABC-123',
    );
    
    if (!response.success) {
      print('Ditolak: ${response.message}');
    }
  }
  
  Future<void> logout() async {
    await scale.disconnect();
    scale.clearApiService();
    await apiService?.auth.logout();
  }
}
```

---

## Testing

### Unit Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('Ownership Verification', () {
    late KGiTONScaleService scaleService;
    late MockKgitonApiService mockApi;
    
    setUp(() {
      mockApi = MockKgitonApiService();
      scaleService = KGiTONScaleService(apiService: mockApi);
    });
    
    test('should allow connection when user owns license', () async {
      // Arrange
      when(mockApi.owner.listOwnLicenses()).thenAnswer((_) async => 
        OwnerLicensesData(
          licenses: [
            License(
              id: '1',
              licenseKey: 'ABC-123',
              isUsed: true,
              assignedTo: 'user-id',
              createdAt: DateTime.now(),
            ),
          ],
          count: 1,
        ),
      );
      
      // Act
      final response = await scaleService.connectWithLicenseKey(
        deviceId: 'KGITON_xxx',
        licenseKey: 'ABC-123',
      );
      
      // Assert
      expect(response.success, true);
    });
    
    test('should reject connection when user does not own license', () async {
      // Arrange
      when(mockApi.owner.listOwnLicenses()).thenAnswer((_) async => 
        OwnerLicensesData(
          licenses: [
            License(
              id: '1',
              licenseKey: 'XYZ-789', // Different license
              isUsed: true,
              assignedTo: 'user-id',
              createdAt: DateTime.now(),
            ),
          ],
          count: 1,
        ),
      );
      
      // Act
      final response = await scaleService.connectWithLicenseKey(
        deviceId: 'KGITON_xxx',
        licenseKey: 'ABC-123',
      );
      
      // Assert
      expect(response.success, false);
      expect(response.message, contains('pemilik sah'));
    });
  });
}
```

---

## Summary

Ownership Verification adalah fitur keamanan yang:

✅ **Mencegah** akses tidak sah ke perangkat  
✅ **Memverifikasi** kepemilikan license key melalui API  
✅ **Optional** dan backward compatible  
✅ **Mudah** diimplementasikan (cukup tambah `apiService`)  
✅ **Aman** dengan keamanan berlapis  

**Recommendation:** Selalu gunakan ownership verification untuk aplikasi production.

---

## Related Documentation

- [Getting Started](01_GETTING_STARTED.md)
- [Device Integration](02_DEVICE_INTEGRATION.md)
- [API Integration](03_API_INTEGRATION.md)
- [Security Checklist](../SECURITY_CHECKLIST.md)
