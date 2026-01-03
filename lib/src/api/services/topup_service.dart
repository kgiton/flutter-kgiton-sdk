import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/topup_models.dart';
import '../exceptions/api_exceptions.dart';

/// Top-up Service
///
/// Provides methods for token top-up operations:
/// - Get available payment methods
/// - Request top-up
/// - Check transaction status
/// - Get transaction history
/// - Cancel pending transaction
class KgitonTopupService {
  final KgitonApiClient _client;

  KgitonTopupService(this._client);

  /// Get available payment methods
  ///
  /// Returns list of [PaymentMethodInfo] containing available payment options
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<List<PaymentMethodInfo>> getPaymentMethods() async {
    final response = await _client.get<List<PaymentMethodInfo>>(
      KgitonApiEndpoints.paymentMethods,
      requiresAuth: true,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((e) => PaymentMethodInfo.fromJson(e as Map<String, dynamic>)).toList();
        }
        throw KgitonApiException(message: 'Invalid response format for payment methods');
      },
    );

    if (!response.success) {
      throw KgitonApiException(message: 'Failed to get payment methods: ${response.message}');
    }

    return response.data ?? [];
  }

  /// Request token top-up
  ///
  /// [tokenCount] - Number of tokens to purchase
  /// [licenseKey] - License key to top-up
  /// [paymentMethod] - Payment method (default: checkout_page)
  /// [customerPhone] - Optional customer phone number
  ///
  /// Returns [TopupResponse] with payment URL or VA number
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if token_count <= 0 or license key invalid
  /// - [KgitonApiException] for other errors
  Future<TopupResponse> requestTopup({required int tokenCount, required String licenseKey, String? paymentMethod, String? customerPhone}) async {
    final request = TopupRequest(tokenCount: tokenCount, licenseKey: licenseKey, paymentMethod: paymentMethod, customerPhone: customerPhone);

    if (!request.isValid()) {
      throw KgitonValidationException(message: 'Invalid top-up request: token_count must be > 0 and license_key must not be empty');
    }

    final response = await _client.post<TopupResponse>(
      KgitonApiEndpoints.topupRequest,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => TopupResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to request top-up: ${response.message}');
    }

    return response.data!;
  }

  /// Check transaction status (public endpoint)
  ///
  /// [transactionId] - The transaction ID to check
  ///
  /// Returns [TransactionStatusResponse] with current status
  ///
  /// Note: This endpoint does not require authentication
  ///
  /// Throws:
  /// - [KgitonNotFoundException] if transaction not found
  /// - [KgitonApiException] for other errors
  Future<TransactionStatusResponse> checkTransactionStatusPublic(String transactionId) async {
    final response = await _client.get<TransactionStatusResponse>(
      KgitonApiEndpoints.checkTransactionPublic(transactionId),
      requiresAuth: false,
      fromJsonT: (json) => TransactionStatusResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to check transaction status: ${response.message}');
    }

    return response.data!;
  }

  /// Check transaction status (authenticated endpoint)
  ///
  /// [transactionId] - The transaction ID to check
  ///
  /// Returns [TopupTransaction] with full transaction details
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if transaction not found
  /// - [KgitonApiException] for other errors
  Future<TopupTransaction> checkTransactionStatus(String transactionId) async {
    final response = await _client.get<TopupTransaction>(
      KgitonApiEndpoints.checkTransactionStatus(transactionId),
      requiresAuth: true,
      fromJsonT: (json) => TopupTransaction.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to check transaction status: ${response.message}');
    }

    return response.data!;
  }

  /// Get transaction history
  ///
  /// Returns list of [TopupTransaction] for the authenticated user
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<List<TopupTransaction>> getTransactionHistory() async {
    final response = await _client.get<List<TopupTransaction>>(
      KgitonApiEndpoints.topupHistory,
      requiresAuth: true,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((e) => TopupTransaction.fromJson(e as Map<String, dynamic>)).toList();
        }
        if (json is Map<String, dynamic>) {
          final transactions = json['transactions'] as List? ?? json['data'] as List? ?? [];
          return transactions.map((e) => TopupTransaction.fromJson(e as Map<String, dynamic>)).toList();
        }
        throw KgitonApiException(message: 'Invalid response format for transaction history');
      },
    );

    if (!response.success) {
      throw KgitonApiException(message: 'Failed to get transaction history: ${response.message}');
    }

    return response.data ?? [];
  }

  /// Cancel pending transaction
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
  /// - [KgitonValidationException] if transaction cannot be cancelled
  /// - [KgitonApiException] for other errors
  Future<bool> cancelTransaction(String transactionId) async {
    final response = await _client.post<void>(KgitonApiEndpoints.cancelTransaction(transactionId), requiresAuth: true);

    if (!response.success) {
      throw KgitonApiException(message: 'Failed to cancel transaction: ${response.message}');
    }

    return true;
  }
}
