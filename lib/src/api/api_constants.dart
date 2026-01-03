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
  static const String defaultBaseUrl = 'https://api.kgiton.com';

  /// API version prefix
  /// 🔧 CHANGE THIS: Update version prefix if API versioning changes
  static const String apiVersion = '/api';

  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Storage keys for SharedPreferences
  static const String baseUrlStorageKey = 'kgiton_api_base_url';
  static const String accessTokenStorageKey = 'kgiton_access_token';
  static const String refreshTokenStorageKey = 'kgiton_refresh_token';
  static const String apiKeyStorageKey = 'kgiton_api_key';
}

/// API Endpoint Paths
/// All paths are relative to the base URL + API version
class KgitonApiEndpoints {
  // ============================================================================
  // AUTHENTICATION ENDPOINTS
  // ============================================================================

  /// Register new user account with license key
  /// POST /api/auth/register
  static const String register = '/auth/register';

  /// Verify email after registration
  /// GET /api/auth/verify-email?token={token}
  static const String verifyEmail = '/auth/verify-email';

  /// Login for user
  /// POST /api/auth/login
  static const String login = '/auth/login';

  /// Logout current user
  /// POST /api/auth/logout
  static const String logout = '/auth/logout';

  /// Forgot password - send reset link via email
  /// POST /api/auth/forgot-password
  static const String forgotPassword = '/auth/forgot-password';

  /// Reset password with token
  /// POST /api/auth/reset-password
  static const String resetPassword = '/auth/reset-password';

  // ============================================================================
  // USER ENDPOINTS
  // ============================================================================

  /// Get user profile with all license keys
  /// GET /api/user/profile
  static const String userProfile = '/user/profile';

  /// Get user's token balance from all license keys
  /// GET /api/user/token-balance
  static const String tokenBalance = '/user/token-balance';

  /// Use 1 token from license key
  /// POST /api/user/license-keys/{licenseKey}/use-token
  static String useToken(String licenseKey) => '/user/license-keys/$licenseKey/use-token';

  /// Assign additional license key to user
  /// POST /api/user/assign-license
  static const String assignLicense = '/user/assign-license';

  /// Regenerate API key
  /// POST /api/user/regenerate-api-key
  static const String regenerateApiKey = '/user/regenerate-api-key';

  /// Revoke API key
  /// POST /api/user/revoke-api-key
  static const String revokeApiKey = '/user/revoke-api-key';

  // ============================================================================
  // LICENSE ENDPOINTS (Public)
  // ============================================================================

  /// Validate license key (public endpoint)
  /// POST /api/licenses/validate
  static const String validateLicense = '/licenses/validate';

  // ============================================================================
  // TOP-UP ENDPOINTS
  // ============================================================================

  /// Get available payment methods
  /// GET /api/topup/payment-methods
  static const String paymentMethods = '/topup/payment-methods';

  /// Request top-up token balance
  /// POST /api/topup/request
  static const String topupRequest = '/topup/request';

  /// Check transaction status (public)
  /// GET /api/topup/check/{transaction_id}
  static String checkTransactionPublic(String transactionId) => '/topup/check/$transactionId';

  /// Check transaction status (authenticated)
  /// GET /api/topup/status/{transaction_id}
  static String checkTransactionStatus(String transactionId) => '/topup/status/$transactionId';

  /// Get transaction history
  /// GET /api/topup/history
  static const String topupHistory = '/topup/history';

  /// Cancel pending transaction
  /// POST /api/topup/cancel/{transaction_id}
  static String cancelTransaction(String transactionId) => '/topup/cancel/$transactionId';

  // ============================================================================
  // LICENSE TRANSACTION ENDPOINTS (User)
  // ============================================================================

  /// Get logged-in user's license transactions
  /// GET /api/license-transactions/my
  static const String myLicenseTransactions = '/license-transactions/my';

  /// Get logged-in user's licenses with device and payment info
  /// GET /api/license-transactions/my-licenses
  static const String myLicenses = '/license-transactions/my-licenses';

  /// Initiate license purchase payment (for buy type)
  /// POST /api/license-transactions/purchase
  static const String initiatePurchase = '/license-transactions/purchase';

  /// Initiate license subscription payment (for rent type)
  /// POST /api/license-transactions/subscription
  static const String initiateSubscription = '/license-transactions/subscription';

  // ============================================================================
  // ADMIN LICENSE ENDPOINTS (Super Admin only)
  // ============================================================================

  /// Create license key
  /// POST /api/admin/license-keys
  static const String createLicenseKey = '/admin/license-keys';

  /// Bulk create license keys
  /// POST /api/admin/license-keys/bulk
  static const String bulkCreateLicenseKeys = '/admin/license-keys/bulk';

  /// Upload licenses from CSV
  /// POST /api/admin/license-keys/bulk-upload
  static const String bulkUploadLicenses = '/admin/license-keys/bulk-upload';

  /// Get all license keys
  /// GET /api/admin/license-keys
  static const String getAllLicenseKeys = '/admin/license-keys';

  /// Get all licenses with devices
  /// GET /api/admin/license-keys/with-devices
  static const String getAllLicensesWithDevices = '/admin/license-keys/with-devices';

  /// Get license key by ID
  /// GET /api/admin/license-keys/{id}
  static String getLicenseKeyById(String id) => '/admin/license-keys/$id';

