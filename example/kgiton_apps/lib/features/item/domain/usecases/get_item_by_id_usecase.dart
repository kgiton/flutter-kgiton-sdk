import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/item.dart';
import '../repositories/item_repository.dart';

/// UseCase for getting item by ID
class GetItemByIdUseCase {
  final ItemRepository repository;

  GetItemByIdUseCase(this.repository);

  Future<Either<Failure, Item>> call(String itemId) async {
    return await repository.getItemById(itemId);
  }
}
