import 'package:flutter/foundation.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../../../../core/error/exceptions.dart';
import '../models/cart_model.dart';

/// Remote data source for cart operations using KGiTON SDK
abstract class CartRemoteDataSource {
  /// Add item to cart - ALWAYS creates new entry
  Future<CartModel> addItemToCart({
    required String cartId,
    required String licenseKey,
    required String itemId,
    required double quantity,
    double? quantityPcs,
    String? notes,
  });

  /// Get all cart items for specific cart ID (session)
  Future<List<CartModel>> getCartItems(String cartId);

  /// Get cart summary with total items and total amount
  Future<CartSummaryData> getCartSummary(String cartId);

  /// Get single cart item by ID
  Future<CartModel> getCartItem(String cartItemId);

  /// Update cart item quantity or notes
  Future<CartModel> updateCartItem({required String cartItemId, double? quantity, double? quantityPcs, String? notes});

  /// Delete a single cart item
  Future<bool> deleteCartItem(String cartItemId);

  /// Clear all cart items for specific cart ID
  Future<bool> clearCart(String cartId);

  /// Checkout cart to create transaction
  Future<Transaction> checkoutCart({required String cartId, required String paymentMethod, required String paymentGateway, String? notes});
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final KgitonApiService apiService;

  CartRemoteDataSourceImpl({required this.apiService});

  @override
  Future<CartModel> addItemToCart({
    required String cartId,
    required String licenseKey,
    required String itemId,
    required double quantity,
    double? quantityPcs,
    String? notes,
  }) async {
    try {
      debugPrint('=== CART DATA SOURCE: Adding to cart via SDK ===');
      debugPrint('=== CART DATA SOURCE: cartId: $cartId, licenseKey: $licenseKey ===');
      debugPrint('=== CART DATA SOURCE: itemId: $itemId, qty: ${quantity.toStringAsFixed(3)}, qtyPcs: $quantityPcs ===');

      final request = AddCartRequest(
        cartId: cartId,
        licenseKey: licenseKey,
        itemId: itemId,
        quantity: quantity,
        quantityPcs: quantityPcs?.toInt(),
        notes: notes,
      );

      final cartItem = await apiService.cart.addItemToCart(request);
      debugPrint('=== CART DATA SOURCE: SDK response - cartItemId: ${cartItem.id}, total: ${cartItem.totalPrice} ===');
      return CartModel.fromSdkCartItem(cartItem);
    } catch (e) {
      debugPrint('=== CART DATA SOURCE: Add to cart ERROR: ${e.toString()} ===');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<CartModel>> getCartItems(String cartId) async {
    try {
      final cartItems = await apiService.cart.getCartItems(cartId);
      return cartItems.map((item) => CartModel.fromSdkCartItem(item)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CartSummaryData> getCartSummary(String cartId) async {
    try {
      debugPrint('=== CART DATA SOURCE: Getting cart summary for cartId: $cartId ===');
      final summary = await apiService.cart.getCartSummary(cartId);
      debugPrint('=== CART DATA SOURCE: Summary received - ${summary.items.length} items, total: ${summary.totalAmount} ===');
      return CartSummaryData(
        totalItems: summary.totalItems,
        totalAmount: summary.totalAmount,
        items: summary.items.map((item) => CartModel.fromSdkCartItem(item)).toList(),
      );
    } catch (e) {
      debugPrint('=== CART DATA SOURCE: Get cart summary ERROR: ${e.toString()} ===');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CartModel> getCartItem(String cartItemId) async {
    try {
      final cartItem = await apiService.cart.getCartItem(cartItemId);
      return CartModel.fromSdkCartItem(cartItem);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CartModel> updateCartItem({required String cartItemId, double? quantity, double? quantityPcs, String? notes}) async {
    try {
      final request = UpdateCartRequest(quantity: quantity, quantityPcs: quantityPcs?.toInt(), notes: notes);

      final cartItem = await apiService.cart.updateCartItem(cartItemId, request);
      return CartModel.fromSdkCartItem(cartItem);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> deleteCartItem(String cartItemId) async {
    try {
      return await apiService.cart.deleteCartItem(cartItemId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> clearCart(String cartId) async {
    try {
      return await apiService.cart.clearCart(cartId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Transaction> checkoutCart({required String cartId, required String paymentMethod, required String paymentGateway, String? notes}) async {
    try {
      final request = CheckoutCartRequest(paymentMethod: paymentMethod, paymentGateway: paymentGateway, notes: notes);

      return await apiService.cart.checkoutCart(cartId, request);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

/// Cart summary data class
class CartSummaryData {
  final int totalItems;
  final double totalAmount;
  final List<CartModel> items;

  CartSummaryData({required this.totalItems, required this.totalAmount, required this.items});
}
