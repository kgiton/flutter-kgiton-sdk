# 💳 Top-up & Payment

Panduan lengkap untuk melakukan top-up token dengan berbagai metode pembayaran.

---

## 📋 Overview

### Metode Pembayaran yang Didukung

| Method | Code | Description |
|--------|------|-------------|
| Checkout Page | `checkout_page` | Halaman pembayaran Winpay |
| QRIS | `qris` | Scan QR untuk bayar |
| VA BRI | `va_bri` | Transfer ke Virtual Account BRI |
| VA BNI | `va_bni` | Transfer ke Virtual Account BNI |
| VA BCA | `va_bca` | Transfer ke Virtual Account BCA |
| VA Mandiri | `va_mandiri` | Transfer ke Virtual Account Mandiri |
| VA Permata | `va_permata` | Transfer ke Virtual Account Permata |
| VA BSI | `va_bsi` | Transfer ke Virtual Account BSI |
| VA CIMB | `va_cimb` | Transfer ke Virtual Account CIMB |

### Flow Pembayaran

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Pilih      │────▶│  Request    │────▶│  Bayar      │────▶│  Token      │
│  Metode     │     │  Top-up     │     │  (User)     │     │  Ditambah   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

---

## 📋 Get Payment Methods

Dapatkan daftar metode pembayaran yang tersedia:

```dart
Future<void> getPaymentMethods() async {
  final methods = await api.topup.getPaymentMethods();
  
  print('💳 Available Payment Methods');
  print('============================');
  
  for (var method in methods) {
    print('');
    print('${method.displayName}');
    print('  Code: ${method.code}');
    print('  Fee: ${method.feeFormatted}');
    print('  Min: Rp ${method.minAmount}');
    print('  Max: Rp ${method.maxAmount}');
  }
}
```

### Dengan Helper

```dart
Future<List<PaymentMethodInfo>> getAvailableMethods() async {
  final result = await topupHelper.getPaymentMethods();
  
  if (result['success']) {
    return result['data'] as List<PaymentMethodInfo>;
  }
  
  return [];
}
```

---

## 🛒 Request Top-up

### Dengan Checkout Page (Recommended)

```dart
Future<void> topupWithCheckoutPage({
  required int tokenCount,
  required String licenseKey,
}) async {
  try {
    final response = await api.topup.requestTopup(
      tokenCount: tokenCount,
      licenseKey: licenseKey,
      paymentMethod: 'checkout_page',
    );
    
    print('✅ Top-up request berhasil');
    print('Transaction ID: ${response.transaction.id}');
    print('Amount: Rp ${response.transaction.amount}');
    print('Expires at: ${response.transaction.expiresAt}');
    
    // Buka URL pembayaran
    final paymentUrl = response.checkoutPageUrl!;
    await launchUrl(Uri.parse(paymentUrl));
    
  } on KgitonApiException catch (e) {
    print('❌ Error: ${e.message}');
  }
}
```

### Dengan Helper (Simplified)

```dart
Future<void> topupWithHelper() async {
  final result = await topupHelper.requestCheckoutTopup(
    tokenCount: 100,
    licenseKey: 'XXXX-XXXX-XXXX-XXXX',
  );
  
  if (result['success']) {
    print('✅ ${result['message']}');
    
    // Buka URL pembayaran
    final paymentUrl = result['paymentUrl'];
    await launchUrl(Uri.parse(paymentUrl));
    
    // Simpan transaction ID untuk cek status nanti
    final transactionId = result['transactionId'];
    
  } else {
    print('❌ ${result['message']}');
  }
}
```

---

## 📱 Top-up dengan QRIS

```dart
Future<void> topupWithQris({
  required int tokenCount,
  required String licenseKey,
}) async {
  final result = await topupHelper.requestQrisTopup(
    tokenCount: tokenCount,
    licenseKey: licenseKey,
  );
  
  if (result['success']) {
    final qrisUrl = result['qrisUrl'];
    
    // Tampilkan QR code untuk di-scan
    showQrisDialog(qrisUrl);
    
    // Polling status pembayaran
    final transactionId = result['transactionId'];
    pollPaymentStatus(transactionId);
    
  } else {
    print('❌ ${result['message']}');
  }
}
```

---

## 🏦 Top-up dengan Virtual Account

