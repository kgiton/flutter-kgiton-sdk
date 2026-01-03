import '../api/kgiton_api_service.dart';
import '../api/models/topup_models.dart';

/// Helper service untuk token top-up operations
///
/// Simplified wrapper untuk top-up related operations dengan:
/// - Consistent return format
/// - Error handling
/// - Easy-to-use API
///
/// Example:
/// ```dart
/// final apiService = KgitonApiService(baseUrl: 'https://api.kgiton.com');
/// final topup = KgitonTopupHelper(apiService);
///
/// // Get available payment methods
/// final methods = await topup.getPaymentMethods();
/// if (methods['success']) {
///   for (var method in methods['data']) {
///     print('${method.name}');
///   }
/// }
///
/// // Request top-up with checkout page
/// final result = await topup.requestTopup(
///   tokenCount: 100,
///   licenseKey: 'LICENSE-KEY',
///   paymentMethod: 'checkout_page',
/// );
/// if (result['success']) {
///   print('Payment URL: ${result['paymentUrl']}');
/// }
///
/// // Check transaction status
/// final status = await topup.checkStatus(transactionId);
/// if (status['success']) {
///   print('Status: ${status['status']}');
/// }
/// ```
class KgitonTopupHelper {
  final KgitonApiService _apiService;

  /// Create topup helper instance
  ///
  /// [apiService] - Authenticated KgitonApiService instance
  KgitonTopupHelper(this._apiService);

  // ============================================
  // PAYMENT METHODS
  // ============================================

  /// Get available payment methods
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String (if error)
  /// - data: List<PaymentMethodInfo>
  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final methods = await _apiService.topup.getPaymentMethods();

