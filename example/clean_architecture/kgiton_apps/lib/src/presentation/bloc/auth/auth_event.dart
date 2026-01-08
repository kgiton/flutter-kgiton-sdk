/// ============================================================================
/// Auth Events
/// ============================================================================
/// 
/// File: src/presentation/bloc/auth/auth_event.dart
/// Deskripsi: Events untuk Auth BLoC
/// ============================================================================

import 'package:equatable/equatable.dart';

/// Base class untuk Auth Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event: Check auth status saat app start
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Event: Login user
class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  
  const LoginEvent({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object?> get props => [email, password];
}

/// Event: Register user baru
class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String licenseKey;
  final String? referralCode;
  
  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.licenseKey,
    this.referralCode,
  });
  
  @override
  List<Object?> get props => [name, email, password, licenseKey, referralCode];
}

/// Event: Logout user
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Event: Load user licenses
class LoadLicensesEvent extends AuthEvent {
  const LoadLicensesEvent();
}
