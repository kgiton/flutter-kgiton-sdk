import 'package:dartz/dartz.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for user logout
class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;
  final KGiTONScaleService scaleService;

  LogoutUseCase(this.repository, this.scaleService);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    // Disconnect dari device BLE jika sedang terhubung
    try {
      await scaleService.disconnect();
    } catch (e) {
      // Ignore error saat disconnect, tetap lanjutkan logout
    }

    // Clear API service dari scale service (disable ownership verification)
    try {
      scaleService.clearApiService();
    } catch (e) {
      // Ignore error
    }

    // Lakukan logout
    return await repository.logout();
  }
}
