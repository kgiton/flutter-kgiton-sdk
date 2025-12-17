import 'package:dartz/dartz.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/cart_item.dart' as domain;
import '../../domain/repositories/cart_repository.dart' as repository;
import '../datasources/cart_remote_data_source.dart';

class CartRepositoryImpl implements repository.CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CartRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, domain.CartItem>> addItemToCart({
    required String cartId,
    required String licenseKey,
    required String itemId,
    required double quantity,
    double? quantityPcs,
    String? notes,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final cartModel = await remoteDataSource.addItemToCart(
          cartId: cartId,
          licenseKey: licenseKey,
          itemId: itemId,
          quantity: quantity,
          quantityPcs: quantityPcs,
          notes: notes,
        );
        return Right(cartModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<domain.CartItem>>> getCartItems(String cartId) async {
    if (await networkInfo.isConnected) {
      try {
        final cartModels = await remoteDataSource.getCartItems(cartId);
        return Right(cartModels.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, repository.CartSummary>> getCartSummary(String cartId) async {
    if (await networkInfo.isConnected) {
      try {
        final summaryData = await remoteDataSource.getCartSummary(cartId);
        return Right(
          repository.CartSummary(
            totalItems: summaryData.totalItems,
            totalAmount: summaryData.totalAmount,
            items: summaryData.items.map((model) => model.toEntity()).toList(),
          ),
        );
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, domain.CartItem>> getCartItem(String cartItemId) async {
    if (await networkInfo.isConnected) {
      try {
        final cartModel = await remoteDataSource.getCartItem(cartItemId);
        return Right(cartModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, domain.CartItem>> updateCartItem({required String cartItemId, double? quantity, double? quantityPcs, String? notes}) async {
    if (await networkInfo.isConnected) {
      try {
        final cartModel = await remoteDataSource.updateCartItem(cartItemId: cartItemId, quantity: quantity, quantityPcs: quantityPcs, notes: notes);
        return Right(cartModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCartItem(String cartItemId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteCartItem(cartItemId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> clearCart(String cartId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.clearCart(cartId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> checkoutCart({
    required String cartId,
    required String paymentMethod,
    required String paymentGateway,
    String? notes,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final transaction = await remoteDataSource.checkoutCart(
          cartId: cartId,
          paymentMethod: paymentMethod,
          paymentGateway: paymentGateway,
          notes: notes,
        );
        return Right(transaction);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, int>> getCartItemCount(String cartId) async {
    final summaryResult = await getCartSummary(cartId);
    return summaryResult.fold((failure) => Left(failure), (summary) => Right(summary.totalItems));
  }

  @override
  Future<Either<Failure, bool>> isCartEmpty(String cartId) async {
    final countResult = await getCartItemCount(cartId);
    return countResult.fold((failure) => Left(failure), (count) => Right(count == 0));
  }
}
