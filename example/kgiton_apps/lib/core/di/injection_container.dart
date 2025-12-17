import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../../features/auth/domain/usecases/enable_scale_ownership_verification_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/cart/data/datasources/cart_remote_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/add_item_to_cart.dart';
import '../../features/cart/domain/usecases/checkout_cart.dart';
import '../../features/cart/domain/usecases/clear_cart.dart';
import '../../features/cart/domain/usecases/delete_cart_item.dart';
import '../../features/cart/domain/usecases/get_cart_items.dart';
import '../../features/cart/domain/usecases/get_cart_summary.dart';
import '../../features/cart/domain/usecases/update_cart_item.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/item/data/datasources/item_remote_data_source.dart';
import '../../features/item/data/repositories/item_repository_impl.dart';
import '../../features/item/domain/repositories/item_repository.dart';
import '../../features/item/domain/usecases/clear_all_items_usecase.dart';
import '../../features/item/domain/usecases/create_item_usecase.dart';
import '../../features/item/domain/usecases/delete_item_usecase.dart';
import '../../features/item/domain/usecases/get_item_by_id_usecase.dart';
import '../../features/item/domain/usecases/get_items_usecase.dart';
import '../../features/item/domain/usecases/update_item_usecase.dart';
import '../../features/item/presentation/bloc/item_bloc.dart';
import '../../features/transaction/data/datasources/transaction_remote_data_source.dart';
import '../../features/transaction/data/repositories/transaction_repository_impl.dart';
import '../../features/transaction/domain/repositories/transaction_repository.dart';
import '../../features/transaction/domain/usecases/get_transactions.dart';
import '../../features/transaction/domain/usecases/get_transactions_by_status.dart';
import '../../features/transaction/presentation/bloc/transaction_bloc.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../config/app_config.dart';
import '../network/network_info.dart';

final sl = GetIt.instance; // Service Locator

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // ===== External =====
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => Connectivity());

  // KGiTON API Service - Using AppConfig for base URL
  final apiService = KgitonApiService(baseUrl: AppConfig.apiBaseUrl);
  sl.registerLazySingleton(() => apiService);

  // KGiTON Scale Service - Singleton
  // Note: Ownership verification akan diaktifkan via setApiService() setelah user login
  sl.registerLazySingleton(() => KGiTONScaleService());

  // ===== Core =====
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl<Connectivity>()));

  // ===== Data Sources =====
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(apiService: sl<KgitonApiService>()));

  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()));

  sl.registerLazySingleton<ItemRemoteDataSource>(() => ItemRemoteDataSourceImpl(apiService: sl<KgitonApiService>()));

  sl.registerLazySingleton<CartRemoteDataSource>(() => CartRemoteDataSourceImpl(apiService: sl<KgitonApiService>()));

  sl.registerLazySingleton<TransactionRemoteDataSource>(() => TransactionRemoteDataSourceImpl(apiService: sl<KgitonApiService>()));

  // ===== Repositories =====
  sl.registerLazySingleton<AuthRepository>(
    () =>
        AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>(), localDataSource: sl<AuthLocalDataSource>(), networkInfo: sl<NetworkInfo>()),
  );

  sl.registerLazySingleton<ItemRepository>(() => ItemRepositoryImpl(remoteDataSource: sl<ItemRemoteDataSource>(), networkInfo: sl<NetworkInfo>()));

  sl.registerLazySingleton<TransactionRepository>(() => TransactionRepositoryImpl(remoteDataSource: sl<TransactionRemoteDataSource>()));

  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(remoteDataSource: sl<CartRemoteDataSource>(), networkInfo: sl<NetworkInfo>()));

  // ===== Use Cases =====
  // Auth
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>(), sl<KGiTONScaleService>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => EnableScaleOwnershipVerificationUseCase(scaleService: sl<KGiTONScaleService>(), apiService: sl<KgitonApiService>()));

  // Item
  sl.registerLazySingleton(() => GetItemsUseCase(sl<ItemRepository>()));
  sl.registerLazySingleton(() => GetItemByIdUseCase(sl<ItemRepository>()));
  sl.registerLazySingleton(() => CreateItemUseCase(sl<ItemRepository>()));
  sl.registerLazySingleton(() => UpdateItemUseCase(sl<ItemRepository>()));
  sl.registerLazySingleton(() => DeleteItemUseCase(sl<ItemRepository>()));
  sl.registerLazySingleton(() => ClearAllItemsUseCase(sl<ItemRepository>()));

  // Cart
  sl.registerLazySingleton(() => GetCartItems(sl<CartRepository>()));
  sl.registerLazySingleton(() => GetCartSummary(sl<CartRepository>()));
  sl.registerLazySingleton(() => AddItemToCart(sl<CartRepository>()));
  sl.registerLazySingleton(() => UpdateCartItem(sl<CartRepository>()));
  sl.registerLazySingleton(() => DeleteCartItem(sl<CartRepository>()));
  sl.registerLazySingleton(() => ClearCart(sl<CartRepository>()));
  sl.registerLazySingleton(() => CheckoutCart(sl<CartRepository>()));

  // Transaction
  sl.registerLazySingleton(() => GetTransactions(sl<TransactionRepository>()));
  sl.registerLazySingleton(() => GetTransactionsByStatus(sl<TransactionRepository>()));

  // ===== BLoC =====
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
      forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
      resetPasswordUseCase: sl<ResetPasswordUseCase>(),
      changePasswordUseCase: sl<ChangePasswordUseCase>(),
      enableScaleOwnershipVerificationUseCase: sl<EnableScaleOwnershipVerificationUseCase>(),
    ),
  );

  // Item Bloc - Singleton to maintain state across navigation
  sl.registerLazySingleton(
    () => ItemBloc(
      getItemsUseCase: sl<GetItemsUseCase>(),
      getItemByIdUseCase: sl<GetItemByIdUseCase>(),
      createItemUseCase: sl<CreateItemUseCase>(),
      updateItemUseCase: sl<UpdateItemUseCase>(),
      deleteItemUseCase: sl<DeleteItemUseCase>(),
      clearAllItemsUseCase: sl<ClearAllItemsUseCase>(),
    ),
  );

  // Cart Bloc - Singleton to maintain cart across navigation
  sl.registerLazySingleton(
    () => CartBloc(
      getCartItems: sl<GetCartItems>(),
      getCartSummary: sl<GetCartSummary>(),
      addItemToCart: sl<AddItemToCart>(),
      updateCartItem: sl<UpdateCartItem>(),
      deleteCartItem: sl<DeleteCartItem>(),
      clearCart: sl<ClearCart>(),
      checkoutCart: sl<CheckoutCart>(),
    ),
  );

  // Transaction Bloc - Singleton to maintain transaction list across navigation
  sl.registerLazySingleton(() => TransactionBloc(getTransactions: sl<GetTransactions>(), getTransactionsByStatus: sl<GetTransactionsByStatus>()));
}
