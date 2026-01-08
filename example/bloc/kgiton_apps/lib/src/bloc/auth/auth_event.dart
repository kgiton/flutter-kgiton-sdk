/// ============================================================================
/// Auth Events - BLoC Pattern
/// ============================================================================
/// 
/// File: src/bloc/auth/auth_event.dart
/// Deskripsi: Definisi events untuk AuthBloc
/// 
/// Events adalah aksi/trigger yang dikirim dari UI ke BLoC.
/// Setiap event merepresentasikan satu aksi user.
/// 
/// Pattern:
/// - Extend dari abstract AuthEvent
/// - Gunakan Equatable untuk comparison
/// - Properties bersifat final/immutable
/// ============================================================================

import 'package:equatable/equatable.dart';

/// Base class untuk semua Auth events
/// 
/// Menggunakan Equatable untuk membandingkan events (testing & optimization)
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk cek status autentikasi saat app start
/// 
/// Dipanggil di main.dart saat app pertama kali dibuka
/// untuk mengecek apakah ada session yang tersimpan.
class CheckAuthStatusEvent extends AuthEvent {}

/// Event untuk login
/// 
/// Contoh penggunaan:
/// ```dart
/// context.read<AuthBloc>().add(
///   LoginEvent(email: 'user@email.com', password: 'password123'),
/// );
/// ```
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

/// Event untuk register
/// 
/// Membutuhkan license key yang valid untuk registrasi.
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

/// Event untuk logout
/// 
/// Akan clear session dan navigasi ke login screen.
class LogoutEvent extends AuthEvent {}

/// Event untuk refresh user data
class RefreshUserDataEvent extends AuthEvent {}

/// Event untuk clear error message
class ClearAuthErrorEvent extends AuthEvent {}
