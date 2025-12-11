import 'package:kgiton_sdk/kgiton_sdk.dart' as sdk;
import '../../domain/entities/item.dart';

/// Model class for Item that extends the SDK Item model
class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.unit,
    required super.price,
    super.pricePerPcs,
    super.description,
    super.isActive,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create ItemModel from SDK Item
  factory ItemModel.fromSdkItem(sdk.Item sdkItem) {
    return ItemModel(
      id: sdkItem.id,
      ownerId: sdkItem.ownerId,
      name: sdkItem.name,
      unit: sdkItem.unit,
      price: sdkItem.price,
      pricePerPcs: sdkItem.pricePerPcs,
      description: sdkItem.description,
      isActive: sdkItem.isActive,
      createdAt: sdkItem.createdAt,
      updatedAt: sdkItem.updatedAt,
    );
  }

  /// Convert to domain entity
  Item toEntity() {
    return Item(
      id: id,
      ownerId: ownerId,
      name: name,
      unit: unit,
      price: price,
      pricePerPcs: pricePerPcs,
      description: description,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
