# Changelog

All notable changes to KGiTON Flutter SDK will be documented in this file.

---

## [Unreleased] - 2025-12-16

### 🔐 Added - Ownership Verification (Security Enhancement)

#### Scale Service (`lib/src/kgiton_scale_service.dart`)
- **Constructor with API Service** - Initialize with optional `KgitonApiService` for ownership verification
  ```dart
  KGiTONScaleService({KgitonApiService? apiService})
  ```
- **setApiService()** - Enable ownership verification after service creation
- **clearApiService()** - Disable ownership verification (e.g., on logout)
- **Enhanced connectWithLicenseKey()** - Automatically verifies license ownership before allowing connection
  - Checks if user is the legitimate owner via API call
  - Returns error if ownership verification fails
  - Backward compatible (verification skipped if no API service)

#### License Helper (`lib/src/helpers/kgiton_license_helper.dart`)
- **verifyLicenseOwnership()** - New method to verify if current user owns a specific license key
  - Returns map with success, message, and isOwner status
  - Fetches user's licenses from API
  - Validates license ownership before device connection

#### Documentation
- **[NEW] 06_OWNERSHIP_VERIFICATION.md** - Complete guide on ownership verification feature
  - Problem statement and solution
  - Implementation guide
  - Security benefits
  - Error handling strategies
  - Migration guide from legacy mode
  - Testing examples
  - FAQ section
- **Updated 02_DEVICE_INTEGRATION.md** - Added secure connection section with ownership verification
- **Updated README.md** - Updated quick start examples to showcase ownership verification
- **Updated 00_INDEX.md** - Added link to new ownership verification documentation

### 🔒 Security Improvements
- **Prevents Unauthorized Access** - Only legitimate license owners can connect to devices
- **Multi-layer Security**:
  1. API-level ownership verification
  2. Device-level license authentication
  3. BLE connection security
- **Audit Trail** - All connections are now verifiable with user identity
- **Multi-tenant Safe** - Different owners cannot access each other's scales

### 🔄 Backward Compatibility
- Feature is **optional** and fully backward compatible
- Existing code without API service continues to work (no ownership verification)
- New code can enable verification by passing API service
- No breaking changes to existing API

### 📝 Examples
```dart
// OLD (without verification) - still works
final scale = KGiTONScaleService();
await scale.connectWithLicenseKey(...);

// NEW (with verification) - recommended
final apiService = KgitonApiService(baseUrl: '...', accessToken: '...');
final scale = KGiTONScaleService(apiService: apiService);
await scale.connectWithLicenseKey(...); // Ownership verified!
```

---

## [Unreleased] - 2025-12-15

### ✨ Added - Password Management Features

#### Authentication Service (`lib/src/api/services/auth_service.dart`)
- `forgotPassword()` - Request password reset via email
- `resetPassword()` - Reset password using token from email
- `changePassword()` - Change password for authenticated users

#### API Models (`lib/src/api/models/auth_models.dart`)
- `ForgotPasswordRequest` - Request model for forgot password
- `ResetPasswordRequest` - Request model for password reset with token
- `ChangePasswordRequest` - Request model for password change

#### API Constants (`lib/src/api/api_constants.dart`)
- `/auth/forgot-password` endpoint
- `/auth/reset-password` endpoint
- `/auth/change-password` endpoint

#### Example App - Password Management UI
- **Forgot Password Page** - Request password reset link
  - Email validation
  - Success confirmation screen
  - Link to login page
- **Reset Password Page** - Reset password with token
  - Token validation from URL query parameters
  - Password confirmation
  - Success confirmation screen
- **Change Password Page** - Change password for authenticated users
  - Current password validation
  - New password confirmation
  - Password strength validation
  - Success confirmation screen

#### Example App - Integration
- Added "Forgot Password?" link on login page
- Added "Change Password" menu item in profile page
- Created usecases: `ForgotPasswordUseCase`, `ResetPasswordUseCase`, `ChangePasswordUseCase`
- Updated `AuthBloc` with new events and states:
  - `ForgotPasswordRequested` event
  - `ResetPasswordRequested` event
  - `ChangePasswordRequested` event
  - `PasswordResetEmailSent` state
  - `PasswordResetSuccess` state
  - `PasswordChangeSuccess` state
- Updated dependency injection container
- Updated app routing with new routes

#### Documentation
- Updated `docs/03_API_INTEGRATION.md` with password management endpoints
- Added comprehensive API examples for all password operations

### 📝 Notes

**Password Reset Flow:**
1. User clicks "Forgot Password?" on login page
2. Enters email address
3. Receives reset link via email (expires in 1 hour)
4. Clicks link to open reset password page with token
5. Enters new password and confirms
6. Redirected to login page on success

**Change Password Flow:**
1. Authenticated user navigates to Profile > Change Password
2. Enters current password
3. Enters new password and confirms
4. Password updated successfully

**Security Features:**
- Email enumeration prevention (always returns success)
- Token expiration (1 hour for reset tokens)
- Password validation (minimum 6 characters)
- Old password verification for password change
- All operations logged in backend

