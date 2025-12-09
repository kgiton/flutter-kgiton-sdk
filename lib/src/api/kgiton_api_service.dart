import 'kgiton_api_client.dart';
import 'services/auth_service.dart';
import 'services/owner_service.dart';
import 'services/transaction_service.dart';
import 'services/cart_service.dart';

/// Main API Service for KGiTON SDK
///
/// Provides centralized access to all API services:
/// - Authentication
/// - Owner Operations
/// - Transaction Management
/// - Shopping Cart
///
/// Example usage:
/// ```dart
/// final apiService = KgitonApiService(baseUrl: 'http://localhost:3000');
///
/// // Login
/// final authData = await apiService.auth.login(
///   email: 'owner@example.com',
///   password: 'password123',
/// );
///
/// // List items
/// final items = await apiService.owner.listItems('LICENSE-KEY');
///
/// // Add to cart
/// await apiService.cart.addItemToCart(
///   AddCartRequest(
///     licenseKey: 'LICENSE-KEY',
///     itemId: 'item-uuid',
///     quantity: 2.5,
///   ),
/// );
/// ```
class KgitonApiService {
  final KgitonApiClient _client;

  late final KgitonAuthService auth;
  late final KgitonOwnerService owner;
  late final KgitonTransactionService transaction;
  late final KgitonCartService cart;

  KgitonApiService({required String baseUrl, String? accessToken, String? refreshToken})
    : _client = KgitonApiClient(baseUrl: baseUrl, accessToken: accessToken, refreshToken: refreshToken) {
    _initializeServices();
  }

  /// Create instance with existing client
  KgitonApiService.withClient(KgitonApiClient client) : _client = client {
    _initializeServices();
  }

  void _initializeServices() {
    auth = KgitonAuthService(_client);
    owner = KgitonOwnerService(_client);
    transaction = KgitonTransactionService(_client);
    cart = KgitonCartService(_client);
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

  /// Set refresh token
  void setRefreshToken(String? token) {
    _client.setRefreshToken(token);
  }

  /// Set both tokens
  void setTokens({String? accessToken, String? refreshToken}) {
    _client.setTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  /// Clear all tokens
  void clearTokens() {
    _client.clearTokens();
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
