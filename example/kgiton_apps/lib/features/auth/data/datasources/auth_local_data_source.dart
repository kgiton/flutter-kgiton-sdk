import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Local data source for authentication using SharedPreferences
abstract class AuthLocalDataSource {
  /// Cache user data locally
  Future<void> cacheUser(UserModel user);

  /// Get cached user data
  Future<UserModel> getCachedUser();

  /// Clear cached user data
  Future<void> clearCachedUser();

  /// Check if user data is cached
  Future<bool> hasValidCache();

  /// Cache authentication token
  Future<void> cacheToken(String token);

  /// Get cached authentication token
  Future<String> getCachedToken();

  /// Clear cached authentication token
  Future<void> clearCachedToken();

  /// Cache license key
  Future<void> cacheLicenseKey(String licenseKey);

  /// Get cached license key
  Future<String?> getCachedLicenseKey();

  /// Clear cached license key
  Future<void> clearCachedLicenseKey();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String cachedUserKey = 'CACHED_USER';
  static const String cachedTokenKey = 'CACHED_TOKEN';
  static const String cachedLicenseKey = 'CACHED_LICENSE_KEY';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = json.encode(user.toJson());
      await sharedPreferences.setString(cachedUserKey, jsonString);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user: $e');
    }
  }

  @override
  Future<UserModel> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(cachedUserKey);
      if (jsonString == null) {
        throw CacheException(message: 'No cached user found');
      }
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return UserModel.fromJson(jsonMap);
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user: $e');
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await sharedPreferences.remove(cachedUserKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cached user: $e');
    }
  }

  @override
  Future<bool> hasValidCache() async {
    try {
      final jsonString = sharedPreferences.getString(cachedUserKey);
      return jsonString != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> cacheToken(String token) async {
    try {
      await sharedPreferences.setString(cachedTokenKey, token);
    } catch (e) {
      throw CacheException(message: 'Failed to cache token: $e');
    }
  }

  @override
  Future<String> getCachedToken() async {
    try {
      final token = sharedPreferences.getString(cachedTokenKey);
      if (token == null) {
        throw CacheException(message: 'No cached token found');
      }
      return token;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached token: $e');
    }
  }

  @override
  Future<void> clearCachedToken() async {
    try {
      await sharedPreferences.remove(cachedTokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cached token: $e');
    }
  }

  @override
  Future<void> cacheLicenseKey(String licenseKey) async {
    try {
      await sharedPreferences.setString(cachedLicenseKey, licenseKey);
    } catch (e) {
      throw CacheException(message: 'Failed to cache license key: $e');
    }
  }

  @override
  Future<String?> getCachedLicenseKey() async {
    try {
      return sharedPreferences.getString(cachedLicenseKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCachedLicenseKey() async {
    try {
      await sharedPreferences.remove(cachedLicenseKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cached license key: $e');
    }
  }
}
