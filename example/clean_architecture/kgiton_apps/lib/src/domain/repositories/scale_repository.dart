/// ============================================================================
/// Scale Repository Interface - Domain Layer
/// ============================================================================

import 'package:dartz/dartz.dart';

import '../entities/scale_device_entity.dart';
import '../../core/error/failures.dart';

/// Repository interface untuk operasi BLE scale
abstract class ScaleRepository {
  /// Scan devices
  Future<Either<Failure, List<ScaleDeviceEntity>>> scanDevices({
    Duration? timeout,
  });
  
  /// Stop scanning
  void stopScan();
  
  /// Connect ke device
  Future<Either<Failure, bool>> connectDevice({
    required String deviceId,
    required String licenseKey,
  });
  
  /// Disconnect
  Future<Either<Failure, void>> disconnect({String? licenseKey});
  
  /// Trigger buzzer
  Future<Either<Failure, void>> triggerBuzzer(String command);
  
  /// Stream device discovery
  Stream<List<ScaleDeviceEntity>> get devicesStream;
  
  /// Stream weight data
  Stream<double> get weightStream;
}
