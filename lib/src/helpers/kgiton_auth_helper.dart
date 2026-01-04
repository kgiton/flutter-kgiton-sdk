import 'package:shared_preferences/shared_preferences.dart';
import '../api/kgiton_api_service.dart';
import '../api/models/auth_models.dart';
import '../utils/debug_logger.dart';

/// Helper service untuk authentication dan session management
///
/// Menyediakan fungsi-fungsi umum untuk:
/// - Login/Register/Logout
/// - Token management (save/load/clear)
/// - User info storage
/// - API key management
/// - Automatic token injection ke API client
///
/// Example:
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// final auth = KgitonAuthHelper(prefs, baseUrl: 'https://api.kgiton.com');
///
/// // Register with license key
/// final regResult = await auth.register(
///   email: 'user@example.com',
///   password: 'password123',
///   name: 'John Doe',
///   licenseKey: 'YOUR-LICENSE-KEY',
/// );
///
/// // Login
/// final result = await auth.login('user@example.com', 'password');
/// if (result['success']) {
///   print('Logged in as: ${auth.getUserEmail()}');
///   print('API Key: ${auth.getApiKey()}');
/// }
///
/// // Check login status
/// if (await auth.isLoggedIn()) {
///   final api = auth.getAuthenticatedApiService();
///   // Use authenticated API
/// }
///
/// // Logout
/// await auth.logout();
/// ```
class KgitonAuthHelper {
  // Storage keys
  static const String _tokenKey = 'kgiton_access_token';
  static const String _tokenExpiresAtKey = 'kgiton_token_expires_at';
  static const String _apiKeyKey = 'kgiton_api_key';
  static const String _userIdKey = 'kgiton_user_id';
  static const String _userEmailKey = 'kgiton_user_email';
  static const String _userNameKey = 'kgiton_user_name';
  static const String _referralCodeKey = 'kgiton_referral_code';

  final SharedPreferences _prefs;
  final KgitonApiService _apiService;

  /// Create auth helper instance with new API service
  ///
  /// [prefs] - SharedPreferences instance for token storage
  /// [baseUrl] - API base URL
  KgitonAuthHelper(this._prefs, {required String baseUrl}) : _apiService = KgitonApiService(baseUrl: baseUrl);

  /// Create auth helper instance with existing API service
  ///
  /// Use this constructor when you want to share the same API service instance
  /// across multiple helpers (e.g., LicenseHelper, TopupHelper).
  /// This ensures that tokens set after login are automatically available
  /// to all services using the same API service instance.
  ///
  /// [prefs] - SharedPreferences instance for token storage
  /// [apiService] - Existing KgitonApiService instance to reuse
  KgitonAuthHelper.withApiService(this._prefs, this._apiService);

  // ============================================
  // LOGIN STATUS
  // ============================================

  /// Check if user is logged in (has valid token)
  Future<bool> isLoggedIn() async {
    final token = getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    // Check token expiration
    final expiresAt = getTokenExpiresAt();
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      // Token expired, clear it
      await _clearTokens();
      return false;
    }

