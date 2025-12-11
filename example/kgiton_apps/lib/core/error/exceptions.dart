/// Base class for all exceptions in the application
class AppException implements Exception {
  final String message;
  final int? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

/// Server exception - when API call fails
class ServerException extends AppException {
  ServerException({required super.message, super.code});
}

/// Cache exception - when local storage fails
class CacheException extends AppException {
  CacheException({required super.message, super.code});
}

/// Network exception - when there's no internet connection
class NetworkException extends AppException {
  NetworkException({required super.message, super.code});
}

/// Validation exception - when input validation fails
class ValidationException extends AppException {
  ValidationException({required super.message, super.code});
}

/// Authentication exception - when authentication fails
class AuthenticationException extends AppException {
  AuthenticationException({required super.message, super.code});
}
