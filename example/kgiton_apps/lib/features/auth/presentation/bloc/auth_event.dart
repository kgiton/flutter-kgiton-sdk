part of 'auth_bloc.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request login
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event to request registration
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String licenseKey;
  final String entityType;
  final String? companyName;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.licenseKey,
    required this.entityType,
    this.companyName,
  });

  @override
  List<Object?> get props => [name, email, password, licenseKey, entityType, companyName];
}

/// Event to request logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Event to check authentication status
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Event to request forgot password
class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event to request password reset with token
class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordRequested({required this.token, required this.newPassword});

  @override
  List<Object?> get props => [token, newPassword];
}

/// Event to request password change for authenticated user
class ChangePasswordRequested extends AuthEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordRequested({required this.oldPassword, required this.newPassword});

  @override
  List<Object?> get props => [oldPassword, newPassword];
}
