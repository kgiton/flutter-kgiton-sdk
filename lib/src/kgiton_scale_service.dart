import 'dart:async';
import 'dart:convert';
import 'package:kgiton_ble_sdk/kgiton_ble_sdk.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/ble_constants.dart';
import 'models/scale_device.dart';
import 'models/scale_connection_state.dart';
import 'models/weight_data.dart';
import 'models/control_response.dart';
import 'exceptions/kgiton_exceptions.dart';

/// KGiTON Scale Service
///
/// Service utama untuk komunikasi dengan timbangan ESP32 via BLE.
///
/// Fitur:
/// - Connect/Disconnect dengan license key
/// - Streaming data berat realtime
/// - Kontrol buzzer
/// - Autentikasi perangkat
class KGiTONScaleService {
  final Logger? logger;

  // BLE SDK
  final _bleSdk = KgitonBleSdk();

  // Connected device info
  String? _connectedDeviceId;
  String? _txCharacteristicId;
  String? _controlCharacteristicId;
  String? _buzzerCharacteristicId;

  // Subscriptions
  StreamSubscription<List<BleDevice>>? _scanSubscription;
  StreamSubscription<Map<String, BleConnectionState>>? _connectionSubscription;
  StreamSubscription<List<int>>? _dataSubscription;
  StreamSubscription<List<int>>? _controlSubscription;

  // Stream Controllers
  final _weightStreamController = StreamController<WeightData>.broadcast();
  final _connectionStateController = StreamController<ScaleConnectionState>.broadcast();
  final _devicesController = StreamController<List<ScaleDevice>>.broadcast();
  final _controlResponseController = StreamController<String>.broadcast();

  // State
  ScaleConnectionState _connectionState = ScaleConnectionState.disconnected;
  final List<ScaleDevice> _availableDevices = [];

  // Storage key untuk license key mapping
  static const String _storageKey = 'kgiton_device_licenses';

  /// Constructor
  KGiTONScaleService({this.logger}) {
    _log('KGiTON Scale Service initialized');
  }

  // ============================================
  // GETTERS
  // ============================================

  /// Stream untuk data berat
  Stream<WeightData> get weightStream => _weightStreamController.stream;

  /// Stream untuk status koneksi
  Stream<ScaleConnectionState> get connectionStateStream => _connectionStateController.stream;

  /// Stream untuk daftar perangkat yang ditemukan
  Stream<List<ScaleDevice>> get devicesStream => _devicesController.stream;

  /// Status koneksi saat ini
  ScaleConnectionState get connectionState => _connectionState;

  /// Apakah sedang terhubung
  bool get isConnected => _connectionState.isConnected;

  /// Apakah sudah terautentikasi
  bool get isAuthenticated => _connectionState == ScaleConnectionState.authenticated;

  /// Device yang terhubung
  ScaleDevice? get connectedDevice {
    if (_connectedDeviceId == null) return null;
    final device = _availableDevices.firstWhere(
      (d) => d.id == _connectedDeviceId,
      orElse: () => ScaleDevice(name: 'Unknown', id: _connectedDeviceId!, rssi: 0),
    );
    return device;
  }

  /// Daftar perangkat yang tersedia
  List<ScaleDevice> get availableDevices => List.unmodifiable(_availableDevices);

  // ============================================
  // PUBLIC METHODS - SCANNING
  // ============================================

  // Timer untuk debounce device processing
  Timer? _deviceProcessingTimer;
  List<BleDevice>? _pendingDevices;

