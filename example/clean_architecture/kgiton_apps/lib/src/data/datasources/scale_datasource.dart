/// ============================================================================
/// Scale Data Source
/// ============================================================================
/// 
/// File: src/data/datasources/scale_datasource.dart
/// Deskripsi: Data source untuk BLE scale menggunakan KGiTON SDK
/// ============================================================================

import 'package:kgiton_sdk/kgiton_sdk.dart';

/// Interface untuk Scale Data Source
abstract class ScaleDataSource {
  Future<void> scanForDevices();
  void stopScan();
  Future<ControlResponse> connectWithLicenseKey(String deviceId, String licenseKey);
  Future<ControlResponse> disconnectWithLicenseKey(String licenseKey);
  Stream<WeightData> get weightStream;
  Stream<ScaleConnectionState> get connectionStateStream;
  Future<void> triggerBuzzer(String command);
  Stream<List<ScaleDevice>> get devicesStream;
}

/// Implementasi Scale Data Source menggunakan KGiTON SDK
class ScaleDataSourceImpl implements ScaleDataSource {
  final KGiTONScaleService scaleService;
  
  ScaleDataSourceImpl({required this.scaleService});
  
  @override
  Future<void> scanForDevices() async {
    try {
      await scaleService.scanForDevices();
    } catch (e) {
      throw Exception('Scan error: $e');
    }
  }
  
  @override
  void stopScan() {
    scaleService.stopScan();
  }
  
  @override
  Future<ControlResponse> connectWithLicenseKey(String deviceId, String licenseKey) async {
    try {
      return await scaleService.connectWithLicenseKey(
        deviceId: deviceId,
        licenseKey: licenseKey,
      );
    } catch (e) {
      throw Exception('Connect error: $e');
    }
  }
  
  @override
  Future<ControlResponse> disconnectWithLicenseKey(String licenseKey) async {
    try {
      return await scaleService.disconnectWithLicenseKey(licenseKey);
    } catch (e) {
      throw Exception('Disconnect error: $e');
    }
  }
  
  @override
  Stream<WeightData> get weightStream => scaleService.weightStream;
  
  @override
  Stream<ScaleConnectionState> get connectionStateStream => 
      scaleService.connectionStateStream;
  
  @override
  Future<void> triggerBuzzer(String command) async {
    try {
      await scaleService.triggerBuzzer(command);
    } catch (e) {
      throw Exception('Buzzer error: $e');
    }
  }
  
  @override
  Stream<List<ScaleDevice>> get devicesStream => scaleService.devicesStream;
}
