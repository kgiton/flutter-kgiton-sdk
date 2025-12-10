# Changelog

All notable changes to KGiTON Flutter SDK will be documented in this file.

---

## [1.2.0] - 2025-12-10

### 🎯 Dual Pricing System Support

#### Changed - Breaking Changes ⚠️

**CartItem Model Updates:**
- ✅ `unitPrice` → `pricePerKg` (nullable)
- ✅ Added `pricePerPcs` (nullable)
- ✅ `quantity` now nullable (at least one of `quantity` or `quantityPcs` required)
- ✅ At least one price (`pricePerKg` or `pricePerPcs`) must be provided

**TransactionDetailItem Model Updates:**
- ✅ `pricePerUnit` → `pricePerKg` (nullable)
- ✅ `weight` now nullable (at least one of `weight` or `quantityPcs` required)
- ✅ At least one price (`pricePerKg` or `pricePerPcs`) must be provided

**AddCartRequest Updates:**
- ✅ `quantity` now nullable
- ✅ `isValid()` updated: requires at least one quantity (quantity OR quantityPcs)

#### Added

- ✅ **Full Dual Pricing Support**
  - Items can have price per kg and/or price per pcs
  - Support 3 pricing variants:
    1. **Per kg only**: Only `pricePerKg` provided
    2. **Per pcs only**: Only `pricePerPcs` provided
    3. **Dual pricing**: Both `pricePerKg` AND `pricePerPcs` provided

- ✅ **Flexible Cart Operations**
  - Add items with kg, pcs, or both quantities simultaneously
  - Example: Buy 2.5kg + 10pcs of same item in one cart entry
  - Total price calculation: `(quantity × pricePerKg) + (quantityPcs × pricePerPcs)`

- ✅ **Backward Compatibility Getters**
  - `TransactionDetailItem.pricePerUnit` (deprecated, use `pricePerKg`)
  - `TransactionDetailItem.unitPrice` (deprecated, use `pricePerKg`)
  - `TransactionDetailItem.quantity` (deprecated, use `weight`)

#### Migration Guide

**Breaking Changes:**

1. **CartItem field changes:**
   ```dart
   // Before (v1.0.0)
   final unitPrice = cartItem.unitPrice;
   
   // After (v1.2.0)
   final pricePerKg = cartItem.pricePerKg; // nullable
   final pricePerPcs = cartItem.pricePerPcs; // nullable
   ```

2. **AddCartRequest validation:**
   ```dart
   // Before (v1.0.0)
   final request = AddCartRequest(
     cartId: 'cart-123',
     licenseKey: 'key',
     itemId: 'item-id',
     quantity: 2.5, // required
   );
   
   // After (v1.2.0) - at least one quantity required
   final requestKg = AddCartRequest(
     cartId: 'cart-123',
     licenseKey: 'key',
     itemId: 'item-id',
     quantity: 2.5, // nullable
   );
   
   final requestPcs = AddCartRequest(
     cartId: 'cart-123',
     licenseKey: 'key',
     itemId: 'item-id',
     quantityPcs: 10, // nullable
   );
   
   final requestDual = AddCartRequest(
     cartId: 'cart-123',
     licenseKey: 'key',
     itemId: 'item-id',
     quantity: 2.5,
     quantityPcs: 10,
   );
   ```

3. **TransactionDetailItem field changes:**
   ```dart
   // Before (v1.0.0)
   final unitPrice = item.pricePerUnit;
   final weight = item.weight;
   
   // After (v1.2.0)
   final pricePerKg = item.pricePerKg; // nullable
   final pricePerPcs = item.pricePerPcs; // nullable
   final weight = item.weight; // nullable
   ```

**Example Usage:**

```dart
// Per kg only
await cartService.addItemToCart(
  AddCartRequest(
    cartId: 'device-123',
    licenseKey: 'ABC-123',
    itemId: 'item-uuid',
    quantity: 2.5,
  ),
);

// Per pcs only
await cartService.addItemToCart(
  AddCartRequest(
    cartId: 'device-123',
    licenseKey: 'ABC-123',
    itemId: 'item-uuid',
    quantityPcs: 10,
  ),
);

// Dual pricing (kg + pcs)
await cartService.addItemToCart(
  AddCartRequest(
    cartId: 'device-123',
    licenseKey: 'ABC-123',
    itemId: 'item-uuid',
    quantity: 2.5,
    quantityPcs: 10,
  ),
);
```

#### Compatibility

- ✅ Compatible with KGiTON API v1.2.0+
- ⚠️ **NOT** compatible with KGiTON API v1.0.0-1.1.x
- ✅ Backward compatible getters provided for gradual migration
- ⚠️ Requires backend migration to v1.2.0 schema

---

## [1.0.0] - 2025-12-07

### Initial Release

#### Features

- ✅ **BLE Scale Integration**
  - Auto-connect to KGiTON scales
  - Real-time weight data streaming
  - Buzzer control (short/long beep)
  - Connection state management

- ✅ **REST API Integration**
  - User authentication (login/logout)
  - Item management (CRUD)
  - Session-based cart operations
  - Transaction management
  - License key validation

- ✅ **Cart System**
  - Session-based cart (device ID grouping)
  - Add/update/delete cart items
  - Cart summary with stored prices
  - Checkout to transaction

- ✅ **Transaction System**
  - Multiple payment methods (QRIS, CASH, BANK_TRANSFER)
  - Multiple payment gateways (external, xendit, midtrans)
  - Transaction history with pagination
  - QRIS expiry tracking

- ✅ **Models & Services**
  - Type-safe models for all entities
  - Service classes for all operations
  - Comprehensive error handling
  - Request/response validation
