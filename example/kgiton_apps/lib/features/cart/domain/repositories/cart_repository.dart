import 'package:dartz/dartz.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_item.dart' as domain;

/// Cart repository interface
abstract class CartRepository {
  /// Add item to cart - ALWAYS creates new entry
  Future<Either<Failure, domain.CartItem>> addItemToCart({
    required String cartId,
    required String licenseKey,
    required String itemId,
    required double quantity,
    double? quantityPcs,
    String? notes,
  });

  /// Get all cart items for specific cart ID (session)
  Future<Either<Failure, List<domain.CartItem>>> getCartItems(String cartId);

  /// Get cart summary with total items and total amount
  Future<Either<Failure, CartSummary>> getCartSummary(String cartId);

  /// Get single cart item by ID
  Future<Either<Failure, domain.CartItem>> getCartItem(String cartItemId);

  /// Update cart item quantity or notes
  Future<Either<Failure, domain.CartItem>> updateCartItem({required String cartItemId, double? quantity, double? quantityPcs, String? notes});

  /// Delete a single cart item
  Future<Either<Failure, bool>> deleteCartItem(String cartItemId);

  /// Clear all cart items for specific cart ID
  Future<Either<Failure, bool>> clearCart(String cartId);

  /// Checkout cart to create transaction
  Future<Either<Failure, Transaction>> checkoutCart({
    required String cartId,
    required String paymentMethod,
    required String paymentGateway,
    String? notes,
  });

  /// Get cart item count for a cart ID
  Future<Either<Failure, int>> getCartItemCount(String cartId);

  /// Check if cart is empty
  Future<Either<Failure, bool>> isCartEmpty(String cartId);
}

/// Cart summary entity
class CartSummary {
  final int totalItems;
  final double totalAmount;
  final List<domain.CartItem> items;

  CartSummary({required this.totalItems, required this.totalAmount, required this.items});
}
