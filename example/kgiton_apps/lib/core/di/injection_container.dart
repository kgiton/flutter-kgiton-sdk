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
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/item/data/datasources/item_remote_data_source.dart';
import '../../features/item/data/repositories/item_repository_impl.dart';
import '../../features/item/domain/repositories/item_repository.dart';
import '../../features/item/domain/usecases/create_item_usecase.dart';
import '../../features/item/domain/usecases/delete_item_permanent_usecase.dart';
import '../../features/item/domain/usecases/delete_item_usecase.dart';
import '../../features/item/domain/usecases/get_item_by_id_usecase.dart';
import '../../features/item/domain/usecases/get_items_usecase.dart';
import '../../features/item/domain/usecases/update_item_usecase.dart';
import '../../features/item/presentation/bloc/item_bloc.dart';
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

  // ===== Core =====
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl<Connectivity>()));

  // ===== Data Sources =====
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(apiService: sl<KgitonApiService>()));

  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()));

  sl.registerLazySingleton<ItemRemoteDataSource>(() => ItemRemoteDataSourceImpl(apiService: sl<KgitonApiService>()));

  // ===== Repositories =====
  sl.registerLazySingleton<AuthRepository>(
    () =>
        AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>(), localDataSource: sl<AuthLocalDataSource>(), networkInfo: sl<NetworkInfo>()),
  );

  sl.registerLazySingleton<ItemRepository>(() => ItemRepositoryImpl(remoteDataSource: sl<ItemRemoteDataSource>(), networkInfo: sl<NetworkInfo>()));

  // ===== Use Cases =====
  // Auth
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));

  // Item
  sl.registerLazySingleton(() => GetItemsUseCase(sl<ItemRepository>()));
  sl.registerLazySingleton(() => GetItemByIdUseCase(sl<ItemRepository>()));
  sl.registerLazySingleton(() => CreateItemUseCase(sl<ItemRepository>()));
  sl.registerLazySingleton(() => UpdateItemUseCase(sl<ItemRepository>()));
  sl.registerLazySingleton(() => DeleteItemUseCase(sl<ItemRepository>()));
  sl.registerLazySingleton(() => DeleteItemPermanentUseCase(sl<ItemRepository>()));

  // ===== BLoC =====
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
    ),
  );

  sl.registerFactory(
    () => ItemBloc(
      getItemsUseCase: sl<GetItemsUseCase>(),
      getItemByIdUseCase: sl<GetItemByIdUseCase>(),
      createItemUseCase: sl<CreateItemUseCase>(),
      updateItemUseCase: sl<UpdateItemUseCase>(),
      deleteItemUseCase: sl<DeleteItemUseCase>(),
      deleteItemPermanentUseCase: sl<DeleteItemPermanentUseCase>(),
    ),
  );
}