```dart
Future<void> topupWithVA({
  required int tokenCount,
  required String licenseKey,
  required String bank, // bri, bni, bca, mandiri, permata, bsi, cimb
}) async {
  final result = await topupHelper.requestVaTopup(
    tokenCount: tokenCount,
    licenseKey: licenseKey,
    bank: bank,
  );
  
  if (result['success']) {
    final vaNumber = result['vaNumber'];
    final bankName = result['bankName'];
    final expiresAt = result['expiresAt'];
    
    print('🏦 Virtual Account Details');
    print('==========================');
    print('Bank: $bankName');
    print('VA Number: $vaNumber');
    print('Amount: ${result['data'].transaction.amount}');
    print('Expires: $expiresAt');
    
    // Tampilkan instruksi pembayaran
    showVaInstructions(bankName, vaNumber);
    
  } else {
    print('❌ ${result['message']}');
  }
}
```

---

## 🔍 Check Payment Status

### Check Status (Authenticated)

```dart
Future<void> checkPaymentStatus(String transactionId) async {
  final result = await topupHelper.checkStatus(transactionId);
  
  print('📊 Transaction Status');
  print('====================');
  print('Status: ${result['status']}');
  print('Is Paid: ${result['isPaid']}');
  
  if (result['isPaid']) {
    print('✅ Pembayaran berhasil! Token sudah ditambahkan.');
  }
}
```

### Check Status (Public - No Auth)

Untuk cek status tanpa login (misalnya dari deep link):

```dart
Future<void> checkStatusPublic(String transactionId) async {
  final result = await topupHelper.checkStatusPublic(transactionId);
  
  if (result['isPaid']) {
    print('✅ Pembayaran berhasil!');
  } else {
    print('⏳ Status: ${result['status']}');
  }
}
```

---

## ⏳ Wait for Payment

Tunggu sampai pembayaran selesai (dengan polling):

```dart
Future<void> waitForPaymentCompletion(String transactionId) async {
  print('⏳ Menunggu pembayaran...');
  
  final result = await topupHelper.waitForPayment(
    transactionId,
    timeoutSeconds: 300,      // Max 5 menit
    pollIntervalSeconds: 5,   // Cek setiap 5 detik
  );
  
  if (result['isPaid']) {
    print('✅ ${result['message']}');
    
    // Refresh token balance
    await refreshTokenBalance();
    
    // Navigate ke success page
    navigateToSuccess();
    
  } else {
    print('❌ ${result['message']}');
    print('Status: ${result['status']}');
    
    if (result['status'] == 'timeout') {
      // Pembayaran belum selesai dalam waktu yang ditentukan
      showPendingPaymentDialog();
    }
  }
}
```

---

## 📜 Transaction History

### Get All History

```dart
Future<void> getTransactionHistory() async {
  final result = await topupHelper.getHistory(
    page: 1,
    limit: 20,
  );
  
  if (result['success']) {
    final transactions = result['data'] as List<TopupTransaction>;
    
    print('📜 Transaction History');
    print('======================');
    
    for (var tx in transactions) {
      print('');
      print('ID: ${tx.id}');
      print('Tokens: ${tx.tokenCount}');
      print('Amount: Rp ${tx.amount}');
      print('Status: ${tx.status}');
      print('Created: ${tx.createdAt}');
    }
  }
}
```

### Filter by Status

```dart
// Get pending transactions only
final pending = await topupHelper.getPendingTransactions();

// Get completed transactions only
final completed = await topupHelper.getCompletedTransactions();

// Filter by license key
final result = await topupHelper.getHistory(
  licenseKey: 'XXXX-XXXX-XXXX-XXXX',
);
```

---

## ❌ Cancel Transaction

Batalkan transaksi yang masih pending:

```dart
Future<void> cancelTransaction(String transactionId) async {
  final result = await topupHelper.cancelTransaction(transactionId);
  
  if (result['success']) {
    print('✅ ${result['message']}');
  } else {
    print('❌ ${result['message']}');
  }
}
```

---

## 💰 Calculate Total

Hitung total yang harus dibayar (termasuk fee):

```dart
Future<void> calculatePaymentTotal() async {
  final result = await topupHelper.calculateTotal(
    tokenCount: 100,
    paymentMethod: 'va_bca',
  );
  
  if (result['success']) {
    print('💰 Payment Calculation');
    print('======================');
    print('Tokens: ${result['tokenCount']}');
    print('Price/Token: Rp ${result['pricePerToken']}');
    print('Subtotal: Rp ${result['subtotal']}');
    print('Fee: Rp ${result['fee']}');
    print('Total: Rp ${result['total']}');
  }
}
```

---

