import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/add_item_to_cart.dart';
import '../../domain/usecases/checkout_cart.dart';
import '../../domain/usecases/clear_cart.dart';
import '../../domain/usecases/delete_cart_item.dart';
import '../../domain/usecases/get_cart_items.dart';
import '../../domain/usecases/get_cart_summary.dart';
import '../../domain/usecases/update_cart_item.dart';

part 'cart_event.dart';
part 'cart_state.dart';

/// BLoC for managing shopping cart with SDK integration
class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartItems getCartItems;
  final GetCartSummary getCartSummary;
  final AddItemToCart addItemToCart;
  final UpdateCartItem updateCartItem;
  final DeleteCartItem deleteCartItem;
  final ClearCart clearCart;
  final CheckoutCart checkoutCart;

  CartBloc({
    required this.getCartItems,
    required this.getCartSummary,
    required this.addItemToCart,
    required this.updateCartItem,
    required this.deleteCartItem,
    required this.clearCart,
    required this.checkoutCart,
  }) : super(CartInitial()) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateCartItemEvent>(_onUpdateCartItem);
    on<ClearCartEvent>(_onClearCart);
    on<CheckoutCartEvent>(_onCheckoutCart);
  }

  Future<void> _onLoadCart(LoadCartEvent event, Emitter<CartState> emit) async {
    debugPrint('=== CART BLOC: Loading cart with cartId: ${event.cartId} ===');
    emit(CartLoading());
    try {
      final result = await getCartSummary(event.cartId);

      result.fold(
        (failure) {
          debugPrint('=== CART BLOC: Load cart FAILED: ${failure.toString()} ===');
          emit(CartError(failure.toString()));
        },
        (summary) {
          debugPrint('=== CART BLOC: Load cart SUCCESS - ${summary.items.length} items, total: ${summary.totalAmount} ===');
          emit(CartLoaded(items: summary.items, totalAmount: summary.totalAmount));
        },
      );
    } catch (e) {
      debugPrint('=== CART BLOC: Load cart EXCEPTION: ${e.toString()} ===');
      emit(CartError('Failed to load cart: ${e.toString()}'));
    }
  }

  Future<void> _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) async {
    debugPrint(
      '=== CART BLOC: Adding to cart - itemId: ${event.itemId}, qty: ${event.quantity.toStringAsFixed(3)}, qtyPcs: ${event.quantityPcs} ===',
    );
    try {
      final result = await addItemToCart(
        AddItemToCartParams(
          cartId: event.cartId,
          licenseKey: event.licenseKey,
          itemId: event.itemId,
          quantity: event.quantity,
          quantityPcs: event.quantityPcs,
          notes: event.notes,
        ),
      );

      await result.fold(
        (failure) async {
          debugPrint('=== CART BLOC: Add to cart FAILED: ${failure.toString()} ===');
          emit(CartError(failure.toString()));
        },
        (cartItem) async {
          debugPrint('=== CART BLOC: Add to cart SUCCESS - cartItemId: ${cartItem.id} ===');
          emit(CartItemAdded(cartItem));

          // Reload cart to get updated list
          debugPrint('=== CART BLOC: Reloading cart after add ===');
          add(LoadCartEvent(event.cartId));
        },
      );
    } catch (e) {
      debugPrint('=== CART BLOC: Add to cart EXCEPTION: ${e.toString()} ===');
      emit(CartError('Failed to add item to cart: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveFromCart(RemoveFromCartEvent event, Emitter<CartState> emit) async {
    try {
      final result = await deleteCartItem(event.cartItemId);

      await result.fold((failure) async => emit(CartError(failure.toString())), (success) async {
        emit(CartItemRemoved(event.cartItemId));

        // Reload cart to get updated list
        add(LoadCartEvent(event.cartId));
      });
    } catch (e) {
      emit(CartError('Failed to remove item from cart: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCartItem(UpdateCartItemEvent event, Emitter<CartState> emit) async {
    try {
      final result = await updateCartItem(
        UpdateCartItemParams(cartItemId: event.cartItemId, quantity: event.quantity, quantityPcs: event.quantityPcs, notes: event.notes),
      );

      await result.fold((failure) async => emit(CartError(failure.toString())), (updatedItem) async {
        // Reload cart to get updated list
        add(LoadCartEvent(event.cartId));
      });
    } catch (e) {
      emit(CartError('Failed to update cart item: ${e.toString()}'));
    }
  }

  Future<void> _onClearCart(ClearCartEvent event, Emitter<CartState> emit) async {
    try {
      final result = await clearCart(event.cartId);

      await result.fold((failure) async => emit(CartError(failure.toString())), (success) async {
        emit(CartCleared());
        emit(const CartLoaded(items: [], totalAmount: 0));
      });
    } catch (e) {
      emit(CartError('Failed to clear cart: ${e.toString()}'));
    }
  }

  Future<void> _onCheckoutCart(CheckoutCartEvent event, Emitter<CartState> emit) async {
    debugPrint('=== CART BLOC: Checking out cart with cartId: ${event.cartId} ===');
    emit(CartLoading());
    try {
      final result = await checkoutCart(
        CheckoutCartParams(cartId: event.cartId, paymentMethod: event.paymentMethod, paymentGateway: event.paymentGateway, notes: event.notes),
      );

      await result.fold(
        (failure) async {
          debugPrint('=== CART BLOC: Checkout FAILED: ${failure.toString()} ===');
          emit(CartError(failure.toString()));
        },
        (transaction) async {
          debugPrint('=== CART BLOC: Checkout SUCCESS - transactionId: ${transaction.id}, number: ${transaction.transactionNumber} ===');
          emit(
            CartCheckedOut(
              transactionId: transaction.id,
              transactionNumber: transaction.transactionNumber,
              totalAmount: transaction.totalAmount,
              paymentMethod: transaction.paymentMethod,
              qrisString: transaction.qrisString,
              qrisExpiredAt: transaction.qrisExpiredAt,
            ),
          );

          // Clear cart after successful checkout
          debugPrint('=== CART BLOC: Clearing cart after successful checkout ===');
          add(ClearCartEvent(event.cartId));
        },
      );
    } catch (e) {
      debugPrint('=== CART BLOC: Checkout EXCEPTION: ${e.toString()} ===');
      emit(CartError('Failed to checkout: ${e.toString()}'));
    }
  }
}
