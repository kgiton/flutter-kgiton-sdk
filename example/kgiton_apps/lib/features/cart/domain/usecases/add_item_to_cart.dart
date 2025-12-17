import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item.dart' as domain;
import '../repositories/cart_repository.dart';

/// Add item to cart use case
class AddItemToCart implements UseCase<domain.CartItem, AddItemToCartParams> {
  final CartRepository repository;

  AddItemToCart(this.repository);

  @override
  Future<Either<Failure, domain.CartItem>> call(AddItemToCartParams params) async {
    return await repository.addItemToCart(
      cartId: params.cartId,
      licenseKey: params.licenseKey,
      itemId: params.itemId,
      quantity: params.quantity,
      quantityPcs: params.quantityPcs,
      notes: params.notes,
    );
  }
}

class AddItemToCartParams {
  final String cartId;
  final String licenseKey;
  final String itemId;
  final double quantity;
  final double? quantityPcs;
  final String? notes;

  AddItemToCartParams({required this.cartId, required this.licenseKey, required this.itemId, required this.quantity, this.quantityPcs, this.notes});
}
