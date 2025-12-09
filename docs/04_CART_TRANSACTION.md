# Cart & Transaction - KGiTON SDK

Panduan sistem cart dan transaksi (SDK v2.0 - Session Based).

## 📋 Daftar Isi

- [Session-Based Cart](#session-based-cart)
- [Cart Operations](#cart-operations)
- [Checkout & Payment](#checkout--payment)
- [Transaction History](#transaction-history)

---

## Session-Based Cart

### Konsep Cart ID (SDK v2.0)

SDK v2.0 menggunakan **session-based cart** dengan `cart_id`:

```dart
// Format: {device_id}_{license_key}
String cartId = '${deviceId}_${licenseKey}';
```

**Keuntungan:**
- ✅ Setiap license punya cart terpisah (multi-branch support)
- ✅ Bisa timbang item yang sama berkali-kali
- ✅ Cart persisten per session
- ✅ No duplicate checking (perfect untuk timbangan)

### Generate Cart ID

```dart
import 'package:uuid/uuid.dart';

class CartManager {
  String _deviceId = '';
  String _cartId = '';
  
  Future<void> initialize(String licenseKey) async {
    // Load or generate device ID
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id') ?? const Uuid().v4();
    await prefs.setString('device_id', _deviceId);
    
    // Generate cart ID
    _cartId = '${_deviceId}_$licenseKey';
    
    print('Cart ID: $_cartId');
  }
  
  String get cartId => _cartId;
}
```

---

## Cart Operations

### Initialize Cart Service

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

final prefs = await SharedPreferences.getInstance();
final apiService = KgitonApiService(prefs);
final cartService = apiService.cartService;
```

### Add Item to Cart

```dart
Future<void> addToCart({
  required String cartId,
  required String licenseKey,
  required int itemId,
  required double quantity, // berat dari timbangan
  String? notes,
}) async {
  try {
    final result = await cartService.addItem(
      cartId: cartId,
      licenseKey: licenseKey,
      itemId: itemId,
      quantity: quantity,
      notes: notes,
    );
    
    if (result['success'] == true) {
      final cartItem = result['data'] as CartItem;
      print('✅ Added: ${cartItem.item?.name} - ${quantity}kg');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### Get Cart Items

```dart
Future<List<CartItem>> getCartItems(String cartId) async {
  try {
    final result = await cartService.getCartItems(cartId);
    
    if (result['success'] == true) {
      return (result['data'] as List).cast<CartItem>();
    }
  } catch (e) {
    print('Error: $e');
  }
  
  return [];
}
```

### Update Cart Item

```dart
Future<void> updateCartItem({
  required int cartItemId,
  double? quantity,
  String? notes,
}) async {
  try {
    final result = await cartService.updateItem(
      cartItemId: cartItemId,
      quantity: quantity,
      notes: notes,
    );
    
    if (result['success'] == true) {
      print('✅ Cart item updated');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### Remove Cart Item

```dart
Future<void> removeFromCart(int cartItemId) async {
  try {
    final result = await cartService.removeItem(cartItemId);
    
    if (result['success'] == true) {
      print('✅ Item removed from cart');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### Clear Cart

```dart
Future<void> clearCart(String cartId) async {
  try {
    final result = await cartService.clearCart(cartId);
    
    if (result['success'] == true) {
      print('✅ Cart cleared');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### Get Cart Summary

```dart
Future<CartSummary?> getCartSummary(String cartId) async {
  try {
    final result = await cartService.getCartSummary(cartId);
    
    if (result['success'] == true) {
      final summary = result['data'] as CartSummary;
      print('Total items: ${summary.totalItems}');
      print('Total weight: ${summary.totalWeight} kg');
      print('Total: Rp ${summary.totalAmount}');
      return summary;
    }
  } catch (e) {
    print('Error: $e');
  }
  
  return null;
}
```

---

## Checkout & Payment

### Checkout Cart

```dart
Future<Transaction?> checkout({
  required String cartId,
  required String paymentMethod, // 'QRIS', 'CASH', 'BANK_TRANSFER'
  String paymentGateway = 'external', // 'external', 'midtrans', 'internal'
}) async {
  try {
    final result = await cartService.checkoutCart(
      cartId: cartId,
      paymentMethod: paymentMethod,
      paymentGateway: paymentGateway,
    );
    
    if (result['success'] == true) {
      final transaction = result['data'] as Transaction;
      print('✅ Transaction created: ${transaction.transactionNumber}');
      
      // Jika QRIS, akan ada qris_string
      if (transaction.qrisString != null) {
        print('QRIS: ${transaction.qrisString}');
        print('Expires in: ${transaction.qrisExpiresAt}');
      }
      
      return transaction;
    }
  } catch (e) {
    print('Error: $e');
  }
  
  return null;
}
```

### Payment Methods

```dart
// Constants dari SDK
class PaymentMethod {
  static const String qris = 'QRIS';
  static const String cash = 'CASH';
  static const String bankTransfer = 'BANK_TRANSFER';
}

class PaymentGateway {
  static const String external = 'external';
  static const String midtrans = 'midtrans';
  static const String internal = 'internal';
}
```

### Checkout Flow Example

```dart
class CheckoutScreen extends StatefulWidget {
  final String cartId;
  final CartSummary summary;
  
  const CheckoutScreen({
    required this.cartId,
    required this.summary,
  });
  
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = PaymentMethod.qris;
  bool _isProcessing = false;
  late CartService _cartService;
  
  @override
  void initState() {
    super.initState();
    _initService();
  }
  
  Future<void> _initService() async {
    final prefs = await SharedPreferences.getInstance();
    final apiService = KgitonApiService(prefs);
    _cartService = apiService.cartService;
  }
  
  Future<void> _processCheckout() async {
    setState(() => _isProcessing = true);
    
    try {
      final result = await _cartService.checkoutCart(
        cartId: widget.cartId,
        paymentMethod: _selectedPayment,
      );
      
      if (result['success'] == true) {
        final transaction = result['data'] as Transaction;
        
        // Navigate ke payment screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(transaction: transaction),
          ),
        );
      } else {
        _showError(result['message'] ?? 'Checkout failed');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Column(
        children: [
          // Summary
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Items: ${widget.summary.totalItems}'),
                  Text('Total Weight: ${widget.summary.totalWeight} kg'),
                  Divider(),
                  Text(
                    'Total: Rp ${widget.summary.totalAmount}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          
          // Payment method
          RadioListTile(
            title: Text('QRIS'),
            value: PaymentMethod.qris,
            groupValue: _selectedPayment,
            onChanged: (value) => setState(() => _selectedPayment = value!),
          ),
          RadioListTile(
            title: Text('Cash'),
            value: PaymentMethod.cash,
            groupValue: _selectedPayment,
            onChanged: (value) => setState(() => _selectedPayment = value!),
          ),
          RadioListTile(
            title: Text('Bank Transfer'),
            value: PaymentMethod.bankTransfer,
            groupValue: _selectedPayment,
            onChanged: (value) => setState(() => _selectedPayment = value!),
          ),
          
          Spacer(),
          
          // Checkout button
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processCheckout,
                child: Text(
                  _isProcessing ? 'Processing...' : 'Bayar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Transaction History

### Get Transactions

```dart
Future<List<Transaction>> getTransactions({
  String? startDate,
  String? endDate,
  int page = 1,
  int perPage = 20,
}) async {
  try {
    final result = await apiService.transactionService.listTransactions(
      startDate: startDate,
      endDate: endDate,
      page: page,
      perPage: perPage,
    );
    
    if (result['success'] == true) {
      return (result['data'] as List).cast<Transaction>();
    }
  } catch (e) {
    print('Error: $e');
  }
  
  return [];
}
```

### Get Transaction Detail

```dart
Future<Transaction?> getTransactionDetail(String transactionNumber) async {
  try {
    final result = await apiService.transactionService.getTransactionDetail(
      transactionNumber,
    );
    
    if (result['success'] == true) {
      return result['data'] as Transaction;
    }
  } catch (e) {
    print('Error: $e');
  }
  
  return null;
}
```

### Transaction List Widget

```dart
class TransactionListWidget extends StatefulWidget {
  @override
  State<TransactionListWidget> createState() => _TransactionListWidgetState();
}

class _TransactionListWidgetState extends State<TransactionListWidget> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  late TransactionService _transactionService;
  
  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }
  
  Future<void> _initAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final apiService = KgitonApiService(prefs);
    _transactionService = apiService.transactionService;
    await _loadTransactions();
  }
  
  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _transactionService.listTransactions();
      
      if (result['success'] == true) {
        setState(() {
          _transactions = (result['data'] as List).cast<Transaction>();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        return ListTile(
          title: Text(tx.transactionNumber),
          subtitle: Text('Rp ${tx.totalAmount} • ${tx.paymentMethod}'),
          trailing: Chip(
            label: Text(tx.paymentStatus),
            backgroundColor: tx.paymentStatus == 'PAID'
                ? Colors.green
                : Colors.orange,
          ),
          onTap: () => _showDetail(tx),
        );
      },
    );
  }
  
  void _showDetail(Transaction tx) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transaction: tx),
      ),
    );
  }
}
```

---

## Next Steps

📖 Untuk troubleshooting:
- [Troubleshooting Guide](05_TROUBLESHOOTING.md)

📱 Contoh lengkap:
- [Example App](../example/timbangan/)

---

**Copyright © 2025 PT KGiTON. All Rights Reserved.**
