/// ============================================================================
/// Auth BLoC
/// ============================================================================
/// 
/// File: src/presentation/bloc/auth/auth_bloc.dart
/// Deskripsi: BLoC untuk manajemen authentication
/// 
/// Menggunakan Clean Architecture dengan Use Cases:
/// - LoginUseCase: Handle login
/// - RegisterUseCase: Handle registrasi
/// - LogoutUseCase: Handle logout
/// - GetCurrentUserUseCase: Ambil current user
/// - GetUserLicensesUseCase: Ambil licenses user
/// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/register_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import '../../../domain/usecases/get_user_licenses_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GetUserLicensesUseCase getUserLicensesUseCase;
  final AuthRepository authRepository;
  
  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.getUserLicensesUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<LoadLicensesEvent>(_onLoadLicenses);
  }
  
  /// Handle check auth status
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCheckingStatus());
    
    final isLoggedIn = await authRepository.isLoggedIn();
    
    if (isLoggedIn) {
      final result = await getCurrentUserUseCase();
      result.fold(
        (failure) => emit(const AuthUnauthenticated()),
        (user) {
          emit(AuthAuthenticated(user: user));
          // Load licenses setelah authenticated
          add(const LoadLicensesEvent());
        },
      );
    } else {
      emit(const AuthUnauthenticated());
    }
  }
  
  /// Handle login
  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) {
        emit(AuthAuthenticated(user: user));
        // Load licenses setelah login
        add(const LoadLicensesEvent());
      },
    );
  }
  
  /// Handle register
  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    final result = await registerUseCase(RegisterParams(
      name: event.name,
      email: event.email,
      password: event.password,
      licenseKey: event.licenseKey,
      referralCode: event.referralCode,
    ));
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (message) => emit(AuthRegisterSuccess(message: message)),
    );
  }
  
  /// Handle logout
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    await logoutUseCase();
    emit(const AuthUnauthenticated());
  }
  
  /// Handle load licenses
  Future<void> _onLoadLicenses(
    LoadLicensesEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;
    
    final result = await getUserLicensesUseCase();
    
    result.fold(
      (failure) {
        // Tidak emit error, tetap di authenticated state
      },
      (licenses) {
        emit(currentState.copyWith(licenses: licenses));
      },
    );
  }
}