## 📝 Data Models

### TopupResponse

```dart
class TopupResponse {
  final String transactionId;
  final String licenseKey;
  final int tokensRequested;
  final double amountToPay;
  final double pricePerToken;
  final String status;
  final String? paymentMethod;      // checkout_page, va_bri, va_bni, qris, dll
  final String? gatewayProvider;
  final String? paymentUrl;          // For checkout_page method
  final VirtualAccountInfo? virtualAccount;
  final QRISInfo? qris;              // For QRIS payment
  final String? gatewayTransactionId;
  final DateTime? expiresAt;

  // Helper methods
  bool get isCheckoutPage => paymentMethod == 'checkout_page';
  bool get isVirtualAccount => virtualAccount != null;
  bool get isQRIS => paymentMethod == 'qris' || qris != null;
  String? get qrisImageUrl => qris?.qrImageUrl;
}
```

### VirtualAccountInfo

```dart
class VirtualAccountInfo {
  final String number;
  final String name;
  final String bank;
}
```

### QRISInfo

```dart
class QRISInfo {
  final String? qrString;     // QRIS string untuk generate QR
  final String? qrImageUrl;   // URL gambar QR code
}
```

### TransactionStatusResponse

```dart
class TransactionStatusResponse {
  final String transactionId;
  final String type;           // 'topup', 'license_purchase', 'license_rental'
  final double amount;
  final int? tokensAdded;      // Only for topup
  final int? tokensRequested;  // Only for topup
  final String? licenseKey;    // Only for license transactions
  final String status;
  final DateTime createdAt;

  // Helper methods
  bool get isTopup => type == 'topup';
  bool get isLicensePurchase => type == 'license_purchase';
  bool get isLicenseRental => type == 'license_rental';
  bool get isSuccess => status == 'SUCCESS' || status == 'success';
  bool get isPending => status == 'PENDING' || status == 'pending';
}
```

### PaymentMethodInfo

```dart
class PaymentMethodInfo {
  final String id;          // va_bca, qris, checkout_page
  final String name;        // Virtual Account BCA
  final String? description;
  final String type;        // 'checkout', 'va', atau 'qris'
  final bool enabled;
}
```

---

## ⚠️ Best Practices

### 1. Simpan Transaction ID

```dart
// Simpan transaction ID untuk cek status nanti
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('pending_topup_id', transactionId);
```

### 2. Handle Deep Link dari Payment

```dart
// Handle deep link callback setelah payment
void handlePaymentCallback(Uri uri) async {
  final transactionId = uri.queryParameters['transaction_id'];
  
  if (transactionId != null) {
    final result = await topupHelper.checkStatus(transactionId);
    
    if (result['isPaid']) {
      showSuccessDialog();
    } else {
      showPendingDialog();
    }
  }
}
```

### 3. Show Loading State

```dart
class TopupPage extends StatefulWidget {
  @override
  _TopupPageState createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  bool isLoading = false;
  
  Future<void> processTopup() async {
    setState(() => isLoading = true);
    
    try {
      final result = await topupHelper.requestCheckoutTopup(
        tokenCount: 100,
        licenseKey: licenseKey,
      );
      
      if (result['success']) {
        await launchUrl(Uri.parse(result['paymentUrl']));
      }
      
    } finally {
      setState(() => isLoading = false);
    }
  }
}
```

---

## Sync Transaction Status

Untuk polling status transaksi secara langsung dari payment gateway (berguna jika webhook tidak diterima):

```dart
Future<void> syncTransaction(String transactionId) async {
  try {
    final result = await api.topup.syncTransactionStatus(transactionId);
    
    print('🔄 Sync Result');
    print('==============');
    print('Transaction ID: ${result.transactionId}');
    print('Status: ${result.status}');
    print('Previous Status: ${result.previousStatus}');
    print('Was Updated: ${result.wasUpdated}');
    
    if (result.wasUpdated && result.isNowSuccess) {
      print('✅ Payment confirmed!');
      // Refresh token balance
      await refreshTokenBalance();
    }
    
  } on KgitonApiException catch (e) {
    print('❌ Error: ${e.message}');
  }
}
```

**Catatan:**
- Hanya mendukung QRIS dan Virtual Account
- Checkout page tidak bisa di-poll (harus menunggu webhook)

---

## 🔗 Next Steps

- [BLE Integration](05_BLE_INTEGRATION.md) - Koneksi ke timbangan
- [API Reference](06_API_REFERENCE.md) - API lengkap