  /// Scan untuk menemukan perangkat timbangan
  ///
  /// [timeout] - Durasi maksimal scan (default: 10 detik)
  /// [autoStopOnFound] - Otomatis stop scan setelah menemukan device (default: false)
  ///
  /// Throws [BLEConnectionException] jika gagal memulai scan
  Future<void> scanForDevices({Duration? timeout, bool autoStopOnFound = false}) async {
    if (_connectionState == ScaleConnectionState.scanning) {
      _log('Already scanning', level: Level.warning);
      return;
    }

    _updateConnectionState(ScaleConnectionState.scanning);
    _availableDevices.clear();
    _devicesController.add([]);

    final scanTimeout = timeout ?? BLEConstants.scanTimeout;
    _log('Starting BLE scan for ${BLEConstants.deviceName} (timeout: ${scanTimeout.inSeconds}s, autoStop: $autoStopOnFound)');

    try {
      _scanSubscription = _bleSdk.scanResults.listen(
        (devices) {
          _log('Received ${devices.length} total device(s) from BLE scan', level: Level.debug);

          // Debounce device processing - wait 300ms before processing
          // This prevents excessive processing when multiple devices are found rapidly
          _pendingDevices = devices;
          _deviceProcessingTimer?.cancel();
          _deviceProcessingTimer = Timer(const Duration(milliseconds: 300), () {
            if (_pendingDevices != null) {
              _processScannedDevices(_pendingDevices!, autoStopOnFound: autoStopOnFound);
              _pendingDevices = null;
            }
          });
        },
        onError: (error) {
          _log('Scan error: $error', level: Level.error);
          stopScan();
        },
      );

      // Start scan without name filter (we'll filter in Dart)
      await _bleSdk.startScan(timeout: scanTimeout);

      // Auto stop setelah timeout
      Timer(scanTimeout, () {
        if (_connectionState == ScaleConnectionState.scanning) {
          stopScan();
          _log('Scan completed - found ${_availableDevices.length} device(s)');

          if (_availableDevices.isEmpty) {
            _updateConnectionState(ScaleConnectionState.disconnected);
          }
        }
      });
    } catch (e) {
      _log('Failed to start scan: $e', level: Level.error);
      _updateConnectionState(ScaleConnectionState.error);
      throw BLEConnectionException('Gagal memulai scan: $e', originalError: e);
    }
  }

  /// Process scanned devices with license key mapping
  Future<void> _processScannedDevices(List<BleDevice> devices, {bool autoStopOnFound = false}) async {
    _availableDevices.clear();

    // Load license key map untuk mapping ke device
    final licenseMap = await _loadLicenseKeyMap();

    // Filter devices by name containing target device name
    for (final device in devices) {
      _log('Device: ${device.name} (${device.id}), RSSI: ${device.rssi}', level: Level.debug);

      // Filter: name must contain "KGiTON" (case-insensitive)
      if (device.name.toUpperCase().contains(BLEConstants.deviceName.toUpperCase())) {
        // Cari license key untuk device ini
        final licenseKey = licenseMap[device.id];

        final scaleDevice = ScaleDevice.fromBleDevice(device.name, device.id, device.rssi, licenseKey: licenseKey);
        _availableDevices.add(scaleDevice);
        _log('✓ Device matched filter: ${device.name}${licenseKey != null ? " (has license key)" : ""}', level: Level.info);
      }
    }

    _devicesController.add(List.from(_availableDevices));
    if (_availableDevices.isNotEmpty) {
      _log('Found ${_availableDevices.length} KGiTON device(s)', level: Level.info);

      // Auto stop scan jika diminta dan ada device yang ditemukan
      if (autoStopOnFound && _connectionState == ScaleConnectionState.scanning) {
        _log('Auto-stopping scan - found device(s)', level: Level.info);
        stopScan();
      }
    }
  }

  /// Stop scanning
  void stopScan() {
    // Cancel debounce timer
    _deviceProcessingTimer?.cancel();
    _deviceProcessingTimer = null;
    _pendingDevices = null;

    // Cancel scan subscription
    _scanSubscription?.cancel();
    _scanSubscription = null;

    try {
      _bleSdk.stopScan();
    } catch (e) {
      _log('Error stopping BLE scan: $e', level: Level.warning);
    }

    if (_connectionState == ScaleConnectionState.scanning) {
      _updateConnectionState(ScaleConnectionState.disconnected);
    }

    _log('Scan stopped');
  }

  // ============================================
  // PUBLIC METHODS - CONNECTION
  // ============================================

