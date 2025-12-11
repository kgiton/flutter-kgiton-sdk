import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/item.dart';

/// Repository interface for item operations
abstract class ItemRepository {
  /// Get all items for the authenticated user
  Future<Either<Failure, List<Item>>> getItems();

  /// Get item by ID
  Future<Either<Failure, Item>> getItemById(String itemId);

  /// Create a new item
  Future<Either<Failure, Item>> createItem({
    required String name,
    required String unit,
    required double price,
    double? pricePerPcs,
    String? description,
  });

  /// Update an existing item
  Future<Either<Failure, Item>> updateItem({
    required String itemId,
    String? name,
    String? unit,
    double? price,
    double? pricePerPcs,
    String? description,
  });

  /// Delete an item (soft delete)
  Future<Either<Failure, bool>> deleteItem(String itemId);

  /// Permanently delete an item
  Future<Either<Failure, bool>> deleteItemPermanent(String itemId);
}
