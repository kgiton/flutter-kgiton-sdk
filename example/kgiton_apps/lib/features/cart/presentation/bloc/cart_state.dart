part of 'cart_bloc.dart';

/// Base state for cart management
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CartInitial extends CartState {}

/// Loading state
class CartLoading extends CartState {}

/// Cart loaded successfully with items
class CartLoaded extends CartState {
  final List<CartItem> items;
  final double totalAmount;

  const CartLoaded({required this.items, required this.totalAmount});

  @override
  List<Object?> get props => [items, totalAmount];

  /// Helper to check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Helper to get total items count
  int get itemCount => items.length;
}

/// Item added to cart successfully
class CartItemAdded extends CartState {
  final CartItem item;

  const CartItemAdded(this.item);

  @override
  List<Object?> get props => [item];
}

/// Item removed from cart successfully
class CartItemRemoved extends CartState {
  final String itemId;

  const CartItemRemoved(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Cart cleared successfully
class CartCleared extends CartState {}

/// Cart checked out successfully, transaction created
class CartCheckedOut extends CartState {
  final String transactionId;
  final String transactionNumber;
  final double totalAmount;
  final String paymentMethod;
  final String? qrisString;
  final DateTime? qrisExpiredAt;

  const CartCheckedOut({
    required this.transactionId,
    required this.transactionNumber,
    required this.totalAmount,
    required this.paymentMethod,
    this.qrisString,
    this.qrisExpiredAt,
  });

  @override
  List<Object?> get props => [transactionId, transactionNumber, totalAmount, paymentMethod, qrisString, qrisExpiredAt];
}

/// Error state
class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}
