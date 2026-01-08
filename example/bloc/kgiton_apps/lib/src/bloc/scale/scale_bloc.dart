/// ============================================================================
/// Scale BLoC - Business Logic Component
/// ============================================================================
/// 
/// File: src/bloc/scale/scale_bloc.dart
/// Deskripsi: BLoC untuk mengelola koneksi BLE ke timbangan
/// 
/// Fitur:
/// - Scan device BLE
/// - Connect/Disconnect dengan license key
/// - Stream weight data
/// - Buzzer control
/// ============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

import '../auth/auth_bloc.dart';
import '../auth/auth_state.dart';
import 'scale_event.dart';
import 'scale_state.dart';

/// ScaleBloc - mengelola koneksi BLE
class ScaleBloc extends Bloc<ScaleEvent, ScaleState> {
  final AuthBloc _authBloc;
  
  // Scale service dari SDK
  KGiTONScaleService? _scaleService;
  
  // Stream subscriptions
  StreamSubscription<List<ScaleDevice>>? _devicesSubscription;
  StreamSubscription<ScaleConnectionState>? _connectionSubscription;
  StreamSubscription<WeightData>? _weightSubscription;
  
  /// Constructor
  ScaleBloc({required AuthBloc authBloc})
    : _authBloc = authBloc,
      super(ScaleInitial()) {
    // Register event handlers
    on<StartScanEvent>(_onStartScan);
    on<StopScanEvent>(_onStopScan);
    on<ConnectDeviceEvent>(_onConnectDevice);
    on<ConnectWithQREvent>(_onConnectWithQR);
    on<DisconnectEvent>(_onDisconnect);
    on<TriggerBuzzerEvent>(_onTriggerBuzzer);
    on<WeightReceivedEvent>(_onWeightReceived);
    on<DevicesUpdatedEvent>(_onDevicesUpdated);
    on<ClearScaleErrorEvent>(_onClearError);
    
    // Initialize service
    _initializeService();
  }
  
  /// Initialize scale service
  void _initializeService() {
    final authState = _authBloc.state;
    if (authState is AuthAuthenticated) {
      _scaleService = KGiTONScaleService(apiService: authState.apiService);
    } else {
      _scaleService = KGiTONScaleService();
    }
    
    _setupListeners();
  }
  
  /// Setup stream listeners
  void _setupListeners() {
    // Listen to device discovery
    _devicesSubscription = _scaleService?.devicesStream.listen((devices) {
      add(DevicesUpdatedEvent(devices: devices));
    });
    
    // Listen to weight data
    _weightSubscription = _scaleService?.weightStream.listen((weight) {
      add(WeightReceivedEvent(weight: weight.weight, unit: weight.unit));
    });
  }
  
  // ==========================================================================
  // EVENT HANDLERS
  // ==========================================================================
  
  /// Handler untuk StartScanEvent
  Future<void> _onStartScan(
    StartScanEvent event,
    Emitter<ScaleState> emit,
  ) async {
    emit(const ScaleScanning());
    
    try {
      await _scaleService?.scanForDevices(
        timeout: event.timeout ?? const Duration(seconds: 10),
      );
    } catch (e) {
      emit(ScaleError(
        message: 'Gagal scan device: $e',
        devices: state.devices,
      ));
    }
  }
  
  /// Handler untuk StopScanEvent
  void _onStopScan(
    StopScanEvent event,
    Emitter<ScaleState> emit,
  ) {
    _scaleService?.stopScan();
    emit(ScaleDevicesFound(devices: state.devices));
  }
  
  /// Handler untuk ConnectDeviceEvent
  Future<void> _onConnectDevice(
    ConnectDeviceEvent event,
    Emitter<ScaleState> emit,
  ) async {
    emit(ScaleConnecting(devices: state.devices));
    
    try {
      final response = await _scaleService?.connectWithLicenseKey(
        deviceId: event.deviceId,
        licenseKey: event.licenseKey,
      );
      
      if (response?.success == true) {
        final device = state.devices.firstWhere(
          (d) => d.id == event.deviceId,
          orElse: () => ScaleDevice(name: 'Unknown', id: event.deviceId, rssi: 0),
        );
        
        emit(ScaleConnected(
          devices: state.devices,
          device: device,
        ));
      } else {
        emit(ScaleError(
          message: response?.message ?? 'Koneksi gagal',
          devices: state.devices,
        ));
      }
    } catch (e) {
      emit(ScaleError(
        message: 'Gagal connect: $e',
        devices: state.devices,
      ));
    }
  }
  
