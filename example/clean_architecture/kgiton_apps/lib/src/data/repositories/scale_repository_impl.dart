/// ============================================================================
/// Scale Repository Implementation
/// ============================================================================
/// 
/// File: src/data/repositories/scale_repository_impl.dart
/// Deskripsi: Implementasi ScaleRepository menggunakan data sources
/// ============================================================================

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/scale_device_entity.dart';
import '../../domain/repositories/scale_repository.dart';
import '../datasources/scale_datasource.dart';
import '../models/scale_device_model.dart';

/// Implementasi Scale Repository
/// 
/// Menggunakan Scale data source untuk:
/// - Scanning BLE devices
/// - Connect/disconnect dengan license key
/// - Streaming weight data
class ScaleRepositoryImpl implements ScaleRepository {
  final ScaleDataSource dataSource;
  
  ScaleRepositoryImpl({required this.dataSource});
  
  @override
  Future<Either<Failure, List<ScaleDeviceEntity>>> scanDevices({Duration? timeout}) async {
    try {
      await dataSource.scanForDevices();
      // Return empty list initially, devices will come through stream
      return const Right([]);
    } catch (e) {
      return Left(BleFailure(message: e.toString()));
    }
  }
  
  @override
  void stopScan() {
    dataSource.stopScan();
  }
  
  @override
  Future<Either<Failure, bool>> connectDevice({
    required String deviceId,
    required String licenseKey,
  }) async {
    try {
      final result = await dataSource.connectWithLicenseKey(deviceId, licenseKey);
      return Right(result.success);
    } catch (e) {
      return Left(BleFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> disconnect({String? licenseKey}) async {
    try {
      if (licenseKey != null) {
        await dataSource.disconnectWithLicenseKey(licenseKey);
      }
      return const Right(null);
    } catch (e) {
      return Left(BleFailure(message: e.toString()));
    }
  }
  
  @override
  Stream<double> get weightStream => 
      dataSource.weightStream.map((weightData) => weightData.weight);
  
  @override
  Stream<List<ScaleDeviceEntity>> get devicesStream =>
      dataSource.devicesStream.map(
        (devices) => devices.map((d) => ScaleDeviceModel.fromSdkModel(d).toEntity()).toList(),
      );
  
  @override
  Future<Either<Failure, void>> triggerBuzzer(String command) async {
    try {
      await dataSource.triggerBuzzer(command);
      return const Right(null);
    } catch (e) {
      return Left(BleFailure(message: e.toString()));
    }
  }
}
