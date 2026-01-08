/// ============================================================================
/// Login Use Case
/// ============================================================================
/// 
/// File: src/domain/usecases/login_usecase.dart
/// Deskripsi: Use case untuk login user
/// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parameters untuk login
class LoginParams extends Equatable {
  final String email;
  final String password;
  
  const LoginParams({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object> get props => [email, password];
}
