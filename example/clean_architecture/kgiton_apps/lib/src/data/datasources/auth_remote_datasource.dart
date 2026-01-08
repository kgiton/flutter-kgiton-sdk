/// ============================================================================
/// Auth Remote Data Source
/// ============================================================================
/// 
/// File: src/data/datasources/auth_remote_datasource.dart
/// Deskripsi: Remote data source untuk auth menggunakan KGiTON SDK
/// ============================================================================

import 'package:kgiton_sdk/kgiton_sdk.dart';

import '../models/user_model.dart';
import '../models/license_model.dart';

/// Interface untuk Auth Remote Data Source
abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<String> register(String name, String email, String password, String licenseKey, String? referralCode);
  Future<void> logout();
  Future<UserModel> getProfile();
  Future<List<LicenseModel>> getUserLicenses();
}

/// Implementasi Auth Remote Data Source menggunakan KGiTON SDK
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final KgitonApiService apiService;
  
  AuthRemoteDataSourceImpl({required this.apiService});
  
  @override
  Future<UserModel> login(String email, String password) async {
    try {
      // login returns AuthData directly (not wrapped)
      final authData = await apiService.auth.login(
        email: email,
        password: password,
      );
      
      return UserModel.fromSdkAuthData(authData);
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
  
  @override
  Future<String> register(String name, String email, String password, String licenseKey, String? referralCode) async {
    try {
      // register returns String message directly
      final message = await apiService.auth.register(
        name: name,
        email: email,
        password: password,
        licenseKey: licenseKey,
        referralCode: referralCode,
      );
      
      return message;
    } catch (e) {
      throw Exception('Register error: $e');
    }
  }
  
  @override
  Future<void> logout() async {
    try {
      await apiService.auth.logout();
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }
  
  @override
  Future<UserModel> getProfile() async {
    try {
      // getProfile returns UserProfileData directly (not wrapped)
      final profile = await apiService.user.getProfile();
      return UserModel.fromProfile(profile);
    } catch (e) {
      throw Exception('Get profile error: $e');
    }
  }
  
  @override
  Future<List<LicenseModel>> getUserLicenses() async {
    try {
      // Get licenses from profile.licenseKeys
      final profile = await apiService.user.getProfile();
      return profile.licenseKeys.map((l) => LicenseModel.fromSdkModel(l)).toList();
    } catch (e) {
      throw Exception('Get licenses error: $e');
    }
  }
}
