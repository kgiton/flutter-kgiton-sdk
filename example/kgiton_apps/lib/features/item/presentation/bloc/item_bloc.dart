import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/item.dart';
import '../../domain/usecases/clear_all_items_usecase.dart';
import '../../domain/usecases/create_item_usecase.dart';
import '../../domain/usecases/delete_item_usecase.dart';
import '../../domain/usecases/get_item_by_id_usecase.dart';
import '../../domain/usecases/get_items_usecase.dart';
import '../../domain/usecases/update_item_usecase.dart';

part 'item_event.dart';
part 'item_state.dart';

/// BLoC for managing item operations
class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final GetItemsUseCase getItemsUseCase;
  final GetItemByIdUseCase getItemByIdUseCase;
  final CreateItemUseCase createItemUseCase;
  final UpdateItemUseCase updateItemUseCase;
  final DeleteItemUseCase deleteItemUseCase;
  final ClearAllItemsUseCase clearAllItemsUseCase;

  ItemBloc({
    required this.getItemsUseCase,
    required this.getItemByIdUseCase,
    required this.createItemUseCase,
    required this.updateItemUseCase,
    required this.deleteItemUseCase,
    required this.clearAllItemsUseCase,
  }) : super(ItemInitial()) {
    on<LoadItemsEvent>(_onLoadItems);
    on<LoadItemByIdEvent>(_onLoadItemById);
    on<CreateItemEvent>(_onCreateItem);
    on<UpdateItemEvent>(_onUpdateItem);
    on<DeleteItemEvent>(_onDeleteItem);
    on<ClearAllItemsEvent>(_onClearAllItems);
  }

  Future<void> _onLoadItems(LoadItemsEvent event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    final result = await getItemsUseCase();

    result.fold((failure) => emit(ItemError(failure.message)), (items) => emit(ItemsLoaded(items)));
  }

  Future<void> _onLoadItemById(LoadItemByIdEvent event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    final result = await getItemByIdUseCase(event.itemId);

    result.fold((failure) => emit(ItemError(failure.message)), (item) => emit(ItemLoaded(item)));
  }

  Future<void> _onCreateItem(CreateItemEvent event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    final params = CreateItemParams(
      licenseKey: event.licenseKey,
      name: event.name,
      unit: event.unit,
      price: event.price,
      pricePerPcs: event.pricePerPcs,
      description: event.description,
    );

    final result = await createItemUseCase(params);

    result.fold((failure) => emit(ItemError(failure.message)), (item) => emit(ItemCreated(item)));
  }

  Future<void> _onUpdateItem(UpdateItemEvent event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    final params = UpdateItemParams(
      itemId: event.itemId,
      name: event.name,
      unit: event.unit,
      price: event.price,
      pricePerPcs: event.pricePerPcs,
      description: event.description,
    );

    final result = await updateItemUseCase(params);

    result.fold((failure) => emit(ItemError(failure.message)), (item) => emit(ItemUpdated(item)));
  }

  Future<void> _onDeleteItem(DeleteItemEvent event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    final result = await deleteItemUseCase(event.itemId);

    result.fold((failure) => emit(ItemError(failure.message)), (success) => emit(ItemDeleted()));
  }

  Future<void> _onClearAllItems(ClearAllItemsEvent event, Emitter<ItemState> emit) async {
    emit(ItemLoading());

    final result = await clearAllItemsUseCase();

    result.fold((failure) => emit(ItemError(failure.message)), (count) => emit(ItemsCleared(count)));
  }
}
