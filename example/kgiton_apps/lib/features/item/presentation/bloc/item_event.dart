part of 'item_bloc.dart';

/// Base event for item management
abstract class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all items for a license
class LoadItemsEvent extends ItemEvent {
  const LoadItemsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load item by ID
class LoadItemByIdEvent extends ItemEvent {
  final String itemId;

  const LoadItemByIdEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Event to create a new item
class CreateItemEvent extends ItemEvent {
  final String name;
  final String unit;
  final double price;
  final double? pricePerPcs;
  final String? description;

  const CreateItemEvent({required this.name, required this.unit, required this.price, this.pricePerPcs, this.description});

  @override
  List<Object?> get props => [name, unit, price, pricePerPcs, description];
}

/// Event to update an item
class UpdateItemEvent extends ItemEvent {
  final String itemId;
  final String? name;
  final String? unit;
  final double? price;
  final double? pricePerPcs;
  final String? description;

  const UpdateItemEvent({required this.itemId, this.name, this.unit, this.price, this.pricePerPcs, this.description});

  @override
  List<Object?> get props => [itemId, name, unit, price, pricePerPcs, description];
}

/// Event to delete an item (soft delete)
class DeleteItemEvent extends ItemEvent {
  final String itemId;

  const DeleteItemEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Event to permanently delete an item
class DeleteItemPermanentEvent extends ItemEvent {
  final String itemId;

  const DeleteItemPermanentEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}
