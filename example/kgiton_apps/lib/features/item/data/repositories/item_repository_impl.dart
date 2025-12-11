import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/item_remote_data_source.dart';

/// Implementation of ItemRepository
class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ItemRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<Item>>> getItems() async {
    if (await networkInfo.isConnected) {
      try {
        final items = await remoteDataSource.getItems();
        return Right(items.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Item>> getItemById(String itemId) async {
    if (await networkInfo.isConnected) {
      try {
        final item = await remoteDataSource.getItemById(itemId);
        return Right(item.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Item>> createItem({
    required String name,
    required String unit,
    required double price,
    double? pricePerPcs,
    String? description,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final item = await remoteDataSource.createItem(name: name, unit: unit, price: price, pricePerPcs: pricePerPcs, description: description);
        return Right(item.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Item>> updateItem({
    required String itemId,
    String? name,
    String? unit,
    double? price,
    double? pricePerPcs,
    String? description,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final item = await remoteDataSource.updateItem(
          itemId: itemId,
          name: name,
          unit: unit,
          price: price,
          pricePerPcs: pricePerPcs,
          description: description,
        );
        return Right(item.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteItem(String itemId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteItem(itemId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteItemPermanent(String itemId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteItemPermanent(itemId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
