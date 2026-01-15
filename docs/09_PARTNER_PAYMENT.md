# 🤝 Partner Payment API

Panduan untuk menggunakan Partner Payment API - memungkinkan partner menghasilkan pembayaran QRIS atau Checkout Page untuk transaksi mereka sendiri.

---

## 📋 Overview

Partner Payment API memungkinkan aplikasi partner (misalnya: Huba POS) untuk:
- Generate pembayaran QRIS untuk pelanggan mereka
- Generate halaman checkout untuk pelanggan mereka
- Menerima callback webhook saat pembayaran berhasil

### Payment Flow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Partner App    │────▶│  KGiTON API     │────▶│  Payment        │
│  Request        │     │  Generate       │     │  Gateway        │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                       │
┌─────────────────┐     ┌─────────────────┐            │
│  Partner App    │◀────│  Webhook        │◀───────────┘
│  Receive        │     │  Callback       │
└─────────────────┘     └─────────────────┘
```

### Biaya
- Setiap request pembayaran akan **mengurangi 1 token** dari license key

---

## 🚀 Quick Start

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// Initialize dengan API Key
final api = KgitonApiService(
  baseUrl: 'https://api.kgiton.com',
  apiKey: 'kgiton_your_api_key_here',
);

// Generate QRIS payment
final payment = await api.partnerPayment.generateQris(
  transactionId: 'TRX-2026-001',
  amount: 50000,
  licenseKey: 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX',
  description: 'Pembayaran Laundry',
  webhookUrl: 'https://api.partner.com/webhook/payment',
);

// Display QRIS QR code
print('QRIS URL: ${payment.qris?.qrImageUrl}');
print('Expires at: ${payment.expiresAt}');
```

---

## 💳 Generate QRIS Payment

QRIS cocok untuk pembayaran langsung di kasir:

```dart
Future<void> generateQrisPayment() async {
  try {
    final payment = await api.partnerPayment.generateQris(
      transactionId: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      amount: 75000,
      licenseKey: licenseKey,
      description: 'Pembayaran Order #123',
      expiryMinutes: 30, // Default 30 menit
      webhookUrl: 'https://api.myapp.com/webhook/kgiton',
      customerName: 'John Doe',
      customerEmail: 'john@example.com',
      customerPhone: '08123456789',
    );
    
    print('✅ QRIS Generated');
    print('Transaction ID: ${payment.transactionId}');
    print('Amount: Rp ${payment.amount}');
    print('QR Image URL: ${payment.qris?.qrImageUrl}');
    print('Expires at: ${payment.expiresAt}');
    
    // Tampilkan QR code untuk customer scan
    showQrCodeDialog(payment.qris!.qrImageUrl);
    
  } on KgitonApiException catch (e) {
    print('❌ Error: ${e.message}');
  }
}
```

---

## 🌐 Generate Checkout Page Payment

Checkout page cocok untuk pembayaran online atau jarak jauh:

```dart
Future<void> generateCheckoutPayment() async {
  try {
    final payment = await api.partnerPayment.generateCheckoutPage(
      transactionId: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      amount: 150000,
      licenseKey: licenseKey,
      description: 'Pembayaran Invoice #456',
      expiryMinutes: 120, // Default 2 jam
      backUrl: 'https://myapp.com/payment/complete',
      webhookUrl: 'https://api.myapp.com/webhook/kgiton',
      items: [
        PartnerPaymentItem(
          id: 'ITEM-001',
          name: 'Laundry Kiloan 5kg',
          price: 100000,
          quantity: 1,
        ),
        PartnerPaymentItem(
          id: 'ITEM-002',
          name: 'Extra Parfum',
          price: 50000,
          quantity: 1,
        ),
      ],
      customerName: 'Jane Doe',
      customerEmail: 'jane@example.com',
      customerPhone: '08987654321',
    );
    
    print('✅ Checkout Page Generated');
    print('Transaction ID: ${payment.transactionId}');
    print('Amount: Rp ${payment.amount}');
    print('Payment URL: ${payment.paymentUrl}');
    print('Expires at: ${payment.expiresAt}');
    
    // Redirect atau buka URL pembayaran
    await launchUrl(Uri.parse(payment.paymentUrl!));
    
  } on KgitonApiException catch (e) {
    print('❌ Error: ${e.message}');
  }
}
```

