# 🔵 BLE Integration

Panduan lengkap untuk integrasi timbangan KGiTON via Bluetooth Low Energy.

---

## 📋 Overview

### Fitur BLE

| Feature | Description |
|---------|-------------|
| Device Discovery | Scan perangkat KGiTON di sekitar |
| Auto-connect | Koneksi otomatis ke device yang dipilih |
| Real-time Weight | Streaming data berat @ 10Hz |
| Buzzer Control | Kontrol buzzer (BEEP, BUZZ, LONG, OFF) |
| Auto-reconnect | Reconnect otomatis saat terputus |

### Karakteristik BLE

| Characteristic | Description |
|----------------|-------------|
| Weight Stream | Menerima data berat realtime |
| Control | Mengirim perintah ke device |
| License Auth | Autentikasi dengan license key |

---

## ⚙️ Setup Permissions

### Request Permissions

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

Future<bool> requestPermissions() async {
  // Request all required permissions
  final granted = await PermissionHelper.requestBLEPermissions();
  
  if (!granted) {
    // Get detailed error message
    final errorMsg = await PermissionHelper.getPermissionErrorMessage();
    print('❌ Permission denied: $errorMsg');
    return false;
  }
  
  print('✅ All permissions granted');
  return true;
}
```

### Check Bluetooth Status

```dart
Future<void> checkBluetoothStatus() async {
  final isEnabled = await PermissionHelper.isBluetoothEnabled();
  
  if (!isEnabled) {
    print('⚠️ Bluetooth is disabled');
    
    // Request user to enable Bluetooth
    await PermissionHelper.requestEnableBluetooth();
  }
}
```

---

## 🔍 Device Discovery

### Initialize Scale Service

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

class ScaleManager {
  late KgitonScaleService _scaleService;
  
  void initialize() {
    _scaleService = KgitonScaleService();
    
    // Listen to discovered devices
    _scaleService.devicesStream.listen((devices) {
      print('Found ${devices.length} device(s)');
      
      for (var device in devices) {
        print('  - ${device.name}');
        print('    License: ${device.licenseKey}');
        print('    RSSI: ${device.rssi} dBm');
        print('    Distance: ${_getDistanceString(device.rssi)}');
      }
    });
    
    // Listen to connection state
    _scaleService.connectionStateStream.listen((state) {
      print('Connection state: ${state.name}');
    });
  }
  
  String _getDistanceString(int rssi) {
    if (rssi > -50) return 'Very close';
    if (rssi > -70) return 'Close';
    if (rssi > -90) return 'Far';
    return 'Very far';
  }
}
```

### Start Scanning

```dart
Future<void> startScanning() async {
  print('🔍 Scanning for KGiTON devices...');
  
  try {
    await _scaleService.startScan(
      timeout: Duration(seconds: 10),  // Auto-stop after 10 seconds
      rssiThreshold: -80,              // Only show devices with RSSI > -80
    );
    
  } on BluetoothException catch (e) {
    print('❌ Scan error: ${e.message}');
  }
}
```

### Stop Scanning

```dart
Future<void> stopScanning() async {
  await _scaleService.stopScan();
  print('⏹️ Scan stopped');
}
```

---

## 🔗 Connect to Device

### Connect by License Key

```dart
Future<void> connectToDevice(String licenseKey) async {
  print('🔗 Connecting to $licenseKey...');
  
  try {
    await _scaleService.connect(licenseKey: licenseKey);
    print('✅ Connected successfully!');
    
  } on DeviceNotFoundException catch (e) {
    print('❌ Device not found: ${e.message}');
    
  } on AuthenticationException catch (e) {
    print('❌ Authentication failed: ${e.message}');
    
  } on ConnectionException catch (e) {
    print('❌ Connection failed: ${e.message}');
  }
}
```

### Connect to Specific Device

