import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/item_repository.dart';

/// UseCase for permanently deleting an item
class DeleteItemPermanentUseCase {
  final ItemRepository repository;

  DeleteItemPermanentUseCase(this.repository);

  Future<Either<Failure, bool>> call(String itemId) async {
    return await repository.deleteItemPermanent(itemId);
  }
}
