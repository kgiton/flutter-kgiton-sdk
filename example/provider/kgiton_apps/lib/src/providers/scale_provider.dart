/// ============================================================================
/// Scale Provider - State Management untuk BLE Scale Connection
/// ============================================================================
/// 
/// File: src/providers/scale_provider.dart
/// Deskripsi: Provider untuk mengelola koneksi BLE ke timbangan KGiTON
/// 
/// Fitur:
/// - Scan device BLE
/// - Connect/Disconnect dengan license key
/// - Streaming data berat realtime
/// - Buzzer control
/// 
/// Cara Penggunaan:
/// ```dart
/// // Scan devices
/// await context.read<ScaleProvider>().startScan();
/// 
/// // Connect ke device
/// await context.read<ScaleProvider>().connectDevice(
///   deviceId: device.id,
///   licenseKey: 'LICENSE-KEY',
/// );
/// 
/// // Listen weight stream
/// context.watch<ScaleProvider>().currentWeight
/// ```
/// ============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

/// Enum untuk scan status
enum ScanStatus {
  idle,
  scanning,
  found,
  error,
}

/// Enum untuk connection status
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  authenticated,
  error,
}

/// Provider untuk mengelola koneksi BLE Scale
class ScaleProvider extends ChangeNotifier {
  // =========================================================================
  // Private Properties
  // =========================================================================
  
  /// KGiTON Scale Service dari SDK
  KGiTONScaleService? _scaleService;
  
  /// List device yang ditemukan
  List<ScaleDevice> _devices = [];
  
  /// Device yang sedang terhubung
  ScaleDevice? _connectedDevice;
  
  /// Data berat terakhir
  WeightData? _currentWeight;
  
  /// Scan status
  ScanStatus _scanStatus = ScanStatus.idle;
  
  /// Connection status
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  
  /// Error message
  String? _errorMessage;
  
  /// Stream subscriptions
  StreamSubscription<List<ScaleDevice>>? _devicesSubscription;
  StreamSubscription<ScaleConnectionState>? _connectionSubscription;
  StreamSubscription<WeightData>? _weightSubscription;
  
  // =========================================================================
  // Getters
  // =========================================================================
  
  /// Get list devices yang ditemukan
  List<ScaleDevice> get devices => List.unmodifiable(_devices);
  
  /// Get connected device
  ScaleDevice? get connectedDevice => _connectedDevice;
  
  /// Get current weight data
  WeightData? get currentWeight => _currentWeight;
  
  /// Get current weight value sebagai string
  String get weightDisplay => _currentWeight?.displayWeight ?? '0.000 kg';
  
  /// Get scan status
  ScanStatus get scanStatus => _scanStatus;
  
  /// Check if scanning
  bool get isScanning => _scanStatus == ScanStatus.scanning;
  
  /// Get connection status
  ConnectionStatus get connectionStatus => _connectionStatus;
  
  /// Check if connected
  bool get isConnected => 
    _connectionStatus == ConnectionStatus.connected ||
    _connectionStatus == ConnectionStatus.authenticated;
  
  /// Check if authenticated (ready to use)
  bool get isAuthenticated => _connectionStatus == ConnectionStatus.authenticated;
  
  /// Get error message
  String? get errorMessage => _errorMessage;
  
  // =========================================================================
  // Constructor & Initialization
  // =========================================================================
  
  /// Constructor
  ScaleProvider() {
    _initializeService();
  }
  
  /// Initialize scale service
  void _initializeService() {
    _scaleService = KGiTONScaleService();
    _setupListeners();
  }
  
  /// Update API service (dipanggil dari ProxyProvider)
  void updateApiService(KgitonApiService? apiService) {
    if (apiService != null) {
      _scaleService?.setApiService(apiService);
    } else {
      _scaleService?.clearApiService();
    }
  }
  
  /// Setup stream listeners
  void _setupListeners() {
    // Listen to device discovery
    _devicesSubscription = _scaleService?.devicesStream.listen((devices) {
      _devices = devices;
      if (devices.isNotEmpty && _scanStatus == ScanStatus.scanning) {
        _setScanStatus(ScanStatus.found);
      }
      notifyListeners();
    });
    
    // Listen to connection state
    _connectionSubscription = _scaleService?.connectionStateStream.listen((state) {
      _updateConnectionStatus(state);
    });
    
    // Listen to weight data
    _weightSubscription = _scaleService?.weightStream.listen((weight) {
      _currentWeight = weight;
      notifyListeners();
    });
  }
  
  // =========================================================================
  // Public Methods - Scanning
  // =========================================================================
  
  /// Start scanning untuk device BLE
  /// 
  /// [timeout] - Durasi scan (default: 10 detik)
  /// 
  /// Contoh:
  /// ```dart
  /// await scaleProvider.startScan();
  /// // Devices akan tersedia di scaleProvider.devices
  /// ```
  Future<void> startScan({Duration? timeout}) async {
    if (_scanStatus == ScanStatus.scanning) return;
    
    try {
      _errorMessage = null;
      _devices = [];
      _setScanStatus(ScanStatus.scanning);
      
      await _scaleService?.scanForDevices(
        timeout: timeout ?? const Duration(seconds: 10),
      );
    } catch (e) {
      _setError('Gagal scan device: $e');
      _setScanStatus(ScanStatus.error);
    }
  }
  
  /// Stop scanning
  void stopScan() {
    _scaleService?.stopScan();
    if (_scanStatus == ScanStatus.scanning) {
      _setScanStatus(_devices.isNotEmpty ? ScanStatus.found : ScanStatus.idle);
    }
  }
  
  // =========================================================================
  // Public Methods - Connection
  // =========================================================================
  
