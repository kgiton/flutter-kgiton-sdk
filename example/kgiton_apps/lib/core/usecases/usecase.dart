import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for all use cases
/// [ReturnType] is the return type
/// [Params] is the parameter type
abstract class UseCase<ReturnType, Params> {
  Future<Either<Failure, ReturnType>> call(Params params);
}

/// No parameters class for use cases that don't need parameters
class NoParams {
  const NoParams();
}
