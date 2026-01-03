# 🔧 Troubleshooting

Panduan untuk mengatasi masalah umum saat menggunakan KGiTON SDK.

---

## 📋 Table of Contents

- [BLE Issues](#ble-issues)
- [API Issues](#api-issues)
- [Authentication Issues](#authentication-issues)
- [Token Issues](#token-issues)
- [Payment Issues](#payment-issues)
- [Platform-Specific Issues](#platform-specific-issues)

---

## 🔵 BLE Issues

### Device Not Found

**Gejala:** Scan tidak menemukan perangkat KGiTON.

**Solusi:**

1. **Pastikan timbangan menyala**
   ```dart
   // Cek apakah scanning berjalan
   print('Is scanning: ${scaleService.isScanning}');
   ```

2. **Pastikan Bluetooth aktif**
   ```dart
   final isEnabled = await PermissionHelper.isBluetoothEnabled();
   if (!isEnabled) {
     await PermissionHelper.requestEnableBluetooth();
   }
   ```

3. **Pastikan Location aktif (Android 10-11)**
   ```dart
   final hasLocation = await PermissionHelper.isLocationEnabled();
   if (!hasLocation) {
     // Minta user enable location
   }
   ```

4. **Tingkatkan timeout scan**
   ```dart
   await scaleService.startScan(
     timeout: Duration(seconds: 30),  // Lebih lama
     rssiThreshold: -100,             // Terima sinyal lemah
   );
   ```

5. **Restart Bluetooth**
   - Matikan dan nyalakan Bluetooth di Settings

---

### Connection Failed

**Gejala:** `ConnectionException` saat connect ke device.

**Solusi:**

1. **Pastikan license key benar**
   ```dart
   // Validate license first
   final valid = await api.license.validateLicense(licenseKey);
   if (!valid.valid) {
     print('License not valid: ${valid.message}');
   }
   ```

2. **Pastikan tidak ada device lain yang terhubung**
   - Timbangan hanya bisa terhubung ke 1 device pada satu waktu
   - Disconnect dari device lain terlebih dahulu

3. **Restart timbangan**
   - Matikan timbangan
   - Tunggu 10 detik
   - Nyalakan kembali

4. **Clear Bluetooth cache (Android)**
   - Settings > Apps > Bluetooth > Clear Cache

---

### Weight Not Updating

**Gejala:** Terhubung tapi data berat tidak muncul.

**Solusi:**

1. **Pastikan sudah subscribe ke stream**
   ```dart
   // Pastikan listener aktif
   scaleService.weightStream.listen((weight) {
     print('Weight: ${weight.value}');
   });
   ```

2. **Check connection state**
   ```dart
   if (scaleService.connectionState != ScaleConnectionState.connected) {
     print('Not connected!');
   }
   ```

3. **Reconnect**
   ```dart
   await scaleService.disconnect();
   await Future.delayed(Duration(seconds: 2));
   await scaleService.connect(licenseKey: licenseKey);
   ```

---

### Bluetooth Permission Denied

**Gejala:** `PermissionHelper.requestBLEPermissions()` returns false.

**Solusi:**

1. **Android: Pastikan permission di manifest**
   ```xml
   <uses-permission android:name="android.permission.BLUETOOTH"/>
   <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
   <uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
   <uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   ```

2. **iOS: Pastikan usage description di Info.plist**
   ```xml
   <key>NSBluetoothAlwaysUsageDescription</key>
   <string>Deskripsi penggunaan Bluetooth</string>
   ```

3. **Redirect ke Settings**
   ```dart
   if (!granted) {
     // Buka settings app
     await openAppSettings();
   }
   ```

---

## 🌐 API Issues

### Network Error

**Gejala:** `SocketException` atau timeout error.

**Solusi:**

1. **Check internet connection**
   ```dart
   import 'package:connectivity_plus/connectivity_plus.dart';
   
   final result = await Connectivity().checkConnectivity();
   if (result == ConnectivityResult.none) {
     print('No internet connection');
   }
   ```

2. **Verify base URL**
   ```dart
   print('Base URL: ${api.baseUrl}');
   // Should be: https://api.example.com
   ```

3. **Check for SSL issues**
   - Pastikan menggunakan HTTPS
   - Update tanggal/waktu perangkat

---

### 401 Unauthorized

**Gejala:** API menolak request dengan status 401.

**Solusi:**

1. **Token expired - Login ulang**
   ```dart
   final expiresAt = authHelper.getTokenExpiresAt();
   if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
     // Token expired, need to login again
     await authHelper.logout();
     // Redirect to login
   }
   ```

2. **Token tidak ter-set**
   ```dart
   // Restore session saat app startup
   await authHelper.restoreSession();
   ```

---

### 400 Bad Request

**Gejala:** API menolak request dengan status 400.

**Solusi:**

1. **Validasi input sebelum kirim**
   ```dart
   if (email.isEmpty || !email.contains('@')) {
     showError('Email tidak valid');
     return;
   }
   ```

2. **Check error message**
   ```dart
   try {
     await api.auth.login(email: email, password: password);
   } on KgitonApiException catch (e) {
     print('Error: ${e.message}');
     print('Data: ${e.data}');
   }
   ```

---

## 🔐 Authentication Issues

### Login Failed

**Gejala:** Login gagal meskipun email/password benar.

**Solusi:**

1. **Check caps lock / keyboard**
   - Pastikan password case-sensitive

2. **Reset password**
   ```dart
   await authHelper.forgotPassword(email);
   ```

3. **Check account status**
   - Akun mungkin diblokir
   - Hubungi support@kgiton.com

---

### Session Lost

**Gejala:** User logout otomatis.

**Solusi:**

1. **Restore session saat startup**
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     final prefs = await SharedPreferences.getInstance();
     final auth = KgitonAuthHelper(prefs, baseUrl: 'https://api.example.com');
     
     // Try restore session
     final restored = await auth.restoreSession();
     
     runApp(MyApp(isLoggedIn: restored));
   }
   ```

2. **Handle token expiration**
   ```dart
   // Check before each API call
   if (!await authHelper.isLoggedIn()) {
     navigateToLogin();
     return;
   }
   ```

---

## 🎫 Token Issues

### Insufficient Tokens

**Gejala:** Tidak bisa menggunakan token (saldo 0).

**Solusi:**

1. **Check balance first**
   ```dart
   final balance = await licenseHelper.getLicenseTokenBalance(licenseKey);
   if (balance['balance'] == 0) {
     showTopupDialog();
     return;
   }
   ```

2. **Top-up tokens**
   - Lihat [Top-up & Payment](04_TOPUP_PAYMENT.md)

---

### Wrong License Key

**Gejala:** Token tidak bisa digunakan untuk license tertentu.

**Solusi:**

1. **Verify ownership**
   ```dart
   final owned = await licenseHelper.isMyLicense(licenseKey);
   if (!owned) {
     showError('License ini bukan milik Anda');
   }
   ```

2. **Check license list**
   ```dart
   final result = await licenseHelper.getMyLicenses();
   for (var lic in result['data']) {
     print('License: ${lic.licenseKey}');
   }
   ```

---

## 💳 Payment Issues

### Payment Timeout

**Gejala:** Pembayaran tidak terkonfirmasi.

**Solusi:**

1. **Check status manually**
   ```dart
   final status = await topupHelper.checkStatus(transactionId);
   print('Status: ${status['status']}');
   ```

2. **Wait longer**
   - Virtual Account bisa memakan waktu hingga 1 jam
   - Refresh status secara berkala

---

### Payment Failed

**Gejala:** Status pembayaran "failed".

**Solusi:**

1. **Coba lagi dengan metode lain**
   ```dart
   await topupHelper.requestTopup(
     tokenCount: 100,
     licenseKey: licenseKey,
     paymentMethod: 'qris',  // Try different method
   );
   ```

2. **Check saldo rekening**
   - Pastikan saldo cukup untuk pembayaran

---

## 📱 Platform-Specific Issues

### Android

#### Location Required for BLE (Android 10-11)

```dart
// Check and request location
if (Platform.isAndroid) {
  final sdk = await DeviceInfoPlugin().androidInfo;
  
  if (sdk.version.sdkInt >= 29 && sdk.version.sdkInt <= 30) {
    // Android 10-11 needs location for BLE
    final locationEnabled = await PermissionHelper.isLocationEnabled();
    
    if (!locationEnabled) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Location Required'),
          content: Text('Please enable location to scan for devices.'),
          actions: [
            TextButton(
              onPressed: () => Geolocator.openLocationSettings(),
              child: Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }
}
```

#### Background BLE Limitations

- Android membatasi BLE scanning di background
- Gunakan foreground service untuk operasi panjang

---

### iOS

#### Bluetooth Usage Description

Pastikan ada description di Info.plist:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Aplikasi memerlukan Bluetooth untuk terhubung ke timbangan KGiTON</string>
```

#### Background Modes

Untuk BLE di background:
```xml
<key>UIBackgroundModes</key>
<array>
  <string>bluetooth-central</string>
</array>
```

---

## 🆘 Getting Help

Jika masalah belum terselesaikan:

1. **Collect logs**
   ```dart
   // Enable debug logging
   KgitonApiClient.enableLogging = true;
   ```

2. **Contact support**
   - Email: support@kgiton.com
   - Sertakan:
     - Device model
     - OS version
     - SDK version
     - Error message lengkap
     - Steps to reproduce

---

## 📋 Common Error Codes

| Code | Description | Solution |
|------|-------------|----------|
| 400 | Bad Request | Check input validation |
| 401 | Unauthorized | Login again |
| 403 | Forbidden | Check permissions |
| 404 | Not Found | Check resource exists |
| 409 | Conflict | Resource already exists |
| 429 | Too Many Requests | Wait and retry |
| 500 | Server Error | Contact support |
