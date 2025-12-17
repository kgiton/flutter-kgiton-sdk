import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({required this.remoteDataSource, required this.localDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.login(email, password);
        await localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String licenseKey,
    required String entityType,
    String? companyName,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.register(name, email, password, licenseKey, entityType, companyName);
        await localDataSource.cacheUser(userModel);
        await localDataSource.cacheLicenseKey(licenseKey);
        return Right(userModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }
      await localDataSource.clearCachedUser();
      await localDataSource.clearCachedToken();
      await localDataSource.clearCachedLicenseKey();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCachedUser();
      return Right(userModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get current user: $e'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await localDataSource.hasValidCache();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.refreshToken();
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<String?> getLicenseKey() async {
    try {
      return await localDataSource.getCachedLicenseKey();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.forgotPassword(email);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String token, required String newPassword}) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.resetPassword(token, newPassword);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({required String oldPassword, required String newPassword}) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.changePassword(oldPassword, newPassword);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(message: e.message, code: e.code));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
