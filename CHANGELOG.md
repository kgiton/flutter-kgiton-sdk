# Changelog

All notable changes to KGiTON Flutter SDK will be documented in this file.

---

## [1.3.1] - 2025-12-11

### 🔧 Fixed

- **Device Connection Reliability**: Improved connection stability
  - Added automatic retry mechanism (up to 2 retries) for commands
  - Reduced connection timeout for faster feedback
  - Fixed command sequencing issues
  - Optimized connection process
- **Connection Speed**: Significantly faster connection process
  - Success: ~1-2 seconds (previously 3-5 seconds)
  - With retry: ~2-5 seconds (previously 8+ seconds)
  - Maximum timeout: 6 seconds (previously 15+ seconds)

### 📝 Notes

- No breaking changes - fully backward compatible
- Connection is now both faster and more reliable
- Automatic retry improves success rate in poor conditions

---

## [1.3.0] - 2025-12-10

### 🎉 Added

- **Helper Classes**: Simplified wrapper classes untuk common operations
  - `KgitonAuthHelper`: Session management, login/register/logout dengan token storage
  - `KgitonCartHelper`: Cart operations dengan consistent return format
  - `KgitonLicenseHelper`: License management dan validation
- **Consistent API**: Semua helpers return Map dengan format `{success, message, data}`
- **Error Handling**: Built-in error handling di setiap helper method
- **Easy Integration**: Aplikasi tidak perlu implement token storage dan error handling sendiri

### 📝 Notes

- Example app sekarang menggunakan SDK helpers (code 70% lebih sedikit)
- Backward compatible - API lama masih bisa digunakan
- Developers bisa pilih: gunakan helpers (simple) atau services langsung (advanced)

### 📚 Migration Guide

**Before (Manual):**
```dart
final apiService = KgitonApiService(baseUrl: url);
final authData = await apiService.auth.login(email, password);
await prefs.setString('token', authData.accessToken);
```

**After (With Helper):**
```dart
final auth = KgitonAuthHelper(prefs, baseUrl: url);
final result = await auth.login(email, password);
if (result['success']) print('Logged in!');
```

---

## [1.2.2] - 2025-12-10

### 🔧 Fixed

- **Bluetooth Auto-Recovery**: SDK now automatically detects and retries when Bluetooth is enabled after being disabled
- **No App Restart Required**: Users no longer need to restart the app or clear data after enabling Bluetooth
- **Smart Error Handling**: Automatically checks Bluetooth permissions and state before scanning
- **Auto-Retry Logic**: Waits 2 seconds and retries scan if Bluetooth becomes available

### 📝 Notes

- `scanForDevices()` now has `retryOnBluetoothError` parameter (default: true)
- SDK automatically requests permissions if not granted
- Fixes issue where "BLUETOOTH_UNAVAILABLE" error persisted after enabling Bluetooth

---

## [1.2.1] - 2025-12-10

### 🔧 Fixed

- **Simplified Logging**: Removed excessive debug box formatting, kept essential logging
- **Backend Sync**: Updated SDK to work seamlessly with backend v1.2.0 dual pricing fixes
- **Performance**: Reduced log verbosity for better performance in production

### 📝 Notes

- Backend v1.2.0 fixed 502 error for PCS only items
- SDK validation already correct, no logic changes needed
- All 3 pricing modes now work correctly: KG only, PCS only, Dual pricing

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