      return {'success': true, 'data': methods};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil payment methods: ${e.toString()}', 'data': <PaymentMethodInfo>[]};
    }
  }

  /// Get payment method by id
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String (if error)
  /// - data: PaymentMethodInfo (if found)
  Future<Map<String, dynamic>> getPaymentMethod(String id) async {
    try {
      final result = await getPaymentMethods();
      if (!result['success']) {
        return result;
      }

      final methods = result['data'] as List<PaymentMethodInfo>;
      final method = methods.firstWhere((m) => m.id == id, orElse: () => throw Exception('Payment method tidak ditemukan'));

      return {'success': true, 'data': method};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil payment method: ${e.toString()}'};
    }
  }

  // ============================================
  // REQUEST TOP-UP
  // ============================================

  /// Request top-up tokens
  ///
  /// [tokenCount] - Number of tokens to purchase
  /// [licenseKey] - License key to add tokens to
  /// [paymentMethod] - Payment method id (checkout_page, va_bri, qris, etc)
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  /// - transactionId: String (if success)
  /// - paymentUrl: String (for checkout_page method)
  /// - vaNumber: String (for VA methods)
  /// - expiresAt: DateTime (if success)
  /// - data: TopupResponse (full response)
  Future<Map<String, dynamic>> requestTopup({
    required int tokenCount,
    required String licenseKey,
    required String paymentMethod,
    String? customerPhone,
  }) async {
    try {
      final response = await _apiService.topup.requestTopup(
        tokenCount: tokenCount,
        licenseKey: licenseKey,
        paymentMethod: paymentMethod,
        customerPhone: customerPhone,
      );

      final result = <String, dynamic>{
        'success': true,
        'message': 'Top-up request berhasil dibuat',
        'transactionId': response.transactionId,
        'status': response.status,
        'amountToPay': response.amountToPay,
        'tokensRequested': response.tokensRequested,
        'expiresAt': response.expiresAt,
        'data': response,
      };

      // Add payment URL if available
      if (response.paymentUrl != null) {
        result['paymentUrl'] = response.paymentUrl;
      }

      // Add VA info if available
      if (response.virtualAccount != null) {
        result['vaNumber'] = response.virtualAccount!.number;
        result['vaBank'] = response.virtualAccount!.bank;
        result['vaName'] = response.virtualAccount!.name;
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Gagal request topup: ${e.toString()}'};
    }
  }

  /// Request top-up with checkout page (simplified)
  ///
  /// Returns payment URL for user to complete payment
  Future<Map<String, dynamic>> requestCheckoutTopup({required int tokenCount, required String licenseKey}) async {
    return requestTopup(tokenCount: tokenCount, licenseKey: licenseKey, paymentMethod: 'checkout_page');
  }

  /// Request top-up with QRIS
  ///
  /// Returns QRIS URL for user to scan
  Future<Map<String, dynamic>> requestQrisTopup({required int tokenCount, required String licenseKey}) async {
    return requestTopup(tokenCount: tokenCount, licenseKey: licenseKey, paymentMethod: 'qris');
  }

  /// Request top-up with Virtual Account
  ///
  /// [bank] - Bank code (bri, bni, bca, mandiri, permata, bsi, cimb)
  ///
  /// Returns VA number for user to transfer
  Future<Map<String, dynamic>> requestVaTopup({required int tokenCount, required String licenseKey, required String bank}) async {
    return requestTopup(tokenCount: tokenCount, licenseKey: licenseKey, paymentMethod: 'va_$bank');
  }

  // ============================================
  // TRANSACTION STATUS
  // ============================================

  /// Check transaction status (authenticated)
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  /// - status: String (pending, success, failed, expired, cancelled)
  /// - isPaid: bool
  /// - data: TopupTransaction (if success)
  Future<Map<String, dynamic>> checkStatus(String transactionId) async {
    try {
      final response = await _apiService.topup.checkTransactionStatus(transactionId);

      final isPaid = response.status == 'success' || response.status == 'completed';

      return {'success': true, 'message': 'Status: ${response.status}', 'status': response.status, 'isPaid': isPaid, 'data': response};
    } catch (e) {
      return {'success': false, 'message': 'Gagal check status: ${e.toString()}', 'status': 'unknown', 'isPaid': false};
    }
  }

  /// Check transaction status (public - no auth required)
  ///
  /// Useful for checking payment status without login
  Future<Map<String, dynamic>> checkStatusPublic(String transactionId) async {
    try {
      final response = await _apiService.topup.checkTransactionStatusPublic(transactionId);

      final isPaid = response.isSuccess;

      return {'success': true, 'message': 'Status: ${response.status}', 'status': response.status, 'isPaid': isPaid, 'data': response};
    } catch (e) {
      return {'success': false, 'message': 'Gagal check status: ${e.toString()}', 'status': 'unknown', 'isPaid': false};
    }
  }

  /// Wait for payment completion
  ///
  /// Polls transaction status until payment is completed, failed, or timeout
  ///
  /// [transactionId] - Transaction to monitor
  /// [timeoutSeconds] - Maximum wait time (default: 300 = 5 minutes)
  /// [pollIntervalSeconds] - Time between checks (default: 5 seconds)
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  /// - status: String
  /// - isPaid: bool
  Future<Map<String, dynamic>> waitForPayment(String transactionId, {int timeoutSeconds = 300, int pollIntervalSeconds = 5}) async {
    final startTime = DateTime.now();
    final timeout = Duration(seconds: timeoutSeconds);
    final pollInterval = Duration(seconds: pollIntervalSeconds);

    while (DateTime.now().difference(startTime) < timeout) {
      final result = await checkStatus(transactionId);

      if (!result['success']) {
        return result;
      }

      final status = result['status'] as String;

      // Check for terminal states
      if (status == 'success' || status == 'completed') {
        return {'success': true, 'message': 'Pembayaran berhasil', 'status': status, 'isPaid': true, 'data': result['data']};
      } else if (status == 'failed' || status == 'expired' || status == 'cancelled') {
        return {'success': false, 'message': 'Pembayaran gagal atau dibatalkan', 'status': status, 'isPaid': false};
      }

      // Wait before next poll
      await Future.delayed(pollInterval);
    }

    // Timeout reached
    return {'success': false, 'message': 'Timeout menunggu pembayaran', 'status': 'timeout', 'isPaid': false};
  }

  // ============================================
  // TRANSACTION HISTORY
  // ============================================

  /// Get top-up transaction history
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String (if error)
  /// - data: List<TopupTransaction>
  Future<Map<String, dynamic>> getHistory() async {
    try {
      final transactions = await _apiService.topup.getTransactionHistory();

      return {'success': true, 'data': transactions};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil history: ${e.toString()}', 'data': <TopupTransaction>[]};
    }
  }

  /// Get pending transactions from history
  Future<Map<String, dynamic>> getPendingTransactions() async {
    final result = await getHistory();
    if (!result['success']) {
      return result;
    }

    final transactions = result['data'] as List<TopupTransaction>;
    final pending = transactions.where((t) => t.isPending).toList();

    return {'success': true, 'data': pending};
  }

  /// Get completed transactions from history
  Future<Map<String, dynamic>> getCompletedTransactions() async {
    final result = await getHistory();
    if (!result['success']) {
      return result;
    }

    final transactions = result['data'] as List<TopupTransaction>;
    final completed = transactions.where((t) => t.isSuccess).toList();

    return {'success': true, 'data': completed};
  }

  // ============================================
  // CANCEL TRANSACTION
  // ============================================

  /// Cancel pending top-up transaction
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  Future<Map<String, dynamic>> cancelTransaction(String transactionId) async {
    try {
      await _apiService.topup.cancelTransaction(transactionId);

      return {'success': true, 'message': 'Transaksi berhasil dibatalkan'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal membatalkan transaksi: ${e.toString()}'};
    }
  }

  // ============================================
  // CALCULATE TOTAL
  // ============================================

  /// Calculate total amount for top-up (client-side estimation)
  ///
  /// Note: This is a client-side calculation. Actual amount is determined by backend.
  ///
  /// Returns map with:
  /// - success: bool
  /// - tokenCount: int
  /// - pricePerToken: double
  /// - subtotal: double
  /// - total: double
  Future<Map<String, dynamic>> calculateTotal({
    required int tokenCount,
    double pricePerToken = 3000.0, // Default Rp 3.000 per token
  }) async {
    try {
      final subtotal = tokenCount * pricePerToken;

      return {'success': true, 'tokenCount': tokenCount, 'pricePerToken': pricePerToken, 'subtotal': subtotal, 'total': subtotal};
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghitung total: ${e.toString()}'};
    }
  }
}