---

## [Unreleased] - 2025-12-13

### 🔥 BREAKING CHANGES

#### Backend API Alignment - License-based Item Management

Updated SDK to align with backend API v1.0.0 changes where items now REQUIRE `license_key` for multi-branch tracking.

**What Changed:**
- ✅ Added `license_key` field to Item model as REQUIRED field
- ✅ Updated `createItem()` to require `license_key` parameter
- ✅ Items are now tied to specific license keys for multi-branch support
- ✅ Added license-based cart operations (NEW endpoints)

### ✨ Added

#### Item Model (`lib/src/api/models/item_models.dart`)
- `licenseKey` field added to Item class (required)
- `licenseKey` parameter added to CreateItemRequest (required)
- All item operations now include license_key in requests/responses

#### Owner Service (`lib/src/api/services/owner_service.dart`)
- `createItem()` now requires `licenseKey` parameter
- Updated documentation to emphasize license_key requirement
- `listItems(String licenseKey)` - Filter items by specific license

#### Cart Service (`lib/src/api/services/cart_service.dart`)
- `getCartItemsByLicenseKey(String licenseKey)` - **NEW** Get cart items by license key
- `clearCartByLicenseKey(String licenseKey)` - **NEW** Clear cart items by license key
- Restored license-based endpoints (previously deprecated, now supported by backend)

#### Cart Helper (`lib/src/helpers/kgiton_cart_helper.dart`)
- `getItemsByLicenseKey(String licenseKey)` - Get cart items for specific license
- `clearCartByLicenseKey(String licenseKey)` - Clear cart for specific license

#### API Constants (`lib/src/api/api_constants.dart`)
- Restored `getCartByLicenseKey(String licenseKey)` endpoint
- Restored `deleteCartByLicenseKey(String licenseKey)` endpoint
- Updated documentation for multi-branch support

### 🔧 Changed

#### Item Creation
**Before:**
```dart
await ownerService.createItem(
  name: 'Product Name',
  price: 10000,
  unit: 'kg',
);
```

**After (REQUIRED):**
```dart
await ownerService.createItem(
  licenseKey: 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX',  // ⚠️ NOW REQUIRED
  name: 'Product Name',
  price: 10000,
  unit: 'kg',
);
```

#### Item Model
**Before:**
```dart
class Item {
  final String id;
  final String ownerId;
  final String name;
  // ...
}
```

**After:**
```dart
class Item {
  final String id;
  final String ownerId;
  final String licenseKey;  // ⚠️ NEW REQUIRED FIELD
  final String name;
  // ...
}
```

### 📝 Migration Guide

#### 1. Update Item Creation

**You MUST now provide license_key when creating items:**
```dart
// ❌ OLD - Will fail
final item = await ownerService.createItem(
  name: 'Product',
  price: 10000,
  unit: 'kg',
);

// ✅ NEW - Required
final item = await ownerService.createItem(
  licenseKey: 'YOUR-LICENSE-KEY',  // Required!
  name: 'Product',
  price: 10000,
  unit: 'kg',
);
```

#### 2. Update Item Model References

**If you manually construct Item objects:**
```dart
// ❌ OLD
final item = Item(
  id: '123',
  ownerId: 'owner-id',
  name: 'Product',
  // ...
);

// ✅ NEW
final item = Item(
  id: '123',
  ownerId: 'owner-id',
  licenseKey: 'YOUR-LICENSE-KEY',  // Required!
  name: 'Product',
  // ...
);
```

#### 3. Multi-Branch Support (NEW)

**For multi-branch owners, you can now:**

```dart
// Filter items by license
final branchAItems = await ownerService.listItems('LICENSE-KEY-A');
final branchBItems = await ownerService.listItems('LICENSE-KEY-B');

// Get cart by license
final cartHelper = KgitonCartHelper(apiService);
final branchACart = await cartHelper.getItemsByLicenseKey('LICENSE-KEY-A');
final branchBCart = await cartHelper.getItemsByLicenseKey('LICENSE-KEY-B');

// Clear cart by license
await cartHelper.clearCartByLicenseKey('LICENSE-KEY-A');
```

### 🔒 Security & Validation

- **Backend validates** that items belong to licenses owned by the user
- **Cart validation** ensures all items in cart have the same license_key
- **Transaction creation** requires consistent license_key across all items
- **Data isolation** - Each license_key maintains completely separate data

### 📖 Best Practices

1. **Single License Owners**: Always use your assigned license_key for all operations
2. **Multi-Branch Owners**: Use different license_key for each branch/location
3. **Data Isolation**: Each license_key maintains separate inventory, cart, and transactions
4. **Immutability**: Once an item is created with a license_key, it cannot be changed

### ⚠️ Important Notes

- **license_key is immutable**: Once set during item creation, it cannot be changed
- **Backward incompatible**: Old SDK versions will fail to create items without license_key
- **All item responses**: Now include license_key field
- **Cart items**: Include the item's license_key in responses

---

