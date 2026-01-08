/// ============================================================================
/// Auth Repository Interface - Domain Layer
/// ============================================================================
/// 
/// File: src/domain/repositories/auth_repository.dart
/// Deskripsi: Repository interface mendefinisikan kontrak untuk data access
/// 
/// Repository Pattern di Clean Architecture:
/// - Domain layer mendefinisikan interface
/// - Data layer mengimplementasikan interface
/// - Ini mengikuti Dependency Inversion Principle
/// ============================================================================

import 'package:dartz/dartz.dart';

import '../entities/user_entity.dart';
import '../entities/license_entity.dart';
import '../../core/error/failures.dart';

/// Repository interface untuk autentikasi
/// 
/// Menggunakan Either<Failure, Success> untuk error handling
/// yang lebih type-safe dibanding try-catch
abstract class AuthRepository {
  /// Login dengan email dan password
  /// 
  /// Returns [Right(UserEntity)] jika berhasil
  /// Returns [Left(Failure)] jika gagal
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });
  
  /// Register user baru
  /// 
  /// Returns [Right(String)] message jika berhasil
  Future<Either<Failure, String>> register({
    required String name,
    required String email,
    required String password,
    required String licenseKey,
    String? referralCode,
  });
  
  /// Logout user
  Future<Either<Failure, void>> logout();
  
  /// Get current user dari local storage
  Future<Either<Failure, UserEntity>> getCurrentUser();
  
  /// Get user's licenses
  Future<Either<Failure, List<LicenseEntity>>> getUserLicenses();
  
  /// Check if user is logged in
  Future<bool> isLoggedIn();
}
