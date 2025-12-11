import 'package:equatable/equatable.dart';

/// User entity representing authenticated user data
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({required this.id, required this.name, required this.email, required this.role, this.phone, required this.createdAt, this.updatedAt});

  @override
  List<Object?> get props => [id, name, email, role, phone, createdAt, updatedAt];

  /// Copy with method for creating modified copies
  User copyWith({String? id, String? name, String? email, String? role, String? phone, DateTime? createdAt, DateTime? updatedAt}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
