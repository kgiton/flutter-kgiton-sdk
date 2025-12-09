# API Integration

## Initialize

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

final prefs = await SharedPreferences.getInstance();
final api = KgitonApiService(prefs);

// Custom base URL (optional)
final api = KgitonApiService(prefs, baseUrl: 'https://your-api.com/api');
```

---

## 1. Authentication

### Register

```dart
final result = await api.authService.register(
  name: 'John Doe',
  email: 'john@example.com',
  password: 'password123',
  licenseKey: 'your-license-key',
);

if (result['success']) {
  final user = result['data']['user'] as User;
  final token = result['data']['token'] as String;
  // Token auto-saved
}
```

### Login

```dart
final result = await api.authService.login(
  email: 'john@example.com',
  password: 'password123',
);

if (result['success']) {
  final user = result['data']['user'] as User;
  // Token auto-saved
}
```

### Get Current User

```dart
final result = await api.authService.getCurrentUser();
if (result['success']) {
  final user = result['data'] as User;
  print(user.name);
}
```

### Logout

```dart
await api.authService.logout();
// Token auto-removed
```

### Check Login

```dart
final token = prefs.getString('auth_token');
final isLoggedIn = token != null && token.isNotEmpty;
```

---

## 2. License Management

### List My Licenses

```dart
final result = await api.ownerService.listLicenses();
if (result['success']) {
  final licenses = (result['data'] as List).cast<License>();
  for (var license in licenses) {
    print('${license.licenseKey} - ${license.deviceName}');
  }
}
```

### Assign License

```dart
final result = await api.ownerService.assignLicense('new-license-key');
if (result['success']) {
  print('License assigned!');
}
```

---

## 3. Item Management

### Create Item

```dart
final result = await api.itemService.createItem(
  name: 'Apple',
  price: 15000,
  unit: 'kg',
);

if (result['success']) {
  final item = result['data'] as Item;
  print('Created: ${item.name}');
}
```

### List Items

```dart
final result = await api.itemService.listItems();
if (result['success']) {
  final items = (result['data'] as List).cast<Item>();
  for (var item in items) {
    print('${item.name} - Rp ${item.price}');
  }
}
```

### Update Item

```dart
final result = await api.itemService.updateItem(
  itemId: 1,
  name: 'Green Apple',
  price: 18000,
);

if (result['success']) {
  print('Updated!');
}
```

### Delete Item

```dart
final result = await api.itemService.deleteItem(1);
if (result['success']) {
  print('Deleted!');
}
```

---

## 4. Cart Management (Session-based v2.0)

### Add to Cart

```dart
final result = await api.cartService.addToCart(
  itemId: 1,
  weight: 0.5, // kg
  pricePerUnit: 15000,
);

if (result['success']) {
  final cartItem = result['data'] as CartItem;
  print('Added: ${cartItem.itemName}');
}
```

### Get Cart

```dart
final result = await api.cartService.getCart();
if (result['success']) {
  final cart = result['data'] as Cart;
  print('Total: Rp ${cart.totalAmount}');
  
  for (var item in cart.items) {
    print('${item.itemName} - ${item.weight} kg - Rp ${item.totalPrice}');
  }
}
```

### Update Cart Item

```dart
final result = await api.cartService.updateCartItem(
  cartItemId: 1,
  weight: 1.0,
);

if (result['success']) {
  print('Updated!');
}
```

### Delete Cart Item

```dart
final result = await api.cartService.deleteCartItem(1);
if (result['success']) {
  print('Deleted!');
}
```

### Clear Cart

```dart
final result = await api.cartService.clearCart();
if (result['success']) {
  print('Cart cleared!');
}
```

---

## 5. Transaction

### Checkout

```dart
final result = await api.transactionService.checkout(
  paymentMethod: 'cash', // or 'qris'
  notes: 'Customer notes',
);

if (result['success']) {
  final transaction = result['data'] as Transaction;
  print('Transaction ID: ${transaction.transactionCode}');
  print('Total: Rp ${transaction.totalAmount}');
  
  if (paymentMethod == 'qris') {
    print('QR Code: ${transaction.qrCodeUrl}');
  }
}
```

### Transaction History

```dart
final result = await api.transactionService.listTransactions();
if (result['success']) {
  final transactions = (result['data'] as List).cast<Transaction>();
  for (var trx in transactions) {
    print('${trx.transactionCode} - Rp ${trx.totalAmount} - ${trx.status}');
  }
}
```

### Transaction Detail

```dart
final result = await api.transactionService.getTransactionDetail(1);
if (result['success']) {
  final transaction = result['data'] as Transaction;
  print('Code: ${transaction.transactionCode}');
  print('Status: ${transaction.status}');
  print('Items: ${transaction.items.length}');
}
```

---

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APIPage extends StatefulWidget {
  @override
  State<APIPage> createState() => _APIPageState();
}

class _APIPageState extends State<APIPage> {
  late KgitonApiService api;
  List<Item> items = [];
  Cart? cart;
  
  @override
  void initState() {
    super.initState();
    initAPI();
  }
  
  Future<void> initAPI() async {
    final prefs = await SharedPreferences.getInstance();
    api = KgitonApiService(prefs);
    
    // Login
    final loginResult = await api.authService.login(
      email: 'test@example.com',
      password: 'password',
    );
    
    if (loginResult['success']) {
      loadItems();
      loadCart();
    }
  }
  
  Future<void> loadItems() async {
    final result = await api.itemService.listItems();
    if (result['success']) {
      setState(() {
        items = (result['data'] as List).cast<Item>();
      });
    }
  }
  
  Future<void> loadCart() async {
    final result = await api.cartService.getCart();
    if (result['success']) {
      setState(() {
        cart = result['data'] as Cart;
      });
    }
  }
  
  Future<void> addToCart(Item item, double weight) async {
    final result = await api.cartService.addToCart(
      itemId: item.id,
      weight: weight,
      pricePerUnit: item.price,
    );
    
    if (result['success']) {
      loadCart();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to cart!')),
      );
    }
  }
  
  Future<void> checkout() async {
    final result = await api.transactionService.checkout(
      paymentMethod: 'cash',
    );
    
    if (result['success']) {
      final trx = result['data'] as Transaction;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Success'),
          content: Text('Transaction: ${trx.transactionCode}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                loadCart();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Integration'),
        actions: [
          IconButton(
            icon: Badge(
              label: Text(cart?.items.length.toString() ?? '0'),
              child: Icon(Icons.shopping_cart),
            ),
            onPressed: () {
              // Show cart
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final item = items[i];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('Rp ${item.price} / ${item.unit}'),
            trailing: ElevatedButton(
              onPressed: () => addToCart(item, 1.0),
              child: Text('Add'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: cart != null && cart!.items.isNotEmpty ? checkout : null,
        icon: Icon(Icons.payment),
        label: Text('Checkout'),
      ),
    );
  }
}
```

---

## Error Handling

```dart
try {
  final result = await api.itemService.createItem(
    name: 'Apple',
    price: 15000,
  );
  
  if (!result['success']) {
    // Handle API error
    print('Error: ${result['message']}');
  }
} catch (e) {
  // Handle network/exception error
  print('Exception: $e');
}
```

---

## Next

- [Cart & Transaction](04_CART_TRANSACTION.md)
- [Troubleshooting](05_TROUBLESHOOTING.md)
