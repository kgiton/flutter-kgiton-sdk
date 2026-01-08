/// ============================================================================
/// User Entity - Domain Layer
/// ============================================================================
/// 
/// File: src/domain/entities/user_entity.dart
/// Deskripsi: Entity adalah object bisnis murni tanpa dependency ke framework
/// 
/// Entity vs Model:
/// - Entity: Domain layer, murni Dart, business logic
/// - Model: Data layer, bisa ada annotation untuk serialization
/// ============================================================================

import 'package:equatable/equatable.dart';

/// User entity - representasi user dalam domain layer
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String apiKey;
  final String? phoneNumber;
  final String referralCode;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.apiKey,
    this.phoneNumber,
    required this.referralCode,
    required this.createdAt,
  });

  /// Check if user is admin
  bool get isAdmin => role == 'admin' || role == 'super_admin';

  @override
  List<Object?> get props => [id, name, email, role, apiKey, phoneNumber, referralCode, createdAt];
}
