import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/cart_models.dart';
import '../models/transaction_models.dart';
import '../exceptions/api_exceptions.dart';

/// Cart Service
///
/// Provides methods for shopping cart operations:
/// - Add item to cart (ALWAYS creates new entry)
/// - Get cart items by cart ID (session-based)
/// - Get cart summary with stored prices
/// - Get single cart item
/// - Update cart item
/// - Delete single cart item
/// - Delete all items by cart ID (clear cart for session)
/// - Checkout cart to create transaction
///
/// Example usage:
/// ```dart
/// // Add item to cart
/// final cartItem = await cartService.addItemToCart(
///   AddCartRequest(
///     cartId: 'device-12345',
///     licenseKey: 'ABC123',
///     itemId: 'item-uuid',
///     quantity: 2.5,
///     quantityPcs: 10,
///     notes: 'Extra fresh',
///   ),
/// );
///
/// // Get cart items by cart ID
/// final cartItems = await cartService.getCartItems('device-12345');
///
/// // Get cart summary
/// final summary = await cartService.getCartSummary('device-12345');
///
/// // Update cart item
/// await cartService.updateCartItem(
///   'cart-item-id',
///   UpdateCartRequest(quantity: 3.0, quantityPcs: 15),
/// );
///
/// // Checkout cart
/// final transaction = await cartService.checkoutCart(
///   'device-12345',
///   CheckoutCartRequest(
///     paymentMethod: PaymentMethod.qris,
///     paymentGateway: PaymentGateway.external,
///   ),
/// );
///
/// // Clear cart after checkout
/// await cartService.clearCart('device-12345');
/// ```
class KgitonCartService {
  final KgitonApiClient _client;

  KgitonCartService(this._client);

  /// Add item to cart
  ///
  /// **ALWAYS creates new entry** - no duplicate checking.
  /// Perfect for scale apps where same item can be weighed multiple times.
  ///
  /// [request] - Add cart request with cart_id, license key, item id, quantity, etc.
  ///
  /// Returns the created [CartItem] with stored prices (unit_price and total_price)
  ///
  /// Behavior:
  /// - ALWAYS creates new cart entry regardless of whether item already exists
  /// - Stores unit_price and total_price at add time for consistency
  /// - Groups by cart_id (session identifier like device ID)
  ///
  /// Use Cases:
  /// - **Scale App**: Same item weighed 3 times = 3 separate cart entries ✅
  /// - **Bulk Purchase**: Same item with different notes/batches = separate entries ✅
  /// - **Flexible Shopping**: Users can manually manage quantities per entry
  ///
  /// Example:
  /// ```dart
  /// // First add: Apples 1.0 kg
  /// await addItemToCart(AddCartRequest(
  ///   cartId: 'device-12345',
  ///   licenseKey: 'ABC123',
  ///   itemId: 'apple-uuid',
  ///   quantity: 1.0,
  ///   notes: 'First weighing',
  /// )); // Creates cart entry #1
  ///
  /// // Second add: Apples 0.5 kg (same item_id, different weight)
  /// await addItemToCart(AddCartRequest(
  ///   cartId: 'device-12345',
  ///   licenseKey: 'ABC123',
  ///   itemId: 'apple-uuid',
  ///   quantity: 0.5,
  ///   notes: 'Second weighing',
  /// )); // Creates cart entry #2
  ///
  /// // Result: 2 separate cart entries for Apples
  /// ```
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if validation fails (quantity <= 0)
  /// - [KgitonNotFoundException] if item not found
  /// - [KgitonApiException] for other errors
  Future<CartItem> addItemToCart(AddCartRequest request) async {
    // Validate request
    if (!request.isValid()) {
      throw KgitonValidationException(
        message: 'Invalid cart request: cart_id, license_key, item_id must not be empty and quantity must be greater than 0',
      );
    }

    final response = await _client.post<CartItem>(
      KgitonApiEndpoints.addToCart,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => CartItem.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to add item to cart: ${response.message}');
    }

    return response.data!;
  }

