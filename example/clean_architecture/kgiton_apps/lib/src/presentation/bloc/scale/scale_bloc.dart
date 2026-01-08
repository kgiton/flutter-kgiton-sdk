/// ============================================================================
/// Scale BLoC
/// ============================================================================
/// 
/// File: src/presentation/bloc/scale/scale_bloc.dart
/// Deskripsi: BLoC untuk manajemen BLE scale connection
/// 
/// Menggunakan Clean Architecture dengan Use Cases:
/// - ScanDevicesUseCase: Scan BLE devices
/// - ConnectDeviceUseCase: Connect dengan license key
/// - DisconnectDeviceUseCase: Disconnect dari device
/// ============================================================================

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/scale_device_entity.dart';
import '../../../domain/repositories/scale_repository.dart';
import '../../../domain/usecases/scan_devices_usecase.dart';
import '../../../domain/usecases/connect_device_usecase.dart';
import 'scale_event.dart';
import 'scale_state.dart';

class ScaleBloc extends Bloc<ScaleEvent, ScaleState> {
  final ScanDevicesUseCase scanDevicesUseCase;
  final StopScanUseCase stopScanUseCase;
  final ConnectDeviceUseCase connectDeviceUseCase;
  final DisconnectDeviceUseCase disconnectDeviceUseCase;
  final ScaleRepository scaleRepository;
  
  StreamSubscription<List<ScaleDeviceEntity>>? _devicesSubscription;
  StreamSubscription<double>? _weightSubscription;
  
  ScaleBloc({
    required this.scanDevicesUseCase,
    required this.stopScanUseCase,
    required this.connectDeviceUseCase,
    required this.disconnectDeviceUseCase,
    required this.scaleRepository,
  }) : super(const ScaleInitial()) {
    on<StartScanEvent>(_onStartScan);
    on<StopScanEvent>(_onStopScan);
    on<DevicesFoundEvent>(_onDevicesFound);
    on<ConnectDeviceEvent>(_onConnectDevice);
    on<DisconnectDeviceEvent>(_onDisconnectDevice);
    on<WeightReceivedEvent>(_onWeightReceived);
    on<TriggerBuzzerEvent>(_onTriggerBuzzer);
  }
  
  /// Handle start scan
  Future<void> _onStartScan(
    StartScanEvent event,
    Emitter<ScaleState> emit,
  ) async {
    emit(const ScaleScanning());
    
    final result = await scanDevicesUseCase();
    
    result.fold(
      (failure) => emit(ScaleError(message: failure.message)),
      (devices) {
        // Listen to devices stream for updates
        _devicesSubscription?.cancel();
        _devicesSubscription = scaleRepository.devicesStream.listen(
          (devices) => add(DevicesFoundEvent(devices: devices)),
        );
        // Emit initial devices
        add(DevicesFoundEvent(devices: devices));
      },
    );
  }
  
  /// Handle stop scan
  Future<void> _onStopScan(
    StopScanEvent event,
    Emitter<ScaleState> emit,
  ) async {
    _devicesSubscription?.cancel();
    await stopScanUseCase();
    emit(const ScaleInitial());
  }
  
  /// Handle devices found
  void _onDevicesFound(
    DevicesFoundEvent event,
    Emitter<ScaleState> emit,
  ) {
    final currentState = state;
    if (currentState is ScaleScanning) {
      emit(currentState.copyWith(devices: event.devices));
    }
  }
  
  /// Handle connect device
  Future<void> _onConnectDevice(
    ConnectDeviceEvent event,
    Emitter<ScaleState> emit,
  ) async {
    final currentState = state;
    ScaleDeviceEntity? selectedDevice;
    
    if (currentState is ScaleScanning) {
      selectedDevice = currentState.devices.firstWhere(
        (d) => d.id == event.deviceId,
        orElse: () => ScaleDeviceEntity(id: event.deviceId, name: 'Unknown', rssi: -100),
      );
    }
    
    emit(ScaleConnecting(
      device: selectedDevice ?? ScaleDeviceEntity(id: event.deviceId, name: 'Unknown', rssi: -100),
    ));
    
    // Stop scanning first
    _devicesSubscription?.cancel();
    await stopScanUseCase();
    
    final result = await connectDeviceUseCase(ConnectDeviceParams(
      deviceId: event.deviceId,
      licenseKey: event.licenseKey,
    ));
    
    result.fold(
      (failure) => emit(ScaleError(message: failure.message)),
      (success) {
        if (success) {
          emit(ScaleConnected(
            device: selectedDevice ?? ScaleDeviceEntity(id: event.deviceId, name: 'Unknown', rssi: -100),
            licenseKey: event.licenseKey,
          ));
          
          // Listen to weight stream
          _weightSubscription?.cancel();
          _weightSubscription = scaleRepository.weightStream.listen(
            (weight) => add(WeightReceivedEvent(weight: weight)),
          );
        } else {
          emit(const ScaleError(message: 'Gagal connect ke device'));
        }
      },
    );
  }
  
  /// Handle disconnect device
  Future<void> _onDisconnectDevice(
    DisconnectDeviceEvent event,
    Emitter<ScaleState> emit,
  ) async {
    _weightSubscription?.cancel();
    
    await disconnectDeviceUseCase(event.licenseKey);
    emit(const ScaleDisconnected());
  }
  
  /// Handle weight received
  void _onWeightReceived(
    WeightReceivedEvent event,
    Emitter<ScaleState> emit,
  ) {
    final currentState = state;
    if (currentState is ScaleConnected) {
      emit(currentState.copyWith(currentWeight: event.weight));
    }
  }
  
  /// Handle trigger buzzer
  Future<void> _onTriggerBuzzer(
    TriggerBuzzerEvent event,
    Emitter<ScaleState> emit,
  ) async {
    await scaleRepository.triggerBuzzer('BUZZ');
  }
  
  @override
  Future<void> close() {
    _devicesSubscription?.cancel();
    _weightSubscription?.cancel();
    return super.close();
  }
}
