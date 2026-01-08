/// ============================================================================
/// Scale Controller - GetX State Management
/// ============================================================================
/// 
/// File: src/controllers/scale_controller.dart
/// Deskripsi: Controller untuk BLE scale connection
/// 
/// Reactive State:
/// - devices: List device yang ditemukan
/// - isScanning: Status scanning
/// - connectedDevice: Device yang terhubung
/// - currentWeight: Berat saat ini
/// ============================================================================

import 'dart:async';
import 'package:get/get.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

/// Scale Controller
class ScaleController extends GetxController {
  // =========================================================================
  // Services
  // =========================================================================
  late final KGiTONScaleService _scaleService;
  
  // =========================================================================
  // Reactive State
  // =========================================================================
  
  /// License key yang digunakan
  final licenseKey = ''.obs;
  
  /// Status scanning
  final isScanning = false.obs;
  
  /// Status connecting
  final isConnecting = false.obs;
  
  /// Status connected
  final isConnected = false.obs;
  
  /// List devices yang ditemukan
  final devices = <ScaleDevice>[].obs;
  
  /// Device yang terhubung
  final Rx<ScaleDevice?> connectedDevice = Rx<ScaleDevice?>(null);
  
  /// Current weight
  final currentWeight = 0.0.obs;
  
  /// Error message
  final errorMessage = ''.obs;
  
  // =========================================================================
  // Stream Subscriptions
  // =========================================================================
  StreamSubscription<List<ScaleDevice>>? _devicesSubscription;
  StreamSubscription<WeightData>? _weightSubscription;
  StreamSubscription<ScaleConnectionState>? _connectionSubscription;
  
  // =========================================================================
  // Lifecycle
  // =========================================================================
  
  @override
  void onInit() {
    super.onInit();
    _scaleService = Get.find<KGiTONScaleService>();
    
    // Get license key dari arguments
    if (Get.arguments != null && Get.arguments['licenseKey'] != null) {
      licenseKey.value = Get.arguments['licenseKey'];
    }
  }
  
  @override
  void onClose() {
    _devicesSubscription?.cancel();
    _weightSubscription?.cancel();
    _connectionSubscription?.cancel();
    stopScan();
    super.onClose();
  }
  
  // =========================================================================
  // Scan Methods
  // =========================================================================
  
  /// Start scanning untuk BLE devices
  Future<void> startScan() async {
    try {
      isScanning.value = true;
      devices.clear();
      errorMessage.value = '';
      
      // Start scan
      await _scaleService.scanForDevices();
      
      // Listen to devices stream
      _devicesSubscription?.cancel();
      _devicesSubscription = _scaleService.devicesStream.listen(
        (foundDevices) {
          devices.assignAll(foundDevices);
        },
        onError: (error) {
          errorMessage.value = 'Scan error: $error';
          isScanning.value = false;
        },
      );
    } catch (e) {
      errorMessage.value = 'Error: $e';
      isScanning.value = false;
      _showError(errorMessage.value);
    }
  }
  
  /// Stop scanning
  Future<void> stopScan() async {
    try {
      _scaleService.stopScan();
    } catch (e) {
      // Ignore
    } finally {
      isScanning.value = false;
      _devicesSubscription?.cancel();
    }
  }
  
  // =========================================================================
  // Connect Methods
  // =========================================================================
  
  /// Connect ke device dengan license key
  Future<void> connectDevice(ScaleDevice device) async {
    try {
      isConnecting.value = true;
      errorMessage.value = '';
      
      // Stop scanning dulu
      await stopScan();
      
      // Connect dengan license key - returns ControlResponse
      final response = await _scaleService.connectWithLicenseKey(
        deviceId: device.id,
        licenseKey: licenseKey.value,
      );
      
      if (response.success) {
        isConnected.value = true;
        connectedDevice.value = device;
        
        // Listen to weight stream - returns WeightData
        _weightSubscription?.cancel();
        _weightSubscription = _scaleService.weightStream.listen(
          (weightData) {
            currentWeight.value = weightData.weight;
          },
          onError: (error) {
            errorMessage.value = 'Weight stream error: $error';
          },
        );
        
        _showSuccess('Terhubung ke ${device.name}');
      } else {
        errorMessage.value = response.message;
        _showError(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Connect error: $e';
      _showError(errorMessage.value);
    } finally {
      isConnecting.value = false;
    }
  }
  
  /// Disconnect dari device
  Future<void> disconnectDevice() async {
    try {
      await _scaleService.disconnectWithLicenseKey(licenseKey.value);
    } catch (e) {
      // Ignore
    } finally {
      _weightSubscription?.cancel();
      _connectionSubscription?.cancel();
      
      isConnected.value = false;
      connectedDevice.value = null;
      currentWeight.value = 0.0;
      
      _showSuccess('Disconnected');
    }
  }
  
  /// Trigger buzzer pada device
  Future<void> triggerBuzzer() async {
    try {
      await _scaleService.triggerBuzzer('BUZZ');
    } catch (e) {
      _showError('Buzzer error: $e');
    }
  }
  
  // =========================================================================
  // Helper Methods
  // =========================================================================
  
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }
  
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }
}
