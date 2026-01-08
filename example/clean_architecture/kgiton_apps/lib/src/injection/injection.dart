/// ============================================================================
/// Dependency Injection Configuration
/// ============================================================================
///
/// File: src/injection/injection.dart
/// Deskripsi: Setup GetIt untuk dependency injection
///
/// Clean Architecture membutuhkan DI untuk:
/// 1. Memisahkan pembuatan object dari penggunaan
/// 2. Memudahkan testing dengan mock dependencies
/// 3. Mengikuti Dependency Inversion Principle
/// ============================================================================

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

// Core
import '../core/constants/constants.dart';

// Domain Layer - Use Cases
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/register_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/get_user_licenses_usecase.dart';
import '../domain/usecases/scan_devices_usecase.dart';
import '../domain/usecases/connect_device_usecase.dart';

// Domain Layer - Repositories (Interfaces)
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/scale_repository.dart';

// Data Layer - Repository Implementations
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/scale_repository_impl.dart';

// Data Layer - Data Sources
import '../data/datasources/auth_local_datasource.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/datasources/scale_datasource.dart';

// Presentation Layer - BLoCs
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/scale/scale_bloc.dart';

/// Global GetIt instance
final getIt = GetIt.instance;

/// Configure all dependencies
///
/// Urutan registrasi penting:
/// 1. External dependencies (SharedPreferences, API client)
/// 2. Data sources
/// 3. Repositories
/// 4. Use cases
/// 5. BLoCs
Future<void> configureDependencies() async {
  // ==========================================================================
  // External Dependencies
  // ==========================================================================

  // SharedPreferences - async initialization
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // KGiTON API Service
  getIt.registerLazySingleton<KgitonApiService>(
    () => KgitonApiService(baseUrl: AppConstants.apiBaseUrl),
  );

  // KGiTON Scale Service
  getIt.registerLazySingleton<KGiTONScaleService>(
    () => KGiTONScaleService(),
  );

  // ==========================================================================
  // Data Sources
  // ==========================================================================

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: getIt()),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiService: getIt()),
  );

  getIt.registerLazySingleton<ScaleDataSource>(
    () => ScaleDataSourceImpl(scaleService: getIt()),
  );

  // ==========================================================================
  // Repositories
  // Implementasi dari domain layer interfaces
  // ==========================================================================

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  getIt.registerLazySingleton<ScaleRepository>(
    () => ScaleRepositoryImpl(
      dataSource: getIt(),
    ),
  );

  // ==========================================================================
  // Use Cases
  // Satu use case = satu action bisnis
  // ==========================================================================

  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt()));
  getIt.registerLazySingleton(() => GetUserLicensesUseCase(getIt()));
  getIt.registerLazySingleton(() => ScanDevicesUseCase(getIt()));
  getIt.registerLazySingleton(() => StopScanUseCase(getIt()));
  getIt.registerLazySingleton(() => ConnectDeviceUseCase(getIt()));
  getIt.registerLazySingleton(() => DisconnectDeviceUseCase(getIt()));

  // ==========================================================================
  // BLoCs
  // ==========================================================================

  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      logoutUseCase: getIt(),
      getCurrentUserUseCase: getIt(),
      getUserLicensesUseCase: getIt(),
      authRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<ScaleBloc>(
    () => ScaleBloc(
      scanDevicesUseCase: getIt(),
      stopScanUseCase: getIt(),
      connectDeviceUseCase: getIt(),
      disconnectDeviceUseCase: getIt(),
      scaleRepository: getIt(),
    ),
  );
}
