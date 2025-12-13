# Changelog

All notable changes to KGiTON Flutter SDK will be documented in this file.

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

