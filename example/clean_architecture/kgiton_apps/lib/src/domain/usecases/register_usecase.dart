/// ============================================================================
/// Register Use Case
/// ============================================================================
/// 
/// File: src/domain/usecases/register_usecase.dart
/// Deskripsi: Use case untuk registrasi user baru
/// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

class RegisterUseCase implements UseCase<String, RegisterParams> {
  final AuthRepository repository;
  
  RegisterUseCase(this.repository);
  
  @override
  Future<Either<Failure, String>> call(RegisterParams params) async {
    return await repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      licenseKey: params.licenseKey,
      referralCode: params.referralCode,
    );
  }
}

/// Parameters untuk register
class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String licenseKey;
  final String? referralCode;
  
  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.licenseKey,
    this.referralCode,
  });
  
  @override
  List<Object?> get props => [name, email, password, licenseKey, referralCode];
}
