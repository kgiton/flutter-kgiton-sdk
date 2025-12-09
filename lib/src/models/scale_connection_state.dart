/// Status koneksi timbangan
enum ScaleConnectionState {
  /// Tidak terhubung
  disconnected,

  /// Sedang mencari perangkat
  scanning,

  /// Sedang menghubungkan
  connecting,

  /// Terhubung tapi belum autentikasi
  connected,

  /// Terhubung dan terautentikasi, siap menerima data
  authenticated,

  /// Terputus karena error
  error,
}

extension ScaleConnectionStateX on ScaleConnectionState {
  String get displayName {
    switch (this) {
      case ScaleConnectionState.disconnected:
        return 'Terputus';
      case ScaleConnectionState.scanning:
        return 'Mencari perangkat...';
      case ScaleConnectionState.connecting:
        return 'Menghubungkan...';
      case ScaleConnectionState.connected:
        return 'Terhubung - Menunggu autentikasi';
      case ScaleConnectionState.authenticated:
        return 'Terhubung - Siap menerima data';
      case ScaleConnectionState.error:
        return 'Error';
    }
  }

  bool get isConnected => this == ScaleConnectionState.connected || this == ScaleConnectionState.authenticated;

  bool get canReceiveData => this == ScaleConnectionState.authenticated;
}
