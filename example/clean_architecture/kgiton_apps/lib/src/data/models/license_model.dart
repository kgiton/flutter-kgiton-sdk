/// ============================================================================
/// License Model
/// ============================================================================
/// 
/// File: src/data/models/license_model.dart
/// Deskripsi: Data model untuk License, extends dari LicenseEntity
/// ============================================================================

import 'package:kgiton_sdk/kgiton_sdk.dart';

import '../../domain/entities/license_entity.dart';

/// License Model - Data layer representation
class LicenseModel extends LicenseEntity {
  const LicenseModel({
    required super.id,
    required super.key,
    required super.tokenBalance,
    required super.status,
    super.deviceName,
    super.deviceSerialNumber,
    required super.createdAt,
  });
  
  /// Factory dari SDK LicenseKey model
  factory LicenseModel.fromSdkModel(LicenseKey license) {
    return LicenseModel(
      id: license.id,
      key: license.key,
      tokenBalance: license.tokenBalance,
      status: license.status,
      deviceName: license.deviceName,
      deviceSerialNumber: license.deviceSerialNumber,
      createdAt: license.createdAt,
    );
  }
  
  /// Factory dari JSON
  factory LicenseModel.fromJson(Map<String, dynamic> json) {
    return LicenseModel(
      id: json['id'] as String,
      key: json['key'] as String,
      tokenBalance: json['tokenBalance'] as int? ?? 0,
      status: json['status'] as String? ?? 'inactive',
      deviceName: json['deviceName'] as String?,
      deviceSerialNumber: json['deviceSerialNumber'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
  
  /// Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'tokenBalance': tokenBalance,
      'status': status,
      'deviceName': deviceName,
      'deviceSerialNumber': deviceSerialNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  /// Convert ke entity
  LicenseEntity toEntity() {
    return LicenseEntity(
      id: id,
      key: key,
      tokenBalance: tokenBalance,
      status: status,
      deviceName: deviceName,
      deviceSerialNumber: deviceSerialNumber,
      createdAt: createdAt,
    );
  }
}
