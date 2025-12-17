import 'package:equatable/equatable.dart';
import '../../../item/domain/entities/item.dart';

/// Cart item entity representing an item added to cart
/// Matches KGiTON SDK CartItem structure
class CartItem extends Equatable {
  final String id;
  final String cartId; // Cart session identifier
  final String licenseKey;
  final String itemId;
  final double quantity; // Quantity in kg or unit
  final double? quantityPcs; // Quantity in pieces (optional)
  final String? notes; // Optional notes for this cart item
  final double unitPrice; // Price stored at add time
  final double totalPrice; // Total price stored at add time
  final DateTime createdAt;
  final DateTime updatedAt;
  final Item? item; // Item details (populated from API response)

  const CartItem({
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

  @override
  List<Object?> get props => [id, cartId, licenseKey, itemId, quantity, quantityPcs, notes, unitPrice, totalPrice, createdAt, updatedAt, item];

  /// Copy with method for updating cart item
  CartItem copyWith({
    String? id,
    String? cartId,
    String? licenseKey,
    String? itemId,
    double? quantity,
    double? quantityPcs,
    String? notes,
    double? unitPrice,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    Item? item,
  }) {
    return CartItem(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      licenseKey: licenseKey ?? this.licenseKey,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      quantityPcs: quantityPcs ?? this.quantityPcs,
      notes: notes ?? this.notes,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      item: item ?? this.item,
    );
  }

  /// Get pricing type based on quantity fields
  PricingType get pricingType {
    if (quantityPcs != null && quantityPcs! > 0) {
      if (quantity > 0) {
        return PricingType.dualPrice;
      }
      return PricingType.perPcs;
    }
    return PricingType.perKg;
  }

  /// Get display quantity based on pricing type
  String get displayQuantity {
    if (pricingType == PricingType.perPcs) {
      return '${quantityPcs?.toStringAsFixed(0)} pcs';
    } else if (pricingType == PricingType.perKg) {
      return '${quantity.toStringAsFixed(2)} kg';
    } else {
      return '${quantity.toStringAsFixed(2)} kg / ${quantityPcs?.toStringAsFixed(0)} pcs';
    }
  }
}

/// Enum for pricing type
enum PricingType {
  perKg, // Only per kg pricing
  perPcs, // Only per pcs pricing
  dualPrice, // Both kg and pcs pricing available
}