---

## 📨 Webhook Callback

Saat pembayaran berhasil, KGiTON akan mengirim POST request ke `webhook_url`:

### Webhook Payload

```json
{
  "event": "partner_payment.success",
  "transaction_id": "TRX-2026-001",
  "license_key": "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX",
  "amount": 50000,
  "payment_type": "qris",
  "paid_at": "2026-01-15T10:30:00.000Z",
  "gateway_transaction_id": "647a5129-76db-483d-ae76-497ae1d310da"
}
```

### Contoh Handler (Backend)

```javascript
// Express.js webhook handler
app.post('/webhook/kgiton', (req, res) => {
  const { event, transaction_id, amount, paid_at } = req.body;
  
  if (event === 'partner_payment.success') {
    // Update order status
    updateOrderStatus(transaction_id, 'paid', paid_at);
    
    // Notify customer
    sendPaymentConfirmation(transaction_id);
  }
  
  res.status(200).json({ received: true });
});
```

---

## 📱 Full Example dengan UI

```dart
class PaymentScreen extends StatefulWidget {
  final double amount;
  final String orderId;
  
  const PaymentScreen({
    required this.amount,
    required this.orderId,
  });
  
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = false;
  PartnerPaymentResponse? payment;
  
  Future<void> _generateQris() async {
    setState(() => isLoading = true);
    
    try {
      final result = await api.partnerPayment.generateQris(
        transactionId: widget.orderId,
        amount: widget.amount,
        licenseKey: await getLicenseKey(),
        webhookUrl: 'https://api.myapp.com/webhook/kgiton',
      );
      
      setState(() => payment = result);
      
    } on KgitonApiException catch (e) {
      _showError(e.message);
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pembayaran')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Total: Rp ${widget.amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 24),
            
            if (payment == null)
              ElevatedButton(
                onPressed: isLoading ? null : _generateQris,
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text('Generate QRIS'),
              )
            else
              Column(
                children: [
                  Image.network(
                    payment!.qris!.qrImageUrl,
                    width: 250,
                    height: 250,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Scan QRIS untuk membayar',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Berlaku hingga: ${payment!.expiresAt}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## ⚠️ Error Handling

| Error Code | Description | Solution |
|------------|-------------|----------|
| 401 | Invalid API key | Periksa API key |
| 402 | Insufficient token balance | Top-up token |
| 403 | License key not active | Aktifkan license key |
| 404 | License key not found | Periksa license key |
| 500 | Payment gateway error | Coba lagi nanti |

```dart
try {
  final payment = await api.partnerPayment.generateQris(...);
} on KgitonPaymentRequiredException catch (e) {
  // Token habis
  showTopupDialog();
} on KgitonForbiddenException catch (e) {
  // License tidak aktif
  showActivateLicenseDialog();
} on KgitonNotFoundException catch (e) {
  // License tidak ditemukan
  showInvalidLicenseDialog();
} on KgitonApiException catch (e) {
  // Error lainnya
  showError(e.message);
}
```

---

## 📊 Models Reference

### PartnerPaymentRequest

```dart
class PartnerPaymentRequest {
  final String transactionId;        // Partner's unique transaction ID
  final double amount;               // Amount in IDR
  final String licenseKey;           // KGiTON license key
  final PartnerPaymentType paymentType; // qris or checkoutPage
  final String? description;         // Transaction description
  final String? backUrl;             // Redirect URL (checkout only)
  final int? expiryMinutes;          // Expiry time
  final List<PartnerPaymentItem>? items;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? webhookUrl;          // Callback URL
}
```

### PartnerPaymentResponse

```dart
class PartnerPaymentResponse {
  final String transactionId;
  final PartnerPaymentType paymentType;
  final double amount;
  final String gatewayProvider;
  final String? gatewayTransactionId;
  final String? paymentUrl;          // Checkout URL
  final PartnerQrisData? qris;       // QRIS data
  final DateTime expiresAt;
  
  // Helpers
  bool get isQris;
  bool get isCheckoutPage;
  String? get actionUrl;             // URL to open
}
```

---

## 🔗 Related Documentation

- [Top-up & Payment](04_TOPUP_PAYMENT.md) - Top-up token balance
- [API Reference](06_API_REFERENCE.md) - Complete API reference
