# KGiTON Example App - BLoC State Management

Contoh aplikasi Flutter menggunakan **KGiTON SDK** dengan **BLoC (Business Logic Component)** sebagai state management.

## 📋 Fitur

- ✅ Register & Login dengan License Key
- ✅ Scan QR Code untuk License Key
- ✅ Scan & Connect device BLE
- ✅ Real-time weight monitoring
- ✅ Buzzer control

## 🏗️ Struktur Project

```
lib/
├── main.dart                      # Entry point & BLoC setup
├── src/
│   ├── config/
│   │   ├── constants.dart
│   │   └── theme.dart
│   │
│   ├── bloc/
│   │   ├── auth/
│   │   │   ├── auth_bloc.dart     # Business logic
│   │   │   ├── auth_event.dart    # Events (actions)
│   │   │   └── auth_state.dart    # States (UI states)
│   │   └── scale/
│   │       ├── scale_bloc.dart
│   │       ├── scale_event.dart
│   │       └── scale_state.dart
│   │
│   └── screens/
│       ├── splash_screen.dart
│       ├── auth/
│       │   └── auth_screen.dart
│       ├── home/
│       │   └── home_screen.dart
│       └── device/
│           └── device_screen.dart
```

## 🚀 Setup

```bash
cd example/bloc/kgiton_apps
flutter pub get
flutter run
```

## 📚 Konsep BLoC Pattern

### Alur Data BLoC

```
┌─────────┐     ┌───────────┐     ┌─────────┐     ┌────────┐
│   UI    │ --> │   Event   │ --> │   BLoC  │ --> │  State │ --> UI
└─────────┘     └───────────┘     └─────────┘     └────────┘
```

1. **UI** mengirim **Event** ke BLoC
2. **BLoC** memproses Event dan emit **State** baru
3. **UI** rebuild berdasarkan State baru

### Definisi Event

```dart
// Events adalah aksi yang dikirim dari UI
abstract class AuthEvent extends Equatable {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  
  const LoginEvent({required this.email, required this.password});
}
```

### Definisi State

```dart
// States merepresentasikan kondisi UI
abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated({required this.user});
}
class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
}
```

### Membuat BLoC

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    // Register event handlers
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }
  
  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await apiService.login(event.email, event.password);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
```

### Menggunakan BLoC di UI

```dart
// Kirim Event
context.read<AuthBloc>().add(LoginEvent(
  email: 'user@email.com',
  password: 'password123',
));

// BlocBuilder - rebuild UI berdasarkan state
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    }
    if (state is AuthAuthenticated) {
      return Text('Welcome ${state.user.name}');
    }
    return LoginForm();
  },
)

// BlocListener - untuk side effects (navigasi, snackbar)
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      Navigator.pushReplacement(context, HomeScreen());
    }
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: YourWidget(),
)

// BlocConsumer - kombinasi Builder + Listener
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    // Side effects
  },
  builder: (context, state) {
    // Build UI
  },
)
```

## 📝 Best Practices

1. **Immutable States**: States harus immutable, gunakan `copyWith` untuk update
2. **Single Responsibility**: Satu BLoC untuk satu domain (Auth, Scale, dll)
3. **Equatable**: Gunakan Equatable untuk optimasi rebuild
4. **BlocObserver**: Gunakan untuk debugging dan logging
5. **Testing**: BLoC mudah di-unit test karena pure functions

## 🧪 Testing

```dart
void main() {
  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when login succeeds',
    build: () => AuthBloc(),
    act: (bloc) => bloc.add(LoginEvent(email: 'test@email.com', password: 'password')),
    expect: () => [
      AuthLoading(),
      isA<AuthAuthenticated>(),
    ],
  );
}
```

## 🔗 Referensi

- [BLoC Library](https://bloclibrary.dev/)
- [flutter_bloc Package](https://pub.dev/packages/flutter_bloc)
- [KGiTON SDK Documentation](../../../docs/)
