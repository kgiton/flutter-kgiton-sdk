/// User model
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String apiKey;
  final String? phoneNumber;
  final String referralCode;
  final String? referredBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.apiKey,
    this.phoneNumber,
    required this.referralCode,
    this.referredBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'user',
      apiKey: (json['api_key'] as String?) ?? '',
      phoneNumber: json['phone_number'] as String?,
      referralCode: (json['referral_code'] as String?) ?? '',
      referredBy: json['referred_by'] as String?,
      createdAt: DateTime.parse((json['created_at'] as String?) ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse((json['updated_at'] as String?) ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'api_key': apiKey,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      'referral_code': referralCode,
      if (referredBy != null) 'referred_by': referredBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if user is super admin
  bool get isSuperAdmin => role == 'super_admin';
}

/// Session model
class Session {
  final String accessToken;
  final int expiresAt;
  final String? refreshToken;

  Session({required this.accessToken, required this.expiresAt, this.refreshToken});

  factory Session.fromJson(Map<String, dynamic> json) {
    // Handle different response structures
    // If access_token is directly in json (flat structure from API)
    if (json.containsKey('access_token') && !json.containsKey('session')) {
      return Session(
        accessToken: (json['access_token'] as String?) ?? '',
        refreshToken: json['refresh_token'] as String?,
        expiresAt: (json['expires_at'] as int?) ?? _getDefaultExpiresAt(),
      );
    }
    // If session object exists (nested structure)
    else if (json.containsKey('session')) {
      final session = json['session'] as Map<String, dynamic>?;
      return Session(
        accessToken: (session?['access_token'] as String?) ?? '',
        refreshToken: session?['refresh_token'] as String?,
        expiresAt: (session?['expires_at'] as int?) ?? _getDefaultExpiresAt(),
      );
    }
    // Default fallback
    return Session(
      accessToken: (json['access_token'] as String?) ?? '',
      refreshToken: json['refresh_token'] as String?,
      expiresAt: (json['expires_at'] as int?) ?? _getDefaultExpiresAt(),
    );
  }

  /// Get default expires_at timestamp (1 hour from now)
  static int _getDefaultExpiresAt() {
    return DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
  }

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'expires_at': expiresAt, if (refreshToken != null) 'refresh_token': refreshToken};
  }

  /// Check if session is expired
  bool get isExpired {
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return DateTime.now().isAfter(expiryTime);
  }
}

/// Auth response data (login response)
class AuthData {
  final User user;
  final Session session;

  AuthData({required this.user, required this.session});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    // Handle API response structure where user and tokens are at same level
    final userJson = json['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw FormatException('User data is missing in response');
    }

    // Create session from flat structure (access_token at root level)
    final session = Session.fromJson(json);

    return AuthData(user: User.fromJson(userJson), session: session);
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'session': session.toJson()};
  }

  /// Get access token from session
  String get accessToken => session.accessToken;
}

/// Register request
class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String licenseKey;
  final String? referralCode;

  RegisterRequest({required this.email, required this.password, required this.name, required this.licenseKey, this.referralCode});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'name': name, 'license_key': licenseKey, if (referralCode != null) 'referral_code': referralCode};
  }
}

/// Login request
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

/// Forgot password request
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

/// Reset password request
class ResetPasswordRequest {
  final String token;
  final String newPassword;

  ResetPasswordRequest({required this.token, required this.newPassword});

  Map<String, dynamic> toJson() {
    return {'token': token, 'new_password': newPassword};
  }
}