## 2025-12-13

### 🔥 BREAKING CHANGES

#### Backend API Alignment - Item Management Refactoring

Complete overhaul of item operations to align with backend API changes. All soft delete functionality has been removed and replaced with permanent delete only.

**What Changed:**
- ✅ Removed `is_active` field from Item model
- ✅ Removed `/permanent` endpoints (`deletePermanentItem`, `deleteAllItemsPermanent`)
- ✅ All delete operations are now permanent (hard delete only)
- ✅ Simplified API surface by consolidating delete endpoints

### ❌ Removed

#### API Constants (`lib/src/api/api_constants.dart`)
- `deletePermanentItem(String id)` - Merged into `deleteItem(String id)`
- `deleteAllItemsPermanent` - Merged into `deleteAllItems`

#### Item Model (`lib/src/api/models/item_models.dart`)
- `isActive` field removed from Item class
- No longer included in `fromJson()` or `toJson()` serialization

#### Example App
- `DeleteItemPermanentEvent` - Consolidated into `DeleteItemEvent`
- `DeleteItemPermanentUseCase` - Use `DeleteItemUseCase` instead
- `deleteItemPermanent()` method from repository
- `isActive` field from Item entity and ItemModel
- Filter logic for `is_active` in data sources

### 🔧 Changed

#### API Endpoints
**Before:**
```dart
DELETE /api/v1/items/:id              // Soft delete
DELETE /api/v1/items/:id/permanent    // Hard delete
DELETE /api/v1/items                  // Soft delete all
DELETE /api/v1/items/permanent        // Hard delete all
```

**After:**
```dart
DELETE /api/v1/items/:id              // Permanent delete (⚠️ cannot be undone)
DELETE /api/v1/items                  // Permanent delete all (⚠️ cannot be undone)
```

#### Owner Service (`lib/src/api/services/owner_service.dart`)
- `deleteItem(String itemId)` - Now performs **permanent deletion** (was soft delete)
- `deleteAllItems()` - Now performs **permanent deletion** (was soft delete)
- Updated documentation to emphasize irreversible nature of deletions

#### Item Model
- Removed `isActive` from all item-related requests and responses
- Simplified model structure

### 📝 Migration Guide

#### 1. Update Item References

**Remove `isActive` from your code:**
```dart
// ❌ OLD - Remove this
final item = Item(
  id: '123',
  name: 'Product',
  isActive: true,  // ❌ Field no longer exists
);

// ✅ NEW - Use this
final item = Item(
  id: '123',
  name: 'Product',
  // isActive field removed
);
```

#### 2. Update Delete Operations

**Consolidate delete methods:**
```dart
// ❌ OLD - Remove permanent-specific methods
await ownerService.deleteItemPermanent(itemId);
await ownerService.deleteAllItemsPermanent();

// ✅ NEW - Use standard delete (now permanent by default)
await ownerService.deleteItem(itemId);          // ⚠️ Permanent deletion
await ownerService.deleteAllItems();            // ⚠️ Permanent deletion
```

#### 3. Update UI Confirmations

**Add stronger warnings for delete operations:**
```dart
// ✅ Recommended: Show clear warning about permanent deletion
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('⚠️ Delete Item'),
    content: Text(
      'Permanently delete "${item.name}"?\n\n'
      '⚠️ THIS ACTION CANNOT BE UNDONE!\n\n'
      'The item will be removed from the database.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          // Perform permanent deletion
          ownerService.deleteItem(itemId);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
        child: Text('Delete Permanently'),
      ),
    ],
  ),
);
```

#### 4. Example App Updates (if you based your code on it)

**Event consolidation:**
```dart
// ❌ OLD - Remove DeleteItemPermanentEvent
context.read<ItemBloc>().add(DeleteItemPermanentEvent(itemId));

// ✅ NEW - Use DeleteItemEvent (now permanent)
context.read<ItemBloc>().add(DeleteItemEvent(itemId));
```

**Dependency injection:**
```dart
// ❌ OLD - Remove from DI container
sl.registerLazySingleton(() => DeleteItemPermanentUseCase(sl()));

// ✅ NEW - Only need DeleteItemUseCase
sl.registerLazySingleton(() => DeleteItemUseCase(sl()));
```

### 💡 Benefits

1. **Simpler API** - Single delete operation per resource type
2. **Clearer Intent** - No confusion between soft/hard delete
3. **Better Alignment** - Matches backend API exactly
4. **Reduced Code** - 40% less code in item management
5. **Improved UX** - Clearer warnings about destructive operations

### ⚠️ Important Notes

- **All deletes are permanent** - Items cannot be recovered after deletion
- **Update confirmation dialogs** - Add clear warnings about irreversible actions
- **No filtering by active status** - All items are active by default
- **Breaking change** - Requires code updates in consuming applications

### 🔗 Related Documentation

- Backend API Changelog: See backend `CHANGELOG.md` for detailed API changes
- Migration Guide: Included in this changelog
- API Reference: Check updated `docs/03_API_INTEGRATION.md`

---

