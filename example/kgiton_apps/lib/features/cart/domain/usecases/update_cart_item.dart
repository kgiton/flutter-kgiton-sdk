import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

/// Update cart item use case
class UpdateCartItem implements UseCase<dynamic, UpdateCartItemParams> {
  final CartRepository repository;

  UpdateCartItem(this.repository);

  @override
  Future<Either<Failure, dynamic>> call(UpdateCartItemParams params) async {
    return await repository.updateCartItem(
      cartItemId: params.cartItemId,
      quantity: params.quantity,
      quantityPcs: params.quantityPcs,
      notes: params.notes,
    );
  }
}

class UpdateCartItemParams {
  final String cartItemId;
  final double? quantity;
  final double? quantityPcs;
  final String? notes;

  UpdateCartItemParams({required this.cartItemId, this.quantity, this.quantityPcs, this.notes});
}
