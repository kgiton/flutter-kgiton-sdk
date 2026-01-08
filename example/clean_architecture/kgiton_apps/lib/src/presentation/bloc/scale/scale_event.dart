/// ============================================================================
/// Scale Events
/// ============================================================================
/// 
/// File: src/presentation/bloc/scale/scale_event.dart
/// Deskripsi: Events untuk Scale BLoC
/// ============================================================================

import 'package:equatable/equatable.dart';

import '../../../domain/entities/scale_device_entity.dart';

/// Base class untuk Scale Events
abstract class ScaleEvent extends Equatable {
  const ScaleEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event: Start scanning untuk devices
class StartScanEvent extends ScaleEvent {
  const StartScanEvent();
}

/// Event: Stop scanning
class StopScanEvent extends ScaleEvent {
  const StopScanEvent();
}

/// Event: Devices found saat scanning
class DevicesFoundEvent extends ScaleEvent {
  final List<ScaleDeviceEntity> devices;
  
  const DevicesFoundEvent({required this.devices});
  
  @override
  List<Object?> get props => [devices];
}

/// Event: Connect ke device dengan license key
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

/// Event: Disconnect dari device
class DisconnectDeviceEvent extends ScaleEvent {
  final String licenseKey;
  
  const DisconnectDeviceEvent({required this.licenseKey});
  
  @override
  List<Object?> get props => [licenseKey];
}

/// Event: Weight data received
class WeightReceivedEvent extends ScaleEvent {
  final double weight;
  
  const WeightReceivedEvent({required this.weight});
  
  @override
  List<Object?> get props => [weight];
}

/// Event: Trigger buzzer
class TriggerBuzzerEvent extends ScaleEvent {
  const TriggerBuzzerEvent();
}
