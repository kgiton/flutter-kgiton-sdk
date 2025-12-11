import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/item.dart';
import '../repositories/item_repository.dart';

/// Parameters for creating an item
class CreateItemParams extends Equatable {
  final String name;
  final String unit;
  final double price;
  final double? pricePerPcs;
  final String? description;

  const CreateItemParams({required this.name, required this.unit, required this.price, this.pricePerPcs, this.description});

  @override
  List<Object?> get props => [name, unit, price, pricePerPcs, description];
}

/// UseCase for creating a new item
class CreateItemUseCase {
  final ItemRepository repository;

  CreateItemUseCase(this.repository);

  Future<Either<Failure, Item>> call(CreateItemParams params) async {
    return await repository.createItem(
      name: params.name,
      unit: params.unit,
      price: params.price,
      pricePerPcs: params.pricePerPcs,
      description: params.description,
    );
  }
}
