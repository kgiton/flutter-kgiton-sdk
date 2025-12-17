import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for reset password with token
class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(token: params.token, newPassword: params.newPassword);
  }
}

/// Parameters for reset password use case
class ResetPasswordParams {
  final String token;
  final String newPassword;

  ResetPasswordParams({required this.token, required this.newPassword});
}
