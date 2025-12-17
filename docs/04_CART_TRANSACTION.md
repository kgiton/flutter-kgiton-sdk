# Cart & Transaction Guide

**Complete guide for shopping cart management and payment processing with KGiTON SDK**

> **Prerequisites**: Complete [Getting Started](01_GETTING_STARTED.md) and [API Integration](03_API_INTEGRATION.md) setup.

---

## Table of Contents

- [Cart System Overview](#cart-system-overview)
- [Cart ID Management](#cart-id-management)
- [Cart Operations](#cart-operations)
- [Checkout Process](#checkout-process)
- [Payment Methods](#payment-methods)
- [Transaction Management](#transaction-management)
- [Receipt Generation](#receipt-generation)
- [Complete Workflow Examples](#complete-workflow-examples)

---

## Cart System Overview

### Session-Based Cart (SDK v2.0)

The KGiTON SDK uses a **session-based cart system** that allows:

✅ **Multi-device support**: Each device/license has its own cart  
✅ **Multiple items**: Same item can be added multiple times (perfect for weighing)  
✅ **Session persistence**: Cart data persists across app restarts  
✅ **No duplicates checking**: Ideal for retail weighing scenarios  

### Cart Architecture

```
┌─────────────────────────────────────┐
│          Shopping Session           │
│  Cart ID: {device_id}_{license_key} │
├─────────────────────────────────────┤
│  Cart Items:                        │
│  ┌─────────────────────────────┐   │
│  │ Item 1: Apple - 2.5 kg      │   │
│  │ Item 2: Apple - 1.0 kg      │   │ ← Same item, different entries
│  │ Item 3: Banana - 0.5 kg     │   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│  Summary:                           │
│  Total Items: 3                     │
│  Total Weight: 4.0 kg               │
│  Total Amount: Rp 65,000            │
└─────────────────────────────────────┘
```

---

## Cart ID Management

### Generate Cart ID

The cart ID format: `{device_id}_{license_key}`

```dart
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartManager {
  static const String _deviceIdKey = 'kgiton_device_id';
  
  String _deviceId = '';
  String _licenseKey = '';
  String _cartId = '';
  
  /// Initialize cart manager with license key
  Future<void> initialize(String licenseKey) async {
    _licenseKey = licenseKey;
    
    // Load or generate device ID
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString(_deviceIdKey) ?? const Uuid().v4();
    
    // Save device ID for future use
    if (!prefs.containsKey(_deviceIdKey)) {
      await prefs.setString(_deviceIdKey, _deviceId);
    }
    
    // Generate cart ID
    _cartId = '${_deviceId}_$licenseKey';
    
    print('📝 Cart ID: $_cartId');
    print('📱 Device ID: $_deviceId');
    print('🔑 License Key: $_licenseKey');
  }
  
  /// Get current cart ID
  String get cartId => _cartId;
  
  /// Get device ID
  String get deviceId => _deviceId;
  
  /// Reset device ID (for testing)
  Future<void> resetDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    _deviceId = const Uuid().v4();
    await prefs.setString(_deviceIdKey, _deviceId);
    _cartId = '${_deviceId}_$_licenseKey';
  }
}
```

### Usage Example

```dart
final cartManager = CartManager();
await cartManager.initialize('YOUR-LICENSE-KEY');

final cartId = cartManager.cartId;
print('Using cart: $cartId');
```

---

## Cart Operations

### Quantity Validation Rules

Starting from SDK, the cart system supports flexible dual pricing with the following validation rules:

#### Valid Quantity Values

- **`quantity` (kg)**: Can be `>= 0` (accepts 0, null, or positive numbers)
- **`quantityPcs` (pcs)**: Can be `>= 0` (accepts 0, null, or positive numbers)
- **Constraint**: At least one field must be `> 0` (both cannot be 0 or null)

#### Semantic Meaning

- **`quantity = 0`** → Item **NOT sold per kg**, only per pcs
- **`quantityPcs = 0`** → Item **NOT sold per pcs**, only per kg
- **Both `> 0`** → Item sold with **dual pricing**

#### Examples

**1. Per Kg Only (Option 1):**
```dart
AddCartRequest(
  cartId: cartId,
  licenseKey: licenseKey,
  itemId: itemId,
  quantity: 2.5,       // 2.5 kg
  quantityPcs: null,   // Not used
)
```

**2. Per Kg Only (Option 2):**
```dart
AddCartRequest(
  cartId: cartId,
  licenseKey: licenseKey,
  itemId: itemId,
  quantity: 2.5,       // 2.5 kg
  quantityPcs: 0,      // Not sold per pcs
)
```

**3. Per Pcs Only (Option 1):**
```dart
AddCartRequest(
  cartId: cartId,
  licenseKey: licenseKey,
  itemId: itemId,
  quantity: null,      // Not used
  quantityPcs: 10,     // 10 pieces
)
```

**4. Per Pcs Only (Option 2):**
```dart
AddCartRequest(
  cartId: cartId,
  licenseKey: licenseKey,
  itemId: itemId,
  quantity: 0,         // Not sold per kg
  quantityPcs: 10,     // 10 pieces
)
```

**5. Dual Pricing:**
```dart
AddCartRequest(
  cartId: cartId,
  licenseKey: licenseKey,
  itemId: itemId,
  quantity: 1.5,       // 1.5 kg
  quantityPcs: 8,      // 8 pieces
)
```

**❌ Invalid Examples:**

```dart
// Both zero - REJECTED
AddCartRequest(
  quantity: 0,
  quantityPcs: 0,
)

// Both null - REJECTED
AddCartRequest(
  quantity: null,
  quantityPcs: null,
)

// Negative values - REJECTED
AddCartRequest(
  quantity: -1.5,
  quantityPcs: 10,
)
```

---

### 1. Add Item to Cart

**Add weighted item from scale:**

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

Future<void> addItemToCart({
  required String cartId,
  required String licenseKey,
  required int itemId,
  required double quantity,  // Weight from scale
  String? notes,
}) async {
  final api = KgitonApiService(
    baseUrl: 'https://api.example.com/api',
  );
  await api.loadConfiguration();
  
  try {
    final cartItem = await api.cart.addItemToCart(
      AddCartRequest(
        cartId: cartId,
        licenseKey: licenseKey,
        itemId: itemId,
        quantity: quantity,
        notes: notes,
      ),
    );
    
    print('✅ Added to cart:');
    print('   Item: ${cartItem.item?.name}');
    print('   Quantity: ${quantity} kg');
    print('   Price: Rp ${cartItem.totalPrice}');
  } catch (e) {
    print('💥 Error: $e');
  }
}
```

**Complete Add Flow with Scale:**

```dart
class AddToCartFlow extends StatefulWidget {
  final Item item;
  final String cartId;
  final String licenseKey;
  
  const AddToCartFlow({
    required this.item,
    required this.cartId,
    required this.licenseKey,
  });
  
  @override
  State<AddToCartFlow> createState() => _AddToCartFlowState();
}

class _AddToCartFlowState extends State<AddToCartFlow> {
  final KGiTONScaleService _scale = KGiTONScaleService();
  late KgitonApiService _api;
  
  double _currentWeight = 0.0;
  bool _isStable = false;
  bool _isAdding = false;
  
  @override
  void initState() {
    super.initState();
    _initServices();
    _listenToWeight();
  }
  
  Future<void> _initServices() async {
    _api = KgitonApiService(
      baseUrl: 'https://api.example.com/api',
    );
    await _api.loadConfiguration();
  }
  
  void _listenToWeight() {
    _scale.weightStream.listen((weight) {
      setState(() {
        _currentWeight = weight.value;
        _isStable = weight.isStable;
      });
    });
  }
  
  Future<void> _addToCart() async {
    if (!_isStable || _currentWeight <= 0) {
      _showMessage('Please wait for stable weight');
      return;
    }
    
    setState(() => _isAdding = true);
    
    try {
      final cartItem = await _api.cart.addItemToCart(
        AddCartRequest(
          cartId: widget.cartId,
          licenseKey: widget.licenseKey,
          itemId: widget.item.id,
          quantity: _currentWeight,
        ),
      );
      
      // Play success sound
      await _scale.sendBuzzerCommand('success');
      
      _showMessage('✅ Added ${_currentWeight} kg to cart');
      
      // Navigate back or reset
      Navigator.pop(context, true);
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() => _isAdding = false);
    }
  }
  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.item.name}'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Item info
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    widget.item.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rp ${widget.item.price} / ${widget.item.unit}',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          
          // Weight display
          Container(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  '${_currentWeight.toStringAsFixed(2)} kg',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: _isStable ? Colors.green : Colors.orange,
                  ),
                ),
                SizedBox(height: 8),
                Chip(
                  label: Text(_isStable ? 'STABLE' : 'WEIGHING...'),
                  backgroundColor: _isStable ? Colors.green : Colors.orange,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Price calculation
          if (_currentWeight > 0)
            Container(
              padding: EdgeInsets.all(16),
              child: Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Total Price', style: TextStyle(fontSize: 14)),
                      Text(
                        'Rp ${(_currentWeight * widget.item.price).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          SizedBox(height: 32),
          
          // Add button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (_isStable && _currentWeight > 0 && !_isAdding)
                    ? _addToCart
                    : null,
                icon: Icon(Icons.add_shopping_cart),
                label: Text(
                  _isAdding ? 'Adding...' : 'Add to Cart',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }
}
```

### 2. Get Cart Items

```dart
Future<List<CartItem>> getCartItems(String cartId) async {
  final api = KgitonApiService(
    baseUrl: 'https://api.example.com/api',
  );
  await api.loadConfiguration();
  
  try {
    final items = await api.cart.getCartItems(cartId);
    
    print('🛒 Cart has ${items.length} items');
    for (var item in items) {
      print('   ${item.item?.name}: ${item.quantity} kg - Rp ${item.totalPrice}');
    }
    
    return items;
  } catch (e) {
    print('Error: $e');
  }
  
  return [];
}
```

### 3. Get Cart Summary

```dart
Future<CartSummary?> getCartSummary(String cartId) async {
  final api = KgitonApiService(
    baseUrl: 'https://api.example.com/api',
  );
  await api.loadConfiguration();
  
  try {
    final summary = await api.cart.getCartSummary(cartId);
    
    print('📊 Cart Summary:');
    print('   Items: ${summary.totalItems}');
    print('   Amount: Rp ${summary.totalAmount}');
    
    return summary;
  } catch (e) {
    print('Error: $e');
  }
  
  return null;
}
```

### 4. Update Cart Item

```dart
Future<void> updateCartItem({
  required String cartItemId,
  double? quantity,
  int? quantityPcs,
  String? notes,
}) async {
  final api = KgitonApiService(
    baseUrl: 'https://api.example.com/api',
  );
  await api.loadConfiguration();
  
  try {
    final updatedItem = await api.cart.updateCartItem(
      cartItemId,
      UpdateCartRequest(
        quantity: quantity,
        quantityPcs: quantityPcs,
        notes: notes,
      ),
    );
    
    print('✅ Cart item updated');
    print('   New quantity: ${updatedItem.quantity}');
    print('   New total: Rp ${updatedItem.totalPrice}');
  } catch (e) {
    print('Error: $e');
  }
}
```

### 5. Remove Cart Item

```dart
Future<void> removeFromCart(String cartItemId) async {
  final api = KgitonApiService(
    baseUrl: 'https://api.example.com/api',
  );
  await api.loadConfiguration();
  
  try {
    final success = await api.cart.deleteCartItem(cartItemId);
    
    if (success) {
      print('✅ Item removed from cart');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### 6. Clear Cart

```dart
Future<void> clearCart(String cartId) async {
  final api = KgitonApiService(
    baseUrl: 'https://api.example.com/api',
  );
  await api.loadConfiguration();
  
  try {
    final success = await api.cart.clearCart(cartId);
    
    if (success) {
      print('✅ Cart cleared');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

---

## Multi-Branch Cart Operations

> **NEW in API v1.0.0**: Support for license-based cart operations for multi-branch owners.

### Get Cart Items by License Key

For multi-branch owners, you can retrieve cart items for a specific license:

```dart
Future<List<CartItem>> getCartByLicense(String licenseKey) async {
  final api = KgitonApiService(
    baseUrl: 'https://api.example.com/api',
  );
  await api.loadConfiguration();
  
  try {
    // Get all cart items for Branch A
    final branchACart = await api.cart.getCartItemsByLicenseKey('LICENSE-KEY-A');
    
    print('🛒 Branch A Cart has ${branchACart.length} items');
    for (var item in branchACart) {
      print('   ${item.item?.name}: ${item.quantity} kg - Rp ${item.totalPrice}');
    }
    
    return branchACart;
  } catch (e) {
    print('Error: $e');
  }
  
  return [];
}
```

### Clear Cart by License Key

Clear all cart items for a specific license:

```dart
Future<void> clearCartByLicense(String licenseKey) async {
  final api = KgitonApiService(
    baseUrl: 'https://api.example.com/api',
  );
  await api.loadConfiguration();
  
  try {
    final success = await api.cart.clearCartByLicenseKey(licenseKey);
    
    if (success) {
      print('✅ Cart cleared for license: $licenseKey');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### Using Cart Helper

For simplified usage, use the `KgitonCartHelper`:

```dart
final cartHelper = KgitonCartHelper(api);

// Get cart by license
final result = await cartHelper.getItemsByLicenseKey('LICENSE-KEY-A');
if (result['success']) {
  List<CartItem> items = result['data'];
  print('Found ${items.length} items');
}

// Clear cart by license
final clearResult = await cartHelper.clearCartByLicenseKey('LICENSE-KEY-A');
if (clearResult['success']) {
  print('Cart cleared successfully');
}
```

---

## Checkout Process

### Payment Methods Available

| Method | Code | Description |
|--------|------|-------------|
| **QRIS** | `QRIS` | Indonesian QR payment standard |
| **Cash** | `CASH` | Cash payment |
| **Bank Transfer** | `BANK_TRANSFER` | Manual bank transfer |

### Checkout Flow

```dart
Future<Transaction?> checkout({
  required String cartId,
  required String paymentMethod,
  String? paymentGateway,
  String? notes,
}) async {
  final api = KgitonApiService(
    baseUrl: 'https://api.example.com/api',
  );
  await api.loadConfiguration();
  
  try {
    final transaction = await api.cart.checkoutCart(
      cartId,
      CheckoutCartRequest(
        paymentMethod: paymentMethod,
        paymentGateway: paymentGateway ?? 'external',
        notes: notes,
      ),
    );
    
    print('✅ Transaction created!');
    print('   Number: ${transaction.transactionNumber}');
    print('   Amount: Rp ${transaction.totalAmount}');
    print('   Status: ${transaction.paymentStatus}');
    
    // QRIS specific
    if (paymentMethod == 'QRIS' && transaction.qrisString != null) {
      print('   QRIS Code: ${transaction.qrisString}');
      print('   Expires: ${transaction.qrisExpiresAt}');
    }
    
    return transaction;
  } catch (e) {
    print('💥 Error: $e');
  }
  
  return null;
}
```

### Complete Checkout Screen

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
  late KgitonApiService _api;
  String _selectedPayment = 'CASH';
  String? _notes;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _initService();
  }
  
  Future<void> _initService() async {
    _api = KgitonApiService(
      baseUrl: 'https://api.example.com/api',
    );
    await _api.loadConfiguration();
  }
  
  Future<void> _processCheckout() async {
    // Confirm checkout
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Checkout'),
        content: Text(
          'Total: Rp ${widget.summary.totalAmount}\n'
          'Payment: $_selectedPayment\n\n'
          'Proceed with checkout?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() => _isProcessing = true);
    
    try {
      final transaction = await _api.cart.checkoutCart(
        widget.cartId,
        CheckoutCartRequest(
          paymentMethod: _selectedPayment,
          paymentGateway: 'external',
          notes: _notes,
        ),
      );
      
      // Navigate to payment/receipt screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(transaction: transaction),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Column(
        children: [
          // Cart Summary
          Card(
            margin: EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Items:'),
                      Text(
                        '${widget.summary.totalItems}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Weight:'),
                      Text(
                        '${widget.summary.totalWeight} kg',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp ${widget.summary.totalAmount}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Payment Method Selection
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                RadioListTile<String>(
                  title: Row(
                    children: [
                      Icon(Icons.qr_code, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('QRIS'),
                    ],
                  ),
                  value: 'QRIS',
                  groupValue: _selectedPayment,
                  onChanged: (value) {
                    setState(() => _selectedPayment = value!);
                  },
                ),
                RadioListTile<String>(
                  title: Row(
                    children: [
                      Icon(Icons.money, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Cash'),
                    ],
                  ),
                  value: 'CASH',
                  groupValue: _selectedPayment,
                  onChanged: (value) {
                    setState(() => _selectedPayment = value!);
                  },
                ),
                RadioListTile<String>(
                  title: Row(
                    children: [
                      Icon(Icons.account_balance, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Bank Transfer'),
                    ],
                  ),
                  value: 'BANK_TRANSFER',
                  groupValue: _selectedPayment,
                  onChanged: (value) {
                    setState(() => _selectedPayment = value!);
                  },
                ),
              ],
            ),
          ),
          
          // Notes (optional)
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Add notes for this transaction',
              ),
              maxLines: 2,
              onChanged: (value) => _notes = value,
            ),
          ),
          
          Spacer(),
          
          // Checkout Button
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isProcessing
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Process Payment',
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

## Payment Methods

### 1. QRIS Payment

**QRIS (Quick Response Code Indonesian Standard)** for digital payments:

```dart
class QRISPaymentScreen extends StatefulWidget {
  final Transaction transaction;
  
  const QRISPaymentScreen({required this.transaction});
  
  @override
  State<QRISPaymentScreen> createState() => _QRISPaymentScreenState();
}

class _QRISPaymentScreenState extends State<QRISPaymentScreen> {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    _startTimer();
  }
  
  void _startTimer() {
    if (widget.transaction.qrisExpiresAt != null) {
      final expiresAt = DateTime.parse(widget.transaction.qrisExpiresAt!);
      _timeRemaining = expiresAt.difference(DateTime.now());
      
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _timeRemaining = expiresAt.difference(DateTime.now());
          
          if (_timeRemaining.isNegative) {
            timer.cancel();
            _showExpiredDialog();
          }
        });
      });
    }
  }
  
  void _showExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('QR Code Expired'),
        content: Text('The QR code has expired. Please create a new transaction.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QRIS Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scan QR Code to Pay',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            
            // QR Code (use qr_flutter package)
            if (widget.transaction.qrisString != null)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: widget.transaction.qrisString!,
                  version: QrVersions.auto,
                  size: 300,
                ),
              ),
            
            SizedBox(height: 32),
            
            // Transaction info
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Total Payment',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Rp ${widget.transaction.totalAmount}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Timer
            if (!_timeRemaining.isNegative)
              Chip(
                avatar: Icon(Icons.timer, size: 16),
                label: Text(
                  'Expires in ${_timeRemaining.inMinutes}:${(_timeRemaining.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.orange[100],
              ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

### 2. Cash Payment

**Instant completion for cash payments:**

```dart
class CashPaymentScreen extends StatelessWidget {
  final Transaction transaction;
  
  const CashPaymentScreen({required this.transaction});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cash Payment'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 32),
            Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Transaction: ${transaction.transactionNumber}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Rp ${transaction.totalAmount}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 48),
            ElevatedButton.icon(
              icon: Icon(Icons.print),
              label: Text('Print Receipt'),
              onPressed: () {
                // TODO: Print receipt
              },
            ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Bank Transfer

**Manual bank transfer with instructions:**

```dart
class BankTransferScreen extends StatelessWidget {
  final Transaction transaction;
  
  const BankTransferScreen({required this.transaction});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank Transfer'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transfer Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(),
                  
                  _buildInfoRow('Bank Name', 'BCA'),
                  _buildInfoRow('Account Number', '1234567890'),
                  _buildInfoRow('Account Name', 'PT KGiTON'),
                  Divider(),
                  
                  _buildInfoRow(
                    'Amount',
                    'Rp ${transaction.totalAmount}',
                    valueStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  
                  _buildInfoRow(
                    'Transaction Code',
                    transaction.transactionNumber,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          Card(
            color: Colors.orange[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Instructions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('1. Transfer the exact amount shown above'),
                  Text('2. Use transaction code as reference'),
                  Text('3. Send proof of payment to admin'),
                  Text('4. Wait for confirmation'),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          ElevatedButton.icon(
            icon: Icon(Icons.upload_file),
            label: Text('Upload Proof of Payment'),
            onPressed: () {
              // TODO: Upload proof
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: valueStyle ?? TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```

---

## Transaction Management

### Get Transaction History

```dart
Future<List<Transaction>> getTransactionHistory({
  String? startDate,
  String? endDate,
  String? status,
  int page = 1,
  int limit = 20,
}) async {
  final api = KgitonApiService(
    baseUrl: 'https://api.example.com/api',
  );
  await api.loadConfiguration();
  
  try {
    final transactionData = await api.transaction.listTransactions(
      page: page,
      limit: limit,
      status: status,
    );
    
    return transactionData.data;
  } catch (e) {
    print('Error: $e');
  }
  
  return [];
}
```

### Get Transaction Details

```dart
Future<TransactionDetail?> getTransactionDetails(String transactionId) async {
  final api = KgitonApiService(
    baseUrl: 'https://api.example.com/api',
  );
  await api.loadConfiguration();
  
  try {
    final transactionDetail = await api.transaction.getTransactionDetail(
      transactionId,
    );
    
    return transactionDetail;
  } catch (e) {
    print('Error: $e');
  }
  
  return null;
}
```

### Transaction History Screen

```dart
class TransactionHistoryScreen extends StatefulWidget {
  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late KgitonApiService _api;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }
  
  Future<void> _initAndLoad() async {
    _api = KgitonApiService(
      baseUrl: 'https://api.example.com/api',
    );
    await _api.loadConfiguration();
    await _loadTransactions();
  }
  
  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    
    try {
      final transactionData = await _api.transaction.listTransactions();
      
      setState(() {
        _transactions = transactionData.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
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
      appBar: AppBar(
        title: Text('Transaction History'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No transactions yet', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTransactions,
                  child: ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      return _buildTransactionCard(tx);
                    },
                  ),
                ),
    );
  }
  
  Widget _buildTransactionCard(Transaction tx) {
    Color statusColor;
    switch (tx.paymentStatus.toUpperCase()) {
      case 'PAID':
      case 'COMPLETED':
        statusColor = Colors.green;
        break;
      case 'PENDING':
        statusColor = Colors.orange;
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            Icons.receipt,
            color: statusColor,
          ),
        ),
        title: Text(
          tx.transactionNumber,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('Rp ${tx.totalAmount}'),
            Text(
              tx.paymentMethod,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            tx.paymentStatus,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: statusColor,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailScreen(
                transactionNumber: tx.transactionNumber,
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

## Receipt Generation

### Print Receipt

```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateAndPrintReceipt(Transaction transaction) async {
  final pdf = pw.Document();
  
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'PT KGiTON',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text('Jl. Example No. 123'),
                  pw.Text('Phone: +62 123 4567 890'),
                  pw.SizedBox(height: 10),
                  pw.Divider(),
                ],
              ),
            ),
            
            // Transaction Info
            pw.SizedBox(height: 10),
            pw.Text('Transaction: ${transaction.transactionNumber}'),
            pw.Text('Date: ${transaction.createdAt}'),
            pw.Text('Payment: ${transaction.paymentMethod}'),
            pw.SizedBox(height: 10),
            pw.Divider(),
            
            // Items
            pw.SizedBox(height: 10),
            for (var item in transaction.items) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(item.itemName ?? 'Unknown'),
                  pw.Text('Rp ${item.totalPrice}'),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text(
                    '  ${item.quantity} kg @ Rp ${item.pricePerUnit}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
            ],
            
            pw.Divider(),
            
            // Total
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Rp ${transaction.totalAmount}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text('Thank you for your purchase!'),
            ),
          ],
        );
      },
    ),
  );
  
  // Print
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
```

---

## Complete Workflow Examples

### Full Transaction Flow

```dart
class FullTransactionFlow {
  final KgitonApiService api;
  final CartManager cartManager;
  
  FullTransactionFlow({
    required this.api,
    required this.cartManager,
  });
  
  /// Complete workflow from cart to payment
  Future<Transaction?> executeCompleteFlow({
    required List<CartItem> items,
    required String paymentMethod,
  }) async {
    try {
      // Step 1: Verify cart has items
      if (items.isEmpty) {
        print('❌ Cart is empty');
        return null;
      }
      
      print('🛒 Step 1: Cart verified (${items.length} items)');
      
      // Step 2: Get cart summary
      final cartSummary = await api.cart.getCartSummary(
        cartManager.cartId,
      );
      
      print('💰 Step 2: Total amount: Rp ${cartSummary.totalAmount}');
      
      // Step 3: Checkout
      print('🔄 Step 3: Processing checkout...');
      final transaction = await api.cart.checkoutCart(
        cartManager.cartId,
        CheckoutCartRequest(
          paymentMethod: paymentMethod,
          paymentGateway: 'external',
        ),
      );
      print('✅ Step 4: Transaction created: ${transaction.transactionNumber}');
      
      // Step 5: Handle payment-specific flow
      if (paymentMethod == 'QRIS') {
        print('📱 QRIS Code: ${transaction.qrisString}');
        // Show QRIS screen
      } else if (paymentMethod == 'CASH') {
        print('💵 Cash payment completed');
        // Show success screen
      }
      
      return transaction;
      
    } catch (e) {
      print('💥 Error in transaction flow: $e');
      return null;
    }
  }
}
```

---

## Best Practices

### 1. Cart State Management

```dart
class CartState extends ChangeNotifier {
  List<CartItem> _items = [];
  CartSummary? _summary;
  bool _isLoading = false;
  
  List<CartItem> get items => _items;
  CartSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;
  
  Future<void> loadCart(String cartId, KgitonApiService api) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load items
      _items = await api.cart.getCartItems(cartId);
      
      // Load summary
      _summary = await api.cart.getCartSummary(cartId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addItem(
    String cartId,
    String licenseKey,
    String itemId,
    double quantity,
    KgitonApiService api,
  ) async {
    await api.cart.addItemToCart(
      AddCartRequest(
        cartId: cartId,
        licenseKey: licenseKey,
        itemId: itemId,
        quantity: quantity,
      ),
    );
    
    await loadCart(cartId, api);
  }
  
  Future<void> removeItem(
    String cartItemId,
    String cartId,
    KgitonApiService api,
  ) async {
    await api.cart.deleteCartItem(cartItemId);
    await loadCart(cartId, api);
  }
  
  void clear() {
    _items = [];
    _summary = null;
    notifyListeners();
  }
}
```

### 2. Error Handling

```dart
try {
  final result = await checkout(/*...*/);
  
  if (result == null) {
    // Handle null result
    showErrorDialog('Checkout failed');
  } else {
    // Success
    navigateToPayment(result);
  }
} on SocketException {
  showErrorDialog('No internet connection');
} on TimeoutException {
  showErrorDialog('Request timeout. Please try again.');
} catch (e) {
  showErrorDialog('An error occurred: $e');
}
```

---

## Next Steps

- **[Troubleshooting Guide](05_TROUBLESHOOTING.md)** - Common issues and solutions
- **[Example App](../example/kgiton_apps/)** - Complete implementation reference

---

**Copyright © 2025 PT KGiTON. All Rights Reserved.**

For support, contact: support@kgiton.com
