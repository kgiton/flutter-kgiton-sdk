import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/auth_models.dart';

/// Authentication Service
///
/// Provides methods for user authentication including:
/// - Owner registration
/// - Login
/// - Get current user info
/// - Logout
class KgitonAuthService {
  final KgitonApiClient _client;

  KgitonAuthService(this._client);

  /// Register a new owner with license key
  ///
  /// [email] - Owner's email address
  /// [password] - Password (minimum 6 characters)
  /// [licenseKey] - Valid license key in format: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
  /// [entityType] - Type of entity: 'individual' or 'company'
  /// [name] - Personal name (for individual) or company name (for company)
  ///
  /// Returns [AuthData] containing user info, profile, and tokens
  ///
  /// Throws:
  /// - [KgitonValidationException] if validation fails
  /// - [KgitonConflictException] if email already exists
  /// - [KgitonApiException] for other errors
  Future<AuthData> registerOwner({
    required String email,
    required String password,
    required String licenseKey,
    required String entityType,
    required String name,
  }) async {
    final request = RegisterOwnerRequest(email: email, password: password, licenseKey: licenseKey, entityType: entityType, name: name);

    final response = await _client.post<AuthData>(
      KgitonApiEndpoints.registerOwner,
      body: request.toJson(),
      requiresAuth: false,
      fromJsonT: (json) => AuthData.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Registration failed: ${response.message}');
    }

    // Save tokens to client
    _client.setTokens(accessToken: response.data!.accessToken, refreshToken: response.data!.refreshToken);
    await _client.saveConfiguration();

    return response.data!;
  }

  /// Login user (Owner only)
  ///
  /// [email] - User's email address
  /// [password] - User's password
  ///
  /// Returns [AuthData] containing user info, profile, and tokens
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if credentials are invalid
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

    // Save tokens to client
    _client.setTokens(accessToken: response.data!.accessToken, refreshToken: response.data!.refreshToken);
    await _client.saveConfiguration();

    return response.data!;
  }

  /// Get current authenticated user info
  ///
  /// Returns [CurrentUserData] containing user and profile information
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated or token expired
  /// - [KgitonApiException] for other errors
  Future<CurrentUserData> getCurrentUser() async {
    try {
      final response = await _client.get<CurrentUserData>(
        KgitonApiEndpoints.getCurrentUser,
        requiresAuth: true,
        fromJsonT: (json) {
          return CurrentUserData.fromJson(json);
        },
      );

      if (!response.success || response.data == null) {
        throw Exception('Failed to get current user: ${response.message}');
      }

      return response.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout user
  ///
  /// Clears local tokens and session
  Future<void> logout() async {
    _client.clearTokens();
    await _client.clearConfiguration();
  }

  /// Check if user is authenticated
  ///
  /// Returns true if access token is available
  bool isAuthenticated() {
    return _client.accessToken != null && _client.accessToken!.isNotEmpty;
  }

  /// Get current access token
  String? getAccessToken() {
    return _client.accessToken;
  }

  /// Get current refresh token
  String? getRefreshToken() {
    return _client.refreshToken;
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

  /// Change password for authenticated user
  ///
  /// [oldPassword] - Current password
  /// [newPassword] - New password (minimum 6 characters)
  ///
  /// Requires user to be authenticated.
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated or old password is incorrect
  /// - [KgitonValidationException] if new password is too short
  /// - [KgitonApiException] for other errors
  Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    final request = ChangePasswordRequest(oldPassword: oldPassword, newPassword: newPassword);

    final response = await _client.post<void>(KgitonApiEndpoints.changePassword, body: request.toJson(), requiresAuth: true);

    if (!response.success) {
      throw Exception('Failed to change password: ${response.message}');
    }
  }
}
