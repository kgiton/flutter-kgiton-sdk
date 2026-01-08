/// ============================================================================
/// Auth States
/// ============================================================================
/// 
/// File: src/presentation/bloc/auth/auth_state.dart
/// Deskripsi: States untuk Auth BLoC
/// ============================================================================

import 'package:equatable/equatable.dart';

import '../../../domain/entities/license_entity.dart';
import '../../../domain/entities/user_entity.dart';

/// Base class untuk Auth States
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

/// State: Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State: Checking auth status
class AuthCheckingStatus extends AuthState {
  const AuthCheckingStatus();
}

/// State: Loading (login/register/logout)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State: User authenticated
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final List<LicenseEntity> licenses;
  
  const AuthAuthenticated({
    required this.user,
    this.licenses = const [],
  });
  
  @override
  List<Object?> get props => [user, licenses];
  
  AuthAuthenticated copyWith({
    UserEntity? user,
    List<LicenseEntity>? licenses,
  }) {
    return AuthAuthenticated(
      user: user ?? this.user,
      licenses: licenses ?? this.licenses,
    );
  }
}

/// State: User not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// State: Register success
class AuthRegisterSuccess extends AuthState {
  final String message;
  
  const AuthRegisterSuccess({required this.message});
  
  @override
  List<Object?> get props => [message];
}

/// State: Error
class AuthError extends AuthState {
  final String message;
  
  const AuthError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
