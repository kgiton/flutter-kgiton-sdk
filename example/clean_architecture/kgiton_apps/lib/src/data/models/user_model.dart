/// ============================================================================
/// User Model
/// ============================================================================
/// 
/// File: src/data/models/user_model.dart
/// Deskripsi: Data model untuk User, extends dari UserEntity
/// ============================================================================

import 'package:kgiton_sdk/kgiton_sdk.dart';

import '../../domain/entities/user_entity.dart';

/// User Model - Data layer representation
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.apiKey,
    super.phoneNumber,
    required super.referralCode,
    required super.createdAt,
  });
  
  /// Factory dari SDK AuthData model (login response)
  factory UserModel.fromSdkAuthData(AuthData authData) {
    final user = authData.user;
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      apiKey: user.apiKey,
      phoneNumber: user.phoneNumber,
      referralCode: user.referralCode,
      createdAt: user.createdAt,
    );
  }
  
  /// Factory dari SDK UserProfileData (getProfile response)
  factory UserModel.fromProfile(UserProfileData profile) {
    return UserModel(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      role: profile.role,
      apiKey: profile.apiKey,
      phoneNumber: null,
      referralCode: '',
      createdAt: profile.createdAt,
    );
  }
  
  /// Factory dari JSON (untuk cache)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'user',
      apiKey: json['apiKey'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      referralCode: json['referralCode'] as String? ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
  
  /// Convert ke JSON (untuk cache)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'apiKey': apiKey,
      'phoneNumber': phoneNumber,
      'referralCode': referralCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  /// Convert ke entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      role: role,
      apiKey: apiKey,
      phoneNumber: phoneNumber,
      referralCode: referralCode,
      createdAt: createdAt,
    );
  }
}
