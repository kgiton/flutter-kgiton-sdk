/// ============================================================================
/// Auth States - BLoC Pattern
/// ============================================================================
/// 
/// File: src/bloc/auth/auth_state.dart
/// Deskripsi: Definisi states untuk AuthBloc
/// 
/// States merepresentasikan kondisi UI pada waktu tertentu.
/// Setiap state change akan trigger rebuild pada widget yang listen.
/// 
/// Pattern:
/// - Extend dari abstract AuthState
/// - Gunakan Equatable untuk comparison (optimization)
/// - States bersifat immutable
/// ============================================================================

import 'package:equatable/equatable.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

/// Base class untuk semua Auth states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// State awal saat BLoC pertama kali dibuat
/// 
/// UI biasanya menampilkan loading indicator saat state ini aktif.
class AuthInitial extends AuthState {}

/// State saat proses autentikasi sedang berjalan
/// 
/// Contoh: saat login/register sedang diproses
class AuthLoading extends AuthState {}

/// State saat user berhasil terautentikasi
/// 
/// Berisi data user dan licenses yang dimiliki.
/// UI akan menampilkan dashboard/home screen.
class AuthAuthenticated extends AuthState {
  final User user;
  final List<LicenseKey> licenses;
  final KgitonApiService apiService;

  const AuthAuthenticated({
    required this.user,
    required this.licenses,
    required this.apiService,
  });

  /// Primary license key (untuk convenience)
  String? get primaryLicenseKey => licenses.isNotEmpty ? licenses.first.key : null;

  @override
  List<Object?> get props => [user, licenses];
  
  /// CopyWith untuk update state dengan data baru
  AuthAuthenticated copyWith({
    User? user,
    List<LicenseKey>? licenses,
    KgitonApiService? apiService,
  }) {
    return AuthAuthenticated(
      user: user ?? this.user,
      licenses: licenses ?? this.licenses,
      apiService: apiService ?? this.apiService,
    );
  }
}

/// State saat user belum/tidak terautentikasi
/// 
/// UI akan menampilkan login/register screen.
class AuthUnauthenticated extends AuthState {}

/// State saat registrasi berhasil
/// 
/// User perlu verifikasi email sebelum bisa login.
class AuthRegistrationSuccess extends AuthState {
  final String message;

  const AuthRegistrationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State saat terjadi error
/// 
/// Berisi pesan error yang akan ditampilkan ke user.
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
