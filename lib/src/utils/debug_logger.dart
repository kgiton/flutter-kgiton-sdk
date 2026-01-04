// ignore_for_file: avoid_print

/// Debug Logger for KGiTON SDK
///
/// This logger only prints important information:
/// - API requests and responses (when debug is enabled)
/// - Errors and exceptions
/// - Authentication events
class DebugLogger {
  static bool _isDebugMode = false;

  /// Enable or disable debug mode
  static void setDebugMode(bool enabled) {
    _isDebugMode = enabled;
  }

  /// Check if debug mode is enabled
  static bool get isDebugMode => _isDebugMode;

  /// Log API request
  static void logRequest(String method, String url, {Map<String, dynamic>? body, Map<String, String>? headers}) {
    if (!_isDebugMode) return;

    print('\n┌─────────────────────────────────────────────────');
    print('│ 🌐 API REQUEST: $method $url');
    if (headers != null && headers.isNotEmpty) {
      print('│ 📋 Headers: ${_sanitizeHeaders(headers)}');
    }
    if (body != null && body.isNotEmpty) {
      print('│ 📦 Body: ${_sanitizeBody(body)}');
    }
    print('└─────────────────────────────────────────────────\n');
  }

  /// Log API response
  static void logResponse(String method, String url, int statusCode, dynamic body) {
    if (!_isDebugMode) return;

    final icon = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    print('\n┌─────────────────────────────────────────────────');
    print('│ $icon API RESPONSE: $method $url');
    print('│ 📊 Status: $statusCode');
    print('│ 📦 Body: $body');
    print('└─────────────────────────────────────────────────\n');
  }

  /// Log error (always printed, regardless of debug mode)
  static void logError(String message, {dynamic error, StackTrace? stackTrace}) {
    print('\n┌─────────────────────────────────────────────────');
    print('│ ❌ ERROR: $message');
    if (error != null) {
      print('│ 💥 Exception: $error');
    }
    if (stackTrace != null && _isDebugMode) {
      print('│ 📍 Stack trace:');
      print(stackTrace.toString().split('\n').take(5).map((line) => '│   $line').join('\n'));
    }
    print('└─────────────────────────────────────────────────\n');
  }

  /// Log authentication event
  static void logAuth(String event, {String? details}) {
    if (!_isDebugMode) return;

    print('\n┌─────────────────────────────────────────────────');
    print('│ 🔐 AUTH EVENT: $event');
    if (details != null) {
      print('│ 📝 Details: $details');
    }
    print('└─────────────────────────────────────────────────\n');
  }

  /// Log info message (only in debug mode)
  static void logInfo(String message) {
    if (!_isDebugMode) return;

    print('ℹ️  $message');
  }

  /// Sanitize headers (hide sensitive data)
  static Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);

    // Hide authorization token
    if (sanitized.containsKey('Authorization')) {
      final authValue = sanitized['Authorization']!;
      if (authValue.startsWith('Bearer ')) {
        final token = authValue.substring(7);
        sanitized['Authorization'] = 'Bearer ${token.substring(0, 10)}...${token.substring(token.length - 10)}';
      }
    }

    // Hide API key
    if (sanitized.containsKey('X-API-Key')) {
      final apiKey = sanitized['X-API-Key']!;
      sanitized['X-API-Key'] = '${apiKey.substring(0, 10)}...${apiKey.substring(apiKey.length - 10)}';
    }

    return sanitized;
  }

  /// Sanitize body (hide sensitive data like passwords)
  static Map<String, dynamic> _sanitizeBody(Map<String, dynamic> body) {
    final sanitized = Map<String, dynamic>.from(body);

    // Hide password fields
    if (sanitized.containsKey('password')) {
      sanitized['password'] = '***HIDDEN***';
    }
    if (sanitized.containsKey('newPassword')) {
      sanitized['newPassword'] = '***HIDDEN***';
    }
    if (sanitized.containsKey('oldPassword')) {
      sanitized['oldPassword'] = '***HIDDEN***';
    }

    return sanitized;
  }
}