  /// Handler untuk ConnectWithQREvent
  Future<void> _onConnectWithQR(
    ConnectWithQREvent event,
    Emitter<ScaleState> emit,
  ) async {
    // Parse license key dari QR
    final licenseKey = _parseLicenseFromQR(event.qrData);
    
    if (licenseKey == null) {
      emit(ScaleError(
        message: 'QR code tidak valid',
        devices: state.devices,
      ));
      return;
    }
    
    // Delegate ke ConnectDeviceEvent
    add(ConnectDeviceEvent(deviceId: event.deviceId, licenseKey: licenseKey));
  }
  
  /// Handler untuk DisconnectEvent
  Future<void> _onDisconnect(
    DisconnectEvent event,
    Emitter<ScaleState> emit,
  ) async {
    try {
      if (event.licenseKey != null) {
        await _scaleService?.disconnectWithLicenseKey(event.licenseKey!);
      } else {
        await _scaleService?.disconnect();
      }
      
      emit(ScaleDisconnected(devices: state.devices));
    } catch (e) {
      // Force disconnect on error
      emit(ScaleDisconnected(devices: state.devices));
    }
  }
  
  /// Handler untuk TriggerBuzzerEvent
  Future<void> _onTriggerBuzzer(
    TriggerBuzzerEvent event,
    Emitter<ScaleState> emit,
  ) async {
    try {
      await _scaleService?.triggerBuzzer(event.command);
    } catch (e) {
      debugPrint('Buzzer error: $e');
    }
  }
  
  /// Handler untuk WeightReceivedEvent (internal)
  void _onWeightReceived(
    WeightReceivedEvent event,
    Emitter<ScaleState> emit,
  ) {
    if (state.connectedDevice != null) {
      emit(ScaleWeightReceived(
        devices: state.devices,
        device: state.connectedDevice!,
        currentWeight: WeightData(weight: event.weight, unit: event.unit),
      ));
    }
  }
  
  /// Handler untuk DevicesUpdatedEvent (internal)
  void _onDevicesUpdated(
    DevicesUpdatedEvent event,
    Emitter<ScaleState> emit,
  ) {
    final devices = event.devices.cast<ScaleDevice>();
    
    if (state is ScaleScanning) {
      if (devices.isNotEmpty) {
        emit(ScaleDevicesFound(devices: devices));
      } else {
        emit(ScaleScanning(devices: devices));
      }
    } else if (state.isConnected) {
      // Keep connected state but update devices
      emit(ScaleConnected(
        devices: devices,
        device: state.connectedDevice!,
        currentWeight: state.currentWeight,
      ));
    } else {
      emit(ScaleDevicesFound(devices: devices));
    }
  }
  
  /// Handler untuk ClearScaleErrorEvent
  void _onClearError(
    ClearScaleErrorEvent event,
    Emitter<ScaleState> emit,
  ) {
    emit(ScaleDisconnected(devices: state.devices));
  }
  
  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================
  
  /// Parse license key dari QR data
  String? _parseLicenseFromQR(String qrData) {
    // Direct license key pattern
    if (RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(qrData)) {
      return qrData;
    }
    
    // URL format
    if (qrData.contains('license=')) {
      final uri = Uri.tryParse(qrData);
      return uri?.queryParameters['license'];
    }
    
    // Return as-is if looks like license
    if (qrData.length >= 16) {
      return qrData;
    }
    
    return null;
  }
  
  // ==========================================================================
  // DISPOSE
  // ==========================================================================
  
  @override
  Future<void> close() {
    _devicesSubscription?.cancel();
    _connectionSubscription?.cancel();
    _weightSubscription?.cancel();
    _scaleService?.disconnect();
    return super.close();
  }
}
