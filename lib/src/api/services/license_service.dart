import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/license_models.dart';
import '../exceptions/api_exceptions.dart';

/// License Service
///
/// Provides methods for license operations:
/// - Validate license key (public)
/// - Admin operations (for super admin users)
class KgitonLicenseService {
  final KgitonApiClient _client;

  KgitonLicenseService(this._client);

  // ============================================================================
  // PUBLIC ENDPOINTS
  // ============================================================================

  /// Validate license key (public endpoint)
  ///
  /// [licenseKey] - The license key to validate
  ///
  /// Returns [ValidateLicenseResponse] with validation result
  ///
  /// Note: This endpoint does not require authentication
  ///
  /// Throws:
  /// - [KgitonApiException] for errors
  Future<ValidateLicenseResponse> validateLicense(String licenseKey) async {
    final request = ValidateLicenseRequest(licenseKey: licenseKey);

    final response = await _client.post<ValidateLicenseResponse>(
      KgitonApiEndpoints.validateLicense,
      body: request.toJson(),
      requiresAuth: false,
      fromJsonT: (json) => ValidateLicenseResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to validate license: ${response.message}');
    }

    return response.data!;
  }
}
