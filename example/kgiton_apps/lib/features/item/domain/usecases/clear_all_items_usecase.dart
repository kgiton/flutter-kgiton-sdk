import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/item_repository.dart';

/// Use case for clearing all items
class ClearAllItemsUseCase implements UseCase<int, NoParams> {
  final ItemRepository repository;

  ClearAllItemsUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call([NoParams? params]) async {
    return await repository.clearAllItems();
  }
}