```dart
Future<void> connectToSpecificDevice(ScaleDevice device) async {
  try {
    await _scaleService.connectToDevice(device);
    print('✅ Connected to ${device.name}');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

---

## ⚖️ Weight Streaming

### Listen to Weight Data

```dart
void listenToWeight() {
  _scaleService.weightStream.listen(
    (weight) {
      print('Weight: ${weight.value} ${weight.unit}');
      print('  Formatted: ${weight.formatted}');
      print('  Stable: ${weight.isStable}');
      print('  Timestamp: ${weight.timestamp}');
      
      // Update UI
      updateWeightDisplay(weight);
    },
    onError: (error) {
      print('❌ Weight stream error: $error');
    },
    onDone: () {
      print('⏹️ Weight stream ended');
    },
  );
}
```

### Weight Data Model

```dart
class WeightData {
  final double value;       // Weight value (e.g., 12.5)
  final String unit;        // Unit (kg, g, lb)
  final String formatted;   // Formatted string (e.g., "12.50 kg")
  final bool isStable;      // Weight stability indicator
  final DateTime timestamp; // Measurement time
}
```

### Handle Weight Updates in UI

```dart
class WeighingPage extends StatefulWidget {
  @override
  _WeighingPageState createState() => _WeighingPageState();
}

class _WeighingPageState extends State<WeighingPage> {
  WeightData? currentWeight;
  StreamSubscription? _weightSubscription;
  
  @override
  void initState() {
    super.initState();
    _startListening();
  }
  
  void _startListening() {
    _weightSubscription = scaleService.weightStream.listen((weight) {
      setState(() {
        currentWeight = weight;
      });
    });
  }
  
