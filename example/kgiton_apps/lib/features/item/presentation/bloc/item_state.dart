part of 'item_bloc.dart';

/// Base state for item management
abstract class ItemState extends Equatable {
  const ItemState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ItemInitial extends ItemState {}

/// Loading state
class ItemLoading extends ItemState {}

/// Items loaded successfully
class ItemsLoaded extends ItemState {
  final List<Item> items;

  const ItemsLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

/// Single item loaded successfully
class ItemLoaded extends ItemState {
  final Item item;

  const ItemLoaded(this.item);

  @override
  List<Object?> get props => [item];
}

/// Item created successfully
class ItemCreated extends ItemState {
  final Item item;

  const ItemCreated(this.item);

  @override
  List<Object?> get props => [item];
}

/// Item updated successfully
class ItemUpdated extends ItemState {
  final Item item;

  const ItemUpdated(this.item);

  @override
  List<Object?> get props => [item];
}

/// Item deleted successfully
class ItemDeleted extends ItemState {}

/// All items cleared successfully
class ItemsCleared extends ItemState {
  final int count;

  const ItemsCleared(this.count);

  @override
  List<Object?> get props => [count];
}

/// Error state
class ItemError extends ItemState {
  final String message;

  const ItemError(this.message);

  @override
  List<Object?> get props => [message];
}