  /// Connect ke device dengan license key
  /// 
  /// [deviceId] - ID device dari hasil scan
  /// [licenseKey] - License key untuk autentikasi
  /// 
  /// Returns true jika berhasil connect
  /// 
  /// Contoh:
  /// ```dart
  /// final success = await scaleProvider.connectDevice(
  ///   deviceId: device.id,
  ///   licenseKey: 'LICENSE-KEY-123',
  /// );
  /// ```
  Future<bool> connectDevice({
    required String deviceId,
    required String licenseKey,
  }) async {
    try {
      _errorMessage = null;
      _setConnectionStatus(ConnectionStatus.connecting);
      
      final response = await _scaleService?.connectWithLicenseKey(
        deviceId: deviceId,
        licenseKey: licenseKey,
      );
      
      if (response?.success == true) {
        // Find connected device
        _connectedDevice = _devices.firstWhere(
          (d) => d.id == deviceId,
          orElse: () => ScaleDevice(name: 'Unknown', id: deviceId, rssi: 0),
        );
        _setConnectionStatus(ConnectionStatus.authenticated);
        return true;
      } else {
        _setError(response?.message ?? 'Koneksi gagal');
        _setConnectionStatus(ConnectionStatus.error);
        return false;
      }
    } catch (e) {
      _setError('Gagal connect: $e');
      _setConnectionStatus(ConnectionStatus.error);
      return false;
    }
  }
  
  /// Connect ke device dengan QR code
  /// 
  /// QR code harus berisi license key
  /// [qrData] - Data dari scan QR
  /// [deviceId] - ID device yang akan diconnect
  Future<bool> connectWithQR({
    required String qrData,
    required String deviceId,
  }) async {
    // QR data bisa berupa:
    // 1. License key langsung: "LICENSE-KEY-123"
    // 2. URL dengan license: "kgiton://connect?license=LICENSE-KEY-123"
    // 3. JSON: {"license_key": "LICENSE-KEY-123"}
    
    String? licenseKey = _parseLicenseFromQR(qrData);
    
    if (licenseKey == null) {
      _setError('QR code tidak valid');
      return false;
    }
    
    return connectDevice(deviceId: deviceId, licenseKey: licenseKey);
  }
  
  /// Disconnect dari device
  /// 
  /// [licenseKey] - License key yang digunakan saat connect
  Future<void> disconnect({String? licenseKey}) async {
    try {
      if (licenseKey != null) {
        await _scaleService?.disconnectWithLicenseKey(licenseKey);
      } else {
        await _scaleService?.disconnect();
      }
      
      _connectedDevice = null;
      _currentWeight = null;
      _setConnectionStatus(ConnectionStatus.disconnected);
    } catch (e) {
      // Force disconnect on error
      _connectedDevice = null;
      _currentWeight = null;
      _setConnectionStatus(ConnectionStatus.disconnected);
    }
  }
  
  // =========================================================================
  // Public Methods - Buzzer
  // =========================================================================
  
  /// Trigger buzzer
  /// 
  /// [command] - Perintah buzzer: BUZZ, BEEP, ON, LONG, OFF
  Future<void> triggerBuzzer(String command) async {
    if (!isAuthenticated) {
      _setError('Belum terhubung ke device');
      return;
    }
    
    try {
      await _scaleService?.triggerBuzzer(command);
    } catch (e) {
      _setError('Gagal trigger buzzer: $e');
    }
  }
  
  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // =========================================================================
  // Private Methods
  // =========================================================================
  
  /// Update scan status
  void _setScanStatus(ScanStatus status) {
    _scanStatus = status;
    notifyListeners();
  }
  
  /// Update connection status
  void _setConnectionStatus(ConnectionStatus status) {
    _connectionStatus = status;
    notifyListeners();
  }
  
  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  /// Map SDK connection state to provider status
  void _updateConnectionStatus(ScaleConnectionState state) {
    switch (state) {
      case ScaleConnectionState.disconnected:
        _connectionStatus = ConnectionStatus.disconnected;
        _connectedDevice = null;
        break;
      case ScaleConnectionState.scanning:
        // Don't change connection status during scan
        break;
      case ScaleConnectionState.connecting:
        _connectionStatus = ConnectionStatus.connecting;
        break;
      case ScaleConnectionState.connected:
        _connectionStatus = ConnectionStatus.connected;
        break;
      case ScaleConnectionState.authenticated:
        _connectionStatus = ConnectionStatus.authenticated;
        break;
      case ScaleConnectionState.error:
        _connectionStatus = ConnectionStatus.error;
        break;
    }
    notifyListeners();
  }
  
  /// Parse license key dari QR data
  String? _parseLicenseFromQR(String qrData) {
    // Try direct license key (uppercase pattern)
    if (RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(qrData)) {
      return qrData;
    }
    
    // Try URL format
    if (qrData.startsWith('kgiton://') || qrData.contains('license=')) {
      final uri = Uri.tryParse(qrData);
      if (uri != null) {
        return uri.queryParameters['license'];
      }
    }
    
    // Try JSON format
    try {
      final json = Map<String, dynamic>.from(
        (qrData.contains('{') ? qrData : '{}') as dynamic
      );
      return json['license_key'] as String?;
    } catch (_) {}
    
    // Return as-is if it looks like a license
    if (qrData.length >= 16) {
      return qrData;
    }
    
    return null;
  }
  
  // =========================================================================
  // Dispose
  // =========================================================================
  
  @override
  void dispose() {
    _devicesSubscription?.cancel();
    _connectionSubscription?.cancel();
    _weightSubscription?.cancel();
    _scaleService?.disconnect();
    super.dispose();
  }
}
