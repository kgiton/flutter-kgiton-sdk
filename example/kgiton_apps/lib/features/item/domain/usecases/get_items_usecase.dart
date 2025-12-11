import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/item.dart';
import '../repositories/item_repository.dart';

/// UseCase for getting all items for the authenticated user
class GetItemsUseCase {
  final ItemRepository repository;

  GetItemsUseCase(this.repository);

  Future<Either<Failure, List<Item>>> call() async {
    return await repository.getItems();
  }
}
