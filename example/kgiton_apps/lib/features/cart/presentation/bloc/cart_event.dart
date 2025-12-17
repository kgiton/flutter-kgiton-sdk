part of 'cart_bloc.dart';

/// Base event for cart management
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load cart items from server
class LoadCartEvent extends CartEvent {
  final String cartId;

  const LoadCartEvent(this.cartId);

  @override
  List<Object?> get props => [cartId];
}

/// Event to add item to cart (SDK integration)
class AddToCartEvent extends CartEvent {
  final String cartId;
  final String licenseKey;
  final String itemId;
  final double quantity;
  final double? quantityPcs;
  final String? notes;

  const AddToCartEvent({required this.cartId, required this.licenseKey, required this.itemId, required this.quantity, this.quantityPcs, this.notes});

  @override
  List<Object?> get props => [cartId, licenseKey, itemId, quantity, quantityPcs, notes];
}

/// Event to remove item from cart
class RemoveFromCartEvent extends CartEvent {
  final String cartId;
  final String cartItemId;

  const RemoveFromCartEvent({required this.cartId, required this.cartItemId});

  @override
  List<Object?> get props => [cartId, cartItemId];
}

/// Event to update cart item quantity or notes
class UpdateCartItemEvent extends CartEvent {
  final String cartId;
  final String cartItemId;
  final double? quantity;
  final double? quantityPcs;
  final String? notes;

  const UpdateCartItemEvent({required this.cartId, required this.cartItemId, this.quantity, this.quantityPcs, this.notes});

  @override
  List<Object?> get props => [cartId, cartItemId, quantity, quantityPcs, notes];
}

/// Event to clear entire cart
class ClearCartEvent extends CartEvent {
  final String cartId;

  const ClearCartEvent(this.cartId);

  @override
  List<Object?> get props => [cartId];
}

/// Event to checkout cart and create transaction
class CheckoutCartEvent extends CartEvent {
  final String cartId;
  final String paymentMethod; // QRIS, CASH, BANK_TRANSFER
  final String paymentGateway; // external, xendit, midtrans, internal
  final String? notes;

  const CheckoutCartEvent({required this.cartId, this.paymentMethod = 'CASH', this.paymentGateway = 'internal', this.notes});

  @override
  List<Object?> get props => [cartId, paymentMethod, paymentGateway, notes];
}
