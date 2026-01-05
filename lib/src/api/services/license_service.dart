import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/license_models.dart';
import '../exceptions/api_exceptions.dart';

/// License Service for Client SDK
///
/// Provides methods for license validation.
/// This is a client-only SDK - admin operations are in flutter-admin-kgiton-sdk.
class KgitonLicenseService {
  final KgitonApiClient _client;

  KgitonLicenseService(this._client);

  /// Validate license key
  ///
  /// [licenseKey] - The license key to validate
  ///
  /// Returns [ValidateLicenseResponse] with validation result including:
  /// - exists: whether the license key exists
  /// - is_valid: whether the license is active/trial
  /// - is_assigned: whether it's already assigned to a user
  /// - Basic license info (status, balance, device info, etc.)
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if license key not found
  /// - [KgitonApiException] for other errors
  Future<ValidateLicenseResponse> validateLicense(String licenseKey) async {
    final response = await _client.get<ValidateLicenseResponse>(
      KgitonApiEndpoints.validateLicense(licenseKey),
      requiresAuth: true,
      fromJsonT: (json) => ValidateLicenseResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to validate license: ${response.message}');
    }

    return response.data!;
  }
}
