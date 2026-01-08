/// ============================================================================
/// Auth Controller - GetX State Management
/// ============================================================================
/// 
/// File: src/controllers/auth_controller.dart
/// Deskripsi: Controller untuk manajemen authentication
/// 
/// GetX Features:
/// 1. Reactive State dengan .obs
/// 2. Lifecycle methods (onInit, onClose)
/// 3. Easy access dengan Get.find<AuthController>()
/// ============================================================================

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

import '../config/routes.dart';

/// Auth Controller
/// 
/// Mengelola state authentication:
/// - isLoggedIn: Status login
/// - user: Data user yang login
/// - isLoading: Status loading
/// - error: Pesan error
class AuthController extends GetxController {
  // =========================================================================
  // Services
  // =========================================================================
  late final KgitonApiService _apiService;
  final _storage = GetStorage();
  
  // =========================================================================
  // Reactive State (.obs)
  // 
  // .obs membuat variable menjadi reactive.
  // Gunakan .value untuk get/set value.
  // Obx(() => ...) akan rebuild otomatis saat value berubah.
  // =========================================================================
  
  /// Status loading
  final isLoading = false.obs;
  
  /// Status login
  final isLoggedIn = false.obs;
  
  /// Data user
  final Rx<User?> user = Rx<User?>(null);
  
  /// Access token
  final accessToken = ''.obs;
  
  /// Error message
  final errorMessage = ''.obs;
  
  /// List licenses
  final licenses = <LicenseKey>[].obs;
  
  // =========================================================================
  // Storage Keys
  // =========================================================================
  static const _tokenKey = 'kgiton_access_token';
  static const _userKey = 'kgiton_user_data';
  
  // =========================================================================
  // Lifecycle Methods
  // =========================================================================
  
  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<KgitonApiService>();
    _checkAuthStatus();
  }
  
  // =========================================================================
  // Methods
  // =========================================================================
  
  /// Check status authentication dari local storage
  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay
    
    final token = _storage.read<String>(_tokenKey);
    
    if (token != null && token.isNotEmpty) {
      accessToken.value = token;
      isLoggedIn.value = true;
      await _loadUserProfile();
      Get.offAllNamed(AppRoutes.home);
    } else {
      isLoggedIn.value = false;
      Get.offAllNamed(AppRoutes.auth);
    }
  }
  
  /// Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // login returns AuthData directly (not wrapped)
      final authData = await _apiService.auth.login(
        email: email,
        password: password,
      );
      
      // Simpan token ke storage
      final token = authData.accessToken;
      await _storage.write(_tokenKey, token);
      
      // Update state
      accessToken.value = token;
      user.value = authData.user;
      isLoggedIn.value = true;
      
      // Load licenses
      await loadLicenses();
      
      // Navigate ke home
      Get.offAllNamed(AppRoutes.home);
      return true;
    } catch (e) {
      errorMessage.value = 'Error: $e';
      _showError(errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Register user baru
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String licenseKey,
    String? referralCode,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // register returns String message directly
      final message = await _apiService.auth.register(
        name: name,
        email: email,
        password: password,
        licenseKey: licenseKey,
        referralCode: referralCode,
      );
      
      _showSuccess(message);
      return true;
    } catch (e) {
      errorMessage.value = 'Error: $e';
      _showError(errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _apiService.auth.logout();
    } catch (e) {
      // Ignore error, tetap logout
    } finally {
      // Clear local data
      await _storage.remove(_tokenKey);
      await _storage.remove(_userKey);
      
      // Reset state
      accessToken.value = '';
      user.value = null;
      isLoggedIn.value = false;
      licenses.clear();
      
      isLoading.value = false;
      
      // Navigate ke auth
      Get.offAllNamed(AppRoutes.auth);
    }
  }
  
  /// Load user profile
  Future<void> _loadUserProfile() async {
    try {
      // getProfile returns UserProfileData directly
      final profile = await _apiService.user.getProfile();
      // Convert UserProfileData to User for state
      user.value = User(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        role: profile.role,
        apiKey: profile.apiKey,
        referralCode: '',
        createdAt: profile.createdAt,
        updatedAt: profile.createdAt,
      );
    } catch (e) {
      // Ignore error
    }
  }
  
  /// Load user licenses
  Future<void> loadLicenses() async {
    try {
      // Get licenses from profile.licenseKeys
      final profile = await _apiService.user.getProfile();
      licenses.assignAll(profile.licenseKeys);
    } catch (e) {
      // Ignore error
    }
  }
  
  // =========================================================================
  // Helper Methods
  // =========================================================================
  
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }
  
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }
}
