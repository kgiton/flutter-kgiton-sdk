/// ============================================================================
/// Scale States - BLoC Pattern
/// ============================================================================

import 'package:equatable/equatable.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

/// Base class untuk semua Scale states
abstract class ScaleState extends Equatable {
  final List<ScaleDevice> devices;
  final ScaleDevice? connectedDevice;
  final WeightData? currentWeight;
  final String? errorMessage;

  const ScaleState({
    this.devices = const [],
    this.connectedDevice,
    this.currentWeight,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [devices, connectedDevice, currentWeight, errorMessage];

  /// Check if connected
  bool get isConnected => connectedDevice != null;

  /// Weight display string
  String get weightDisplay => currentWeight?.displayWeight ?? '0.000 kg';
}

/// State awal
class ScaleInitial extends ScaleState {}

/// State saat scanning device
class ScaleScanning extends ScaleState {
  const ScaleScanning({
    super.devices,
  });
}

/// State saat device ditemukan
class ScaleDevicesFound extends ScaleState {
  const ScaleDevicesFound({
    required super.devices,
  });
}

/// State saat connecting ke device
class ScaleConnecting extends ScaleState {
  const ScaleConnecting({
    super.devices,
  });
}

/// State saat connected dan authenticated
class ScaleConnected extends ScaleState {
  const ScaleConnected({
    required super.devices,
    required ScaleDevice device,
    super.currentWeight,
  }) : super(connectedDevice: device);
}

/// State saat menerima weight data (extend dari ScaleConnected)
class ScaleWeightReceived extends ScaleState {
  const ScaleWeightReceived({
    required super.devices,
    required ScaleDevice device,
    required super.currentWeight,
  }) : super(connectedDevice: device);
}

/// State saat disconnected
class ScaleDisconnected extends ScaleState {
  const ScaleDisconnected({
    super.devices,
  });
}

/// State saat error
class ScaleError extends ScaleState {
  const ScaleError({
    required String message,
    super.devices,
    super.connectedDevice,
    super.currentWeight,
  }) : super(errorMessage: message);
}