  /// Connect ke perangkat dengan license key
  ///
  /// [deviceId] - ID perangkat dari hasil scan
  /// [licenseKey] - License key untuk autentikasi
  ///
  /// Throws [DeviceNotFoundException] jika device tidak ditemukan
  /// Throws [BLEConnectionException] jika gagal connect
  /// Throws [LicenseKeyException] jika license key invalid
  Future<ControlResponse> connectWithLicenseKey({required String deviceId, required String licenseKey}) async {
    _log('Connecting with license key to device: $deviceId');

    // Stop scan jika masih berjalan
    if (_connectionState == ScaleConnectionState.scanning) {
      _log('Stopping scan before connecting', level: Level.info);
      stopScan();
    }

    // Validasi device ada dalam daftar
    if (!_availableDevices.any((d) => d.id == deviceId)) {
      throw DeviceNotFoundException('Device $deviceId tidak ditemukan');
    }

    try {
      // Connect ke device
      await _connectToDevice(deviceId);

      // Send CONNECT command dengan license key
      final response = await _sendControlCommand('CONNECT:$licenseKey');

      // Jika berhasil connect, simpan license key ke storage
      if (response.success) {
        await _saveLicenseKey(deviceId, licenseKey);

        // Update device di list dengan license key
        final deviceIndex = _availableDevices.indexWhere((d) => d.id == deviceId);
        if (deviceIndex >= 0) {
          _availableDevices[deviceIndex] = _availableDevices[deviceIndex].copyWith(licenseKey: licenseKey);
          _devicesController.add(List.from(_availableDevices));
        }
      }

      // Jika gagal (license invalid), error akan di-handle di _sendControlCommand
      // dan auto-disconnect sudah dilakukan
      return response;
    } catch (e) {
      // Pastikan disconnect jika terjadi error
      _log('Connect failed, ensuring cleanup: $e', level: Level.error);
      await _disconnectDevice();
      rethrow;
    }
  }

  /// Disconnect dari perangkat dengan license key
  ///
  /// [licenseKey] - License key yang sama dengan saat connect
  ///
  /// Throws [LicenseKeyException] jika license key tidak sesuai
  Future<ControlResponse> disconnectWithLicenseKey(String licenseKey) async {
    if (!isConnected) {
      return ControlResponse.error('Tidak terhubung ke perangkat');
    }

    _log('Disconnecting with license key');

    // Send DISCONNECT command dengan license key
    final response = await _sendControlCommand('DISCONNECT:$licenseKey');

    // Disconnect BLE
    await _disconnectDevice();

    return response;
  }

  /// Disconnect tanpa license key (force disconnect)
  Future<void> disconnect() async {
    _log('Force disconnect');

    // Make sure to stop any ongoing scans
    if (_connectionState == ScaleConnectionState.scanning) {
      stopScan();
    }

    await _disconnectDevice();
  }

  // ============================================
  // PUBLIC METHODS - BUZZER
  // ============================================

  /// Trigger buzzer dengan perintah tertentu
  ///
  /// [command] - Perintah buzzer: BUZZ, BEEP, ON, LONG, OFF
  ///
  /// Throws [BLEConnectionException] jika tidak terhubung
  Future<void> triggerBuzzer(String command) async {
    if (!isAuthenticated) {
      throw BLEConnectionException('Tidak terhubung atau belum terautentikasi');
    }

    if (_buzzerCharacteristicId == null) {
      throw BLEConnectionException('Buzzer characteristic tidak tersedia');
    }

    _log('Triggering buzzer: $command');

    try {
      final bytes = command.codeUnits;
      await _bleSdk.write(_buzzerCharacteristicId!, bytes);
      _log('Buzzer command sent successfully');
    } catch (e) {
      _log('Failed to trigger buzzer: $e', level: Level.error);
      throw BLEConnectionException('Gagal mengirim perintah buzzer: $e', originalError: e);
    }
  }

  // ============================================
  // PRIVATE METHODS - CONNECTION
  // ============================================

  Future<void> _connectToDevice(String deviceId) async {
    _updateConnectionState(ScaleConnectionState.connecting);
    _log('Connecting to $deviceId...');

    try {
      // Listen connection state
      _connectionSubscription = _bleSdk.connectionState.listen((stateMap) {
        if (stateMap.containsKey(deviceId)) {
          final state = stateMap[deviceId]!;
          _log('Connection state changed: ${state.name}');

          if (state.isDisconnected) {
            _handleDisconnection();
          } else if (state.isConnected) {
            _updateConnectionState(ScaleConnectionState.connected);
          }
        }
      });

      // Connect
      await _bleSdk.connect(deviceId);

      _connectedDeviceId = deviceId;

      // Discover services
      await _discoverServices(deviceId);
    } catch (e) {
      _log('Connection failed: $e', level: Level.error);
      _handleDisconnection();
      throw BLEConnectionException('Gagal terhubung: $e', originalError: e);
    }
  }

