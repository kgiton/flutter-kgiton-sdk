import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/partner_payment_models.dart';
import '../exceptions/api_exceptions.dart';

/// Partner Payment Service
///
/// Allows partners to generate payments for their own transactions
/// using KGiTON's payment gateway.
///
/// This service requires API key authentication (x-api-key header).
///
/// Payment Types:
/// - QRIS: Generate QRIS QR code for payment (expires in 30 minutes by default)
/// - Checkout Page: Generate URL to Winpay checkout page (expires in 120 minutes by default)
class KgitonPartnerPaymentService {
  final KgitonApiClient _client;

  KgitonPartnerPaymentService(this._client);

  /// Generate payment (QRIS or Checkout Page)
  ///
  /// Creates a payment request for partner transactions using KGiTON's
  /// payment gateway. This will deduct 1 token from the license key balance.
  ///
  /// [request] - Partner payment request containing transaction details
  ///
  /// Returns [PartnerPaymentResponse] with payment URL or QRIS data
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if API key is invalid
  /// - [KgitonPaymentRequiredException] if token balance is insufficient
  /// - [KgitonForbiddenException] if license key is not active
  /// - [KgitonNotFoundException] if license key not found
  /// - [KgitonApiException] for other errors
  Future<PartnerPaymentResponse> generatePayment(PartnerPaymentRequest request) async {
    if (!request.isValid()) {
      throw KgitonValidationException(message: 'Invalid payment request: transaction_id, amount > 0, and license_key are required');
    }

    final response = await _client.post<PartnerPaymentResponse>(
      KgitonApiEndpoints.partnerPaymentGenerate,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => PartnerPaymentResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to generate payment: ${response.message}');
    }

    return response.data!;
  }

  /// Generate QRIS payment
  ///
  /// Shorthand for generating a QRIS payment.
  ///
  /// [transactionId] - Partner's unique transaction ID
  /// [amount] - Amount to charge in IDR
  /// [licenseKey] - KGiTON license key
  /// [description] - Optional transaction description
  /// [expiryMinutes] - Optional expiry in minutes (default 30)
  /// [webhookUrl] - Optional URL to receive payment status callback
  ///
  /// Returns [PartnerPaymentResponse] with QRIS data
  Future<PartnerPaymentResponse> generateQris({
    required String transactionId,
    required double amount,
    required String licenseKey,
    String? description,
    int? expiryMinutes,
    String? webhookUrl,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
  }) async {
    return generatePayment(
      PartnerPaymentRequest(
        transactionId: transactionId,
        amount: amount,
        licenseKey: licenseKey,
        paymentType: PartnerPaymentType.qris,
        description: description,
        expiryMinutes: expiryMinutes ?? 30,
        webhookUrl: webhookUrl,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
      ),
    );
  }

  /// Generate Checkout Page payment
  ///
  /// Shorthand for generating a checkout page payment.
  ///
  /// [transactionId] - Partner's unique transaction ID
  /// [amount] - Amount to charge in IDR
  /// [licenseKey] - KGiTON license key
  /// [description] - Optional transaction description
  /// [backUrl] - Optional URL to redirect after payment
  /// [expiryMinutes] - Optional expiry in minutes (default 120)
  /// [webhookUrl] - Optional URL to receive payment status callback
  ///
  /// Returns [PartnerPaymentResponse] with payment URL
  Future<PartnerPaymentResponse> generateCheckoutPage({
    required String transactionId,
    required double amount,
    required String licenseKey,
    String? description,
    String? backUrl,
    int? expiryMinutes,
    String? webhookUrl,
    List<PartnerPaymentItem>? items,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
  }) async {
    return generatePayment(
      PartnerPaymentRequest(
        transactionId: transactionId,
        amount: amount,
        licenseKey: licenseKey,
        paymentType: PartnerPaymentType.checkoutPage,
        description: description,
        backUrl: backUrl,
        expiryMinutes: expiryMinutes ?? 120,
        webhookUrl: webhookUrl,
        items: items,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
      ),
    );
  }
}
