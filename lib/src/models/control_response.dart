/// Response dari perintah kontrol
class ControlResponse {
  final bool success;
  final String message;
  final String? errorCode;

  ControlResponse({required this.success, required this.message, this.errorCode});

  factory ControlResponse.success(String message) {
    return ControlResponse(success: true, message: message);
  }

  factory ControlResponse.error(String message, {String? errorCode}) {
    return ControlResponse(success: false, message: message, errorCode: errorCode);
  }

  factory ControlResponse.fromDeviceResponse(String response) {
    if (response.startsWith('ERROR:')) {
      final errorCode = response.substring(6);
      return ControlResponse.error(_getErrorMessage(errorCode), errorCode: errorCode);
    }

    switch (response) {
      case 'CONNECTED':
        return ControlResponse.success('Berhasil terhubung');
      case 'DISCONNECTED':
        return ControlResponse.success('Berhasil terputus');
      case 'ALREADY_CONNECTED':
        return ControlResponse.error('Sudah terhubung');
      case 'ALREADY_DISCONNECTED':
        return ControlResponse.error('Sudah terputus');
      default:
        return ControlResponse.error('Response tidak dikenal: $response');
    }
  }

  static String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'INVALID_LICENSE':
      case 'INVALID_KEY': // Shortened version for BLE MTU
        return 'License key tidak valid';
      case 'INVALID_FORMAT':
        return 'Format perintah salah';
      case 'UNKNOWN_COMMAND':
        return 'Perintah tidak dikenal';
      default:
        return 'Error: $errorCode';
    }
  }

  @override
  String toString() => 'ControlResponse(success: $success, message: $message)';
}
