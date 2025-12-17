import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/item_repository.dart';

/// UseCase for permanently deleting an item (cannot be undone)
class DeleteItemUseCase {
  final ItemRepository repository;

  DeleteItemUseCase(this.repository);

  Future<Either<Failure, bool>> call(String itemId) async {
    return await repository.deleteItem(itemId);
  }
}
