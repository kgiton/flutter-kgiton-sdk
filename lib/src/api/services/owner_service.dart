import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/license_models.dart';
import '../models/item_models.dart';

/// Owner Service
///
/// Provides methods for owner operations:
/// - List own licenses
/// - Assign additional license
/// - Manage items (create, list, update, delete)
class KgitonOwnerService {
  final KgitonApiClient _client;

  KgitonOwnerService(this._client);

  // ==================== License Operations ====================

  /// List all licenses owned by the authenticated owner
  ///
  /// Returns [OwnerLicensesData] containing list of licenses and count
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonAuthorizationException] if not owner role
  /// - [KgitonApiException] for other errors
  Future<OwnerLicensesData> listOwnLicenses() async {
    final response = await _client.get<OwnerLicensesData>(
      KgitonApiEndpoints.listOwnerLicenses,
      requiresAuth: true,
      fromJsonT: (json) => OwnerLicensesData.fromJson(json),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to list own licenses: ${response.message}');
    }

    return response.data!;
  }

  /// Assign additional license to owner (for multi-branch support)
  ///
  /// [licenseKey] - The license key to assign
  ///
  /// Returns the assigned [License]
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if license key is invalid
  /// - [KgitonConflictException] if license already used
  /// - [KgitonApiException] for other errors
  Future<License> assignAdditionalLicense(String licenseKey) async {
    final request = AssignLicenseRequest(licenseKey: licenseKey);

    final response = await _client.post<License>(
      KgitonApiEndpoints.assignAdditionalLicense,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => License.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to assign license: ${response.message}');
    }

    return response.data!;
  }

  // ==================== Item Operations ====================

  /// Create a new item
  ///
  /// [licenseKey] - The license key to associate the item with
  /// [name] - Item name
  /// [unit] - Unit of measurement (e.g., 'kg', 'pcs', 'box')
  /// [price] - Item price
  ///
  /// Returns the created [Item]
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if validation fails
  /// - [KgitonNotFoundException] if license not found
  /// - [KgitonApiException] for other errors
  Future<Item> createItem({
    required String licenseKey,
    required String name,
    required String unit,
    required double price,
    double? pricePerPcs,
    String? description,
  }) async {
    final request = CreateItemRequest(
      licenseKey: licenseKey,
      name: name,
      unit: unit,
      price: price,
      pricePerPcs: pricePerPcs,
      description: description,
    );

    final response = await _client.post<Item>(
      KgitonApiEndpoints.createItem,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => Item.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to create item: ${response.message}');
    }

    return response.data!;
  }

  /// List all items owned by the authenticated user
  ///
  /// Returns [ItemListData] containing list of items and count
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<ItemListData> listAllItems() async {
    final response = await _client.get<ItemListData>(
      KgitonApiEndpoints.listItems,
      requiresAuth: true,
      fromJsonT: (json) => ItemListData.fromJson(json),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to list items: ${response.message}');
    }

    return response.data!;
  }

  /// List all items for a specific license
  ///
  /// [licenseKey] - The license key to filter items
  ///
  /// Returns [ItemListData] containing list of items and count
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if license not found
  /// - [KgitonApiException] for other errors
  Future<ItemListData> listItems(String licenseKey) async {
    final queryParams = {'license_key': licenseKey};

    final response = await _client.get<ItemListData>(
      KgitonApiEndpoints.listItems,
      queryParameters: queryParams,
      requiresAuth: true,
      fromJsonT: (json) => ItemListData.fromJson(json),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to list items: ${response.message}');
    }

    return response.data!;
  }

  /// Get item detail by ID
  ///
  /// [itemId] - The item ID
  ///
  /// Returns the [Item] detail
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if item not found
  /// - [KgitonAuthorizationException] if item doesn't belong to owner
  /// - [KgitonApiException] for other errors
  Future<Item> getItemDetail(String itemId) async {
    final response = await _client.get<Item>(
      KgitonApiEndpoints.getItemById(itemId),
      requiresAuth: true,
      fromJsonT: (json) => Item.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to get item detail: ${response.message}');
    }

    return response.data!;
  }

  /// Update an existing item
  ///
  /// [itemId] - The item ID to update
  /// [name] - New item name (optional)
  /// [unit] - New unit of measurement (optional)
  /// [price] - New price (optional)
  /// [pricePerPcs] - New price per piece (optional)
  /// [description] - New description (optional)
  ///
  /// Returns the updated [Item]
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if item not found
  /// - [KgitonAuthorizationException] if item doesn't belong to owner
  /// - [KgitonApiException] for other errors
  Future<Item> updateItem({required String itemId, String? name, String? unit, double? price, double? pricePerPcs, String? description}) async {
    final request = UpdateItemRequest(name: name, unit: unit, price: price, pricePerPcs: pricePerPcs, description: description);

    final response = await _client.put<Item>(
      KgitonApiEndpoints.updateItem(itemId),
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => Item.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to update item: ${response.message}');
    }

    return response.data!;
  }

  /// Delete an item permanently
  ///
  /// This performs a **permanent delete** by removing the item from the database.
  /// This action is **irreversible** and the item cannot be recovered.
  ///
  /// [itemId] - The item ID to permanently delete
  ///
  /// Returns `true` if item was permanently deleted successfully
  ///
  /// **Warning:** This action is irreversible! The item will be completely
  /// removed from the database and cannot be restored.
  ///
  /// Example:
  /// ```dart
  /// // Show confirmation dialog first!
  /// final confirm = await showDialog<bool>(
  ///   context: context,
  ///   builder: (context) => AlertDialog(
  ///     title: Text('Delete Item?'),
  ///     content: Text('This action cannot be undone!'),
  ///     actions: [
  ///       TextButton(
  ///         onPressed: () => Navigator.pop(context, false),
  ///         child: Text('Cancel'),
  ///       ),
  ///       TextButton(
  ///         onPressed: () => Navigator.pop(context, true),
  ///         child: Text('Delete'),
  ///         style: TextButton.styleFrom(foregroundColor: Colors.red),
  ///       ),
  ///     ],
  ///   ),
  /// );
  ///
  /// if (confirm == true) {
  ///   try {
  ///     final deleted = await ownerService.deleteItem(itemId);
  ///
  ///     if (deleted) {
  ///       // Refresh item list
  ///       final updatedItems = await ownerService.listAllItems();
  ///       setState(() {
  ///         items = updatedItems.items;
  ///       });
  ///       showSuccess('Item deleted successfully');
  ///     }
  ///   } catch (e) {
  ///     showError('Failed to delete: $e');
  ///   }
  /// }
  /// ```
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if item not found
  /// - [KgitonAuthorizationException] if item doesn't belong to owner
  /// - [KgitonApiException] for other errors
  Future<bool> deleteItem(String itemId) async {
    final response = await _client.delete(KgitonApiEndpoints.deletePermanentItem(itemId), requiresAuth: true);

    if (!response.success) {
      throw Exception('Failed to delete item: ${response.message}');
    }

    return true;
  }
}
