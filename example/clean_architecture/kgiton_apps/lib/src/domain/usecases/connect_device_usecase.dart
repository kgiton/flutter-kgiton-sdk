/// ============================================================================
/// Connect Device Use Case
/// ============================================================================
/// 
/// File: src/domain/usecases/connect_device_usecase.dart
/// Deskripsi: Use case untuk connect ke device dengan license key
/// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../repositories/scale_repository.dart';
import 'usecase.dart';

class ConnectDeviceUseCase implements UseCase<bool, ConnectDeviceParams> {
  final ScaleRepository repository;
  
  ConnectDeviceUseCase(this.repository);
  
  @override
  Future<Either<Failure, bool>> call(ConnectDeviceParams params) async {
    return await repository.connectDevice(
      deviceId: params.deviceId,
      licenseKey: params.licenseKey,
    );
  }
}

class DisconnectDeviceUseCase implements UseCase<void, String> {
  final ScaleRepository repository;
  
  DisconnectDeviceUseCase(this.repository);
  
  @override
  Future<Either<Failure, void>> call(String licenseKey) async {
    return await repository.disconnect(licenseKey: licenseKey);
  }
}

/// Parameters untuk connect device
class ConnectDeviceParams extends Equatable {
  final String deviceId;
  final String licenseKey;
  
  const ConnectDeviceParams({
    required this.deviceId,
    required this.licenseKey,
  });
  
  @override
  List<Object> get props => [deviceId, licenseKey];
}
