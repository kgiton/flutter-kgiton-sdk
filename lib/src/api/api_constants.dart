/// API Configuration Constants for KGiTON SDK
///
/// This file contains all API-related constants including:
/// - Base URL configuration
/// - API versioning
/// - Endpoint paths
/// - Default values
library;

/// API Configuration
class KgitonApiConfig {
  /// Default base URL (can be overridden during initialization)
  /// 🔧 CHANGE THIS: Update this URL when API endpoint changes
  static const String defaultBaseUrl = 'https://api.example.com';

  /// API version prefix
  /// 🔧 CHANGE THIS: Update version prefix if API versioning changes (e.g., /api/v2)
  static const String apiVersion = '/api/v1';

  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 10);

  /// Storage keys for SharedPreferences
  static const String baseUrlStorageKey = 'kgiton_api_base_url';
  static const String accessTokenStorageKey = 'kgiton_access_token';
  static const String refreshTokenStorageKey = 'kgiton_refresh_token';
}

/// API Endpoint Paths
/// All paths are relative to the base URL + API version
class KgitonApiEndpoints {
  // ============================================================================
  // AUTHENTICATION ENDPOINTS
  // ============================================================================

  /// Register new owner account
  /// POST /v1/auth/register-owner
  static const String registerOwner = '/auth/register-owner';

  /// Login for owner
  /// POST /v1/auth/login
  static const String login = '/auth/login';

  /// Get current authenticated user
  /// GET /v1/auth/me
  static const String getCurrentUser = '/auth/me';

  /// Logout current user
  /// POST /v1/auth/logout
  static const String logout = '/auth/logout';

  // ============================================================================
  // OWNER OPERATIONS ENDPOINTS
  // ============================================================================

  /// List owner's own licenses
  /// GET /v1/owner/licenses
  static const String listOwnerLicenses = '/owner/licenses';

  /// Assign additional license to owner
  /// POST /v1/owner/licenses/assign
  static const String assignAdditionalLicense = '/owner/licenses/assign';

  // ============================================================================
  // ITEMS/PRODUCTS ENDPOINTS (Owner)
  // ============================================================================

  /// Create new item
  /// POST /v1/items
  static const String createItem = '/items';

  /// List all items with pagination
  /// GET /v1/items?page={page}&limit={limit}
  static const String listItems = '/items';

  /// Get item by ID
  /// GET /v1/items/:id
  static String getItemById(String id) => '/items/$id';

  /// Update item
  /// PUT /v1/items/:id
  static String updateItem(String id) => '/items/$id';

  /// Delete item (soft delete - set is_active = false)
  /// DELETE /v1/items/:id
  static String deleteItem(String id) => '/items/$id';

  /// Permanently delete item (hard delete - remove from database)
  /// DELETE /v1/items/:id/permanent
  static String deletePermanentItem(String id) => '/items/$id/permanent';

  // ============================================================================
  // TRANSACTION ENDPOINTS (Owner)
  // ============================================================================

  /// List all transactions with pagination and filters
  /// GET /v1/transactions?page={page}&limit={limit}&status={status}&start_date={start}&end_date={end}
  static const String listTransactions = '/transactions';

  /// Get transaction by ID
  /// GET /v1/transactions/:id
  static String getTransactionById(String id) => '/transactions/$id';

  /// Get transaction statistics
  /// GET /v1/transactions/stats?start_date={start}&end_date={end}
  static const String getTransactionStats = '/transactions/stats';

  /// Cancel transaction
  /// POST /v1/transactions/:id/cancel
  static String cancelTransaction(String id) => '/transactions/$id/cancel';

  /// Xendit payment callback
  /// POST /v1/transactions/callback
  static const String paymentCallback = '/transactions/callback';

  // ============================================================================
  // CART ENDPOINTS (Owner)
  // ============================================================================

  /// Add item to cart (ALWAYS creates new entry)
  /// POST /v1/cart
  static const String addToCart = '/cart';

  /// Get all cart items by cart ID (session-based)
  /// GET /v1/cart/:cartId
  static String getCartByCartId(String cartId) => '/cart/$cartId';

  /// Get cart summary with total amount (from stored prices)
  /// GET /v1/cart/:cartId/summary
  static String getCartSummary(String cartId) => '/cart/$cartId/summary';

  /// Get single cart item by ID
  /// GET /v1/cart/item/:id
  static String getCartItem(String id) => '/cart/item/$id';

  /// Update cart item
  /// PUT /v1/cart/:id
  static String updateCartItem(String id) => '/cart/$id';

  /// Delete single cart item
  /// DELETE /v1/cart/:id
  static String deleteCartItem(String id) => '/cart/$id';

  /// Delete all cart items by cart ID (clear cart for session)
  /// DELETE /v1/cart/:cartId/clear
  static String deleteCartByCartId(String cartId) => '/cart/$cartId/clear';

  /// Checkout cart to create transaction
  /// POST /v1/cart/:cartId/checkout
  static String checkoutCart(String cartId) => '/cart/$cartId/checkout';

  /// Deprecated: Use getCartByCartId instead
  @Deprecated('Use getCartByCartId instead. Cart is now session-based (cart_id).')
  static String getCartByLicenseKey(String licenseKey) => '/cart/license/$licenseKey';

  /// Deprecated: Use deleteCartByCartId instead
  @Deprecated('Use deleteCartByCartId instead. Cart is now session-based (cart_id).')
  static String deleteCartByLicenseKey(String licenseKey) => '/cart/license/$licenseKey';
}

/// HTTP Status Codes
class HttpStatusCode {
  static const int ok = 200;
  static const int created = 201;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int tooManyRequests = 429;
  static const int internalServerError = 500;
}

/// Common query parameter keys
class QueryParams {
  static const String page = 'page';
  static const String limit = 'limit';
  static const String status = 'status';
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';
  static const String search = 'search';
  static const String sortBy = 'sort_by';
  static const String sortOrder = 'sort_order';
}

/// Default pagination values
class PaginationDefaults {
  static const int defaultPage = 1;
  static const int defaultLimit = 10;
  static const int maxLimit = 100;
}

/// License status values
class LicenseStatus {
  static const String available = 'available';
  static const String assigned = 'assigned';
  static const String expired = 'expired';
  static const String revoked = 'revoked';
}

/// Transaction status values
class TransactionStatus {
  static const String pending = 'pending';
  static const String paid = 'paid';
  static const String cancelled = 'cancelled';
  static const String expired = 'expired';
  static const String refunded = 'refunded';
}

/// Entity type values
class EntityType {
  static const String individual = 'individual';
  static const String company = 'company';
}

/// User role values
class UserRole {
  static const String owner = 'owner';
}
