/// ============================================================================
/// Scan Devices Use Case
/// ============================================================================
/// 
/// File: src/domain/usecases/scan_devices_usecase.dart
/// Deskripsi: Use case untuk scanning BLE devices
/// ============================================================================

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/scale_device_entity.dart';
import '../repositories/scale_repository.dart';
import 'usecase.dart';

class ScanDevicesUseCase implements UseCaseNoParams<List<ScaleDeviceEntity>> {
  final ScaleRepository repository;
  
  ScanDevicesUseCase(this.repository);
  
  @override
  Future<Either<Failure, List<ScaleDeviceEntity>>> call() async {
    return await repository.scanDevices();
  }
}

class StopScanUseCase implements UseCaseNoParams<void> {
  final ScaleRepository repository;
  
  StopScanUseCase(this.repository);
  
  @override
  Future<Either<Failure, void>> call() async {
    repository.stopScan();
    return const Right(null);
  }
}
