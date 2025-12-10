import 'package:shared_preferences/shared_preferences.dart';
import '../api/kgiton_api_service.dart';
import '../api/models/auth_models.dart' show AuthData;

/// Helper service untuk authentication dan session management
///
/// Menyediakan fungsi-fungsi umum untuk:
/// - Login/Register/Logout
/// - Token management (save/load/clear)
/// - User info storage
/// - Automatic token injection ke API client
///
/// Example:
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// final auth = KgitonAuthHelper(prefs, baseUrl: 'https://api.example.com');
///
/// // Login
/// final result = await auth.login('user@example.com', 'password');
/// if (result.success) {
///   print('Logged in as: ${auth.getUserEmail()}');
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
  static const String _refreshTokenKey = 'kgiton_refresh_token';
  static const String _ownerIdKey = 'kgiton_owner_id';
  static const String _userEmailKey = 'kgiton_user_email';
  static const String _userNameKey = 'kgiton_user_name';

  final SharedPreferences _prefs;
  final KgitonApiService _apiService;

  /// Create auth helper instance
  ///
  /// [prefs] - SharedPreferences instance for token storage
  /// [baseUrl] - API base URL
  /// [customStoragePrefix] - Optional custom prefix for storage keys (default: 'kgiton_')
  KgitonAuthHelper(this._prefs, {required String baseUrl, String? customStoragePrefix}) : _apiService = KgitonApiService(baseUrl: baseUrl);

  // ============================================
  // LOGIN STATUS
  // ============================================

  /// Check if user is logged in (has valid token)
  Future<bool> isLoggedIn() async {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================
  // TOKEN MANAGEMENT
  // ============================================

  /// Get stored access token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  /// Get stored refresh token
  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  /// Save tokens to storage
  Future<void> _saveTokens(AuthData authData) async {
    await _prefs.setString(_tokenKey, authData.accessToken);
    if (authData.refreshToken != null) {
      await _prefs.setString(_refreshTokenKey, authData.refreshToken!);
    }
    await _prefs.setString(_ownerIdKey, authData.user.id);
    await _prefs.setString(_userEmailKey, authData.user.email);
    // Note: User model doesn't have name field, only email
    await _prefs.setString(_userNameKey, authData.user.email.split('@')[0]);
  }

  /// Clear all stored tokens and user data
  Future<void> _clearTokens() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_ownerIdKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userNameKey);
  }

  // ============================================
  // USER INFO
  // ============================================

  /// Get stored owner ID
  String? getOwnerId() {
    return _prefs.getString(_ownerIdKey);
  }

  /// Get stored user email
  String? getUserEmail() {
    return _prefs.getString(_userEmailKey);
  }

  /// Get stored user name
  String? getUserName() {
    return _prefs.getString(_userNameKey);
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
      final authData = await _apiService.auth.login(email: email, password: password);

      // Save tokens and user info
      await _saveTokens(authData);

      // Inject token to API client for future requests
      _apiService.client.setTokens(accessToken: authData.accessToken);

      return {'success': true, 'message': 'Login berhasil', 'data': authData};
    } catch (e) {
      return {'success': false, 'message': 'Login gagal: ${e.toString()}'};
    }
  }

  /// Register owner account
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String licenseKey,
    required String entityType, // 'individual' or 'company'
  }) async {
    try {
      await _apiService.auth.registerOwner(name: name, email: email, password: password, licenseKey: licenseKey, entityType: entityType);

      return {'success': true, 'message': 'Registrasi berhasil. Silakan login.'};
    } catch (e) {
      return {'success': false, 'message': 'Registrasi gagal: ${e.toString()}'};
    }
  }

  /// Logout (clear all stored data)
  Future<void> logout() async {
    await _clearTokens();
    // Note: Tidak perlu call API logout karena token-based
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

    _apiService.client.setTokens(accessToken: token);
    return _apiService;
  }

  /// Get API service (even if not logged in)
  ///
  /// Use this for public endpoints that don't require authentication
  KgitonApiService getApiService() {
    final token = getToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.setTokens(accessToken: token);
    }
    return _apiService;
  }

  // ============================================
  // TOKEN REFRESH (if backend supports)
  // ============================================

  /// Refresh access token using refresh token
  ///
  /// Note: This depends on backend implementation
  /// Returns new access token if successful
  Future<String?> refreshAccessToken() async {
    final refreshToken = getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      // Note: Implement this if backend supports token refresh
      // final newToken = await _apiService.auth.refreshToken(refreshToken);
      // await _prefs.setString(_tokenKey, newToken);
      // return newToken;

      // For now, return null (not implemented)
      return null;
    } catch (e) {
      return null;
    }
  }
}
