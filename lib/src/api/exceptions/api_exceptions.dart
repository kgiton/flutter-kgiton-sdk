/// Base exception for all KGiTON SDK API errors
class KgitonApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  KgitonApiException({required this.message, this.statusCode, this.details});

  @override
  String toString() {
    final buffer = StringBuffer('KgitonApiException: $message');
    if (statusCode != null) {
      buffer.write(' (Status Code: $statusCode)');
    }
    if (details != null) {
      buffer.write('\nDetails: $details');
    }
    return buffer.toString();
  }
}

/// Exception for validation errors (400)
class KgitonValidationException extends KgitonApiException {
  KgitonValidationException({required super.message, super.details}) : super(statusCode: 400);

  @override
  String toString() => 'KgitonValidationException: $message${details != null ? '\nDetails: $details' : ''}';
}

/// Exception for authentication errors (401)
class KgitonAuthenticationException extends KgitonApiException {
  KgitonAuthenticationException({required super.message}) : super(statusCode: 401);

  @override
  String toString() => 'KgitonAuthenticationException: $message';
}

/// Exception for authorization/permission errors (403)
class KgitonAuthorizationException extends KgitonApiException {
  KgitonAuthorizationException({required super.message}) : super(statusCode: 403);

  @override
  String toString() => 'KgitonAuthorizationException: $message';
}

/// Exception for resource not found errors (404)
class KgitonNotFoundException extends KgitonApiException {
  KgitonNotFoundException({required super.message}) : super(statusCode: 404);

  @override
  String toString() => 'KgitonNotFoundException: $message';
}

/// Exception for conflict errors (409)
class KgitonConflictException extends KgitonApiException {
  KgitonConflictException({required super.message}) : super(statusCode: 409);

  @override
  String toString() => 'KgitonConflictException: $message';
}

/// Exception for rate limit errors (429)
class KgitonRateLimitException extends KgitonApiException {
  KgitonRateLimitException({required super.message}) : super(statusCode: 429);

  @override
  String toString() => 'KgitonRateLimitException: $message';
}

/// Exception for network errors
class KgitonNetworkException extends KgitonApiException {
  KgitonNetworkException({required super.message});

  @override
  String toString() => 'KgitonNetworkException: $message';
}