    return true;
  }

  // ============================================
  // TOKEN MANAGEMENT
  // ============================================

  /// Get stored access token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  /// Get token expiration date
  DateTime? getTokenExpiresAt() {
    final expiresAtStr = _prefs.getString(_tokenExpiresAtKey);
    if (expiresAtStr != null) {
      return DateTime.tryParse(expiresAtStr);
    }
    return null;
  }

  /// Get stored API key
  String? getApiKey() {
    return _prefs.getString(_apiKeyKey);
  }

  /// Save auth data to storage
  Future<void> _saveAuthData(AuthData authData) async {
    await _prefs.setString(_tokenKey, authData.accessToken);

    // Calculate expiration from session.expiresAt (unix timestamp in seconds)
    final expiresAtDateTime = DateTime.fromMillisecondsSinceEpoch(authData.session.expiresAt * 1000);
    await _prefs.setString(_tokenExpiresAtKey, expiresAtDateTime.toIso8601String());

    await _prefs.setString(_userIdKey, authData.user.id);
    await _prefs.setString(_userEmailKey, authData.user.email);
    await _prefs.setString(_userNameKey, authData.user.name);
    await _prefs.setString(_apiKeyKey, authData.user.apiKey);
    await _prefs.setString(_referralCodeKey, authData.user.referralCode);
  }

  /// Clear all stored tokens and user data
  Future<void> _clearTokens() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_tokenExpiresAtKey);
    await _prefs.remove(_apiKeyKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_referralCodeKey);
  }

  // ============================================
  // USER INFO
  // ============================================

  /// Get stored user ID
  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  /// Get stored user email
  String? getUserEmail() {
    return _prefs.getString(_userEmailKey);
  }

  /// Get stored user name
  String? getUserName() {
    return _prefs.getString(_userNameKey);
  }

  /// Get stored referral code
  String? getReferralCode() {
    return _prefs.getString(_referralCodeKey);
  }

  // ============================================
  // AUTHENTICATION
  // ============================================

  /// Login with email and password
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  /// - data: AuthData (if success)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      DebugLogger.logAuth('Login attempt', details: 'Email: $email');

      final authData = await _apiService.auth.login(email: email, password: password);

      // Save tokens and user info
      await _saveAuthData(authData);

      // Inject token and API key to API client for future requests
      _apiService.setAccessToken(authData.accessToken);
      _apiService.setApiKey(authData.user.apiKey);

      DebugLogger.logAuth('Login successful', details: 'User: ${authData.user.name}');
      return {'success': true, 'message': 'Login berhasil', 'data': authData};
    } catch (e, stackTrace) {
      DebugLogger.logError('Login failed', error: e, stackTrace: stackTrace);
      return {'success': false, 'message': 'Login gagal: ${e.toString()}'};
    }
  }

  /// Register new user with license key
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String licenseKey,
    String? referralCode,
  }) async {
    try {
      final message = await _apiService.auth.register(
        email: email,
        password: password,
        name: name,
        licenseKey: licenseKey,
        referralCode: referralCode,
      );

      return {'success': true, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Registrasi gagal: ${e.toString()}'};
    }
  }

  /// Logout (clear all stored data and call API logout)
  Future<Map<String, dynamic>> logout() async {
    try {
      // Call API logout to invalidate session
      await _apiService.auth.logout();

      // Clear local storage
      await _clearTokens();

      // Clear tokens from API client
      _apiService.clearCredentials();

      return {'success': true, 'message': 'Logout berhasil'};
    } catch (e) {
      // Still clear local storage even if API call fails
      await _clearTokens();
      _apiService.clearCredentials();

      return {'success': true, 'message': 'Logout berhasil (offline)'};
    }
  }

  /// Request password reset email
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      await _apiService.auth.forgotPassword(email: email);
      return {'success': true, 'message': 'Email reset password telah dikirim'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengirim email reset: ${e.toString()}'};
    }
  }

  /// Reset password with token
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  Future<Map<String, dynamic>> resetPassword({required String token, required String newPassword}) async {
    try {
      await _apiService.auth.resetPassword(token: token, newPassword: newPassword);
      return {'success': true, 'message': 'Password berhasil direset'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal reset password: ${e.toString()}'};
    }
  }

  // ============================================
  // API SERVICE
  // ============================================

  /// Get authenticated API service instance
  ///
  /// Automatically injects stored token for authenticated requests
  ///
  /// Returns null if not logged in
  KgitonApiService? getAuthenticatedApiService() {
    final token = getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    // Check token expiration
    final expiresAt = getTokenExpiresAt();
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      return null;
    }

    _apiService.setAccessToken(token);

    final apiKey = getApiKey();
    if (apiKey != null) {
      _apiService.setApiKey(apiKey);
    }

    return _apiService;
  }

  /// Get API service (even if not logged in)
  ///
  /// Use this for public endpoints that don't require authentication
  KgitonApiService getApiService() {
    final token = getToken();
    if (token != null && token.isNotEmpty) {
      _apiService.setAccessToken(token);
    }

    final apiKey = getApiKey();
    if (apiKey != null) {
      _apiService.setApiKey(apiKey);
    }

    return _apiService;
  }

  // ============================================
  // API KEY MANAGEMENT
  // ============================================

  /// Regenerate API key
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  /// - apiKey: String (if success)
  Future<Map<String, dynamic>> regenerateApiKey() async {
    try {
      final newApiKey = await _apiService.user.regenerateApiKey();

      // Save new API key
      await _prefs.setString(_apiKeyKey, newApiKey);

      // Update API client
      _apiService.setApiKey(newApiKey);

      return {'success': true, 'message': 'API key berhasil diperbarui', 'apiKey': newApiKey};
    } catch (e) {
      return {'success': false, 'message': 'Gagal regenerate API key: ${e.toString()}'};
    }
  }

  /// Revoke API key
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  Future<Map<String, dynamic>> revokeApiKey() async {
    try {
      await _apiService.user.revokeApiKey();

      // Remove API key from storage
      await _prefs.remove(_apiKeyKey);

      // Clear API key from client
      _apiService.setApiKey(null);

      return {'success': true, 'message': 'API key berhasil direvoke'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal revoke API key: ${e.toString()}'};
    }
  }

  // ============================================
  // RESTORE SESSION
  // ============================================

  /// Restore session from stored tokens
  ///
  /// Call this on app startup to restore previous session
  Future<bool> restoreSession() async {
    final isLogged = await isLoggedIn();
    if (!isLogged) {
      return false;
    }

    final token = getToken();
    final apiKey = getApiKey();

    _apiService.setAccessToken(token);
    if (apiKey != null) {
      _apiService.setApiKey(apiKey);
    }

    return true;
  }
}
