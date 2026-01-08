/// ============================================================================
/// Scale Device Entity - Domain Layer
/// ============================================================================

import 'package:equatable/equatable.dart';

/// Scale device entity
class ScaleDeviceEntity extends Equatable {
  final String id;
  final String name;
  final int rssi;
  final String? licenseKey;

  const ScaleDeviceEntity({
    required this.id,
    required this.name,
    required this.rssi,
    this.licenseKey,
  });

  /// Signal quality based on RSSI
  SignalQuality get signalQuality {
    if (rssi >= -60) return SignalQuality.excellent;
    if (rssi >= -70) return SignalQuality.good;
    if (rssi >= -80) return SignalQuality.fair;
    return SignalQuality.poor;
  }

  @override
  List<Object?> get props => [id, name, rssi, licenseKey];
}

enum SignalQuality { excellent, good, fair, poor }
