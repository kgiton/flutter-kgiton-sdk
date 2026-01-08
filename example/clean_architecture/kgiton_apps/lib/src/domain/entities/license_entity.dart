/// ============================================================================
/// License Entity - Domain Layer
/// ============================================================================

import 'package:equatable/equatable.dart';

/// License entity
class LicenseEntity extends Equatable {
  final String id;
  final String key;
  final int tokenBalance;
  final String status;
  final String? deviceName;
  final String? deviceSerialNumber;
  final DateTime createdAt;

  const LicenseEntity({
    required this.id,
    required this.key,
    required this.tokenBalance,
    required this.status,
    this.deviceName,
    this.deviceSerialNumber,
    required this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isTrial => status == 'trial';

  @override
  List<Object?> get props => [id, key, tokenBalance, status, deviceName, createdAt];
}
