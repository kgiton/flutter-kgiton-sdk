import 'kgiton_api_client.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/license_service.dart';
import 'services/topup_service.dart';
import 'services/license_transaction_service.dart';
import 'services/partner_payment_service.dart';

/// Main API Service for KGiTON SDK
///
/// Provides centralized access to all API services:
/// - Authentication (login, register, password reset)
/// - User (profile, token balance, use token)
/// - License (validate license)
/// - Top-up (purchase tokens)
/// - License Transactions (purchase/subscription)
/// - Partner Payment (generate QRIS/checkout page for partner transactions)
///
/// Example usage:
/// ```dart
/// final apiService = KgitonApiService(baseUrl: 'https://api.kgiton.com');
///
/// // Login
/// final authData = await apiService.auth.login(
///   email: 'user@example.com',
///   password: 'password123',
/// );
///
/// // Get profile
/// final profile = await apiService.user.getProfile();
///
/// // Use token
/// final result = await apiService.user.useToken('LICENSE-KEY-123');
///
/// // Top-up tokens
/// final topup = await apiService.topup.requestTopup(
///   tokenCount: 100,
///   licenseKey: 'LICENSE-KEY-123',
/// );
///
/// // Generate partner payment (QRIS)
/// final payment = await apiService.partnerPayment.generateQris(
///   transactionId: 'TRX-001',
///   amount: 50000,
///   licenseKey: 'LICENSE-KEY-123',
/// );
/// ```
class KgitonApiService {
  final KgitonApiClient _client;

  late final KgitonAuthService auth;
  late final KgitonUserService user;
  late final KgitonLicenseService license;
  late final KgitonTopupService topup;
  late final KgitonLicenseTransactionService licenseTransaction;
  late final KgitonPartnerPaymentService partnerPayment;

  KgitonApiService({required String baseUrl, String? accessToken, String? apiKey})
    : _client = KgitonApiClient(baseUrl: baseUrl, accessToken: accessToken, apiKey: apiKey) {
    _initializeServices();
  }

  /// Create instance with existing client
  KgitonApiService.withClient(KgitonApiClient client) : _client = client {
    _initializeServices();
  }

  void _initializeServices() {
    auth = KgitonAuthService(_client);
    user = KgitonUserService(_client);
    license = KgitonLicenseService(_client);
    topup = KgitonTopupService(_client);
    licenseTransaction = KgitonLicenseTransactionService(_client);
    partnerPayment = KgitonPartnerPaymentService(_client);
  }

  /// Get the underlying API client
  KgitonApiClient get client => _client;

  /// Set base URL
  void setBaseUrl(String url) {
    _client.setBaseUrl(url);
  }

  /// Get current base URL
  String get baseUrl => _client.baseUrl;

  /// Set access token
  void setAccessToken(String? token) {
    _client.setAccessToken(token);
  }

  /// Set API key
  void setApiKey(String? key) {
    _client.setApiKey(key);
  }

  /// Clear all credentials (tokens and API key)
  void clearCredentials() {
    _client.clearCredentials();
  }

  /// Save configuration to local storage
  Future<void> saveConfiguration() async {
    await _client.saveConfiguration();
  }

  /// Load configuration from local storage
  Future<void> loadConfiguration() async {
    await _client.loadConfiguration();
  }

  /// Clear saved configuration
  Future<void> clearConfiguration() async {
    await _client.clearConfiguration();
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return auth.isAuthenticated();
  }

  /// Dispose resources
  void dispose() {
    _client.dispose();
  }
}
