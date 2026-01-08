/// ============================================================================
/// Use Case Base Class
/// ============================================================================
/// 
/// File: src/domain/usecases/usecase.dart
/// Deskripsi: Base class untuk semua Use Cases
/// ============================================================================

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

/// Base Use Case dengan parameter
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use Case tanpa parameter
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// Kelas kosong untuk use case tanpa params
class NoParams {}
