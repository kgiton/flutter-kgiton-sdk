/// ============================================================================
/// Auth Provider - State Management untuk Autentikasi
/// ============================================================================
///
/// File: src/providers/auth_provider.dart
/// Deskripsi: Provider untuk mengelola state autentikasi pengguna
///
/// Fitur:
/// - Login dengan email & password
/// - Register dengan license key
/// - Logout
/// - Auto-load saved session
/// - Token management
///
/// Cara Penggunaan:
/// ```dart
/// // Mengakses provider di widget
/// final authProvider = context.read<AuthProvider>();
///
/// // Login
/// await authProvider.login(email: 'user@email.com', password: 'password');
///
/// // Cek status login
/// if (authProvider.isLoggedIn) {
///   // User sudah login
/// }
///
/// // Listen perubahan state
/// context.watch<AuthProvider>().isLoading // untuk rebuild UI
/// ```
/// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

import '../config/constants.dart';

/// Enum untuk status autentikasi
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Provider untuk mengelola state autentikasi
///
/// Extends [ChangeNotifier] untuk reactive UI updates.
/// Gunakan [context.watch<AuthProvider>()] untuk listen perubahan.
class AuthProvider extends ChangeNotifier {
  // =========================================================================
  // Private Properties
  // =========================================================================

  /// API Service instance dari SDK
  KgitonApiService? _apiService;

  /// Current user data
  User? _user;

  /// Auth status
  AuthStatus _status = AuthStatus.initial;

  /// Error message jika ada
  String? _errorMessage;

  /// License keys yang dimiliki user
  List<LicenseKey> _licenses = [];

  // =========================================================================
  // Getters
  // =========================================================================

  /// Get API service instance
  KgitonApiService? get apiService => _apiService;

  /// Get current user
  User? get user => _user;

  /// Get auth status
  AuthStatus get status => _status;

  /// Check if user is logged in
  bool get isLoggedIn => _status == AuthStatus.authenticated && _user != null;

  /// Check if loading
  bool get isLoading => _status == AuthStatus.loading;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Get user's license keys
  List<LicenseKey> get licenses => List.unmodifiable(_licenses);

  /// Get first license key (convenience getter)
  String? get primaryLicenseKey => _licenses.isNotEmpty ? _licenses.first.key : null;

  // =========================================================================
  // Constructor & Initialization
  // =========================================================================

  /// Constructor - automatically initializes API service
  AuthProvider() {
    _initializeApiService();
  }

  /// Initialize API service dan load saved session
  /// TODO: Change base URL jika perlu
  Future<void> _initializeApiService() async {
    _apiService = KgitonApiService(baseUrl: AppConstants.apiSandboxUrl);

    // Coba load saved session
    await checkAuthStatus();
  }

  // =========================================================================
  // Public Methods
  // =========================================================================

  /// Check authentication status dari saved session
  ///
  /// Dipanggil saat app start untuk cek apakah user masih login.
  Future<void> checkAuthStatus() async {
    try {
      _setStatus(AuthStatus.loading);

      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(AppConstants.userDataKey);
      final accessToken = prefs.getString(AppConstants.tokenKey);

      if (userData != null && accessToken != null) {
        // Restore user data
        _user = User.fromJson(json.decode(userData));

        // Set token ke API service
        _apiService?.setAccessToken(accessToken);

        // Load licenses
        await _loadUserLicenses();

        _setStatus(AuthStatus.authenticated);
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _setError('Gagal memuat sesi: $e');
    }
  }

  /// Login dengan email dan password
  ///
  /// [email] - Email pengguna
  /// [password] - Password pengguna
  ///
  /// Returns true jika berhasil login
  ///
  /// Contoh:
  /// ```dart
  /// final success = await authProvider.login(
  ///   email: 'user@email.com',
  ///   password: 'password123',
  /// );
  /// if (success) {
  ///   // Navigate to home
  /// }
  /// ```
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setStatus(AuthStatus.loading);
      _errorMessage = null;

      // Call API login
      final authData = await _apiService!.auth.login(
        email: email,
        password: password,
      );

      // Save to local storage
      await _saveSession(authData);

      // Update state
      _user = authData.user;

      // Load user's licenses
      await _loadUserLicenses();

      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      _setError('Login gagal: ${_parseError(e)}');
      return false;
    }
  }

  /// Register pengguna baru dengan license key
  ///
  /// [email] - Email pengguna
  /// [password] - Password (minimal 6 karakter)
  /// [name] - Nama lengkap
  /// [licenseKey] - License key yang valid
  /// [referralCode] - Kode referral (opsional)
  ///
  /// Returns true jika berhasil register
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String licenseKey,
    String? referralCode,
  }) async {
    try {
      _setStatus(AuthStatus.loading);
      _errorMessage = null;

      // Call API register
      await _apiService!.auth.register(
        email: email,
        password: password,
        name: name,
        licenseKey: licenseKey,
        referralCode: referralCode,
      );

      // Register berhasil - user perlu verifikasi email
      _setStatus(AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      _setError('Register gagal: ${_parseError(e)}');
      return false;
    }
  }

  /// Logout dan hapus session
  Future<void> logout() async {
    try {
      _setStatus(AuthStatus.loading);

      // Call API logout
      await _apiService?.auth.logout();

      // Clear local storage
      await _clearSession();

      // Reset state
      _user = null;
      _licenses = [];

      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      // Tetap logout meskipun API gagal
      await _clearSession();
      _user = null;
      _licenses = [];
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  /// Validate license key
  ///
  /// [licenseKey] - License key yang akan divalidasi
  ///
  /// Returns [ValidateLicenseResponse] jika valid
  Future<ValidateLicenseResponse?> validateLicense(String licenseKey) async {
    try {
      return await _apiService?.license.validateLicense(licenseKey);
    } catch (e) {
      _setError('Validasi license gagal: ${_parseError(e)}');
      return null;
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (!isLoggedIn) return;

    try {
      final profile = await _apiService?.user.getProfile();
      if (profile != null) {
        _user = User(
          id: profile.id,
          email: profile.email,
          name: profile.name,
          apiKey: profile.apiKey,
          role: profile.role,
          referralCode: _user?.referralCode ?? '',
          createdAt: profile.createdAt,
          updatedAt: _user?.updatedAt ?? DateTime.now(),
        );

        // Save updated user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userDataKey, json.encode(_user!.toJson()));

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gagal refresh user data: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =========================================================================
  // Private Methods
  // =========================================================================

  /// Update status dan notify listeners
  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  /// Set error dan update status
  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
    notifyListeners();
  }

  /// Save session ke local storage
  Future<void> _saveSession(AuthData authData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, authData.accessToken);
    await prefs.setString(AppConstants.userDataKey, json.encode(authData.user.toJson()));
    if (authData.user.apiKey.isNotEmpty) {
      await prefs.setString(AppConstants.apiKeyKey, authData.user.apiKey);
    }
  }

  /// Clear session dari local storage
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.apiKeyKey);
    await prefs.remove(AppConstants.userDataKey);
    await prefs.remove(AppConstants.connectedLicenseKey);
  }

  /// Load user's license keys
  Future<void> _loadUserLicenses() async {
    try {
      final profile = await _apiService?.user.getProfile();
      if (profile != null) {
        _licenses = profile.licenseKeys;
      }
    } catch (e) {
      debugPrint('Gagal load licenses: $e');
      // Don't fail login if licenses fail to load
    }
  }

  /// Parse error message
  String _parseError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}
