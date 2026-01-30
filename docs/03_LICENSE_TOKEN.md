# 🎫 License & Token

Panduan lengkap untuk mengelola license key dan sistem token KGiTON.

---

## 📋 Overview

### Konsep Dasar

| Konsep | Deskripsi |
|--------|-----------|
| **License Key** | Kunci unik untuk mengakses perangkat KGiTON (1 license = 1 device) |
| **Token** | Unit penggunaan timbangan (1 token = 1 sesi penimbangan) |
| **Saldo Token** | Jumlah token yang tersedia untuk digunakan |

### Flow Penggunaan

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Beli/Top-up   │────▶│  Gunakan Token  │────▶│  Akses Scale    │
│     Token       │     │   (1 token)     │     │    via BLE      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

---

## 📊 Cek Saldo Token

### Cek Semua License

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

Future<void> checkAllBalance() async {
  final balance = await api.user.getTokenBalance();
  
  print('📊 Token Balance Summary');
  print('========================');
  print('Total Saldo: ${balance.totalRemainingBalance} tokens');
  print('');
  
  for (var license in balance.licenses) {
    print('License: ${license.licenseKey}');
    print('  Status: ${license.status}');
    print('  Saldo: ${license.remainingBalance} tokens');
    print('  Total Used: ${license.totalUsed} tokens');
    print('  Total Purchased: ${license.totalPurchased} tokens');
    print('');
  }
}
```

### Cek License Tertentu (dengan Helper)

```dart
Future<void> checkLicenseBalance(String licenseKey) async {
  final result = await licenseHelper.getLicenseTokenBalance(licenseKey);
  
  if (result['success']) {
    print('Saldo: ${result['balance']} tokens');
    
    final data = result['data'] as LicenseKeyBalance;
    print('Status: ${data.status}');
    
  } else {
    print('Error: ${result['message']}');
  }
}
```

---

## 🎯 Gunakan Token

Panggil ini sebelum memulai sesi penimbangan:

### Menggunakan API Service

```dart
Future<bool> useTokenForSession(String licenseKey) async {
  try {
    final result = await api.user.useToken(licenseKey);
    
    if (result.success) {
      print('✅ Token berhasil digunakan');
      print('Sisa saldo: ${result.remainingBalance} tokens');
      return true;
      
    } else {
      print('❌ ${result.message}');
      return false;
    }
    
  } on KgitonApiException catch (e) {
    if (e.statusCode == 400) {
      print('⚠️ Saldo token habis! Silakan top-up');
    } else {
      print('❌ Error: ${e.message}');
    }
    return false;
  }
}
```

### Menggunakan Helper

```dart
Future<void> useTokenWithHelper(String licenseKey) async {
  final result = await licenseHelper.useToken(licenseKey);
  
  if (result['success']) {
    print('✅ ${result['message']}');
    print('Sisa: ${result['remaining']} tokens');
    
    // Lanjutkan ke koneksi BLE
    await connectToScale(licenseKey);
    
  } else {
    print('❌ ${result['message']}');
    
    // Redirect ke halaman top-up
    navigateToTopup();
  }
}
```

---

## ✅ Validasi License

### Validasi Public (Tanpa Login)

```dart
Future<void> validateLicense(String licenseKey) async {
  final result = await api.license.validateLicense(licenseKey);
  
  print('License: ${result.licenseKey}');
  print('Valid: ${result.valid}');
  print('Status: ${result.status}');
  print('Message: ${result.message}');
  
  if (result.valid) {
    print('✅ License valid, bisa digunakan');
  } else {
    print('❌ License tidak valid');
  }
}
```

### Validasi dengan Helper

```dart
Future<void> validateWithHelper(String licenseKey) async {
  final result = await licenseHelper.validateLicense(licenseKey);
  
  if (result['success']) {
    final data = result['data'] as ValidateLicenseResponse;
    print('Valid: ${data.valid}');
  }
}
```

---

## 📝 Daftar License Saya

### Get All My Licenses

```dart
Future<void> getMyLicenses() async {
  final result = await licenseHelper.getMyLicenses();
  
  if (result['success']) {
    final licenses = result['data'] as List<LicenseTransaction>;
    
    print('📋 My Licenses (${licenses.length})');
    print('================================');
    
    for (var lic in licenses) {
      print('');
      print('License: ${lic.licenseKey}');
      print('  Status: ${lic.status}');
      print('  Type: ${lic.type}'); // buy atau rent
      print('  Created: ${lic.createdAt}');
    }
    
  } else {
    print('Error: ${result['message']}');
  }
}
```

### Verifikasi Kepemilikan

```dart
Future<bool> verifyOwnership(String licenseKey) async {
  final result = await licenseHelper.verifyLicenseOwnership(licenseKey);
  
  if (result['isOwner']) {
    print('✅ Anda adalah pemilik sah license ini');
    return true;
  } else {
    print('❌ ${result['message']}');
    return false;
  }
}
```

---

## ➕ Assign License Tambahan

```dart
Future<void> assignNewLicense(String licenseKey) async {
  final result = await licenseHelper.assignLicense(licenseKey);
  
  if (result['success']) {
    print('✅ ${result['message']}');
    
    final license = result['data'] as LicenseKey;
    print('License: ${license.licenseKey}');
    print('Device: ${license.deviceName}');
    
  } else {
    print('❌ ${result['message']}');
  }
}
```

---

## 📊 License Summary

Dapatkan ringkasan lengkap semua license dan token:

```dart
Future<void> getLicenseSummary() async {
  final result = await licenseHelper.getLicenseSummary();
  
  if (result['success']) {
    print('📊 License Summary');
    print('==================');
    print('Total Licenses: ${result['totalLicenses']}');
    print('Active Licenses: ${result['activeLicenses']}');
    print('Total Tokens: ${result['totalTokens']}');
  }
}
```

---

## 📝 Data Models

### TokenBalanceData

```dart
class TokenBalanceData {
  final int totalRemainingBalance;  // Total saldo semua license
  final List<LicenseKeyBalance> licenses;
}

