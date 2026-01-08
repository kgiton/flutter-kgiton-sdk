/// ============================================================================
/// Auth Repository Implementation
/// ============================================================================
/// 
/// File: src/data/repositories/auth_repository_impl.dart
/// Deskripsi: Implementasi AuthRepository menggunakan data sources
/// ============================================================================

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/license_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementasi Auth Repository
/// 
/// Menggunakan Remote dan Local data sources untuk:
/// - Remote: API calls untuk auth
/// - Local: Caching user data dan token
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Panggil API login
      final userModel = await remoteDataSource.login(email, password);
      
      // Cache user data
      await localDataSource.cacheUser(userModel);
      
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, String>> register({
    required String name,
    required String email,
    required String password,
    required String licenseKey,
    String? referralCode,
  }) async {
    try {
      final message = await remoteDataSource.register(name, email, password, licenseKey, referralCode);
      return Right(message);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      // Tetap clear cache meskipun API gagal
      await localDataSource.clearCache();
      return const Right(null);
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      // Coba ambil dari cache dulu
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }
      
      // Jika tidak ada di cache, ambil dari API
      final userModel = await remoteDataSource.getProfile();
      await localDataSource.cacheUser(userModel);
      
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<LicenseEntity>>> getUserLicenses() async {
    try {
      final licenses = await remoteDataSource.getUserLicenses();
      return Right(licenses.map((l) => l.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.isLoggedIn();
  }
}
