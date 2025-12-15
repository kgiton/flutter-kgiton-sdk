/// User model
class User {
  final String id;
  final String email;

  User({required this.id, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: (json['id'] as String?) ?? '', email: (json['email'] as String?) ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email};
  }
}

/// User profile model
class UserProfile {
  final String userId;
  final String role;
  final String entityType;
  final String name;
  final String? fullName;
  final String? companyName;

  UserProfile({required this.userId, required this.role, required this.entityType, required this.name, this.fullName, this.companyName});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: (json['user_id'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'user',
      entityType: (json['entity_type'] as String?) ?? 'individual',
      name: (json['name'] as String?) ?? 'Unknown',
      fullName: json['full_name'] as String?,
      companyName: json['company_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role': role,
      'entity_type': entityType,
      'name': name,
      if (fullName != null) 'full_name': fullName,
      if (companyName != null) 'company_name': companyName,
    };
  }
}

/// Auth response data
class AuthData {
  final User user;
  final UserProfile profile;
  final String accessToken;
  final String? refreshToken;

  AuthData({required this.user, required this.profile, required this.accessToken, this.refreshToken});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      profile: UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'profile': profile.toJson(), 'access_token': accessToken, if (refreshToken != null) 'refresh_token': refreshToken};
  }
}

/// Current user data
class CurrentUserData {
  final User user;
  final UserProfile profile;

  CurrentUserData({required this.user, required this.profile});

  factory CurrentUserData.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw FormatException('Invalid CurrentUserData format: expected Map, got ${json.runtimeType}');
    }

    // Check if response has nested 'user' and 'profile' keys
    if (json.containsKey('user') && json.containsKey('profile')) {
      return CurrentUserData(
        user: User.fromJson(json['user'] as Map<String, dynamic>),
        profile: UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      );
    }

    // Handle flat structure where user and profile data are mixed
    // Try to extract user fields (id, email)
    if (json.containsKey('id') && json.containsKey('email')) {
      final user = User(id: (json['id'] as String?) ?? '', email: (json['email'] as String?) ?? '');

      // Extract profile fields with safe defaults
      final profile = UserProfile(
        userId: (json['user_id'] as String?) ?? (json['id'] as String?) ?? '',
        role: (json['role'] as String?) ?? 'user',
        entityType: (json['entity_type'] as String?) ?? 'individual',
        name: (json['name'] as String?) ?? 'Unknown',
        fullName: json['full_name'] as String?,
        companyName: json['company_name'] as String?,
      );

      return CurrentUserData(user: user, profile: profile);
    }

    throw FormatException('Invalid CurrentUserData format: missing required fields');
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'profile': profile.toJson()};
  }
}

/// Register owner request
class RegisterOwnerRequest {
  final String email;
  final String password;
  final String licenseKey;
  final String entityType;
  final String name;

  RegisterOwnerRequest({required this.email, required this.password, required this.licenseKey, required this.entityType, required this.name});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'license_key': licenseKey, 'entity_type': entityType, 'name': name};
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

/// Change password request
class ChangePasswordRequest {
  final String oldPassword;
  final String newPassword;

  ChangePasswordRequest({required this.oldPassword, required this.newPassword});

  Map<String, dynamic> toJson() {
    return {'old_password': oldPassword, 'new_password': newPassword};
  }
}
