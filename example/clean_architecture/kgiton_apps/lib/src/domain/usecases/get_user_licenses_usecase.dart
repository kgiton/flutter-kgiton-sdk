/// ============================================================================
/// Get User Licenses Use Case
/// ============================================================================
/// 
/// File: src/domain/usecases/get_user_licenses_usecase.dart
/// Deskripsi: Use case untuk mendapatkan licenses user
/// ============================================================================

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/license_entity.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

class GetUserLicensesUseCase implements UseCaseNoParams<List<LicenseEntity>> {
  final AuthRepository repository;
  
  GetUserLicensesUseCase(this.repository);
  
  @override
  Future<Either<Failure, List<LicenseEntity>>> call() async {
    return await repository.getUserLicenses();
  }
}
