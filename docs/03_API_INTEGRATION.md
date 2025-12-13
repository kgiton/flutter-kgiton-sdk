# API Integration Guide

**Complete REST API reference for KGiTON backend services**

> **Prerequisites**: Complete [Getting Started](01_GETTING_STARTED.md) setup and have API credentials.

---

## Table of Contents

- [API Overview](#api-overview)
- [Initialization](#initialization)
- [Authentication](#authentication)
- [License Management](#license-management)
- [Item Management](#item-management)
- [Cart Operations](#cart-operations)
- [Transaction Management](#transaction-management)
- [Error Handling](#error-handling)
- [API Reference](#api-reference)

---

## API Overview

### Base URL

```
https://api.example.com/api/v1
```

### Authentication

The API uses **JWT (JSON Web Token)** authentication:
- Access Token: Short-lived token for API requests
- Refresh Token: Long-lived token for obtaining new access tokens

### Response Format

All API responses follow this structure:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { }
}
```

### HTTP Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid request data |
| 401 | Unauthorized | Authentication required or token expired |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 422 | Validation Error | Request validation failed |
| 500 | Server Error | Internal server error |

---

## Initialization

### Basic Initialization

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// Initialize API Service with base URL
final api = KgitonApiService(
  baseUrl: 'https://api.example.com/api',
);

// Load saved configuration (access/refresh tokens)
await api.loadConfiguration();

// Custom base URL
final api = KgitonApiService(
  baseUrl: 'https://your-api.com/api',
);
```

### Advanced Configuration

```dart
class ApiConfig {
  static const String productionUrl = 'https://api.example.com/api';
  static const String stagingUrl = 'https://staging-api.example.com/api';
  static const String developmentUrl = 'http://localhost:3000/api';
  
  static String getBaseUrl(String environment) {
    switch (environment) {
      case 'production':
        return productionUrl;
      case 'staging':
        return stagingUrl;
      default:
        return developmentUrl;
    }
  }
}

// Usage
final api = KgitonApiService(
  prefs,
  baseUrl: ApiConfig.getBaseUrl('production'),
);
```

---

## Authentication

### 1. Register New Owner

**Endpoint**: `POST /auth/register-owner`

**Request**:
```dart
final authData = await api.auth.registerOwner(
  name: 'John Doe',
  email: 'john@example.com',
  password: 'SecurePass123!',
  licenseKey: 'KGITON-12345-ABCDE-67890-FGHIJ',
  entityType: 'individual',
);
```

**Request Body**:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "licenseKey": "KGITON-12345-ABCDE-67890-FGHIJ"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "user": {
      "id": 1,
      "email": "john@example.com",
      "name": "John Doe",
      "role": "owner",
      "createdAt": "2025-12-12T10:00:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Codes**:
- `422`: Validation error (email format, password length)
- `409`: Email already exists
- `400`: Invalid license key

### 2. Login

**Endpoint**: `POST /auth/login`

**Request**:
```dart
final authData = await api.auth.login(
  email: 'john@example.com',
  password: 'SecurePass123!',
);

print('Welcome, ${authData.user.email}!');
print('Access Token: ${authData.accessToken}');
// Tokens are automatically saved
```

**Request Body**:
```json
{
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "email": "john@example.com",
      "name": "John Doe",
      "role": "owner"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Codes**:
- `401`: Invalid email or password
- `400`: Missing required fields

### 3. Get Current User

**Endpoint**: `GET /auth/me`

**Request**:
```dart
final currentUserData = await api.auth.getCurrentUser();

print('ID: ${currentUserData.user.id}');
print('Email: ${currentUserData.user.email}');
print('Role: ${currentUserData.profile.role}');
print('Name: ${currentUserData.profile.name}');
```

**Response**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "john@example.com",
    "name": "John Doe",
    "role": "owner",
    "createdAt": "2025-12-12T10:00:00Z"
  }
}
```

**Error Codes**:
- `401`: Unauthorized (no token or expired token)

### 4. Logout

**Endpoint**: `POST /auth/logout`

**Request**:
```dart
await api.auth.logout();
// Tokens are automatically cleared from storage
```

**Response**:
```json
{
  "success": true,
  "message": "Logout successful"
}
```

### Token Management

```dart
// Check if user is logged in
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('auth_token');
final isLoggedIn = token != null && token.isNotEmpty;

if (!isLoggedIn) {
  // Redirect to login
}

// Manually set token (if needed)
prefs.setString('auth_token', 'your-token-here');

// Clear token
prefs.remove('auth_token');
```

---

## License Management

### 1. List My Licenses

**Endpoint**: `GET /owner/licenses`

**Request**:
```dart
final licensesData = await api.owner.listOwnLicenses();

for (var license in licensesData.licenses) {
  print('License Key: ${license.licenseKey}');
  print('Entity: ${license.entityName}');
  print('Type: ${license.entityType}');
  print('Expires: ${license.expiresAt}');
}
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "licenseKey": "KGITON-12345-ABCDE-67890-FGHIJ",
      "deviceName": "Main Counter Scale",
      "status": "active",
      "expiresAt": "2026-12-31T23:59:59Z",
      "createdAt": "2025-01-01T00:00:00Z"
    }
  ]
}
```

### 2. Assign Additional License

**Endpoint**: `POST /owner/licenses/assign`

**Request**:
```dart
final license = await api.owner.assignAdditionalLicense(
  'KGITON-NEW12-34567-89ABC-DEFGH'
);

print('License assigned successfully!');
print('License Key: ${license.licenseKey}');
print('Entity: ${license.entityName}');
```

**Request Body**:
```json
{
  "licenseKey": "KGITON-NEW12-34567-89ABC-DEFGH"
}
```

**Response**:
```json
{
  "success": true,
  "message": "License assigned successfully",
  "data": {
    "id": 2,
    "licenseKey": "KGITON-NEW12-34567-89ABC-DEFGH",
    "status": "active"
  }
}
```

**Error Codes**:
- `400`: Invalid license key format
- `404`: License key not found
- `409`: License already assigned

---

## Item Management

### 1. Create Item

**Endpoint**: `POST /items`

**Request**:
```dart
final item = await api.owner.createItem(
  name: 'Organic Apple',
  unit: 'kg',
  price: 18500,
  pricePerPcs: 2000,
  description: 'Fresh organic apples',
);

print('Created item ID: ${item.id}');
print('Name: ${item.name}');
print('Price per kg: Rp ${item.pricePerKg}');
```

**Request Body**:
```json
{
  "name": "Organic Apple",
  "price": 18500,
  "unit": "kg",
  "category": "Fruits",
  "sku": "FRUIT-001"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Item created successfully",
  "data": {
    "id": 1,
    "name": "Organic Apple",
    "price": 18500,
    "unit": "kg",
    "category": "Fruits",
    "sku": "FRUIT-001",
    "createdAt": "2025-12-12T10:00:00Z"
  }
}
```

### 2. List Items

**Endpoint**: `GET /items?page=1&limit=20`

**Request**:
```dart
final itemListData = await api.owner.listItems(
  'YOUR-LICENSE-KEY',
);

for (var item in itemListData.items) {
  print('${item.name} - Rp ${item.pricePerKg}/kg');
  if (item.pricePerPcs != null) {
    print('  or Rp ${item.pricePerPcs}/pcs');
  }
}
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Organic Apple",
      "price": 18500,
      "unit": "kg",
      "category": "Fruits",
      "sku": "FRUIT-001"
    },
    {
      "id": 2,
      "name": "Fresh Banana",
      "price": 12000,
      "unit": "kg",
      "category": "Fruits",
      "sku": "FRUIT-002"
    }
  ],
  "pagination": {
    "total": 50,
    "page": 1,
    "limit": 20,
    "totalPages": 3
  }
}
```

### 3. Get Item by ID

**Endpoint**: `GET /items/:id`

**Request**:
```dart
final item = await api.owner.getItemDetail('item-uuid-here');

print('Item: ${item.name}');
print('Price: Rp ${item.pricePerKg}');
```

**Response**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Organic Apple",
    "price": 18500,
    "unit": "kg",
    "category": "Fruits",
    "sku": "FRUIT-001"
  }
}
```

### 4. Update Item

**Endpoint**: `PUT /items/:id`

**Request**:
```dart
final updatedItem = await api.owner.updateItem(
  itemId: 'item-uuid-here',
  name: 'Premium Organic Apple',
  price: 22000,
);

print('Item updated successfully');
print('New name: ${updatedItem.name}');
```

**Request Body**:
```json
{
  "name": "Premium Organic Apple",
  "price": 22000
}
```

**Response**:
```json
{
  "success": true,
  "message": "Item updated successfully",
  "data": {
    "id": 1,
    "name": "Premium Organic Apple",
    "price": 22000,
    "unit": "kg",
    "category": "Fruits"
  }
}
```

### 5. Delete Item (Permanent)

**Endpoint**: `DELETE /items/:id`

**Request**:
```dart
// ⚠️ WARNING: This permanently deletes the item from database
// This action CANNOT be undone!
final success = await api.owner.deleteItem('item-uuid-here');

if (success) {
  print('Item permanently deleted');
}
```

**Response**:
```json
{
  "success": true,
  "message": "Item deleted successfully"
}
```

**Important Notes**:
- All delete operations are now **permanent** (hard delete)
- Deleted items **cannot be recovered**
- No soft delete functionality - items are removed from database
- Always show strong confirmation dialog to users before calling this method
- Consider implementing typed confirmation (e.g., "DELETE" keyword) for critical operations

### 6. Delete All Items (Permanent Delete)

**Endpoint**: `DELETE /items/permanent`

**Request**:
```dart
// ⚠️ WARNING: This permanently deletes ALL items from database
try {
  final result = await api.owner.deleteAllItems();
  print('Successfully deleted ${result.count} items');
} catch (e) {
  print('Error: $e');
}
```

**Response**:
```json
{
  "success": true,
  "message": "5 item(s) permanently deleted",
  "data": {
    "count": 5
  }
}
```

**Response (No Items)**:
```json
{
  "success": true,
  "message": "0 item(s) permanently deleted",
  "data": {
    "count": 0
  }
}
```

**Important Notes**:
- This performs a **permanent delete** (hard delete) on **ALL items**
- Deleted items **cannot be recovered**
- Only deletes items belonging to the authenticated owner
- **MUST** show double confirmation dialog to users
- Recommended to implement backup/export before deletion

**Example with Confirmation Dialog**:
```dart
Future<void> deleteAllItemsWithConfirmation(BuildContext context) async {
  // Get current items count
  final items = await api.owner.listAllItems();
  final count = items.items.length;
  
  if (count == 0) {
    showSnackbar('No items to delete');
    return;
  }
  
  // Show confirmation dialog
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 8),
          Text('Delete All Items?'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚠️ WARNING',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 12),
          Text('This will permanently delete ALL $count item(s)!'),
          SizedBox(height: 8),
          Text(
            'This action CANNOT be undone!',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text('Are you absolutely sure?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text('Delete All'),
        ),
      ],
    ),
  );
  
  if (confirmed != true) return;
  
  // Perform deletion
  try {
    final result = await api.owner.deleteAllItems();
    showSnackbar('${result.count} item(s) deleted successfully');
    
    // Refresh items list
    // ... refresh your UI here
  } catch (e) {
    showSnackbar('Failed to delete items: $e');
  }
}
```

**Error Codes**:
- `401`: Unauthorized - Token invalid or expired
- `403`: Forbidden - User is not an owner
- `400`: Bad Request - Failed to delete items

**Use Cases**:
1. **Reset Inventory** - Owner wants to clear all items and start fresh
2. **Data Cleanup** - Remove all old/test data before production
3. **Account Migration** - Clear data before switching to new system

**See Also**: [DELETE_ALL_ITEMS.md](../docs/DELETE_ALL_ITEMS.md) for complete implementation guide

---

## Cart Operations

### 1. Add to Cart

**Endpoint**: `POST /cart/add`

**Request**:
```dart
final cartItem = await api.cart.addItemToCart(
  AddCartRequest(
    cartId: 'device-12345',
    licenseKey: 'YOUR-LICENSE-KEY',
    itemId: 'item-uuid',
    quantity: 2.5,  // kg from scale
  ),
);

print('Added: ${cartItem.item?.name}');
print('Total: Rp ${cartItem.totalPrice}');
```

**Request Body**:
```json
{
  "itemId": 1,
  "weight": 2.5,
  "pricePerUnit": 18500
}
```

**Response**:
```json
{
  "success": true,
  "message": "Item added to cart",
  "data": {
    "id": 1,
    "itemId": 1,
    "itemName": "Organic Apple",
    "weight": 2.5,
    "pricePerUnit": 18500,
    "totalPrice": 46250,
    "createdAt": "2025-12-12T10:30:00Z"
  }
}
```

### 2. Get Cart

**Endpoint**: `GET /cart?cart_id=device-12345`

**Request**:
```dart
final items = await api.cart.getCartItems('device-12345');

print('Cart Items: ${items.length}');

for (var item in items) {
  print('${item.item?.name} - ${item.quantity} kg - Rp ${item.totalPrice}');
}

// Get cart summary
final summary = await api.cart.getCartSummary('device-12345');
print('Total Amount: Rp ${summary.totalAmount}');
print('Total Items: ${summary.totalItems}');
```

**Response**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "itemId": 1,
        "itemName": "Organic Apple",
        "weight": 2.5,
        "pricePerUnit": 18500,
        "totalPrice": 46250
      },
      {
        "id": 2,
        "itemId": 2,
        "itemName": "Fresh Banana",
        "weight": 1.0,
        "pricePerUnit": 12000,
        "totalPrice": 12000
      }
    ],
    "totalAmount": 58250,
    "totalWeight": 3.5,
    "totalItems": 2
  }
}
```

### 3. Update Cart Item

**Endpoint**: `PUT /cart/:id`

**Request**:
```dart
final updatedItem = await api.cart.updateCartItem(
  'cart-item-uuid',
  UpdateCartRequest(
    quantity: 3.0,
  ),
);

print('Cart item updated');
print('New quantity: ${updatedItem.quantity}');
print('New total: Rp ${updatedItem.totalPrice}');
```

**Request Body**:
```json
{
  "weight": 3.0
}
```

**Response**:
```json
{
  "success": true,
  "message": "Cart item updated",
  "data": {
    "id": 1,
    "weight": 3.0,
    "totalPrice": 55500
  }
}
```

### 4. Delete Cart Item

**Endpoint**: `DELETE /cart/:id`

**Request**:
```dart
final success = await api.cart.deleteCartItem('cart-item-uuid');

if (success) {
  print('Item removed from cart');
}
```

**Response**:
```json
{
  "success": true,
  "message": "Item removed from cart"
}
```

### 5. Clear Cart

**Endpoint**: `DELETE /cart?cart_id=device-12345`

**Request**:
```dart
final success = await api.cart.clearCart('device-12345');

if (success) {
  print('Cart cleared');
}
```

**Response**:
```json
{
  "success": true,
  "message": "Cart cleared"
}
```

---

## Transaction Management

### 1. Checkout

**Endpoint**: `POST /transactions/checkout`

**Request**:
```dart
// Note: Use cart.checkoutCart() instead for cart-based checkout
// This is for direct transaction creation
final transaction = await api.transaction.createTransaction(
  CheckoutRequest(
    paymentMethod: PaymentMethod.cash,
    notes: 'Customer special request',
  ),
);

print('Transaction Number: ${transaction.transactionNumber}');
print('Total: Rp ${transaction.totalAmount}');
print('Status: ${transaction.paymentStatus}');

if (transaction.paymentMethod == PaymentMethod.qris && transaction.qrisString != null) {
  print('QRIS Code: ${transaction.qrisString}');
  }
}
```

**Request Body**:
```json
{
  "paymentMethod": "cash",
  "notes": "Customer special request"
}
```

**Response (Cash)**:
```json
{
  "success": true,
  "message": "Checkout successful",
  "data": {
    "id": 1,
    "transactionCode": "TRX-20251212-0001",
    "totalAmount": 58250,
    "paymentMethod": "cash",
    "status": "completed",
    "notes": "Customer special request",
    "items": [
      {
        "itemName": "Organic Apple",
        "weight": 2.5,
        "pricePerUnit": 18500,
        "totalPrice": 46250
      }
    ],
    "createdAt": "2025-12-12T10:45:00Z"
  }
}
```

**Response (QRIS)**:
```json
{
  "success": true,
  "message": "QRIS payment initiated",
  "data": {
    "id": 1,
    "transactionCode": "TRX-20251212-0001",
    "totalAmount": 58250,
    "paymentMethod": "qris",
    "status": "pending",
    "qrCodeUrl": "https://qr.example.com/trx/abc123...",
    "expiresAt": "2025-12-12T11:00:00Z"
  }
}
```

### 2. Get Transaction History

**Endpoint**: `GET /transactions?page=1&limit=20&status=completed`

**Request**:
```dart
final transactionData = await api.transaction.listTransactions(
  page: 1,
  limit: 20,
  status: 'completed',  // optional filter
);

for (var trx in transactionData.data) {
  print('${trx.transactionNumber} - Rp ${trx.totalAmount} - ${trx.paymentStatus}');
}

print('Total: ${transactionData.totalCount}');
print('Page: ${transactionData.currentPage}/${transactionData.totalPages}');
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "transactionCode": "TRX-20251212-0001",
      "totalAmount": 58250,
      "paymentMethod": "cash",
      "status": "completed",
      "createdAt": "2025-12-12T10:45:00Z"
    }
  ],
  "pagination": {
    "total": 150,
    "page": 1,
    "limit": 20
  }
}
```

### 3. Get Transaction Detail

**Endpoint**: `GET /transactions/:id`

**Request**:
```dart
final transactionDetail = await api.transaction.getTransactionDetail(
  'transaction-uuid-here',
);

print('Number: ${transactionDetail.transaction.transactionNumber}');
print('Status: ${transactionDetail.transaction.paymentStatus}');
print('Total: Rp ${transactionDetail.transaction.totalAmount}');

for (var item in transactionDetail.items) {
  print('- ${item.item?.name}: ${item.quantity} kg @ Rp ${item.unitPrice}');
  }
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "transactionCode": "TRX-20251212-0001",
    "totalAmount": 58250,
    "paymentMethod": "cash",
    "status": "completed",
    "notes": "Customer special request",
    "items": [
      {
        "id": 1,
        "itemId": 1,
        "itemName": "Organic Apple",
        "weight": 2.5,
        "pricePerUnit": 18500,
        "totalPrice": 46250
      },
      {
        "id": 2,
        "itemId": 2,
        "itemName": "Fresh Banana",
        "weight": 1.0,
        "pricePerUnit": 12000,
        "totalPrice": 12000
      }
    ],
    "createdAt": "2025-12-12T10:45:00Z",
    "updatedAt": "2025-12-12T10:45:30Z"
  }
}
```

---

## Error Handling

### Error Response Format

```json
{
  "success": false,
  "message": "Error message here",
  "errors": {
    "field": ["Validation error message"]
  }
}
```

### Exception Handling

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

try {
  final item = await api.owner.createItem(
    name: 'Apple',
    unit: 'kg',
    price: 15000,
  );
  
  print('Success! Item created: ${item.name}');
} on KgitonAuthenticationException catch (e) {
  print('Authentication Error: $e');
  // Redirect to login
} on KgitonValidationException catch (e) {
  print('Validation Error: $e');
  // Show validation errors to user
} on KgitonNetworkException catch (e) {
  print('Network Error: $e');
  // Check internet connection
} catch (e) {
  print('Unknown Error: $e');
}
```

### Common Error Scenarios

**401 Unauthorized - Token Expired**:
```dart
if (result['message'].contains('token expired')) {
  // Logout and redirect to login
  await api.auth.logout();
  Navigator.pushReplacementNamed(context, '/login');
}
```

**422 Validation Error**:
```dart
if (result['errors'] != null) {
  final errors = result['errors'] as Map<String, dynamic>;
  errors.forEach((field, messages) {
    print('$field: ${messages.join(', ')}');
  });
}
```

**Network Error**:
```dart
try {
  final itemListData = await api.owner.listItems(licenseKey);
} catch (e) {
  if (e.toString().contains('SocketException')) {
    print('No internet connection');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Connection Error'),
        content: Text('Please check your internet connection'),
      ),
    );
  }
}
```

---

## API Reference

### Authentication Service

| Method | Endpoint | Description |
|--------|----------|-------------|
| `register()` | POST /auth/register-owner | Register new owner |
| `login()` | POST /auth/login | User login |
| `getCurrentUser()` | GET /auth/me | Get current user info |
| `logout()` | POST /auth/logout | User logout |

### Owner Service

| Method | Endpoint | Description |
|--------|----------|-------------|
| `listLicenses()` | GET /owner/licenses | List user's licenses |
| `assignLicense()` | POST /owner/licenses/assign | Assign new license |

### Item Service

| Method | Endpoint | Description |
|--------|----------|-------------|
| `createItem()` | POST /items | Create new item |
| `listItems()` | GET /items | List all items |
| `getItem()` | GET /items/:id | Get item details |
| `updateItem()` | PUT /items/:id | Update item |
| `deleteItem()` | DELETE /items/:id | Delete item (⚠️ permanent) |
| `deleteAllItems()` | DELETE /items | Delete all items (⚠️ permanent) |

### Cart Service

| Method | Endpoint | Description |
|--------|----------|-------------|
| `addToCart()` | POST /cart/add | Add item to cart |
| `getCart()` | GET /cart | Get current cart |
| `updateCartItem()` | PUT /cart/:id | Update cart item |
| `deleteCartItem()` | DELETE /cart/:id | Remove from cart |
| `clearCart()` | DELETE /cart | Clear entire cart |

### Transaction Service

| Method | Endpoint | Description |
|--------|----------|-------------|
| `checkout()` | POST /transactions/checkout | Process checkout |
| `listTransactions()` | GET /transactions | Get transaction history |
| `getTransactionDetail()` | GET /transactions/:id | Get transaction details |

---

## Best Practices

### 1. Token Management

```dart
class AuthManager {
  final KgitonApiService api;
  
  AuthManager(this.api);
  
  Future<bool> ensureAuthenticated() async {
    try {
      await api.auth.getCurrentUser();
      return true;
    } catch (e) {
      // Token expired or invalid
      return false;
    }
  }
  
  Future<void> refreshIfNeeded() async {
    if (!await ensureAuthenticated()) {
      // Redirect to login
    }
  }
}
```

### 2. Pagination

```dart
Future<List<Item>> loadAllItems() async {
  List<Item> allItems = [];
  int page = 1;
  bool hasMore = true;
  
  // Note: SDK listItems doesn't support pagination currently
  // This gets all items for the license
  final itemListData = await api.owner.listItems(
    licenseKey,
  );
  
  return itemListData.items;
}
```

### 3. Retry Logic

```dart
Future<T?> retryRequest<T>(
  Future<Map<String, dynamic>> Function() request,
  {int maxRetries = 3}
) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      final result = await request();
      if (result['success']) {
        return result['data'] as T;
      }
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: 2 * (i + 1)));
    }
  }
  return null;
}
```

---

## Next Steps

- **[Cart & Transaction Guide](04_CART_TRANSACTION.md)** - Complete cart and payment workflows
- **[Troubleshooting](05_TROUBLESHOOTING.md)** - Error codes and common issues
- **[Example App](../example/kgiton_apps/)** - Full implementation reference

---

**Copyright © 2025 PT KGiTON. All Rights Reserved.**

For support, contact: support@kgiton.com