  Future<void> _discoverServices(String deviceId) async {
    _log('Discovering services...');

    try {
      final services = await _bleSdk.discoverServices(deviceId);
      _log('Found ${services.length} services');

      BleService? targetService;

      // Cari service yang sesuai
      for (final service in services) {
        if (service.uuid.toLowerCase() == BLEConstants.serviceUUID.toLowerCase()) {
          targetService = service;
          _log('Target service found');
          break;
        }
      }

      if (targetService == null) {
        throw BLEConnectionException('Service timbangan tidak ditemukan');
      }

      // Cari characteristics
      for (final char in targetService.characteristics) {
        final uuid = char.uuid.toLowerCase();

        if (uuid == BLEConstants.txCharacteristicUUID.toLowerCase()) {
          _txCharacteristicId = char.id;
          _log('TX characteristic found');
        } else if (uuid == BLEConstants.controlCharacteristicUUID.toLowerCase()) {
          _controlCharacteristicId = char.id;
          _log('Control characteristic found');
        } else if (uuid == BLEConstants.buzzerCharacteristicUUID.toLowerCase()) {
          _buzzerCharacteristicId = char.id;
          _log('Buzzer characteristic found');
        }
      }

      // Validasi characteristics yang diperlukan
      if (_txCharacteristicId == null || _controlCharacteristicId == null) {
        throw BLEConnectionException('Karakteristik yang diperlukan tidak ditemukan');
      }

      // Setup listeners
      await _setupControlListener();

      _log('Service discovery completed');
    } catch (e) {
      _log('Service discovery failed: $e', level: Level.error);
      throw BLEConnectionException('Gagal menemukan service: $e', originalError: e);
    }
  }

  Future<void> _setupControlListener() async {
    if (_controlCharacteristicId == null) return;

    try {
      await _bleSdk.setNotify(_controlCharacteristicId!, true);

      // Wait for writeDescriptor operation to complete
      // Android GATT operations are sequential - 100ms is sufficient for modern devices
      await Future.delayed(const Duration(milliseconds: 100));

      _controlSubscription = _bleSdk
          .notificationStream(_controlCharacteristicId!)
          .listen(
            (value) {
              final response = String.fromCharCodes(value).trim();
              _log('Control response received: $response');

              // Emit response ke stream untuk digunakan oleh _sendControlCommand
              _controlResponseController.add(response);
            },
            onError: (error) {
              _log('Control stream error: $error', level: Level.error);
            },
          );

      _log('Control listener setup completed');
    } catch (e) {
      _log('Failed to setup control listener: $e', level: Level.error);
    }
  }

  Future<void> _setupDataListener() async {
    if (_txCharacteristicId == null) return;

    try {
      _log('Setting up data listener...');

      await _bleSdk.setNotify(_txCharacteristicId!, true);

      // Wait for writeDescriptor operation to complete
      await Future.delayed(const Duration(milliseconds: 100));

      _dataSubscription = _bleSdk
          .notificationStream(_txCharacteristicId!)
          .listen(
            (value) {
              try {
                // Log raw bytes untuk debugging
                _log('Raw bytes received: $value (length: ${value.length})', level: Level.debug);

                final weightStr = String.fromCharCodes(value).trim();
                _log('Parsed string: "$weightStr" (length: ${weightStr.length})', level: Level.debug);

                final weight = double.tryParse(weightStr);

                if (weight != null) {
                  final weightData = WeightData(weight: weight);
                  _weightStreamController.add(weightData);
                  _log('Weight received: ${weightData.formattedWeight} kg (raw: $weight)', level: Level.info);
                } else {
                  _log('Invalid weight format: "$weightStr" (bytes: $value)', level: Level.warning);
                }
              } catch (e) {
                _log('Error processing weight data: $e (bytes: $value)', level: Level.error);
              }
            },
            onError: (error) {
              _log('Data stream error: $error', level: Level.error);
            },
          );

      _log('Data listener active');
    } catch (e) {
      _log('Failed to setup data listener: $e', level: Level.error);
    }
  }

