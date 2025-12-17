import 'package:kgiton_sdk/kgiton_sdk.dart' as sdk;
import '../../domain/entities/cart_item.dart' as domain;
import '../../../item/domain/entities/item.dart' as domain_item;

/// Cart model for data layer
class CartModel {
  final String id;
  final String cartId;
  final String licenseKey;
  final String itemId;
  final double quantity;
  final double? quantityPcs;
  final String? notes;
  final double unitPrice;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ItemData? item;

  CartModel({
    required this.id,
    required this.cartId,
    required this.licenseKey,
    required this.itemId,
    required this.quantity,
    this.quantityPcs,
    this.notes,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    this.item,
  });

  /// Convert from SDK CartItem to CartModel
  factory CartModel.fromSdkCartItem(sdk.CartItem sdkItem) {
    return CartModel(
      id: sdkItem.id,
      cartId: sdkItem.cartId,
      licenseKey: sdkItem.licenseKey,
      itemId: sdkItem.itemId,
      quantity: sdkItem.quantity ?? 0.0,
      quantityPcs: sdkItem.quantityPcs?.toDouble(),
      notes: sdkItem.notes,
      unitPrice: sdkItem.totalPrice / (sdkItem.quantity ?? 1.0), // Calculate unit price from total
      totalPrice: sdkItem.totalPrice,
      createdAt: sdkItem.createdAt,
      updatedAt: sdkItem.updatedAt,
      item: sdkItem.item != null ? ItemData.fromSdkItem(sdkItem.item!) : null,
    );
  }

  /// Convert to domain entity
  domain.CartItem toEntity() {
    return domain.CartItem(
      id: id,
      cartId: cartId,
      licenseKey: licenseKey,
      itemId: itemId,
      quantity: quantity,
      quantityPcs: quantityPcs,
      notes: notes,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      createdAt: createdAt,
      updatedAt: updatedAt,
      item: item != null
          ? domain_item.Item(
              id: item!.id,
              ownerId: '', // SDK doesn't provide ownerId in cart response
              licenseKey: item!.licenseKey,
              name: item!.name,
              unit: item!.unit,
              price: item!.price,
              pricePerPcs: item!.pricePerPcs,
              description: item!.description,
              createdAt: item!.createdAt,
              updatedAt: item!.updatedAt,
            )
          : null,
    );
  }
}

/// Item data nested in cart response
class ItemData {
  final String id;
  final String licenseKey;
  final String name;
  final String unit;
  final double price;
  final double? pricePerPcs;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemData({
    required this.id,
    required this.licenseKey,
    required this.name,
    required this.unit,
    required this.price,
    this.pricePerPcs,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemData.fromSdkItem(sdk.Item sdkItem) {
    return ItemData(
      id: sdkItem.id,
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
}
