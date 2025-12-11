import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/item.dart';
import '../repositories/item_repository.dart';

/// Parameters for updating an item
class UpdateItemParams extends Equatable {
  final String itemId;
  final String? name;
  final String? unit;
  final double? price;
  final double? pricePerPcs;
  final String? description;

  const UpdateItemParams({required this.itemId, this.name, this.unit, this.price, this.pricePerPcs, this.description});

  @override
  List<Object?> get props => [itemId, name, unit, price, pricePerPcs, description];
}

/// UseCase for updating an item
class UpdateItemUseCase {
  final ItemRepository repository;

  UpdateItemUseCase(this.repository);

  Future<Either<Failure, Item>> call(UpdateItemParams params) async {
    return await repository.updateItem(
      itemId: params.itemId,
      name: params.name,
      unit: params.unit,
      price: params.price,
      pricePerPcs: params.pricePerPcs,
      description: params.description,
    );
  }
}
