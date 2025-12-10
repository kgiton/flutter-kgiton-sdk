import '../api/kgiton_api_service.dart';

/// Helper service untuk license management operations
///
/// Simplified wrapper untuk license-related operations dengan:
/// - Consistent return format
/// - Error handling
/// - Easy-to-use API
///
/// Example:
/// ```dart
/// final apiService = KgitonApiService(baseUrl: 'https://api.example.com');
/// final license = KgitonLicenseHelper(apiService);
///
/// // Get all licenses for current owner
/// final result = await license.getMyLicenses();
/// if (result['success']) {
///   for (var lic in result['data']) {
///     print('License: ${lic['license_key']} - ${lic['status']}');
///   }
/// }
///
/// // Validate license
/// final isValid = await license.validateLicense('ABC123');
/// if (isValid) {
///   print('License is valid');
/// }
///
/// // Assign new license
/// final assigned = await license.assignLicense('NEW123');
/// if (assigned['success']) {
///   print('License assigned successfully');
/// }
/// ```
class KgitonLicenseHelper {
  final KgitonApiService _apiService;

  /// Create license helper instance
  ///
  /// [apiService] - Authenticated KgitonApiService instance
  KgitonLicenseHelper(this._apiService);

  // ============================================
  // GET LICENSES
  // ============================================

  /// Get all licenses owned by current user
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String (if error)
  /// - data: List<Map> with license info:
  ///   - license_key: String
  ///   - status: String ('active', 'inactive', 'expired')
  ///   - device_name: String
  ///   - expiry_date: DateTime?
  Future<Map<String, dynamic>> getMyLicenses() async {
    try {
      final licensesData = await _apiService.owner.listOwnLicenses();

      // Convert to simple map format
      final licenses = licensesData.licenses.map((license) {
        return {
          'license_key': license.licenseKey,
          'status': 'active', // All owner licenses are active
          'device_name': 'KGiTON Scale',
          'expiry_date': null, // Add expiry date if available in backend
        };
      }).toList();

      return {'success': true, 'data': licenses};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil licenses: ${e.toString()}', 'data': <Map<String, dynamic>>[]};
    }
  }

  /// Get license details by license key
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String (if error)
  /// - data: Map with license info (if success)
  Future<Map<String, dynamic>> getLicenseDetails(String licenseKey) async {
    try {
      final licenses = await getMyLicenses();
      if (!licenses['success']) {
        return licenses;
      }

      final data = licenses['data'] as List<Map<String, dynamic>>;
      final license = data.firstWhere((l) => l['license_key'] == licenseKey, orElse: () => {});

      if (license.isEmpty) {
        return {'success': false, 'message': 'License tidak ditemukan'};
      }

      return {'success': true, 'data': license};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil detail license: ${e.toString()}'};
    }
  }

  // ============================================
  // VALIDATE LICENSE
  // ============================================

  /// Validate if license exists and owned by current user
  ///
  /// Returns true if license is valid and active
  Future<bool> validateLicense(String licenseKey) async {
    try {
      final result = await getMyLicenses();
      if (!result['success']) {
        return false;
      }

      final licenses = result['data'] as List<Map<String, dynamic>>;
      return licenses.any((l) => l['license_key'] == licenseKey && l['status'] == 'active');
    } catch (e) {
      return false;
    }
  }

  /// Check if user has at least one active license
  Future<bool> hasActiveLicense() async {
    try {
      final result = await getMyLicenses();
      if (!result['success']) {
        return false;
      }

      final licenses = result['data'] as List<Map<String, dynamic>>;
      return licenses.any((l) => l['status'] == 'active');
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // ASSIGN LICENSE
  // ============================================

  /// Assign new license to current owner
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  Future<Map<String, dynamic>> assignLicense(String licenseKey) async {
    try {
      await _apiService.owner.assignAdditionalLicense(licenseKey);
      return {'success': true, 'message': 'License berhasil ditambahkan'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal menambahkan license: ${e.toString()}'};
    }
  }

  // ============================================
  // LICENSE COUNT
  // ============================================

  /// Get total number of licenses owned
  Future<int> getLicenseCount() async {
    try {
      final result = await getMyLicenses();
      if (!result['success']) {
        return 0;
      }

      final licenses = result['data'] as List<Map<String, dynamic>>;
      return licenses.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get number of active licenses
  Future<int> getActiveLicenseCount() async {
    try {
      final result = await getMyLicenses();
      if (!result['success']) {
        return 0;
      }

      final licenses = result['data'] as List<Map<String, dynamic>>;
      return licenses.where((l) => l['status'] == 'active').length;
    } catch (e) {
      return 0;
    }
  }
}
