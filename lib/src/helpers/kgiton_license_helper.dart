import '../api/kgiton_api_service.dart';
import '../api/models/license_models.dart';
import '../api/models/license_transaction_models.dart';

/// Helper service untuk license management operations
///
/// Simplified wrapper untuk license-related operations dengan:
/// - Consistent return format
/// - Error handling
/// - Easy-to-use API
///
/// Example:
/// ```dart
/// final apiService = KgitonApiService(baseUrl: 'https://api.kgiton.com');
/// final license = KgitonLicenseHelper(apiService);
///
/// // Get all my licenses
/// final result = await license.getMyLicenses();
/// if (result['success']) {
///   for (var lic in result['data']) {
///     print('License: ${lic.licenseKey} - ${lic.status}');
///   }
/// }
///
/// // Validate license (public)
/// final validation = await license.validateLicense('ABC123');
/// if (validation['success']) {
///   print('License is valid: ${validation['data'].valid}');
/// }
///
/// // Get token balance for license
/// final balance = await license.getTokenBalance();
/// if (balance['success']) {
///   final data = balance['data'] as TokenBalanceData;
///   for (var lic in data.licenseKeys) {
///     print('${lic.licenseKey}: ${lic.tokenBalance} tokens');
///   }
/// }
///
/// // Use token
/// final useResult = await license.useToken('LICENSE-KEY');
/// if (useResult['success']) {
///   print('Remaining: ${useResult['remaining']} tokens');
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
  /// - data: List<LicenseTransaction> with license info
  Future<Map<String, dynamic>> getMyLicenses() async {
    try {
      final licenses = await _apiService.licenseTransaction.getMyLicenses();

      return {'success': true, 'data': licenses};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil licenses: ${e.toString()}', 'data': <LicenseTransaction>[]};
    }
  }

  /// Get license details by license key from user's licenses
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String (if error)
  /// - data: LicenseTransaction (if success)
  Future<Map<String, dynamic>> getLicenseDetails(String licenseKey) async {
    try {
      final result = await getMyLicenses();
      if (!result['success']) {
        return result;
      }

      final licenses = result['data'] as List<LicenseTransaction>;
      final license = licenses.firstWhere((l) => l.licenseKey == licenseKey, orElse: () => throw Exception('License tidak ditemukan'));

      return {'success': true, 'data': license};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil detail license: ${e.toString()}'};
    }
  }

  // ============================================
  // VALIDATE LICENSE
  // ============================================

  /// Validate license key
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  /// - data: ValidateLicenseResponse (if success)
  Future<Map<String, dynamic>> validateLicense(String licenseKey) async {
    try {
      final response = await _apiService.license.validateLicense(licenseKey);

      return {'success': true, 'message': response.isValid ? 'License valid' : 'License tidak valid', 'data': response};
    } catch (e) {
      return {'success': false, 'message': 'Gagal validasi license: ${e.toString()}'};
    }
  }

  /// Check if a specific license key is owned by current user
  ///
  /// Returns true if license is owned by user
  Future<bool> isMyLicense(String licenseKey) async {
    try {
      final result = await getMyLicenses();
      if (!result['success']) {
        return false;
      }

      final licenses = result['data'] as List<LicenseTransaction>;
      return licenses.any((l) => l.licenseKey == licenseKey);
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

      final licenses = result['data'] as List<LicenseTransaction>;
      return licenses.any((l) => l.status == 'active' || l.status == 'completed');
    } catch (e) {
      return false;
    }
  }

  /// Verify if the current user owns a specific license key
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  /// - isOwner: bool
  Future<Map<String, dynamic>> verifyLicenseOwnership(String licenseKey) async {
    try {
      final isOwned = await isMyLicense(licenseKey);

      if (!isOwned) {
        return {'success': false, 'message': 'Anda bukan pemilik sah dari license key ini', 'isOwner': false};
      }

      return {'success': true, 'message': 'Verifikasi kepemilikan berhasil', 'isOwner': true};
    } catch (e) {
      return {'success': false, 'message': 'Error saat verifikasi kepemilikan: ${e.toString()}', 'isOwner': false};
    }
  }

  // ============================================
  // TOKEN BALANCE
  // ============================================

  /// Get token balance for all user's licenses
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String (if error)
  /// - data: TokenBalanceData (if success)
  Future<Map<String, dynamic>> getTokenBalance() async {
    try {
      final balance = await _apiService.user.getTokenBalance();

      return {'success': true, 'data': balance};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil token balance: ${e.toString()}'};
    }
  }

  /// Get token balance for a specific license key
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String (if error)
  /// - balance: int - remaining token balance
  /// - data: LicenseKeyBalance (if success)
  Future<Map<String, dynamic>> getLicenseTokenBalance(String licenseKey) async {
    try {
      final result = await getTokenBalance();
      if (!result['success']) {
        return result;
      }

      final data = result['data'] as TokenBalanceData;
      final license = data.licenseKeys.firstWhere((l) => l.licenseKey == licenseKey, orElse: () => throw Exception('License tidak ditemukan'));

      return {'success': true, 'balance': license.tokenBalance, 'data': license};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil balance license: ${e.toString()}', 'balance': 0};
    }
  }

  // ============================================
  // USE TOKEN
  // ============================================

  /// Use 1 token from a license
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  /// - remaining: int - remaining tokens after use
  /// - data: UseTokenResponse (if success)
  Future<Map<String, dynamic>> useToken(String licenseKey) async {
    try {
      final response = await _apiService.user.useToken(licenseKey);

      return {'success': true, 'message': 'Token berhasil digunakan', 'remaining': response.newBalance, 'data': response};
    } catch (e) {
      return {'success': false, 'message': 'Gagal menggunakan token: ${e.toString()}', 'remaining': 0};
    }
  }

  // ============================================
  // ASSIGN LICENSE
  // ============================================

  /// Assign additional license to current user
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String
  /// - data: LicenseKey (if success)
  Future<Map<String, dynamic>> assignLicense(String licenseKey) async {
    try {
      final license = await _apiService.user.assignLicense(licenseKey);

      return {'success': true, 'message': 'License berhasil ditambahkan', 'data': license};
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

      final licenses = result['data'] as List<LicenseTransaction>;
      return licenses.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get number of active/completed licenses
  Future<int> getActiveLicenseCount() async {
    try {
      final result = await getMyLicenses();
      if (!result['success']) {
        return 0;
      }

      final licenses = result['data'] as List<LicenseTransaction>;
      return licenses.where((l) => l.status == 'active' || l.status == 'completed').length;
    } catch (e) {
      return 0;
    }
  }

  // ============================================
  // LICENSE SUMMARY
  // ============================================

  /// Get summary of all licenses with token info
  ///
  /// Returns map with:
  /// - success: bool
  /// - message: String (if error)
  /// - totalLicenses: int
  /// - activeLicenses: int
  /// - totalTokens: int - total remaining tokens across all licenses
  /// - licenses: List of simplified license info
  Future<Map<String, dynamic>> getLicenseSummary() async {
    try {
      final licensesResult = await getMyLicenses();
      final balanceResult = await getTokenBalance();

      final licenses = licensesResult['success'] ? licensesResult['data'] as List<LicenseTransaction> : <LicenseTransaction>[];

      int totalTokens = 0;
      if (balanceResult['success']) {
        final data = balanceResult['data'] as TokenBalanceData;
        totalTokens = data.totalBalance;
      }

      final activeLicenses = licenses.where((l) => l.status == 'active' || l.status == 'completed').length;

      return {'success': true, 'totalLicenses': licenses.length, 'activeLicenses': activeLicenses, 'totalTokens': totalTokens, 'licenses': licenses};
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil summary: ${e.toString()}',
        'totalLicenses': 0,
        'activeLicenses': 0,
        'totalTokens': 0,
        'licenses': <LicenseTransaction>[],
      };
    }
  }
}
