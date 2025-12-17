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
  final String licenseKey;
  final String name;
  final String unit;
  final double price;
  final double? pricePerPcs;
  final String? description;

  const CreateItemEvent({required this.licenseKey, required this.name, required this.unit, required this.price, this.pricePerPcs, this.description});

  @override
  List<Object?> get props => [licenseKey, name, unit, price, pricePerPcs, description];
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

/// Event to delete an item (permanent - cannot be undone)
class DeleteItemEvent extends ItemEvent {
  final String itemId;

  const DeleteItemEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Event to clear all items
class ClearAllItemsEvent extends ItemEvent {
  const ClearAllItemsEvent();

  @override
  List<Object?> get props => [];
}
