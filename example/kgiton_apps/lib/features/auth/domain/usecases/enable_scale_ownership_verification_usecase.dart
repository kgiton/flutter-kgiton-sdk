import 'package:kgiton_sdk/kgiton_sdk.dart';

/// Use case untuk enable ownership verification setelah login
///
/// Mengaktifkan verifikasi kepemilikan license key dengan menyediakan
/// API service yang sudah authenticated ke scale service.
class EnableScaleOwnershipVerificationUseCase {
  final KGiTONScaleService scaleService;
  final KgitonApiService apiService;

  EnableScaleOwnershipVerificationUseCase({required this.scaleService, required this.apiService});

  /// Enable ownership verification
  ///
  /// Setelah method ini dipanggil, semua koneksi ke device akan
  /// otomatis memverifikasi bahwa user adalah pemilik sah dari license key.
  void call() {
    scaleService.setApiService(apiService);
  }
}
