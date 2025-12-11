import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server failure - when API call fails
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Cache failure - when local storage fails
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Network failure - when there's no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Validation failure - when input validation fails
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Authentication failure - when authentication fails
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message, super.code});
}

/// Authorization failure - when user doesn't have permission
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({required super.message, super.code});
}