  /// Get all cart items for a specific cart ID (session)
  ///
  /// [cartId] - The cart session identifier (e.g., device ID, session ID)
  ///
  /// Returns list of [CartItem] with item details and stored prices included
  ///
  /// Note: Results are sorted by created_at descending (newest first)
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<List<CartItem>> getCartItems(String cartId) async {
    final endpoint = KgitonApiEndpoints.getCartByCartId(cartId);

    final response = await _client.get<List<CartItem>>(
      endpoint,
      requiresAuth: true,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
        }
        throw KgitonApiException(message: 'Invalid response format for cart items');
      },
    );

    if (!response.success) {
      throw KgitonApiException(message: 'Failed to get cart items: ${response.message}');
    }

    return response.data ?? [];
  }

  /// Get cart summary including total items and total amount from stored prices
  ///
  /// [cartId] - The cart session identifier (e.g., device ID, session ID)
  ///
  /// Returns [CartSummary] with total items, total amount (from stored prices), and items list
  ///
  /// Total amount is calculated from stored prices:
  /// - Sum of all cart items' total_price (stored at add time)
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<CartSummary> getCartSummary(String cartId) async {
    final endpoint = KgitonApiEndpoints.getCartSummary(cartId);

    final response = await _client.get<CartSummary>(
      endpoint,
      requiresAuth: true,
      fromJsonT: (json) => CartSummary.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to get cart summary: ${response.message}');
    }

    return response.data!;
  }

  /// Get single cart item by ID
  ///
  /// [cartItemId] - The cart item ID (UUID)
  ///
  /// Returns [CartItem] with item details included
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if cart item not found
  /// - [KgitonApiException] for other errors
  Future<CartItem> getCartItem(String cartItemId) async {
    final endpoint = KgitonApiEndpoints.getCartItem(cartItemId);

    final response = await _client.get<CartItem>(endpoint, requiresAuth: true, fromJsonT: (json) => CartItem.fromJson(json as Map<String, dynamic>));

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to get cart item: ${response.message}');
    }

    return response.data!;
  }

  /// Update cart item quantity or notes
  ///
  /// [cartItemId] - The cart item ID to update
  /// [request] - Update request with new quantity, quantity_pcs, or notes
  ///
  /// Returns the updated [CartItem]
  ///
  /// Note: At least one field (quantity, quantity_pcs, or notes) must be provided
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if validation fails
  /// - [KgitonNotFoundException] if cart item not found
  /// - [KgitonApiException] for other errors
  Future<CartItem> updateCartItem(String cartItemId, UpdateCartRequest request) async {
    // Validate request
    if (!request.isValid()) {
      throw KgitonValidationException(message: 'Invalid update request: at least one field must be provided and values must be greater than 0');
    }

    final endpoint = KgitonApiEndpoints.updateCartItem(cartItemId);

    final response = await _client.put<CartItem>(
      endpoint,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => CartItem.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to update cart item: ${response.message}');
    }

    return response.data!;
  }

  /// Delete a single cart item
  ///
  /// [cartItemId] - The cart item ID to delete
  ///
  /// Returns true if deletion was successful
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if cart item not found
  /// - [KgitonApiException] for other errors
  Future<bool> deleteCartItem(String cartItemId) async {
    final endpoint = KgitonApiEndpoints.deleteCartItem(cartItemId);

    final response = await _client.delete(endpoint, requiresAuth: true);

    if (!response.success) {
      throw KgitonApiException(message: 'Failed to delete cart item: ${response.message}');
    }

    return true;
  }

  /// Delete all cart items for a specific cart ID (clear cart for session)
  ///
  /// [cartId] - The cart session identifier to clear cart for
  ///
  /// Returns true if deletion was successful
  ///
  /// Note: This is typically used after successful checkout/transaction creation
  /// Cart is automatically cleared after successful checkout
  /// Does not throw error if cart is empty (0 items deleted)
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<bool> clearCart(String cartId) async {
    final endpoint = KgitonApiEndpoints.deleteCartByCartId(cartId);

    final response = await _client.delete(endpoint, requiresAuth: true);

    if (!response.success) {
      throw KgitonApiException(message: 'Failed to clear cart: ${response.message}');
    }

    return true;
  }

  /// Checkout cart to create transaction
  ///
  /// Converts all cart items to a transaction with payment gateway selection.
  /// Cart is automatically cleared after successful checkout.
  ///
  /// [cartId] - The cart session identifier to checkout
  /// [request] - Checkout request with payment method and gateway
  ///
  /// Returns [Transaction] with payment details and QRIS (if payment_method = QRIS)
  ///
  /// Payment Methods:
  /// - QRIS: Digital payment via QR code (generates qris_string)
  /// - CASH: Cash payment at counter (no QRIS)
  /// - BANK_TRANSFER: Bank transfer payment (no QRIS)
  ///
  /// Payment Gateways:
  /// - external (default): External 3rd party payment gateway
  /// - xendit: Xendit payment gateway integration
  /// - midtrans: Midtrans payment gateway integration
  /// - internal: KGiTON internal QRIS generation
  ///
  /// Example:
  /// ```dart
  /// final transaction = await cartService.checkoutCart(
  ///   'device-12345',
  ///   CheckoutCartRequest(
  ///     paymentMethod: PaymentMethod.qris,
  ///     paymentGateway: PaymentGateway.external,
  ///     notes: 'Bulk purchase',
  ///   ),
  /// );
  ///
  /// // Check if QRIS available
  /// if (transaction.paymentMethod == PaymentMethod.qris &&
  ///     transaction.qrisString != null) {
  ///   // Display QRIS code
  ///   displayQRIS(transaction.qrisString!);
  /// }
  /// ```
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if cart is empty or validation fails
  /// - [KgitonApiException] for other errors
  Future<Transaction> checkoutCart(String cartId, CheckoutCartRequest request) async {
    // Validate request
    if (!request.isValid()) {
      throw KgitonValidationException(
        message:
            'Invalid checkout request: payment_method must be QRIS/CASH/BANK_TRANSFER and payment_gateway must be external/xendit/midtrans/internal',
      );
    }

    final endpoint = KgitonApiEndpoints.checkoutCart(cartId);

    final response = await _client.post<Transaction>(
      endpoint,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => Transaction.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to checkout cart: ${response.message}');
    }

    return response.data!;
  }

  /// Convenience method: Clear cart after successful checkout
  ///
  /// [cartId] - The cart session identifier to clear cart for
  ///
  /// This is an alias for [clearCart] with a more descriptive name
  Future<bool> clearCartAfterCheckout(String cartId) async {
    return clearCart(cartId);
  }

  /// Convenience method: Get cart item count for a cart ID
  ///
  /// [cartId] - The cart session identifier to count items for
  ///
  /// Returns the number of items in the cart
  Future<int> getCartItemCount(String cartId) async {
    final summary = await getCartSummary(cartId);
    return summary.totalItems;
  }

  /// Convenience method: Check if cart is empty
  ///
  /// [cartId] - The cart session identifier to check
  ///
  /// Returns true if cart is empty
  Future<bool> isCartEmpty(String cartId) async {
    final count = await getCartItemCount(cartId);
    return count == 0;
  }

  // ============================================================================
  // DEPRECATED METHODS (for backwards compatibility)
  // ============================================================================

  /// @deprecated Use [getCartItems] with cartId instead
  @Deprecated('Use getCartItems(cartId) instead. Cart is now session-based (cart_id).')
  Future<List<CartItem>> getCartItemsByLicenseKey(String licenseKey) async {
    // For backwards compatibility, try to get cart items
    // However, this may not work as expected since cart is now cart_id based
    throw KgitonApiException(
      message:
          'getCartItemsByLicenseKey is deprecated. Use getCartItems(cartId) instead. '
          'Cart is now session-based (cart_id) not license-based.',
    );
  }

  /// @deprecated Use [clearCart] with cartId instead
  @Deprecated('Use clearCart(cartId) instead. Cart is now session-based (cart_id).')
  Future<bool> deleteAllByLicenseKey(String licenseKey) async {
    throw KgitonApiException(
      message:
          'deleteAllByLicenseKey is deprecated. Use clearCart(cartId) instead. '
          'Cart is now session-based (cart_id) not license-based.',
    );
  }
}
