/// ============================================================================
/// Scale States
/// ============================================================================
/// 
/// File: src/presentation/bloc/scale/scale_state.dart
/// Deskripsi: States untuk Scale BLoC
/// ============================================================================

import 'package:equatable/equatable.dart';

import '../../../domain/entities/scale_device_entity.dart';

/// Base class untuk Scale States
abstract class ScaleState extends Equatable {
  const ScaleState();
  
  @override
  List<Object?> get props => [];
}

/// State: Initial state
class ScaleInitial extends ScaleState {
  const ScaleInitial();
}

/// State: Scanning for devices
class ScaleScanning extends ScaleState {
  final List<ScaleDeviceEntity> devices;
  
  const ScaleScanning({this.devices = const []});
  
  @override
  List<Object?> get props => [devices];
  
  ScaleScanning copyWith({List<ScaleDeviceEntity>? devices}) {
    return ScaleScanning(devices: devices ?? this.devices);
  }
}

/// State: Connecting to device
class ScaleConnecting extends ScaleState {
  final ScaleDeviceEntity device;
  
  const ScaleConnecting({required this.device});
  
  @override
  List<Object?> get props => [device];
}

/// State: Connected to device
class ScaleConnected extends ScaleState {
  final ScaleDeviceEntity device;
  final String licenseKey;
  final double currentWeight;
  
  const ScaleConnected({
    required this.device,
    required this.licenseKey,
    this.currentWeight = 0.0,
  });
  
  @override
  List<Object?> get props => [device, licenseKey, currentWeight];
  
  ScaleConnected copyWith({
    ScaleDeviceEntity? device,
    String? licenseKey,
    double? currentWeight,
  }) {
    return ScaleConnected(
      device: device ?? this.device,
      licenseKey: licenseKey ?? this.licenseKey,
      currentWeight: currentWeight ?? this.currentWeight,
    );
  }
}

/// State: Disconnected
class ScaleDisconnected extends ScaleState {
  const ScaleDisconnected();
}

/// State: Error
class ScaleError extends ScaleState {
  final String message;
  
  const ScaleError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
