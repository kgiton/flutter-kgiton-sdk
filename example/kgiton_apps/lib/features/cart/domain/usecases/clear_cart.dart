import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

/// Clear cart use case
class ClearCart implements UseCase<bool, String> {
  final CartRepository repository;

  ClearCart(this.repository);

  @override
  Future<Either<Failure, bool>> call(String cartId) async {
    return await repository.clearCart(cartId);
  }
}
