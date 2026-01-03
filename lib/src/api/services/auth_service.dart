import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/auth_models.dart';

/// Authentication Service
///
/// Provides methods for user authentication including:
/// - Registration with license key
/// - Login
/// - Logout
/// - Password reset
class KgitonAuthService {
  final KgitonApiClient _client;

  KgitonAuthService(this._client);

  /// Register a new user with license key
  ///
  /// [email] - User's email address
  /// [password] - Password (minimum 6 characters)
  /// [name] - User's full name
  /// [licenseKey] - Valid license key (must have confirmed payment)
  /// [referralCode] - Optional referral code
  ///
  /// Returns success message. User needs to verify email before login.
  ///
  /// Throws:
  /// - [KgitonValidationException] if validation fails
  /// - [KgitonConflictException] if email already exists
  /// - [KgitonApiException] for other errors
  Future<String> register({
    required String email,
    required String password,
    required String name,
    required String licenseKey,
    String? referralCode,
  }) async {
    final request = RegisterRequest(email: email, password: password, name: name, licenseKey: licenseKey, referralCode: referralCode);

    final response = await _client.post<void>(KgitonApiEndpoints.register, body: request.toJson(), requiresAuth: false);

    if (!response.success) {
      throw Exception('Registration failed: ${response.message}');
    }

    return response.message;
  }

  /// Login user
  ///
  /// [email] - User's email address
  /// [password] - User's password
  ///
  /// Returns [AuthData] containing user info and session tokens
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if credentials are invalid or email not verified
  /// - [KgitonApiException] for other errors
  Future<AuthData> login({required String email, required String password}) async {
    final request = LoginRequest(email: email, password: password);

    final response = await _client.post<AuthData>(
      KgitonApiEndpoints.login,
      body: request.toJson(),
      requiresAuth: false,
      fromJsonT: (json) => AuthData.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Login failed: ${response.message}');
    }

    final authData = response.data!;

    // Save tokens and API key to client
    _client.setAccessToken(authData.accessToken);
    _client.setApiKey(authData.user.apiKey);
    await _client.saveConfiguration();

    return authData;
  }

  /// Logout user
  ///
  /// Clears local tokens and invalidates session on server
  Future<void> logout() async {
    try {
      await _client.post<void>(KgitonApiEndpoints.logout, requiresAuth: true);
    } finally {
      // Always clear local tokens even if server request fails
      _client.clearCredentials();
      await _client.clearConfiguration();
    }
  }

  /// Check if user is authenticated
  ///
  /// Returns true if access token or API key is available
  bool isAuthenticated() {
    return _client.hasAccessToken() || _client.hasApiKey();
  }

  /// Get current access token
  String? getAccessToken() {
    return _client.accessToken;
  }

  /// Get current API key
  String? getApiKey() {
    return _client.apiKey;
  }

  /// Request password reset via email
  ///
  /// [email] - User's email address
  ///
  /// Sends a password reset link to the provided email if it exists.
  /// Always returns success to prevent email enumeration attacks.
  ///
  /// Throws:
  /// - [KgitonValidationException] if email format is invalid
  /// - [KgitonApiException] for other errors
  Future<void> forgotPassword({required String email}) async {
    final request = ForgotPasswordRequest(email: email);

    final response = await _client.post<void>(KgitonApiEndpoints.forgotPassword, body: request.toJson(), requiresAuth: false);

    if (!response.success) {
      throw Exception('Failed to request password reset: ${response.message}');
    }
  }

  /// Reset password using token from email
  ///
  /// [token] - Reset token received via email
  /// [newPassword] - New password (minimum 6 characters)
  ///
  /// Throws:
  /// - [KgitonValidationException] if password is too short or token is invalid
  /// - [KgitonApiException] for other errors
  Future<void> resetPassword({required String token, required String newPassword}) async {
    final request = ResetPasswordRequest(token: token, newPassword: newPassword);

    final response = await _client.post<void>(KgitonApiEndpoints.resetPassword, body: request.toJson(), requiresAuth: false);

    if (!response.success) {
      throw Exception('Failed to reset password: ${response.message}');
    }
  }
}
