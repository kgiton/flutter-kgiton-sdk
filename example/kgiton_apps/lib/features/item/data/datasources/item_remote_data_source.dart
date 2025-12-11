import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../../../../core/error/exceptions.dart';
import '../models/item_model.dart';

/// Remote data source for item operations using KGiTON SDK
abstract class ItemRemoteDataSource {
  /// Get all items for the authenticated user
  Future<List<ItemModel>> getItems();

  /// Get item by ID
  Future<ItemModel> getItemById(String itemId);

  /// Create a new item
  Future<ItemModel> createItem({required String name, required String unit, required double price, double? pricePerPcs, String? description});

  /// Update an existing item
  Future<ItemModel> updateItem({required String itemId, String? name, String? unit, double? price, double? pricePerPcs, String? description});

  /// Delete an item (soft delete)
  Future<bool> deleteItem(String itemId);

  /// Permanently delete an item
  Future<bool> deleteItemPermanent(String itemId);
}

class ItemRemoteDataSourceImpl implements ItemRemoteDataSource {
  final KgitonApiService apiService;

  ItemRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<ItemModel>> getItems() async {
    try {
      final itemListData = await apiService.owner.listAllItems();

      // Filter active items only
      final filteredItems = itemListData.items.where((item) => item.isActive).toList();

      return filteredItems.map((sdkItem) => ItemModel.fromSdkItem(sdkItem)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ItemModel> getItemById(String itemId) async {
    try {
      // SDK doesn't have getItemById, so we get all items and filter
      final itemListData = await apiService.owner.listAllItems();
      final sdkItem = itemListData.items.firstWhere((item) => item.id == itemId, orElse: () => throw ServerException(message: 'Item not found'));
      return ItemModel.fromSdkItem(sdkItem);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ItemModel> createItem({required String name, required String unit, required double price, double? pricePerPcs, String? description}) async {
    try {
      final sdkItem = await apiService.owner.createItem(name: name, unit: unit, price: price, pricePerPcs: pricePerPcs, description: description);

      return ItemModel.fromSdkItem(sdkItem);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ItemModel> updateItem({required String itemId, String? name, String? unit, double? price, double? pricePerPcs, String? description}) async {
    try {
      final sdkItem = await apiService.owner.updateItem(
        itemId: itemId,
        name: name,
        unit: unit,
        price: price,
        pricePerPcs: pricePerPcs,
        description: description,
      );

      return ItemModel.fromSdkItem(sdkItem);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> deleteItem(String itemId) async {
    try {
      return await apiService.owner.deleteItem(itemId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> deleteItemPermanent(String itemId) async {
    try {
      // SDK owner service uses deleteItem for both soft and hard delete
      // Using soft delete as fallback
      return await apiService.owner.deleteItem(itemId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
