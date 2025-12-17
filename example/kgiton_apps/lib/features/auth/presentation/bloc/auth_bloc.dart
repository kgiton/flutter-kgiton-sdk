import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/enable_scale_ownership_verification_usecase.dart';
import '../../../../core/usecases/usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final EnableScaleOwnershipVerificationUseCase enableScaleOwnershipVerificationUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.changePasswordUseCase,
    required this.enableScaleOwnershipVerificationUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await loginUseCase(LoginParams(email: event.email, password: event.password));

    result.fold((failure) => emit(AuthError(message: failure.message)), (user) {
      // Enable ownership verification setelah login berhasil
      enableScaleOwnershipVerificationUseCase();
      emit(Authenticated(user: user));
    });
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

    result.fold((failure) => emit(AuthError(message: failure.message)), (user) {
      // Enable ownership verification setelah register berhasil
      enableScaleOwnershipVerificationUseCase();
      emit(Authenticated(user: user));
    });
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await logoutUseCase(const NoParams());

    result.fold((failure) => emit(AuthError(message: failure.message)), (_) => emit(Unauthenticated()));
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await getCurrentUserUseCase(const NoParams());

    result.fold((failure) => emit(Unauthenticated()), (user) {
      // Enable ownership verification jika user sudah authenticated
      enableScaleOwnershipVerificationUseCase();
      emit(Authenticated(user: user));
    });
  }

  Future<void> _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await forgotPasswordUseCase(ForgotPasswordParams(email: event.email));

    result.fold((failure) => emit(AuthError(message: failure.message)), (_) => emit(const PasswordResetEmailSent()));
  }

  Future<void> _onResetPasswordRequested(ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await resetPasswordUseCase(ResetPasswordParams(token: event.token, newPassword: event.newPassword));

    result.fold((failure) => emit(AuthError(message: failure.message)), (_) => emit(const PasswordResetSuccess()));
  }

  Future<void> _onChangePasswordRequested(ChangePasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await changePasswordUseCase(ChangePasswordParams(oldPassword: event.oldPassword, newPassword: event.newPassword));

    result.fold((failure) => emit(AuthError(message: failure.message)), (_) => emit(const PasswordChangeSuccess()));
  }
}