  /// Update license key by ID
  /// PUT /api/admin/license-keys/{id}
  static String updateLicenseKeyById(String id) => '/admin/license-keys/$id';

  /// Delete license key by ID
  /// DELETE /api/admin/license-keys/{id}
  static String deleteLicenseKeyById(String id) => '/admin/license-keys/$id';

  /// Get license key by key string
  /// GET /api/admin/license-keys/key/{key}
  static String getLicenseKeyByKey(String key) => '/admin/license-keys/key/$key';

  /// Update license key by key string
  /// PUT /api/admin/license-keys/key/{key}
  static String updateLicenseKeyByKey(String key) => '/admin/license-keys/key/$key';

  /// Delete license key by key string
  /// DELETE /api/admin/license-keys/key/{key}
  static String deleteLicenseKeyByKey(String key) => '/admin/license-keys/key/$key';

  /// Set trial mode for license key
  /// POST /api/admin/license-keys/{id}/trial
  static String setTrialMode(String id) => '/admin/license-keys/$id/trial';

  /// Add token balance to license key
  /// POST /api/admin/license-keys/{id}/add-tokens
  static String addTokenBalance(String id) => '/admin/license-keys/$id/add-tokens';

  /// Unassign license key from user
  /// POST /api/admin/license-keys/{id}/unassign
  static String unassignLicenseKey(String id) => '/admin/license-keys/$id/unassign';

  /// Confirm cash payment for license
  /// POST /api/admin/license-keys/{id}/confirm-payment
  static String confirmCashPayment(String id) => '/admin/license-keys/$id/confirm-payment';

  /// Initiate payment for license (admin)
  /// POST /api/admin/license-keys/{id}/initiate-payment
  static String initiatePayment(String id) => '/admin/license-keys/$id/initiate-payment';

  /// Renew subscription for license
  /// POST /api/admin/license-keys/{id}/renew
  static String renewSubscription(String id) => '/admin/license-keys/$id/renew';

  // ============================================================================
  // ADMIN TOP-UP ENDPOINTS (Super Admin only)
  // ============================================================================

  /// Get all transactions (admin)
  /// GET /api/topup/admin/all
  static const String getAllTransactions = '/topup/admin/all';

  // ============================================================================
  // ADMIN LICENSE TRANSACTION ENDPOINTS (Super Admin only)
  // ============================================================================

  /// Get all license transactions
  /// GET /api/license-transactions/admin
  static const String adminAllLicenseTransactions = '/license-transactions/admin';

  /// Get license status summary
  /// GET /api/license-transactions/admin/summary
  static const String adminLicenseStatusSummary = '/license-transactions/admin/summary';

  /// Get license transaction by ID
  /// GET /api/license-transactions/admin/{id}
  static String adminGetLicenseTransactionById(String id) => '/license-transactions/admin/$id';

  /// Get transactions by license key
  /// GET /api/license-transactions/admin/license/{licenseKey}
  static String adminGetTransactionsByLicenseKey(String licenseKey) => '/license-transactions/admin/license/$licenseKey';
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

/// User role values
class UserRole {
  static const String superAdmin = 'super_admin';
  static const String user = 'user';
}

/// License status values
class LicenseStatus {
  static const String active = 'active';
  static const String inactive = 'inactive';
  static const String trial = 'trial';
}

/// License purchase type values
class LicensePurchaseType {
  static const String buy = 'buy';
  static const String rent = 'rent';
}

/// License transaction status values
class LicenseTransactionStatus {
  static const String pending = 'pending';
  static const String paid = 'paid';
  static const String active = 'active';
  static const String expired = 'expired';
  static const String cancelled = 'cancelled';
}

/// Transaction status values (for top-up)
class TransactionStatus {
  static const String success = 'success';
  static const String failed = 'failed';
  static const String pending = 'pending';
  static const String expired = 'expired';
  static const String cancelled = 'cancelled';
}

/// Payment method values
class PaymentMethod {
  /// Winpay Checkout Page (all payment methods in one page)
  static const String checkoutPage = 'checkout_page';

  /// Virtual Account Banks
  static const String vaBri = 'va_bri';
  static const String vaBni = 'va_bni';
  static const String vaBca = 'va_bca';
  static const String vaMandiri = 'va_mandiri';
  static const String vaPermata = 'va_permata';
  static const String vaBsi = 'va_bsi';
  static const String vaCimb = 'va_cimb';
  static const String vaSinarmas = 'va_sinarmas';
  static const String vaMuamalat = 'va_muamalat';
  static const String vaIndomaret = 'va_indomaret';
  static const String vaAlfamart = 'va_alfamart';

  /// QRIS payment
  static const String qris = 'qris';

  /// List of all payment methods
  static const List<String> allMethods = [
    checkoutPage,
    vaBri,
    vaBni,
    vaBca,
    vaMandiri,
    vaPermata,
    vaBsi,
    vaCimb,
    vaSinarmas,
    vaMuamalat,
    vaIndomaret,
    vaAlfamart,
    qris,
  ];

  /// List of VA payment methods
  static const List<String> vaMethods = [vaBri, vaBni, vaBca, vaMandiri, vaPermata, vaBsi, vaCimb, vaSinarmas, vaMuamalat, vaIndomaret, vaAlfamart];
}
