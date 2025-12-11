import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Login with email and password
  /// Returns [User] if successful, [Failure] otherwise
  Future<Either<Failure, User>> login({required String email, required String password});

  /// Register new user account with license key
  /// Returns [User] if successful, [Failure] otherwise
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String licenseKey,
    required String entityType,
    String? companyName,
  });

  /// Logout current user
  /// Returns [void] if successful, [Failure] otherwise
  Future<Either<Failure, void>> logout();

  /// Get current logged in user
  /// Returns [User] if authenticated, [Failure] otherwise
  Future<Either<Failure, User>> getCurrentUser();

  /// Check if user is authenticated
  /// Returns [true] if authenticated, [false] otherwise
  Future<bool> isAuthenticated();

  /// Refresh authentication token
  /// Returns [void] if successful, [Failure] otherwise
  Future<Either<Failure, void>> refreshToken();
}
