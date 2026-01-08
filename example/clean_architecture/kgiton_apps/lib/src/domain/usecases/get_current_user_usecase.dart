/// ============================================================================
/// Get Current User Use Case
/// ============================================================================
/// 
/// File: src/domain/usecases/get_current_user_usecase.dart
/// Deskripsi: Use case untuk mendapatkan current user
/// ============================================================================

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

class GetCurrentUserUseCase implements UseCaseNoParams<UserEntity> {
  final AuthRepository repository;
  
  GetCurrentUserUseCase(this.repository);
  
  @override
  Future<Either<Failure, UserEntity>> call() async {
    return await repository.getCurrentUser();
  }
}
