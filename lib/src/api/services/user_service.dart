import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/license_models.dart';
import '../models/license_transaction_models.dart';
import '../exceptions/api_exceptions.dart';

/// User Service
///
/// Provides methods for user operations:
/// - Get user profile
/// - Get token balance
/// - Use token
/// - Assign additional license
/// - API key management
class KgitonUserService {
  final KgitonApiClient _client;

  KgitonUserService(this._client);

  /// Get user profile with all license keys
  ///
  /// Returns [UserProfileData] containing user info and all owned license keys
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<UserProfileData> getProfile() async {
    final response = await _client.get<UserProfileData>(
      KgitonApiEndpoints.userProfile,
      requiresAuth: true,
      fromJsonT: (json) => UserProfileData.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to get user profile: ${response.message}');
    }

    return response.data!;
  }

  /// Get token balance from all license keys
  ///
  /// Returns [TokenBalanceData] containing all license keys with their balances
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<TokenBalanceData> getTokenBalance() async {
    final response = await _client.get<TokenBalanceData>(
      KgitonApiEndpoints.tokenBalance,
      requiresAuth: true,
      fromJsonT: (json) => TokenBalanceData.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to get token balance: ${response.message}');
    }

    return response.data!;
  }

  /// Use 1 token from a license key
  ///
  /// [licenseKey] - The license key to use token from
  /// [purpose] - Optional purpose description
  /// [metadata] - Optional additional data
  ///
  /// Returns [UseTokenResponse] with previous and new balance
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if token balance is 0
  /// - [KgitonNotFoundException] if license key not found
  /// - [KgitonApiException] for other errors
  Future<UseTokenResponse> useToken(String licenseKey, {String? purpose, Map<String, dynamic>? metadata}) async {
    final request = UseTokenRequest(purpose: purpose, metadata: metadata);

    final response = await _client.post<UseTokenResponse>(
      KgitonApiEndpoints.useToken(licenseKey),
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => UseTokenResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to use token: ${response.message}');
    }

    return response.data!;
  }

  /// Assign additional license key to user
  ///
  /// [licenseKey] - The license key to assign
  ///
  /// Returns the assigned [LicenseKey]
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if license key is invalid
  /// - [KgitonConflictException] if license already assigned to another user
  /// - [KgitonApiException] for other errors
  Future<LicenseKey> assignLicense(String licenseKey) async {
    final request = AssignLicenseRequest(licenseKey: licenseKey);

    final response = await _client.post<LicenseKey>(
      KgitonApiEndpoints.assignLicense,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => LicenseKey.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to assign license: ${response.message}');
    }

    return response.data!;
  }

  /// Regenerate API key
  ///
  /// Generates a new API key and invalidates the old one
  ///
  /// Returns the new API key string
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<String> regenerateApiKey() async {
    final response = await _client.post<Map<String, dynamic>>(
      KgitonApiEndpoints.regenerateApiKey,
      requiresAuth: true,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to regenerate API key: ${response.message}');
    }

    final newApiKey = response.data!['api_key'] as String;

    // Update client with new API key
    _client.setApiKey(newApiKey);
    await _client.saveConfiguration();

    return newApiKey;
  }

  /// Revoke API key
  ///
  /// Invalidates the current API key
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<void> revokeApiKey() async {
    final response = await _client.post<void>(KgitonApiEndpoints.revokeApiKey, requiresAuth: true);

    if (!response.success) {
      throw KgitonApiException(message: 'Failed to revoke API key: ${response.message}');
    }

    // Clear API key from client
    _client.setApiKey(null);
    await _client.saveConfiguration();
  }
}
