import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';
import 'exceptions/api_exceptions.dart';
import 'models/api_response.dart';

/// API Client configuration and management
class KgitonApiClient {
  String _baseUrl;
  String? _accessToken;
  String? _refreshToken;
  final http.Client _httpClient;

  KgitonApiClient({String? baseUrl, String? accessToken, String? refreshToken, http.Client? httpClient})
    : _baseUrl = baseUrl ?? KgitonApiConfig.defaultBaseUrl,
      _accessToken = accessToken,
      _refreshToken = refreshToken,
      _httpClient = httpClient ?? http.Client();

  /// Get base URL
  String get baseUrl => _baseUrl;

  /// Get access token
  String? get accessToken => _accessToken;

  /// Get refresh token
  String? get refreshToken => _refreshToken;

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

  /// Set both tokens
  void setTokens({String? accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  /// Clear all tokens
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  /// Check if access token exists
  bool hasAccessToken() {
    return _accessToken != null && _accessToken!.isNotEmpty;
  }

  /// Check if refresh token exists
  bool hasRefreshToken() {
    return _refreshToken != null && _refreshToken!.isNotEmpty;
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
  }

  /// Load configuration from local storage
  Future<void> loadConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(KgitonApiConfig.baseUrlStorageKey) ?? _baseUrl;
    _accessToken = prefs.getString(KgitonApiConfig.accessTokenStorageKey);
    _refreshToken = prefs.getString(KgitonApiConfig.refreshTokenStorageKey);
  }

  /// Clear saved configuration
  Future<void> clearConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KgitonApiConfig.accessTokenStorageKey);
    await prefs.remove(KgitonApiConfig.refreshTokenStorageKey);
    clearTokens();
  }

  /// Get default headers
  Map<String, String> _getHeaders({bool requiresAuth = false}) {
    final headers = <String, String>{'Content-Type': 'application/json', 'Accept': 'application/json'};

    if (requiresAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
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
    final Map<String, dynamic> jsonBody;

    try {
      jsonBody = json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw KgitonApiException(message: 'Invalid JSON response', statusCode: response.statusCode);
    }

    // Handle success responses
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse<T>.fromJson(jsonBody, fromJsonT);
    }

    // Handle error responses
    final message = jsonBody['message'] as String? ?? 'Unknown error';
    final details = jsonBody['details'];

    switch (response.statusCode) {
      case 400:
        throw KgitonValidationException(message: message, details: details);
      case 401:
        throw KgitonAuthenticationException(message: message);
      case 403:
        throw KgitonAuthorizationException(message: message);
      case 404:
        throw KgitonNotFoundException(message: message);
      case 409:
        throw KgitonConflictException(message: message);
      case 429:
        throw KgitonRateLimitException(message: message);
      default:
        throw KgitonApiException(message: message, statusCode: response.statusCode, details: details);
    }
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requiresAuth = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      var uri = Uri.parse(_buildUrl(endpoint));
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final response = await _httpClient.get(uri, headers: _getHeaders(requiresAuth: requiresAuth)).timeout(KgitonApiConfig.requestTimeout);

      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      if (e is KgitonApiException) rethrow;
      throw KgitonApiException(message: 'Network error: $e');
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(String endpoint, {Map<String, dynamic>? body, bool requiresAuth = false, T Function(dynamic)? fromJsonT}) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));

      final response = await _httpClient
          .post(
            uri,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(KgitonApiConfig.requestTimeout);

      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      if (e is KgitonApiException) rethrow;
      throw KgitonApiException(message: 'Network error: $e');
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(String endpoint, {Map<String, dynamic>? body, bool requiresAuth = false, T Function(dynamic)? fromJsonT}) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));

      final response = await _httpClient
          .put(
            uri,
            headers: _getHeaders(requiresAuth: requiresAuth),
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
  Future<ApiResponse<T>> delete<T>(String endpoint, {Map<String, dynamic>? body, bool requiresAuth = false, T Function(dynamic)? fromJsonT}) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));

      final response = await _httpClient
          .delete(
            uri,
            headers: _getHeaders(requiresAuth: requiresAuth),
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
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      final headers = _getHeaders(requiresAuth: requiresAuth);
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