  Future<ControlResponse> _sendControlCommand(String command) async {
    if (_controlCharacteristicId == null) {
      throw BLEConnectionException('Control characteristic tidak tersedia');
    }

    _log('Sending control command: ${command.split(':').first}');

    try {
      final bytes = command.codeUnits;
      await _bleSdk.write(_controlCharacteristicId!, bytes);

      // Tunggu response dari notification stream (2 detik cukup untuk ESP32)
      final responseStr = await _controlResponseController.stream.first.timeout(const Duration(seconds: 2), onTimeout: () => 'TIMEOUT');

      _log('Control response: $responseStr');

      if (responseStr == 'TIMEOUT') {
        throw BLEConnectionException('Timeout menunggu response dari device');
      }

      final response = ControlResponse.fromDeviceResponse(responseStr);

      // Update state berdasarkan response
      if (response.success) {
        if (responseStr == 'CONNECTED' || responseStr == 'ALREADY_CONNECTED') {
          _updateConnectionState(ScaleConnectionState.authenticated);

          // Setup data listener setelah authenticated
          await _setupDataListener();

          // Trigger buzzer sukses (hanya untuk CONNECTED, bukan ALREADY_CONNECTED)
          // Non-blocking untuk tidak menambah delay pada proses autentikasi
          if (responseStr == 'CONNECTED') {
            // Fire and forget - tidak menunggu buzzer selesai
            triggerBuzzer('BUZZ').catchError((e) {
              _log('Failed to trigger success buzzer: $e', level: Level.warning);
            });
          }
        } else if (responseStr == 'DISCONNECTED') {
          _updateConnectionState(ScaleConnectionState.connected);
        }
      } else {
        // Jika response error (license key invalid, dll), auto-disconnect
        _log('Control command failed: ${response.message}. Auto-disconnecting...', level: Level.warning);

        // Disconnect dari device karena autentikasi gagal
        await _disconnectDevice();
      }

      return response;
    } catch (e) {
      _log('Control command failed: $e', level: Level.error);
      throw BLEConnectionException('Gagal mengirim perintah: $e', originalError: e);
    }
  }

  Future<void> _disconnectDevice() async {
    if (_connectedDeviceId != null) {
      try {
        await _bleSdk.disconnect(_connectedDeviceId!);
      } catch (e) {
        _log('Disconnect error: $e', level: Level.warning);
      }
    }

    _handleDisconnection();
  }

  void _handleDisconnection() {
    _log('Handling disconnection');

    _connectedDeviceId = null;
    _txCharacteristicId = null;
    _controlCharacteristicId = null;
    _buzzerCharacteristicId = null;

    _connectionSubscription?.cancel();
    _dataSubscription?.cancel();
    _controlSubscription?.cancel();

    _updateConnectionState(ScaleConnectionState.disconnected);
  }

  // ============================================
  // PRIVATE METHODS - UTILITIES
  // ============================================

  void _updateConnectionState(ScaleConnectionState newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      _connectionStateController.add(newState);
      _log('Connection state: ${newState.displayName}');
    }
  }

  void _log(String message, {Level level = Level.debug}) {
    if (logger != null) {
      switch (level) {
        case Level.debug:
          logger!.d('[KGiTON SDK] $message');
          break;
        case Level.info:
          logger!.i('[KGiTON SDK] $message');
          break;
        case Level.warning:
          logger!.w('[KGiTON SDK] $message');
          break;
        case Level.error:
          logger!.e('[KGiTON SDK] $message');
          break;
        default:
          logger!.d('[KGiTON SDK] $message');
      }
    }
  }

  // ============================================
  // PRIVATE METHODS - LICENSE KEY STORAGE
  // ============================================

  /// Simpan license key untuk device tertentu
  Future<void> _saveLicenseKey(String deviceId, String licenseKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load existing mapping
      final Map<String, String> licenseMap = await _loadLicenseKeyMap();

      // Update mapping
      licenseMap[deviceId] = licenseKey;

      // Save back to storage
      final jsonString = jsonEncode(licenseMap);
      await prefs.setString(_storageKey, jsonString);

      _log('License key saved for device: $deviceId', level: Level.info);
    } catch (e) {
      _log('Failed to save license key: $e', level: Level.error);
    }
  }

  /// Load semua mapping deviceId -> licenseKey
  Future<Map<String, String>> _loadLicenseKeyMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        return Map<String, String>.from(decoded);
      }

      return {};
    } catch (e) {
      _log('Failed to load license key map: $e', level: Level.error);
      return {};
    }
  }

  // ============================================
  // CLEANUP
  // ============================================

  /// Dispose - hanya panggil saat app closing
  void dispose() {
    _log('Disposing KGiTON Scale Service');

    // Cancel debounce timer
    _deviceProcessingTimer?.cancel();
    _deviceProcessingTimer = null;
    _pendingDevices = null;

    stopScan();
    _disconnectDevice();

    _weightStreamController.close();
    _connectionStateController.close();
    _devicesController.close();
    _controlResponseController.close();

    _bleSdk.dispose();
  }
}
