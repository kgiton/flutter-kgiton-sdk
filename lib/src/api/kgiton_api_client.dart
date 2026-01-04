import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';
import 'exceptions/api_exceptions.dart';
import 'models/api_response.dart';
import '../utils/debug_logger.dart';

/// API Client configuration and management
class KgitonApiClient {
  String _baseUrl;
  String? _accessToken;
  String? _refreshToken;
  String? _apiKey;
  final http.Client _httpClient;

  KgitonApiClient({String? baseUrl, String? accessToken, String? refreshToken, String? apiKey, http.Client? httpClient})
    : _baseUrl = baseUrl ?? KgitonApiConfig.defaultBaseUrl,
      _accessToken = accessToken,
      _refreshToken = refreshToken,
      _apiKey = apiKey,
      _httpClient = httpClient ?? http.Client();

  /// Get base URL
  String get baseUrl => _baseUrl;

  /// Get access token
  String? get accessToken => _accessToken;

  /// Get refresh token
  String? get refreshToken => _refreshToken;

  /// Get API key
  String? get apiKey => _apiKey;

  /// Set base URL
  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  /// Set access token
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  /// Set refresh token
  void setRefreshToken(String? token) {
    _refreshToken = token;
  }

  /// Set API key
  void setApiKey(String? key) {
    _apiKey = key;
  }

  /// Set both tokens
  void setTokens({String? accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  /// Clear all tokens and API key
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  /// Clear all credentials (tokens and API key)
  void clearCredentials() {
    _accessToken = null;
    _refreshToken = null;
    _apiKey = null;
  }

  /// Check if access token exists
  bool hasAccessToken() {
    return _accessToken != null && _accessToken!.isNotEmpty;
  }

  /// Check if refresh token exists
  bool hasRefreshToken() {
    return _refreshToken != null && _refreshToken!.isNotEmpty;
  }

  /// Check if API key exists
  bool hasApiKey() {
    return _apiKey != null && _apiKey!.isNotEmpty;
  }

  /// Save configuration to local storage
  Future<void> saveConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KgitonApiConfig.baseUrlStorageKey, _baseUrl);
    if (_accessToken != null) {
      await prefs.setString(KgitonApiConfig.accessTokenStorageKey, _accessToken!);
    } else {
      await prefs.remove(KgitonApiConfig.accessTokenStorageKey);
    }
    if (_refreshToken != null) {
      await prefs.setString(KgitonApiConfig.refreshTokenStorageKey, _refreshToken!);
    } else {
      await prefs.remove(KgitonApiConfig.refreshTokenStorageKey);
    }
    if (_apiKey != null) {
      await prefs.setString(KgitonApiConfig.apiKeyStorageKey, _apiKey!);
    } else {
      await prefs.remove(KgitonApiConfig.apiKeyStorageKey);
    }
  }

