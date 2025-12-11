import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for user registration
class RegisterUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      licenseKey: params.licenseKey,
      entityType: params.entityType,
      companyName: params.companyName,
    );
  }
}

/// Parameters for register use case
class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String licenseKey;
  final String entityType; // 'individual' or 'company'
  final String? companyName; // Required if entityType = 'company'

  RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.licenseKey,
    required this.entityType,
    this.companyName,
  });
}
