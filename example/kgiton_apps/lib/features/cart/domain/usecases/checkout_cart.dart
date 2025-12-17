import 'package:dartz/dartz.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

/// Checkout cart use case
class CheckoutCart implements UseCase<Transaction, CheckoutCartParams> {
  final CartRepository repository;

  CheckoutCart(this.repository);

  @override
  Future<Either<Failure, Transaction>> call(CheckoutCartParams params) async {
    return await repository.checkoutCart(
      cartId: params.cartId,
      paymentMethod: params.paymentMethod,
      paymentGateway: params.paymentGateway,
      notes: params.notes,
    );
  }
}

class CheckoutCartParams {
  final String cartId;
  final String paymentMethod;
  final String paymentGateway;
  final String? notes;

  CheckoutCartParams({required this.cartId, required this.paymentMethod, required this.paymentGateway, this.notes});
}