  /// Load configuration from local storage
  Future<void> loadConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(KgitonApiConfig.baseUrlStorageKey) ?? _baseUrl;
    _accessToken = prefs.getString(KgitonApiConfig.accessTokenStorageKey);
    _refreshToken = prefs.getString(KgitonApiConfig.refreshTokenStorageKey);
    _apiKey = prefs.getString(KgitonApiConfig.apiKeyStorageKey);
  }

  /// Clear saved configuration
  Future<void> clearConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KgitonApiConfig.accessTokenStorageKey);
    await prefs.remove(KgitonApiConfig.refreshTokenStorageKey);
    await prefs.remove(KgitonApiConfig.apiKeyStorageKey);
    clearCredentials();
  }

  /// Get default headers
  /// [requiresAuth] - If true, adds Bearer token or API key
  /// [useApiKey] - If true and API key exists, use API key instead of Bearer token
  Map<String, String> _getHeaders({bool requiresAuth = false, bool useApiKey = false}) {
    final headers = <String, String>{'Content-Type': 'application/json', 'Accept': 'application/json'};

    if (requiresAuth) {
      // Prefer API key if specified and available
      if (useApiKey && _apiKey != null) {
        headers['X-API-Key'] = _apiKey!;
      } else if (_accessToken != null) {
        headers['Authorization'] = 'Bearer $_accessToken';
      } else if (_apiKey != null) {
        // Fallback to API key if no access token
        headers['X-API-Key'] = _apiKey!;
      }
    }

    return headers;
  }

  /// Build full URL with API versioning
  String _buildUrl(String endpoint) {
    final cleanBase = _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$cleanBase${KgitonApiConfig.apiVersion}$cleanEndpoint';
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(http.Response response, T Function(dynamic)? fromJsonT) {
    // Handle success responses first
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> jsonBody;

      try {
        jsonBody = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw KgitonApiException(message: 'Invalid JSON response from server', statusCode: response.statusCode);
      }

      return ApiResponse<T>.fromJson(jsonBody, fromJsonT);
    }

    // Handle error responses
    Map<String, dynamic>? jsonBody;
    String errorMessage = 'Unknown error';
    dynamic errorDetails;

    try {
      jsonBody = json.decode(response.body) as Map<String, dynamic>;
      errorMessage = jsonBody['message'] as String? ?? jsonBody['error'] as String? ?? 'Unknown error';
      errorDetails = jsonBody['details'];
    } catch (e) {
      final bodyPreview = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      errorMessage = 'Server returned non-JSON response: $bodyPreview';
    }

    // Throw appropriate exception based on status code
    switch (response.statusCode) {
      case 400:
        throw KgitonValidationException(message: errorMessage, details: errorDetails);
      case 401:
        throw KgitonAuthenticationException(message: errorMessage);
      case 403:
        throw KgitonAuthorizationException(message: errorMessage);
      case 404:
        throw KgitonNotFoundException(message: errorMessage);
      case 409:
        throw KgitonConflictException(message: errorMessage);
      case 429:
        throw KgitonRateLimitException(message: errorMessage);
      case 502:
        throw KgitonApiException(
          message: 'Bad Gateway - Backend server error. Please check if the backend is running correctly.',
          statusCode: response.statusCode,
          details: errorMessage,
        );
      case 503:
        throw KgitonApiException(
          message: 'Service Unavailable - Backend server is temporarily unavailable.',
          statusCode: response.statusCode,
          details: errorMessage,
        );
      case 504:
        throw KgitonApiException(
          message: 'Gateway Timeout - Backend server took too long to respond.',
          statusCode: response.statusCode,
          details: errorMessage,
        );
      default:
        throw KgitonApiException(message: errorMessage, statusCode: response.statusCode, details: errorDetails);
    }
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requiresAuth = false,
    bool useApiKey = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      var uri = Uri.parse(_buildUrl(endpoint));
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final headers = _getHeaders(requiresAuth: requiresAuth, useApiKey: useApiKey);
      DebugLogger.logRequest('GET', uri.toString(), headers: headers);

      final response = await _httpClient.get(uri, headers: headers).timeout(KgitonApiConfig.requestTimeout);

      DebugLogger.logResponse('GET', uri.toString(), response.statusCode, response.body);
      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      DebugLogger.logError('GET request failed', error: e);
      if (e is KgitonApiException) rethrow;
      throw KgitonApiException(message: 'Network error: $e');
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    bool useApiKey = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      final headers = _getHeaders(requiresAuth: requiresAuth, useApiKey: useApiKey);

      DebugLogger.logRequest('POST', uri.toString(), headers: headers, body: body);

      final response = await _httpClient
          .post(uri, headers: headers, body: body != null ? json.encode(body) : null)
          .timeout(KgitonApiConfig.requestTimeout);

      DebugLogger.logResponse('POST', uri.toString(), response.statusCode, response.body);
      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      DebugLogger.logError('POST request failed', error: e);
      if (e is KgitonApiException) rethrow;
      throw KgitonApiException(message: 'Network error: $e');
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    bool useApiKey = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));

      final response = await _httpClient
          .put(
            uri,
            headers: _getHeaders(requiresAuth: requiresAuth, useApiKey: useApiKey),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(KgitonApiConfig.requestTimeout);

      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      if (e is KgitonApiException) rethrow;
      throw KgitonApiException(message: 'Network error: $e');
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    bool useApiKey = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));

      final response = await _httpClient
          .delete(
            uri,
            headers: _getHeaders(requiresAuth: requiresAuth, useApiKey: useApiKey),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(KgitonApiConfig.requestTimeout);

      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      if (e is KgitonApiException) rethrow;
      throw KgitonApiException(message: 'Network error: $e');
    }
  }

  /// POST multipart request (for file uploads)
  Future<ApiResponse<T>> postMultipart<T>(
    String endpoint, {
    required Map<String, String> fields,
    required String fileFieldName,
    required String filePath,
    bool requiresAuth = false,
    bool useApiKey = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      final headers = _getHeaders(requiresAuth: requiresAuth, useApiKey: useApiKey);
      headers.remove('Content-Type'); // Let multipart set its own content type
      request.headers.addAll(headers);

      // Add fields
      request.fields.addAll(fields);

      // Add file
      request.files.add(await http.MultipartFile.fromPath(fileFieldName, filePath));

      final streamedResponse = await request.send().timeout(KgitonApiConfig.requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      if (e is KgitonApiException) rethrow;
      throw KgitonApiException(message: 'Network error: $e');
    }
  }

  /// Dispose HTTP client
  void dispose() {
    _httpClient.close();
  }
}
