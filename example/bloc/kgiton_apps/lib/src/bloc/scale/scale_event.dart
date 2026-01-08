/// ============================================================================
/// Scale Events - BLoC Pattern
/// ============================================================================

import 'package:equatable/equatable.dart';

/// Base class untuk semua Scale events
abstract class ScaleEvent extends Equatable {
  const ScaleEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk start scanning device BLE
class StartScanEvent extends ScaleEvent {
  final Duration? timeout;

  const StartScanEvent({this.timeout});

  @override
  List<Object?> get props => [timeout];
}

/// Event untuk stop scanning
class StopScanEvent extends ScaleEvent {}

/// Event untuk connect ke device dengan license key
class ConnectDeviceEvent extends ScaleEvent {
  final String deviceId;
  final String licenseKey;

  const ConnectDeviceEvent({
    required this.deviceId,
    required this.licenseKey,
  });

  @override
  List<Object?> get props => [deviceId, licenseKey];
}

/// Event untuk connect dengan QR code
class ConnectWithQREvent extends ScaleEvent {
  final String qrData;
  final String deviceId;

  const ConnectWithQREvent({
    required this.qrData,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [qrData, deviceId];
}

/// Event untuk disconnect
class DisconnectEvent extends ScaleEvent {
  final String? licenseKey;

  const DisconnectEvent({this.licenseKey});

  @override
  List<Object?> get props => [licenseKey];
}

/// Event untuk trigger buzzer
class TriggerBuzzerEvent extends ScaleEvent {
  final String command;

  const TriggerBuzzerEvent({required this.command});

  @override
  List<Object?> get props => [command];
}

/// Event saat weight data diterima (internal)
class WeightReceivedEvent extends ScaleEvent {
  final double weight;
  final String unit;

  const WeightReceivedEvent({
    required this.weight,
    this.unit = 'kg',
  });

  @override
  List<Object?> get props => [weight, unit];
}

/// Event saat device list diupdate (internal)
class DevicesUpdatedEvent extends ScaleEvent {
  final List<dynamic> devices;

  const DevicesUpdatedEvent({required this.devices});

  @override
  List<Object?> get props => [devices];
}

/// Event untuk clear error
class ClearScaleErrorEvent extends ScaleEvent {}
