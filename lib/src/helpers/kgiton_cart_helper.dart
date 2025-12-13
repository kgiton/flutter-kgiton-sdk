import '../api/kgiton_api_service.dart';
import '../api/services/cart_service.dart';
import '../api/models/cart_models.dart';

/// Helper service untuk cart operations
///
/// Simplified wrapper untuk KgitonCartService dengan:
/// - Consistent return format (Map with success/message/data)
/// - Error handling
/// - Easy-to-use API
///
/// Example:
/// ```dart
/// final apiService = KgitonApiService(baseUrl: 'https://api.example.com');
/// final cart = KgitonCartHelper(apiService);
///
/// // Add item to cart
/// final result = await cart.addItem(
///   cartId: 'device-123',
///   licenseKey: 'ABC123',
///   itemId: 'item-uuid',
///   quantity: 2.5,
/// );
///
/// if (result['success']) {
///   print('Item added: ${result['data']}');
/// }
///
/// // Get cart items
/// final items = await cart.getItems('device-123');
/// print('Cart has ${items['data'].length} items');
///
/// // Checkout
/// final checkout = await cart.checkout(
///   cartId: 'device-123',
///   paymentMethod: 'CASH',
/// );
/// ```
class KgitonCartHelper {
  final KgitonCartService _cartService;

  /// Create cart helper instance
  ///
  /// [apiService] - Authenticated KgitonApiService instance
  KgitonCartHelper(KgitonApiService apiService) : _cartService = apiService.cart;

  // ============================================
  // ADD TO CART
  // ============================================

  /// Add item to cart (ALWAYS creates new entry)
  ///
  /// Perfect for scale apps where same item can be weighed multiple times
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  /// - data: CartItem (if success)
  Future<Map<String, dynamic>> addItem({
    required String cartId,
    required String licenseKey,
    required String itemId,
    double? quantity,
    int? quantityPcs,
    String? notes,
  }) async {
    try {
      // Validate that at least one quantity is provided
      if (quantity == null && quantityPcs == null) {
        return {'success': false, 'message': 'At least one quantity (kg or pcs) must be provided'};
      }

      final request = AddCartRequest(
        cartId: cartId,
        licenseKey: licenseKey,
        itemId: itemId,
        quantity: quantity,
        quantityPcs: quantityPcs,
        notes: notes,
      );

      // Validate request before sending
      if (!request.isValid()) {
        return {'success': false, 'message': 'Invalid cart request: Please check all required fields'};
      }

      final cartItem = await _cartService.addItemToCart(request);

      return {'success': true, 'message': 'Item berhasil ditambahkan', 'data': cartItem};
    } catch (e) {
      return {'success': false, 'message': 'Gagal menambahkan item: ${e.toString()}'};
    }
  }

  // ============================================
  // GET CART DATA
  // ============================================

  /// Get all cart items by cart ID
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String (if error)
  /// - data: List<CartItem> (if success)
  Future<Map<String, dynamic>> getItems(String cartId) async {
    try {
      final items = await _cartService.getCartItems(cartId);
      return {'success': true, 'data': items};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil cart: ${e.toString()}', 'data': <CartItem>[]};
    }
  }

  /// Get cart summary (total items & total price)
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String (if error)
  /// - data: CartSummary (if success)
  Future<Map<String, dynamic>> getSummary(String cartId) async {
    try {
      final summary = await _cartService.getCartSummary(cartId);
      return {'success': true, 'data': summary};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil summary: ${e.toString()}'};
    }
  }

  // ============================================
  // UPDATE CART
  // ============================================

  /// Update cart item quantity or notes
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  /// - data: CartItem (if success)
  Future<Map<String, dynamic>> updateItem({required String cartItemId, double? quantity, int? quantityPcs, String? notes}) async {
    try {
      final updatedItem = await _cartService.updateCartItem(
        cartItemId,
        UpdateCartRequest(quantity: quantity, quantityPcs: quantityPcs, notes: notes),
      );

      return {'success': true, 'message': 'Item berhasil diupdate', 'data': updatedItem};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengupdate item: ${e.toString()}'};
    }
  }

  /// Delete cart item
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  Future<Map<String, dynamic>> deleteItem(String cartItemId) async {
    try {
      await _cartService.deleteCartItem(cartItemId);
      return {'success': true, 'message': 'Item berhasil dihapus'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghapus item: ${e.toString()}'};
    }
  }

  /// Clear all items in cart
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  Future<Map<String, dynamic>> clearCart(String cartId) async {
    try {
      await _cartService.clearCart(cartId);
      return {'success': true, 'message': 'Cart berhasil dikosongkan'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengosongkan cart: ${e.toString()}'};
    }
  }

  // ============================================
  // LICENSE-BASED OPERATIONS (Multi-Branch Support)
  // ============================================

  /// Get all cart items for a specific license key
  ///
  /// Useful for multi-branch owners to view cart items per license
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String (if error)
  /// - data: List<CartItem> (if success)
  Future<Map<String, dynamic>> getItemsByLicenseKey(String licenseKey) async {
    try {
      final items = await _cartService.getCartItemsByLicenseKey(licenseKey);
      return {'success': true, 'data': items};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil cart by license: ${e.toString()}', 'data': <CartItem>[]};
    }
  }

  /// Clear all cart items for a specific license key
  ///
  /// Useful for multi-branch owners to clear cart per license
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  Future<Map<String, dynamic>> clearCartByLicenseKey(String licenseKey) async {
    try {
      await _cartService.clearCartByLicenseKey(licenseKey);
      return {'success': true, 'message': 'Cart berhasil dikosongkan untuk license ini'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengosongkan cart: ${e.toString()}'};
    }
  }

  // ============================================
  // CHECKOUT
  // ============================================

  /// Checkout cart to create transaction
  ///
  /// Cart will be automatically cleared after successful checkout
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  /// - data: Transaction (if success)
  Future<Map<String, dynamic>> checkout({
    required String cartId,
    required String paymentMethod, // QRIS, CASH, BANK_TRANSFER
    String paymentGateway = 'external', // external, xendit, midtrans, internal
    String? notes,
  }) async {
    try {
      final transaction = await _cartService.checkoutCart(
        cartId,
        CheckoutCartRequest(paymentMethod: paymentMethod, paymentGateway: paymentGateway, notes: notes),
      );

      return {'success': true, 'message': 'Checkout berhasil', 'data': transaction};
    } catch (e) {
      return {'success': false, 'message': 'Gagal checkout: ${e.toString()}'};
    }
  }
}
