/// ============================================================================
/// Auth Local Data Source
/// ============================================================================
/// 
/// File: src/data/datasources/auth_local_datasource.dart
/// Deskripsi: Local data source untuk cache auth data
/// ============================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/constants.dart';
import '../models/user_model.dart';

/// Interface untuk Auth Local Data Source
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearCache();
  Future<bool> isLoggedIn();
}

/// Implementasi Auth Local Data Source menggunakan SharedPreferences
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  AuthLocalDataSourceImpl({required this.sharedPreferences});
  
  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(
      AppConstants.userDataKey,
      json.encode(user.toJson()),
    );
  }
  
  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = sharedPreferences.getString(AppConstants.userDataKey);
    if (jsonString != null) {
      return UserModel.fromJson(json.decode(jsonString));
    }
    return null;
  }
  
  @override
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString(AppConstants.tokenKey, token);
  }
  
  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(AppConstants.tokenKey);
  }
  
  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(AppConstants.tokenKey);
    await sharedPreferences.remove(AppConstants.userDataKey);
  }
  
  @override
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
