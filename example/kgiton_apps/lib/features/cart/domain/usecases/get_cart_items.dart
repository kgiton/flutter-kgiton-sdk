import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item.dart' as domain;
import '../repositories/cart_repository.dart';

/// Get cart items use case
class GetCartItems implements UseCase<List<domain.CartItem>, String> {
  final CartRepository repository;

  GetCartItems(this.repository);

  @override
  Future<Either<Failure, List<domain.CartItem>>> call(String cartId) async {
    return await repository.getCartItems(cartId);
  }
}
