import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../../../core/usecases/usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({required this.loginUseCase, required this.registerUseCase, required this.logoutUseCase, required this.getCurrentUserUseCase})
    : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await loginUseCase(LoginParams(email: event.email, password: event.password));

    result.fold((failure) => emit(AuthError(message: failure.message)), (user) => emit(Authenticated(user: user)));
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
        licenseKey: event.licenseKey,
        entityType: event.entityType,
        companyName: event.companyName,
      ),
    );

    result.fold((failure) => emit(AuthError(message: failure.message)), (user) => emit(Authenticated(user: user)));
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await logoutUseCase(const NoParams());

    result.fold((failure) => emit(AuthError(message: failure.message)), (_) => emit(Unauthenticated()));
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await getCurrentUserUseCase(const NoParams());

    result.fold((failure) => emit(Unauthenticated()), (user) => emit(Authenticated(user: user)));
  }
}
