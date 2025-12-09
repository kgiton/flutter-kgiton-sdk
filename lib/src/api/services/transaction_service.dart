import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/transaction_models.dart';
import '../exceptions/api_exceptions.dart';

/// Transaction Service
///
/// Provides methods for transaction operations:
/// - List transactions with filters and pagination
/// - Get transaction detail
/// - Get transaction statistics
/// - Cancel transaction
/// - Create transaction (direct, not recommended - use cart checkout instead)
///
/// Recommended workflow:
/// 1. Add items to cart (CartService.addItemToCart)
/// 2. Checkout cart (CartService.checkoutCart) - creates transaction
/// 3. Get transaction list/detail for viewing history
class KgitonTransactionService {
  final KgitonApiClient _client;

  KgitonTransactionService(this._client);

  /// List all transactions with filters and pagination
  ///
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 20)
  /// [status] - Filter by payment status: PENDING, PAID, EXPIRED, CANCELLED, REFUNDED (optional)
  /// [startDate] - Filter transactions from this date (optional)
  /// [endDate] - Filter transactions until this date (optional)
  ///
  /// Returns [TransactionListData] containing transactions and pagination info
  ///
  /// Example:
  /// ```dart
  /// // Get all transactions
  /// final transactions = await transactionService.listTransactions();
  ///
  /// // Get pending transactions
  /// final pending = await transactionService.listTransactions(status: PaymentStatus.pending);
  ///
  /// // Get transactions for date range
  /// final transactions = await transactionService.listTransactions(
  ///   startDate: DateTime(2025, 12, 1),
  ///   endDate: DateTime(2025, 12, 31),
  /// );
  /// ```
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<TransactionListData> listTransactions({int page = 1, int limit = 20, String? status, DateTime? startDate, DateTime? endDate}) async {
    final queryParams = <String, String>{'page': page.toString(), 'limit': limit.toString()};

    if (status != null) {
      queryParams['status'] = status;
    }

    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String().split('T').first;
    }

    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String().split('T').first;
    }

    final response = await _client.get<TransactionListData>(
      KgitonApiEndpoints.listTransactions,
      queryParameters: queryParams,
      requiresAuth: true,
      fromJsonT: (json) => TransactionListData.fromJson(json),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to list transactions: ${response.message}');
    }

    return response.data!;
  }

  /// Get transaction by ID
  ///
  /// [transactionId] - The transaction ID (UUID)
  ///
  /// Returns [Transaction] with basic transaction info
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if transaction not found
  /// - [KgitonAuthorizationException] if transaction doesn't belong to owner
  /// - [KgitonApiException] for other errors
  Future<Transaction> getTransactionById(String transactionId) async {
    final response = await _client.get<Transaction>(
      KgitonApiEndpoints.getTransactionById(transactionId),
      requiresAuth: true,
      fromJsonT: (json) => Transaction.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to get transaction: ${response.message}');
    }

    return response.data!;
  }

  /// Get transaction detail with items
  ///
  /// [transactionId] - The transaction ID (UUID)
  ///
  /// Returns [TransactionDetail] containing transaction and all items
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if transaction not found
  /// - [KgitonAuthorizationException] if transaction doesn't belong to owner
  /// - [KgitonApiException] for other errors
  Future<TransactionDetail> getTransactionDetail(String transactionId) async {
    final response = await _client.get<TransactionDetail>(
      '${KgitonApiEndpoints.getTransactionById(transactionId)}/detail',
      requiresAuth: true,
      fromJsonT: (json) => TransactionDetail.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to get transaction detail: ${response.message}');
    }

    return response.data!;
  }

  /// Get transaction statistics
  ///
  /// Returns [TransactionStatistics] with overall transaction stats
  /// (total, success, pending, cancelled counts and amounts)
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<TransactionStatistics> getTransactionStats() async {
    final response = await _client.get<TransactionStatistics>(
      KgitonApiEndpoints.getTransactionStats,
      requiresAuth: true,
      fromJsonT: (json) => TransactionStatistics.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to get transaction statistics: ${response.message}');
    }

    return response.data!;
  }

  /// Get transaction statistics for a specific license
  ///
  /// [licenseKey] - The license key to get statistics for
  ///
  /// Returns [LicenseTransactionStatistics] with license-specific transaction stats
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if license not found
  /// - [KgitonApiException] for other errors
  Future<LicenseTransactionStatistics> getLicenseTransactionStats(String licenseKey) async {
    final response = await _client.get<LicenseTransactionStatistics>(
      '/transactions/license/$licenseKey/stats',
      requiresAuth: true,
      fromJsonT: (json) => LicenseTransactionStatistics.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to get license transaction statistics: ${response.message}');
    }

    return response.data!;
  }

  /// Get all licenses with transaction statistics
  ///
  /// Returns list of [LicenseTransactionStatistics] for all licenses owned by user
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<List<LicenseTransactionStatistics>> getAllLicensesWithStats() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/transactions/licenses/stats',
      requiresAuth: true,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to get all licenses statistics: ${response.message}');
    }

    final licenses = (response.data!['licenses'] as List).map((e) => LicenseTransactionStatistics.fromJson(e as Map<String, dynamic>)).toList();

    return licenses;
  }

  /// Cancel transaction
  ///
  /// [transactionId] - The transaction ID to cancel
  ///
  /// Returns true if cancellation was successful
  ///
  /// Note: Only pending transactions can be cancelled
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if transaction not found
  /// - [KgitonValidationException] if transaction cannot be cancelled (already paid/expired)
  /// - [KgitonApiException] for other errors
  Future<bool> cancelTransaction(String transactionId) async {
    final response = await _client.post(KgitonApiEndpoints.cancelTransaction(transactionId), requiresAuth: true);

    if (!response.success) {
      throw KgitonApiException(message: 'Failed to cancel transaction: ${response.message}');
    }

    return true;
  }

  /// Create transaction directly (not from cart)
  ///
  /// **⚠️ DEPRECATED: Use cart checkout instead**
  ///
  /// Recommended workflow:
  /// 1. Add items to cart using CartService.addItemToCart()
  /// 2. Checkout cart using CartService.checkoutCart()
  ///
  /// This method creates transaction directly without cart and is not recommended.
  ///
  /// [request] - Checkout request containing license key, items, payment method, etc.
  ///
  /// Returns [Transaction] containing the created transaction with payment details
  ///
  /// Example (not recommended):
  /// ```dart
  /// final checkoutRequest = CheckoutRequest(
  ///   licenseKey: 'ABC123',
  ///   items: [
  ///     CheckoutItemRequest(
  ///       itemName: 'Apel Fuji',
  ///       weight: 2.5,
  ///       unit: 'kg',
  ///       pricePerUnit: 15000,
  ///       totalPrice: 37500,
  ///     ),
  ///   ],
  ///   totalAmount: 37500,
  ///   paymentMethod: PaymentMethod.qris,
  ///   paymentGateway: PaymentGateway.external,
  ///   notes: 'Belanja buah',
  /// );
  /// final transaction = await transactionService.createTransaction(checkoutRequest);
  /// ```
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if validation fails (empty items, invalid total, etc.)
  /// - [KgitonNotFoundException] if license not found
  /// - [KgitonApiException] for other errors
  @Deprecated('Use cart checkout instead. Add items to cart then use CartService.checkoutCart()')
  Future<Transaction> createTransaction(CheckoutRequest request) async {
    if (!request.isValid()) {
      throw KgitonValidationException(
        message: 'Invalid checkout request: license key, items, total amount, and valid payment method/gateway are required',
      );
    }

    final response = await _client.post<Transaction>(
      KgitonApiEndpoints.listTransactions,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => Transaction.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to create transaction: ${response.message}');
    }

    return response.data!;
  }
}
