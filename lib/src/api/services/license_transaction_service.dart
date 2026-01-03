import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/license_models.dart';
import '../models/license_transaction_models.dart';
import '../exceptions/api_exceptions.dart';

/// License Transaction Service
///
/// Provides methods for license purchase and subscription operations:
/// - Get user's license transactions
/// - Get user's licenses with device info
/// - Initiate purchase payment (for buy type)
/// - Initiate subscription payment (for rent type)
class KgitonLicenseTransactionService {
  final KgitonApiClient _client;

  KgitonLicenseTransactionService(this._client);

  // ============================================================================
  // USER ENDPOINTS
  // ============================================================================

  /// Get logged-in user's license transactions
  ///
  /// Returns list of [LicenseTransaction] for the authenticated user
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<List<LicenseTransaction>> getMyTransactions() async {
    final response = await _client.get<List<LicenseTransaction>>(
      KgitonApiEndpoints.myLicenseTransactions,
      requiresAuth: true,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((e) => LicenseTransaction.fromJson(e as Map<String, dynamic>)).toList();
        }
        if (json is Map<String, dynamic>) {
          final transactions = json['transactions'] as List? ?? json['data'] as List? ?? [];
          return transactions.map((e) => LicenseTransaction.fromJson(e as Map<String, dynamic>)).toList();
        }
        throw KgitonApiException(message: 'Invalid response format for license transactions');
      },
    );

    if (!response.success) {
      throw KgitonApiException(message: 'Failed to get license transactions: ${response.message}');
    }

    return response.data ?? [];
  }

  /// Get logged-in user's licenses with device and payment info
  ///
  /// Returns list of [LicenseKey] with full details
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<List<LicenseKey>> getMyLicenses() async {
    final response = await _client.get<List<LicenseKey>>(
      KgitonApiEndpoints.myLicenses,
      requiresAuth: true,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((e) => LicenseKey.fromJson(e as Map<String, dynamic>)).toList();
        }
        if (json is Map<String, dynamic>) {
          final licenses = json['licenses'] as List? ?? json['data'] as List? ?? [];
          return licenses.map((e) => LicenseKey.fromJson(e as Map<String, dynamic>)).toList();
        }
        throw KgitonApiException(message: 'Invalid response format for licenses');
      },
    );

    if (!response.success) {
      throw KgitonApiException(message: 'Failed to get licenses: ${response.message}');
    }

    return response.data ?? [];
  }

  /// Initiate license purchase payment (for buy type)
  ///
  /// [licenseKey] - The license key to purchase
  /// [paymentMethod] - Payment method (default: checkout_page)
  /// [customerPhone] - Optional customer phone number
  ///
  /// Returns [InitiatePaymentResponse] with payment URL or VA number
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if license key is invalid or not buy type
  /// - [KgitonApiException] for other errors
  Future<InitiatePaymentResponse> initiatePurchase({required String licenseKey, String? paymentMethod, String? customerPhone}) async {
    final request = InitiatePaymentRequest(licenseKey: licenseKey, paymentMethod: paymentMethod, customerPhone: customerPhone);

    final response = await _client.post<InitiatePaymentResponse>(
      KgitonApiEndpoints.initiatePurchase,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => InitiatePaymentResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to initiate purchase: ${response.message}');
    }

    return response.data!;
  }

  /// Initiate license subscription payment (for rent type)
  ///
  /// [licenseKey] - The license key to subscribe
  /// [paymentMethod] - Payment method (default: checkout_page)
  /// [customerPhone] - Optional customer phone number
  ///
  /// Returns [InitiatePaymentResponse] with payment URL or VA number
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if license key is invalid or not rent type
  /// - [KgitonApiException] for other errors
  Future<InitiatePaymentResponse> initiateSubscription({required String licenseKey, String? paymentMethod, String? customerPhone}) async {
    final request = InitiatePaymentRequest(licenseKey: licenseKey, paymentMethod: paymentMethod, customerPhone: customerPhone);

    final response = await _client.post<InitiatePaymentResponse>(
      KgitonApiEndpoints.initiateSubscription,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => InitiatePaymentResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to initiate subscription: ${response.message}');
    }

    return response.data!;
  }
}
