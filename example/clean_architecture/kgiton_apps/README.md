# KGiTON Example App - Clean Architecture

Contoh aplikasi menggunakan KGiTON SDK dengan **Clean Architecture** pattern.

## 📁 Struktur Folder

```
lib/
├── main.dart                    # Entry point dengan DI setup
└── src/
    ├── core/                    # Core utilities
    │   ├── constants/           # App constants
    │   ├── error/               # Failure classes
    │   └── theme/               # KGiTON theme
    │
    ├── data/                    # Data Layer
    │   ├── datasources/         # Remote & Local data sources
    │   ├── models/              # Data models (extends entities)
    │   └── repositories/        # Repository implementations
    │
    ├── domain/                  # Domain Layer (Business Logic)
    │   ├── entities/            # Business entities
    │   ├── repositories/        # Repository interfaces
    │   └── usecases/            # Use cases (business actions)
    │
    ├── injection/               # Dependency Injection
    │   └── injection.dart       # GetIt configuration
    │
    └── presentation/            # Presentation Layer
        ├── bloc/                # BLoC (auth, scale)
        └── pages/               # UI pages
```

## 🏗 Clean Architecture Layers

### 1. Domain Layer (Innermost)
Berisi business logic murni, tidak bergantung pada framework.

```dart
// Entity - Pure business object
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  // ...
}

// Repository Interface - Contract
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({...});
  Future<Either<Failure, String>> register({...});
}

// Use Case - Single business action
class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  
  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}
```

### 2. Data Layer
Implementasi repository dan data sources.

```dart
// Model - Extends Entity dengan conversion methods
class UserModel extends UserEntity {
  factory UserModel.fromSdkModel(AuthData data) => ...;
  factory UserModel.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;
}

// Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  @override
  Future<Either<Failure, UserEntity>> login({...}) async {
    try {
      final user = await remoteDataSource.login(email, password);
      await localDataSource.cacheUser(user);
      return Right(user.toEntity());
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}
```

### 3. Presentation Layer
UI components dan state management.

```dart
// BLoC - Handles UI logic
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }
}
```

## 🔧 Dependency Injection

Menggunakan **GetIt** untuk DI:

```dart
// Registrasi dependencies (urutan penting!)
Future<void> configureDependencies() async {
  // 1. External
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  
  // 2. Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiService: getIt()),
  );
  
  // 3. Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );
  
  // 4. Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  
  // 5. BLoCs
  getIt.registerFactory(() => AuthBloc(loginUseCase: getIt()));
}

// Penggunaan
final authBloc = getIt<AuthBloc>();
```

## 📦 Error Handling dengan Either

Menggunakan **dartz** package untuk functional error handling:

```dart
// Either<Left, Right> - Left untuk error, Right untuk success
Future<Either<Failure, UserEntity>> login({...}) async {
  try {
    final user = await api.login(email, password);
    return Right(user);  // Success
  } catch (e) {
    return Left(AuthFailure(message: e.toString()));  // Error
  }
}

// Folding result
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (user) => print('Success: ${user.name}'),
);
```

## 🚀 Menjalankan Aplikasi

```bash
# Install dependencies
flutter pub get

# Run app
flutter run
```

## 📱 Fitur Aplikasi

1. **Authentication**
   - Login dengan email/password
   - Register akun baru
   - Logout

2. **License Management**
   - View assigned licenses
   - Scan QR code untuk license

3. **Device Connection**
   - Scan BLE devices
   - Connect dengan license key
   - Monitor weight realtime

## 🧪 Testing

Clean Architecture memudahkan testing dengan mock:

```dart
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase loginUseCase;
  
  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
  });
  
  test('should return UserEntity on successful login', () async {
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => Right(testUser));
    
    final result = await loginUseCase(LoginParams(...));
    
    expect(result.isRight(), true);
  });
}
```

## 📚 Referensi

- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture - Reso Coder](https://resocoder.com/flutter-clean-architecture-tdd/)
- [GetIt Package](https://pub.dev/packages/get_it)
- [Dartz Package](https://pub.dev/packages/dartz)

## 📄 License

MIT License - lihat LICENSE untuk detail.
