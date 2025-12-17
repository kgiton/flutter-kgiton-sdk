import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

/// Get cart summary use case
class GetCartSummary implements UseCase<dynamic, String> {
  final CartRepository repository;

  GetCartSummary(this.repository);

  @override
  Future<Either<Failure, dynamic>> call(String cartId) async {
    return await repository.getCartSummary(cartId);
  }
}
