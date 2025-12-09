# Troubleshooting - KGiTON SDK

Solusi untuk masalah umum dalam menggunakan KGiTON SDK.

## 📋 Kategori

- [Permission Issues](#permission-issues)
- [Device Connection Problems](#device-connection-problems)
- [Android 10-11 Specific](#android-10-11-specific)
- [API Errors](#api-errors)
- [Weight Reading Issues](#weight-reading-issues)

---

## Permission Issues

### Problem: Permission Denied saat Scan

**Symptoms:**
- Device scan tidak berjalan
- Error "Permission denied" di log

**Solution:**

1. **Cek AndroidManifest.xml**
```xml
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

2. **Request runtime permissions:**
```dart
final granted = await PermissionHelper.requestBLEPermissions();
if (!granted) {
  await PermissionHelper.openAppSettings();
}
```

3. **Android 10-11**: Location Service harus **AKTIF** di device settings

### Problem: Permission sudah granted tapi tetap tidak bisa scan

**Solution:**
1. Restart aplikasi
2. Check Location Service aktif (Android 10-11)
3. Re-install aplikasi
4. Clear app data & cache

---

## Device Connection Problems

### Problem: Device tidak ditemukan saat scan

**Checklist:**
- ✅ Timbangan menyala dan dalam mode pairing
- ✅ Jarak < 10 meter
- ✅ Permissions granted
- ✅ Location Service ON (Android 10-11)
- ✅ Tidak ada device lain yang sedang connect

**Solution:**
```dart
// Increase scan timeout
await scaleService.scanForDevices(timeout: Duration(seconds: 15));

// Restart scan
scaleService.stopScan();
await Future.delayed(Duration(seconds: 2));
await scaleService.scanForDevices();
```

### Problem: Connection timeout

**Symptoms:**
- Device ditemukan
- Connect loading lama
- Timeout error

**Solution:**

1. **Pastikan license key valid:**
```dart
// Cek license key format (uppercase, no spaces)
final licenseKey = 'ABC123XYZ'.toUpperCase().trim();
```

2. **Restart timbangan**
3. **Disconnect device lain yang terkoneksi**
4. **Try again:**
```dart
await scaleService.disconnect();
await Future.delayed(Duration(seconds: 2));
await scaleService.connectWithLicenseKey(
  deviceId: deviceId,
  licenseKey: licenseKey,
);
```

### Problem: Authentication failed

**Symptoms:**
- Connect berhasil
- Authentication gagal
- Message: "Invalid license key"

**Possible causes:**
- ❌ License key salah
- ❌ License sudah expired
- ❌ License untuk device lain
- ❌ Format license key salah (ada space/lowercase)

**Solution:**
1. Verifikasi license key dengan admin
2. Pastikan format uppercase tanpa space
3. Contact support untuk cek status license

---

## Android 10-11 Specific

### Problem: Device scanning tidak work di Android 10/11

**Root cause:**  
Android 10+ memerlukan **ACCESS_FINE_LOCATION** + **Location Service AKTIF** untuk device scanning.

**Solution:**

1. **Tambahkan permissions:**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

2. **Request location permission:**
```dart
await Permission.locationWhenInUse.request();
```

3. **Cek Location Service:**
```dart
import 'package:location/location.dart';

Future<bool> isLocationServiceEnabled() async {
  Location location = Location();
  return await location.serviceEnabled();
}

// Minta user aktifkan
Future<void> requestLocationService() async {
  Location location = Location();
  
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      print('Location service disabled');
    }
  }
}
```

4. **User guide:**
```
Settings → Location → ON
```

### Problem: Scan work tapi tidak menemukan device (Android 10-11)

1. Location Service **HARUS** aktif
2. App harus punya ACCESS_FINE_LOCATION
3. Restart app setelah grant permission
4. Try airplane mode ON → OFF

---

## API Errors

### Problem: 401 Unauthorized

**Cause:** Token expired atau tidak valid

**Solution:**
```dart
// Logout & login ulang
await apiService.authService.logout();

// Login
await apiService.authService.login(email, password);
```

### Problem: 422 Validation Error

**Cause:** Data input tidak valid

**Solution:**
```dart
try {
  await apiService.ownerService.createItem(
    licenseKey: licenseKey,
    name: name,
    price: price,
    unit: unit,
  );
} catch (e) {
  // Check error message untuk detail
  print('Validation error: $e');
}
```

### Problem: Network timeout

**Solution:**
1. Check internet connection
2. Check backend URL
3. Increase timeout (if using custom HTTP client)

---

## Weight Reading Issues

### Problem: Weight data tidak stabil

**Symptoms:**
- Angka loncat-loncat terus
- `isStable` selalu false

**Cause:** 
- Timbangan bergetar
- Permukaan tidak rata
- Item bergerak

**Solution:**
1. Pastikan timbangan di permukaan rata & stabil
2. Tunggu sampai `isStable = true`:
```dart
weightStream.listen((weight) {
  if (weight.isStable) {
    print('Stable weight: ${weight.weight}kg');
    // Baru ambil nilai
  }
});
```

### Problem: Weight selalu 0

**Possible causes:**
- Timbangan perlu kalibrasi
- BLE connection issue
- Firmware issue

**Solution:**
1. Restart timbangan
2. Reconnect
3. Contact support untuk kalibrasi

---

## General Tips

### Debug Mode

Enable debug logging:
```dart
// Di main.dart
void main() {
  // Enable debug
  debugPrint('Debug mode ON');
  
  runApp(MyApp());
}
```

### Check SDK Version

```dart
// pubspec.yaml
dependencies:
  kgiton_sdk:
    git:
      url: https://github.com/kgiton/flutter-kgiton-sdk.git
      ref: main  # atau tag version tertentu
```

### Reset Everything

Jika semua solusi gagal:
```dart
// 1. Logout
await apiService.authService.logout();

// 2. Disconnect device
await scaleService.disconnect();

// 3. Clear local data
final prefs = await SharedPreferences.getInstance();
await prefs.clear();

// 4. Restart app
// 5. Login & connect ulang
```

---

## Masih Ada Masalah?

### Contact Support

Untuk authorized users:

📧 **Email**: support@kgiton.com

**Sertakan informasi:**
- Device model & OS version
- SDK version
- Error logs
- Steps to reproduce
- Screenshots/screen recording

**Response time**: < 24 jam (business days)

---

## Frequently Asked Questions

**Q: Apakah SDK support iOS?**  
A: Ya, SDK support Android & iOS.

**Q: Berapa jarak maksimal koneksi timbangan?**  
A: Optimal < 10 meter, tergantung environment.

**Q: Apakah bisa connect multiple device?**  
A: Saat ini SDK support 1 device per session.

**Q: Apakah weight data realtime?**  
A: Ya, streaming ~10 Hz (10 updates per detik).

**Q: Bagaimana cara update SDK?**  
A: `flutter pub upgrade` atau update di pubspec.yaml

---

**Copyright © 2025 PT KGiTON. All Rights Reserved.**
