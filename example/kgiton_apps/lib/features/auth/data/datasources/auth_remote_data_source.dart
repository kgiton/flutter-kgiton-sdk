import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Remote data source for authentication using KGiTON SDK
abstract class AuthRemoteDataSource {
  /// Login user with email and password
  Future<UserModel> login(String email, String password);

  /// Register new user with complete information
  Future<UserModel> register(String name, String email, String password, String licenseKey, String entityType, String? companyName);

  /// Logout current user
  Future<void> logout();

  /// Refresh authentication token
  Future<void> refreshToken();

  /// Get current user data from API
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final KgitonApiService apiService;

  AuthRemoteDataSourceImpl({required this.apiService});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final authData = await apiService.auth.login(email: email, password: password);

      // Convert SDK AuthData to UserModel
      // Note: SDK User model may have different structure
      return UserModel(
        id: authData.user.id,
        name: authData.user.email, // Use email as name for now
        email: authData.user.email,
        role: 'owner', // Default role
        phone: null,
        createdAt: DateTime.now(),
        updatedAt: null,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> register(String name, String email, String password, String licenseKey, String entityType, String? companyName) async {
    try {
      // Use SDK registerOwner method
      final authData = await apiService.auth.registerOwner(
        email: email,
        password: password,
        licenseKey: licenseKey,
        entityType: entityType,
        name: entityType == 'company' ? (companyName ?? name) : name,
      );

      // Convert SDK User to UserModel
      return UserModel(
        id: authData.user.id,
        email: authData.user.email,
        name: authData.profile.name,
        role: authData.profile.role,
        phone: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiService.auth.logout();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> refreshToken() async {
    try {
      // SDK doesn't have refreshToken method yet
      throw UnimplementedError('Refresh token not available in SDK yet');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      // Get user data from stored token or API
      // For now, we'll throw an exception as SDK doesn't have this method
      throw UnimplementedError('Get current user not implemented in SDK');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
