import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

/// Delete cart item use case
class DeleteCartItem implements UseCase<bool, String> {
  final CartRepository repository;

  DeleteCartItem(this.repository);

  @override
  Future<Either<Failure, bool>> call(String cartItemId) async {
    return await repository.deleteCartItem(cartItemId);
  }
}