class LicenseKeyBalance {
  final String licenseKey;
  final String status;           // active, inactive, expired
  final int remainingBalance;    // Saldo tersedia
  final int totalUsed;           // Total pernah dipakai
  final int totalPurchased;      // Total pernah dibeli
  final List<TokenUsage> recentUsage;
}
```

### UseTokenResponse

```dart
class UseTokenResponse {
  final bool success;
  final String message;
  final int remainingBalance;  // Sisa saldo setelah digunakan
  final DateTime usedAt;
}
```

### ValidateLicenseResponse

```dart
class ValidateLicenseResponse {
  final String licenseKey;
  final bool valid;
  final String status;    // available, assigned, expired
  final String message;
}
```

---

## ⚠️ Best Practices

### 1. Cek Saldo Sebelum Gunakan

```dart
Future<bool> canUseToken(String licenseKey) async {
  final result = await licenseHelper.getLicenseTokenBalance(licenseKey);
  
  if (result['success'] && result['balance'] > 0) {
    return true;
  }
  
  // Show top-up dialog
  showTopupDialog();
  return false;
}
```

### 2. Handle Saldo Habis

```dart
scale.weightStream.listen(
  (weight) {
    // Handle weight data
  },
  onError: (error) {
    if (error is InsufficientTokenException) {
      // Disconnect dan tampilkan dialog top-up
      scale.disconnect();
      showTopupDialog();
    }
  },
);
```

### 3. Periodic Balance Check

```dart
Timer.periodic(Duration(minutes: 5), (_) async {
  final balance = await licenseHelper.getLicenseTokenBalance(currentLicense);
  
  if (balance['balance'] <= 5) {
    showLowBalanceWarning();
  }
});
```

---

## Token Usage Statistics

### Get Token Usage Stats

Dapatkan statistik penggunaan token (mingguan, rata-rata harian, estimasi sisa hari).

```dart
Future<void> getUsageStats() async {
  final stats = await api.user.getTokenUsageStats();
  
  print('Weekly Usage: ${stats.weeklyUsage}');
  print('Labels: ${stats.weeklyLabels}');
  print('Total This Week: ${stats.totalThisWeek}');
  print('Avg Daily Usage: ${stats.avgDailyUsage}');
  print('Est Days Remaining: ${stats.estDaysRemaining}');
}
```

**Response:**

```dart
class TokenUsageStats {
  final List<int> weeklyUsage;      // [12, 19, 8, 15, 22, 10, 5]
  final List<String> weeklyLabels;  // ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
  final int totalThisWeek;          // Total minggu ini
  final int avgDailyUsage;          // Rata-rata harian
  final int estDaysRemaining;       // Estimasi hari tersisa
}
```

---

### Get Per-License Usage History

Dapatkan riwayat penggunaan token untuk license tertentu.

```dart
Future<void> getLicenseUsage(String licenseKey) async {
  final response = await api.user.getLicenseTokenUsage(
    licenseKey,
    page: 1,
    limit: 20,
  );
  
  print('License: ${response.data.licenseKey}');
  print('Current Balance: ${response.data.currentBalance}');
  print('Weekly Usage: ${response.data.weeklyUsage}');
  print('Avg Daily: ${response.data.avgDailyUsage}');
  
  // Usage history
  for (var record in response.data.usageHistory) {
    print('${record.purpose}: -${record.tokensUsed} (${record.createdAt})');
  }
  
  // Pagination
  print('Page ${response.page} of ${response.totalPages}');
}
```

**Response:**

```dart
class LicenseTokenUsageResponse {
  final LicenseTokenUsage data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
}

class LicenseTokenUsage {
  final String licenseKey;
  final int currentBalance;
  final int weeklyUsage;
  final int avgDailyUsage;
  final List<TokenUsageRecord> usageHistory;
}

class TokenUsageRecord {
  final String id;
  final int tokensUsed;
  final int previousBalance;
  final int newBalance;
  final String purpose;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
}
```

---

## Next Steps

- [Top-up & Payment](04_TOPUP_PAYMENT.md) - Cara top-up token
- [BLE Integration](05_BLE_INTEGRATION.md) - Koneksi ke timbangan
