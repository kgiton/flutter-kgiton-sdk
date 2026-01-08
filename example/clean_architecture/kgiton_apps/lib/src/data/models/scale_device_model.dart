/// ============================================================================
/// Scale Device Model
/// ============================================================================
/// 
/// File: src/data/models/scale_device_model.dart
/// Deskripsi: Data model untuk Scale Device, extends dari ScaleDeviceEntity
/// ============================================================================

import 'package:kgiton_sdk/kgiton_sdk.dart';

import '../../domain/entities/scale_device_entity.dart';

/// Scale Device Model - Data layer representation
class ScaleDeviceModel extends ScaleDeviceEntity {
  const ScaleDeviceModel({
    required super.id,
    required super.name,
    required super.rssi,
    super.licenseKey,
  });
  
  /// Factory dari SDK ScaleDevice model
  factory ScaleDeviceModel.fromSdkModel(ScaleDevice device) {
    return ScaleDeviceModel(
      id: device.id,
      name: device.name,
      rssi: device.rssi,
    );
  }
  
  /// Factory dari JSON
  factory ScaleDeviceModel.fromJson(Map<String, dynamic> json) {
    return ScaleDeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      rssi: json['rssi'] as int? ?? -100,
      licenseKey: json['licenseKey'] as String?,
    );
  }
  
  /// Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rssi': rssi,
      'licenseKey': licenseKey,
    };
  }
  
  /// Convert ke entity
  ScaleDeviceEntity toEntity() {
    return ScaleDeviceEntity(
      id: id,
      name: name,
      rssi: rssi,
      licenseKey: licenseKey,
    );
  }
}
