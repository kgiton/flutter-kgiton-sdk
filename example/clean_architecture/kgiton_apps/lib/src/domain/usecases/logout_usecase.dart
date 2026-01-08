/// ============================================================================
/// Logout Use Case
/// ============================================================================
/// 
/// File: src/domain/usecases/logout_usecase.dart
/// Deskripsi: Use case untuk logout user
/// ============================================================================

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

class LogoutUseCase implements UseCaseNoParams<void> {
  final AuthRepository repository;
  
  LogoutUseCase(this.repository);
  
  @override
  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
