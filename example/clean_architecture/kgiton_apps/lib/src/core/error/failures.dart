/// ============================================================================
/// Failure Classes - Core Error Handling
/// ============================================================================
/// 
/// File: src/core/error/failures.dart
/// Deskripsi: Failure classes untuk error handling dengan Either
/// ============================================================================

import 'package:equatable/equatable.dart';

/// Base class untuk semua failures
abstract class Failure extends Equatable {
  final String message;
  
  const Failure({required this.message});
  
  @override
  List<Object> get props => [message];
}

/// Server failure (API errors)
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Cache failure (local storage errors)
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Tidak ada koneksi internet'});
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// BLE failure
class BleFailure extends Failure {
  const BleFailure({required super.message});
}