  @override
  void dispose() {
    _weightSubscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentWeight?.formatted ?? '0.00 kg',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          if (currentWeight?.isStable == true)
            Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }
}
```

---

## 🔔 Buzzer Control

### Buzzer Commands

```dart
enum BuzzerCommand {
  beep,   // Short beep
  buzz,   // Medium buzz
  long,   // Long beep
  off,    // Turn off buzzer
}
```

### Send Buzzer Command

```dart
Future<void> controlBuzzer(BuzzerCommand command) async {
  try {
    final response = await _scaleService.buzzer(command);
    
    if (response.success) {
      print('✅ Buzzer command sent: ${command.name}');
    } else {
      print('❌ Buzzer command failed: ${response.message}');
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
}

// Usage
await controlBuzzer(BuzzerCommand.beep);  // Short beep
await controlBuzzer(BuzzerCommand.buzz);  // Medium buzz
await controlBuzzer(BuzzerCommand.long);  // Long beep
await controlBuzzer(BuzzerCommand.off);   // Turn off
```

---

## 🔌 Disconnect

### Manual Disconnect

```dart
Future<void> disconnect() async {
  await _scaleService.disconnect();
  print('🔌 Disconnected');
}
```

### Handle Disconnection

```dart
_scaleService.connectionStateStream.listen((state) {
  switch (state) {
    case ScaleConnectionState.connected:
      print('✅ Connected');
      break;
      
    case ScaleConnectionState.disconnected:
      print('🔌 Disconnected');
      // Show reconnect dialog
      showReconnectDialog();
      break;
      
    case ScaleConnectionState.connecting:
      print('🔗 Connecting...');
      break;
      
    case ScaleConnectionState.disconnecting:
      print('🔌 Disconnecting...');
      break;
      
    case ScaleConnectionState.error:
      print('❌ Connection error');
      break;
  }
});
```

---

## 🔄 Auto-reconnect

```dart
class ScaleConnectionManager {
  final KgitonScaleService _scaleService;
  String? _lastLicenseKey;
  int _reconnectAttempts = 0;
  static const _maxReconnectAttempts = 3;
  
  void enableAutoReconnect() {
    _scaleService.connectionStateStream.listen((state) {
      if (state == ScaleConnectionState.disconnected && 
          _lastLicenseKey != null &&
          _reconnectAttempts < _maxReconnectAttempts) {
        _attemptReconnect();
      }
    });
  }
  
  Future<void> _attemptReconnect() async {
    _reconnectAttempts++;
    print('🔄 Reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts');
    
    await Future.delayed(Duration(seconds: 2));
    
    try {
      await _scaleService.connect(licenseKey: _lastLicenseKey!);
      _reconnectAttempts = 0;  // Reset on success
      
    } catch (e) {
      print('❌ Reconnect failed: $e');
    }
  }
  
  Future<void> connect(String licenseKey) async {
    _lastLicenseKey = licenseKey;
    _reconnectAttempts = 0;
    await _scaleService.connect(licenseKey: licenseKey);
  }
}
```

---

## 📝 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

class ScalePage extends StatefulWidget {
  final String licenseKey;
  
  const ScalePage({required this.licenseKey});
  
  @override
  _ScalePageState createState() => _ScalePageState();
}

class _ScalePageState extends State<ScalePage> {
  late KgitonScaleService _scale;
  WeightData? _currentWeight;
  ScaleConnectionState _connectionState = ScaleConnectionState.disconnected;
  List<ScaleDevice> _devices = [];
  
  @override
  void initState() {
    super.initState();
    _initScale();
  }
  
  void _initScale() {
    _scale = KgitonScaleService();
    
    // Listen to devices
    _scale.devicesStream.listen((devices) {
      setState(() => _devices = devices);
    });
    
    // Listen to connection state
    _scale.connectionStateStream.listen((state) {
      setState(() => _connectionState = state);
    });
    
    // Listen to weight
    _scale.weightStream.listen((weight) {
      setState(() => _currentWeight = weight);
    });
  }
  
  Future<void> _startScan() async {
    final granted = await PermissionHelper.requestBLEPermissions();
    if (!granted) {
      _showError('Bluetooth permission required');
      return;
    }
    
    await _scale.startScan();
  }
  
  Future<void> _connect() async {
    try {
      await _scale.connect(licenseKey: widget.licenseKey);
    } catch (e) {
      _showError(e.toString());
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  void dispose() {
    _scale.disconnect();
    _scale.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('KGiTON Scale')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Connection status
            Chip(
              label: Text(_connectionState.name),
              backgroundColor: _connectionState == ScaleConnectionState.connected
                  ? Colors.green
                  : Colors.grey,
            ),
            
            SizedBox(height: 32),
            
            // Weight display
            Text(
              _currentWeight?.formatted ?? '0.00 kg',
              style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            ),
            
            if (_currentWeight?.isStable == true)
              Icon(Icons.check_circle, color: Colors.green, size: 32),
            
            SizedBox(height: 32),
            
            // Buttons
            if (_connectionState == ScaleConnectionState.disconnected) ...[
              ElevatedButton(
                onPressed: _startScan,
                child: Text('Scan Devices'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _connect,
                child: Text('Connect'),
              ),
            ],
            
            if (_connectionState == ScaleConnectionState.connected) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.volume_up),
                    onPressed: () => _scale.buzzer(BuzzerCommand.beep),
                  ),
                  IconButton(
                    icon: Icon(Icons.volume_off),
                    onPressed: () => _scale.buzzer(BuzzerCommand.off),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _scale.disconnect(),
                child: Text('Disconnect'),
              ),
            ],
            
            // Device list
            if (_devices.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return ListTile(
                      leading: Icon(Icons.bluetooth),
                      title: Text(device.name),
                      subtitle: Text('RSSI: ${device.rssi} dBm'),
                      onTap: () => _scale.connectToDevice(device),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## ⚠️ Troubleshooting

### Device Not Found

1. Pastikan timbangan menyala
2. Pastikan Bluetooth enabled
3. Pastikan location enabled (Android 10-11)
4. Coba restart scan

### Connection Failed

1. Pastikan license key benar
2. Pastikan tidak ada device lain yang connect
3. Restart timbangan
4. Restart Bluetooth

### Weight Not Updating

1. Pastikan sudah subscribe ke weightStream
2. Check connection state
3. Pastikan characteristic weight sudah enabled

---

## 🔗 Next Steps

- [API Reference](06_API_REFERENCE.md) - Referensi API lengkap
- [Troubleshooting](07_TROUBLESHOOTING.md) - Solusi masalah umum
