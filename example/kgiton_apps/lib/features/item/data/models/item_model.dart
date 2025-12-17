import 'package:kgiton_sdk/kgiton_sdk.dart' as sdk;
import '../../domain/entities/item.dart';

/// Model class for Item that extends the SDK Item model
class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.ownerId,
    required super.licenseKey,
    required super.name,
    required super.unit,
    required super.price,
    super.pricePerPcs,
    super.description,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create ItemModel from SDK Item
  factory ItemModel.fromSdkItem(sdk.Item sdkItem) {
    return ItemModel(
      id: sdkItem.id,
      ownerId: sdkItem.ownerId,
      licenseKey: sdkItem.licenseKey,
      name: sdkItem.name,
      unit: sdkItem.unit,
      price: sdkItem.price,
      pricePerPcs: sdkItem.pricePerPcs,
      description: sdkItem.description,
      createdAt: sdkItem.createdAt,
      updatedAt: sdkItem.updatedAt,
    );
  }

  /// Convert to domain entity
  Item toEntity() {
    return Item(
      id: id,
      ownerId: ownerId,
      licenseKey: licenseKey,
      name: name,
      unit: unit,
      price: price,
      pricePerPcs: pricePerPcs,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
