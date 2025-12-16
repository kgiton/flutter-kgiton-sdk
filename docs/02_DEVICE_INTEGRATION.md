# Device Integration Guide

**Complete guide for integrating KGiTON BLE scale devices into your Flutter application.**

> **Prerequisites**: Complete [Getting Started](01_GETTING_STARTED.md) setup before proceeding.

---

## Table of Contents

- [Permission Management](#permission-management)
- [Device Scanning](#device-scanning)
- [Connection & Authentication](#connection--authentication)
- [Weight Data Streaming](#weight-data-streaming)
- [Device Control](#device-control)
- [Connection State Management](#connection-state-management)
- [Best Practices](#best-practices)
- [Complete Examples](#complete-examples)

---

## Permission Management

### Overview

BLE operations require specific permissions that vary by platform and OS version:

| Platform | Permissions Required | Notes |
|----------|---------------------|-------|
| **Android API 21-28** | BLUETOOTH, BLUETOOTH_ADMIN | Location not required |
| **Android API 29-30** | + ACCESS_FINE_LOCATION | Location Service must be ON |
| **Android API 31+** | BLUETOOTH_SCAN, BLUETOOTH_CONNECT | Location optional |
| **iOS 12+** | Bluetooth Always Usage | Declared in Info.plist |

### 1. Request Permissions

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// Simple permission request
final granted = await PermissionHelper.requestBLEPermissions();
if (!granted) {
  // User denied permissions - open settings
  await PermissionHelper.openAppSettings();
  return;
}

print('✅ BLE permissions granted');
```

### Advanced Permission Handling

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  /// Request all required permissions with detailed status
  static Future<bool> requestAllPermissions() async {
    // Check Bluetooth availability
    if (!await _isBluetoothAvailable()) {
      print('❌ Bluetooth not available on this device');
      return false;
    }
    
    // Request BLE permissions via SDK helper
    final bleGranted = await PermissionHelper.requestBLEPermissions();
    
    if (!bleGranted) {
      print('❌ BLE permissions denied');
      return false;
    }
    
    // Android 10-11: Check location service
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 29 && androidInfo.version.sdkInt <= 30) {
        final locationEnabled = await Permission.location.serviceStatus.isEnabled;
        if (!locationEnabled) {
          print('⚠️ Location service must be enabled for Android 10-11');
          // Guide user to enable location
          return false;
        }
      }
    }
    
    print('✅ All permissions granted');
    return true;
  }
  
  /// Check if Bluetooth hardware is available
  static Future<bool> _isBluetoothAvailable() async {
    // Platform-specific check
    return true; // Implement platform channel check
  }
  
  /// Show permission explanation dialog
  static Future<bool> showPermissionRationale(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bluetooth Permission Required'),
        content: Text(
          'This app needs Bluetooth permission to connect to your KGiTON scale device '
          'and receive real-time weight measurements.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Grant Permission'),
          ),
        ],
      ),
    ) ?? false;
  }
}
```

### Permission Status Check

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> checkPermissionStatus() async {
  // Bluetooth Scan
  final scanStatus = await Permission.bluetoothScan.status;
  print('Bluetooth Scan: ${scanStatus.isGranted ? '✅' : '❌'}');
  
  // Bluetooth Connect
  final connectStatus = await Permission.bluetoothConnect.status;
  print('Bluetooth Connect: ${connectStatus.isGranted ? '✅' : '❌'}');
  
  // Location (Android 10-11)
  if (Platform.isAndroid) {
    final locationStatus = await Permission.location.status;
    print('Location: ${locationStatus.isGranted ? '✅' : '❌'}');
  }
}
```

---

## Device Scanning

### Overview

Device scanning discovers nearby KGiTON scale devices using BLE advertising. The SDK provides:

- **Auto-stop scanning**: Stops when device is found (battery efficient)
- **RSSI filtering**: Only show devices with good signal strength
- **Timeout handling**: Prevents indefinite scanning
- **Real-time updates**: Stream-based device list

### 2. Basic Scanning

```dart
final scale = KGiTONScaleService();

// Start scan
await scale.scanForDevices(timeout: Duration(seconds: 10));

// Listen devices
scale.devicesStream.listen((devices) {
  for (var device in devices) {
    print('${device.name} - ${device.deviceId}');
  }
});

// Stop scan
scale.stopScan();
```

### UI Example

```dart
class ScanPage extends StatefulWidget {
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final scale = KGiTONScaleService();
  List<ScaleDevice> devices = [];
  bool scanning = false;
  
  @override
  void initState() {
    super.initState();
    scale.devicesStream.listen((d) => setState(() => devices = d));
  }
  
  Future<void> startScan() async {
    setState(() => scanning = true);
    await scale.scanForDevices(timeout: Duration(seconds: 10));
    setState(() => scanning = false);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan'),
        actions: [
          IconButton(
            icon: Icon(scanning ? Icons.stop : Icons.search),
            onPressed: scanning ? null : startScan,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (ctx, i) {
          final device = devices[i];
          return ListTile(
            leading: Icon(Icons.scale),
            title: Text(device.name),
            subtitle: Text(device.deviceId),
            trailing: ElevatedButton(
              onPressed: () => Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => ConnectPage(device: device),
                ),
              ),
              child: Text('Connect'),
            ),
          );
        },
      ),
    );
  }
  
  @override
  void dispose() {
    scale.dispose();
    super.dispose();
  }
}
```

---

## 3. Connect & Authenticate

### Basic Connection (Without Ownership Verification)

```dart
final response = await scale.connectWithLicenseKey(
  deviceId: 'KGITON_xxx',
  licenseKey: 'your-license-key',
);

if (response.success) {
  print('Connected!');
} else {
  print('Failed: ${response.message}');
}
```

### Secure Connection (With Ownership Verification) ⭐ RECOMMENDED

Untuk memastikan hanya pemilik sah yang bisa connect ke timbangan, aktifkan verifikasi kepemilikan dengan menyediakan `KgitonApiService` saat inisialisasi:

```dart
// 1. Inisialisasi API Service (biasanya setelah login)
final apiService = KgitonApiService(
  baseUrl: 'https://api.example.com',
  accessToken: 'user-access-token',
);

// 2. Buat scale service DENGAN API service
final scale = KGiTONScaleService(apiService: apiService);

// ATAU set API service setelah user login
final scale = KGiTONScaleService();
// ... setelah user login ...
scale.setApiService(apiService);

// 3. Connect - akan otomatis memverifikasi kepemilikan
final response = await scale.connectWithLicenseKey(
  deviceId: 'KGITON_xxx',
  licenseKey: 'your-license-key',
);

if (response.success) {
  print('Connected! (Ownership verified)');
} else {
  print('Failed: ${response.message}');
  // Error bisa jadi:
  // - "Anda bukan pemilik sah dari license key ini"
  // - "License tidak valid"
  // - dll.
}
```

**Cara Kerja:**
1. Saat `connectWithLicenseKey` dipanggil, SDK akan mengecek apakah user adalah pemilik license key
2. SDK memanggil API `/owner/licenses` untuk mendapatkan daftar license milik user
3. Jika license key ada dalam daftar, koneksi diizinkan
4. Jika tidak, koneksi ditolak dengan error

**Keuntungan:**
- ✅ Hanya pemilik sah yang bisa connect
- ✅ Mencegah akses tidak sah meskipun license key diketahui orang lain
- ✅ Audit trail yang lebih baik
- ✅ Keamanan berlapis (verifikasi API + verifikasi device)

**Catatan:**
- Jika API service TIDAK disediakan, verifikasi kepemilikan akan di-skip (backward compatible)
- Verifikasi kepemilikan memerlukan koneksi internet
- User harus sudah login sebelum connect

### Monitor Connection State

```dart
scale.connectionStateStream.listen((state) {
  switch (state) {
    case ScaleConnectionState.disconnected:
      print('Disconnected');
      break;
    case ScaleConnectionState.connecting:
      print('Connecting...');
      break;
    case ScaleConnectionState.authenticating:
      print('Authenticating...');
      break;
    case ScaleConnectionState.connected:
      print('Connected!');
      break;
  }
});
```

### UI Example

```dart
class ConnectPage extends StatefulWidget {
  final ScaleDevice device;
  const ConnectPage({required this.device});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final scale = KGiTONScaleService();
  final licenseCtrl = TextEditingController();
  ScaleConnectionState state = ScaleConnectionState.disconnected;
  
  @override
  void initState() {
    super.initState();
    scale.connectionStateStream.listen((s) {
      setState(() => state = s);
      if (s == ScaleConnectionState.connected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => WeightPage(scale: scale)),
        );
      }
    });
  }
  
  Future<void> connect() async {
    if (licenseCtrl.text.isEmpty) return;
    
    final res = await scale.connectWithLicenseKey(
      deviceId: widget.device.deviceId,
      licenseKey: licenseCtrl.text,
    );
    
    if (!res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connect')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: licenseCtrl,
              decoration: InputDecoration(
                labelText: 'License Key',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: state == ScaleConnectionState.connecting 
                  ? null 
                  : connect,
              child: Text(state == ScaleConnectionState.connecting 
                  ? 'Connecting...' 
                  : 'Connect'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 4. Read Weight

```dart
scale.weightStream.listen((weight) {
  print('Weight: ${weight.displayWeight}');
  print('Raw: ${weight.weight} kg');
  print('Stable: ${weight.isStable}');
});
```

### UI Example

```dart
class WeightPage extends StatefulWidget {
  final KGiTONScaleService scale;
  const WeightPage({required this.scale});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  WeightData? weight;
  
  @override
  void initState() {
    super.initState();
    widget.scale.weightStream.listen((w) => setState(() => weight = w));
  }
  
  @override
  Widget build(BuildContext context) {
    if (weight == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: Text('Weight')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weight!.displayWeight,
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: weight!.isStable ? Colors.green : Colors.orange,
              ),
            ),
            SizedBox(height: 16),
            Chip(
              label: Text(weight!.isStable ? 'STABLE' : 'WEIGHING...'),
              backgroundColor: weight!.isStable 
                  ? Colors.green 
                  : Colors.orange,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.volume_up),
              label: Text('Beep'),
              onPressed: () => widget.scale.sendBuzzerCommand('beep'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Control Buzzer

```dart
// Short beep
await scale.sendBuzzerCommand('beep');

// Long beep
await scale.sendBuzzerCommand('long_beep');

// Error sound
await scale.sendBuzzerCommand('error');

// Success sound
await scale.sendBuzzerCommand('success');
```

---

## 6. Disconnect

```dart
await scale.disconnect();

// Listen disconnect
scale.connectionStateStream.listen((state) {
  if (state == ScaleConnectionState.disconnected) {
    print('Disconnected');
  }
});
```

---

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

class DevicePage extends StatefulWidget {
  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final scale = KGiTONScaleService();
  List<ScaleDevice> devices = [];
  WeightData? weight;
  ScaleConnectionState state = ScaleConnectionState.disconnected;
  
  @override
  void initState() {
    super.initState();
    
    scale.devicesStream.listen((d) => setState(() => devices = d));
    scale.connectionStateStream.listen((s) => setState(() => state = s));
    scale.weightStream.listen((w) => setState(() => weight = w));
    
    requestPermissions();
  }
  
  Future<void> requestPermissions() async {
    final granted = await PermissionHelper.requestBLEPermissions();
    if (!granted) {
      await PermissionHelper.openAppSettings();
    }
  }
  
  Future<void> scan() async {
    await scale.scanForDevices(timeout: Duration(seconds: 10));
  }
  
  Future<void> connect(String deviceId) async {
    final res = await scale.connectWithLicenseKey(
      deviceId: deviceId,
      licenseKey: 'your-license-key',
    );
    
    if (!res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scale Device'),
        actions: [
          if (state == ScaleConnectionState.disconnected)
            IconButton(
              icon: Icon(Icons.search),
              onPressed: scan,
            ),
        ],
      ),
      body: state == ScaleConnectionState.connected
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weight?.displayWeight ?? '0.0 kg',
                    style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => scale.sendBuzzerCommand('beep'),
                    child: Text('Beep'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (ctx, i) {
                final device = devices[i];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.deviceId),
                  trailing: ElevatedButton(
                    onPressed: () => connect(device.deviceId),
                    child: Text('Connect'),
                  ),
                );
              },
            ),
    );
  }
  
  @override
  void dispose() {
    scale.dispose();
    super.dispose();
  }
}
```

---

## Best Practices

### 1. Resource Management

```dart
class ScaleManager {
  KGiTONScaleService? _service;
  
  KGiTONScaleService get service {
    _service ??= KGiTONScaleService();
    return _service!;
  }
  
  void dispose() {
    _service?.dispose();
    _service = null;
  }
}
```

### 2. Error Handling

```dart
Future<void> safeConnect(String deviceId, String licenseKey) async {
  try {
    final response = await scale.connectWithLicenseKey(
      deviceId: deviceId,
      licenseKey: licenseKey,
    );
    
    if (response.success) {
      print('✅ Connected successfully');
    } else {
      print('❌ Connection failed: ${response.message}');
      // Handle specific errors
      if (response.message.contains('license')) {
        // Invalid license key
      } else if (response.message.contains('timeout')) {
        // Connection timeout - retry?
      }
    }
  } catch (e) {
    print('💥 Exception: $e');
    // Handle exception
  }
}
```

### 3. Connection Retry Logic

```dart
Future<bool> connectWithRetry({
  required String deviceId,
  required String licenseKey,
  int maxRetries = 3,
}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      final response = await scale.connectWithLicenseKey(
        deviceId: deviceId,
        licenseKey: licenseKey,
      );
      
      if (response.success) {
        print('✅ Connected on attempt ${i + 1}');
        return true;
      }
      
      if (i < maxRetries - 1) {
        print('⏳ Retry ${i + 1}/$maxRetries in 2 seconds...');
        await Future.delayed(Duration(seconds: 2));
      }
    } catch (e) {
      print('❌ Attempt ${i + 1} failed: $e');
    }
  }
  
  print('💥 Failed after $maxRetries attempts');
  return false;
}
```

### 4. Weight Data Validation

```dart
StreamSubscription<WeightData>? _weightSubscription;

void listenToWeight() {
  _weightSubscription = scale.weightStream.listen(
    (weight) {
      // Validate weight data
      if (weight.value < 0) {
        print('⚠️ Invalid negative weight');
        return;
      }
      
      if (weight.value > 500) {
        print('⚠️ Weight exceeds maximum capacity');
        return;
      }
      
      // Only use stable weights for transactions
      if (weight.isStable) {
        processWeight(weight.value);
      }
    },
    onError: (error) {
      print('❌ Weight stream error: $error');
    },
  );
}

void dispose() {
  _weightSubscription?.cancel();
}
```

### 5. Background/Foreground Handling

```dart
class ScaleLifecycleManager extends WidgetsBindingObserver {
  final KGiTONScaleService scale;
  
  ScaleLifecycleManager(this.scale) {
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App in background - stop scanning to save battery
        scale.stopScan();
        break;
      case AppLifecycleState.resumed:
        // App resumed - check connection
        _checkConnection();
        break;
      default:
        break;
    }
  }
  
  Future<void> _checkConnection() async {
    // Verify connection still active
    final currentState = await scale.connectionStateStream.first;
    if (currentState == ScaleConnectionState.disconnected) {
      print('⚠️ Connection lost while in background');
      // Attempt reconnection?
    }
  }
  
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
```

### 6. Memory Management

```dart
class WeightMonitor {
  StreamSubscription? _weightSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _devicesSub;
  
  void startMonitoring(KGiTONScaleService scale) {
    _weightSub = scale.weightStream.listen((weight) { });
    _stateSub = scale.connectionStateStream.listen((state) { });
    _devicesSub = scale.devicesStream.listen((devices) { });
  }
  
  void stopMonitoring() {
    _weightSub?.cancel();
    _stateSub?.cancel();
    _devicesSub?.cancel();
  }
}
```

---

## API Reference

### KGiTONScaleService

#### Methods

| Method | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `scanForDevices` | `timeout: Duration?` | `Future<void>` | Start BLE device scan |
| `stopScan` | - | `void` | Stop active scan |
| `connectWithLicenseKey` | `deviceId: String, licenseKey: String` | `Future<ControlResponse>` | Connect and authenticate |
| `disconnect` | - | `Future<void>` | Disconnect from device |
| `sendBuzzerCommand` | `command: String` | `Future<void>` | Control device buzzer |
| `dispose` | - | `void` | Clean up resources |

#### Streams

| Stream | Type | Description |
|--------|------|-------------|
| `devicesStream` | `Stream<List<ScaleDevice>>` | Discovered devices |
| `weightStream` | `Stream<WeightData>` | Real-time weight data (~10 Hz) |
| `connectionStateStream` | `Stream<ScaleConnectionState>` | Connection status |

#### Models

**ScaleDevice**
```dart
class ScaleDevice {
  final String deviceId;      // e.g., "KGITON_ABC123"
  final String name;          // Device name
  final int rssi;             // Signal strength
}
```

**WeightData**
```dart
class WeightData {
  final double value;         // Weight in kg
  final String unit;          // "kg" or "g"
  final bool isStable;        // Stable reading?
  final String displayWeight; // Formatted string
}
```

**ScaleConnectionState**
```dart
enum ScaleConnectionState {
  disconnected,    // Not connected
  connecting,      // BLE connection in progress
  authenticating,  // License verification
  connected,       // Fully connected and ready
}
```

**ControlResponse**
```dart
class ControlResponse {
  final bool success;    // Operation succeeded?
  final String message;  // Status or error message
}
```

---

## Troubleshooting

### Device Not Found

**Problem**: Scan doesn't find device

**Solutions**:
1. Ensure device is powered on and in pairing mode
2. Check distance < 10 meters
3. Verify permissions granted
4. Android 10-11: Enable Location Service
5. Try longer scan timeout (15-20 seconds)

### Connection Timeout

**Problem**: Connection attempt times out

**Solutions**:
1. Verify license key is correct (uppercase, no spaces)
2. Ensure device not connected to another phone
3. Restart device
4. Move closer to device
5. Check Bluetooth is enabled

### Weight Data Not Streaming

**Problem**: Connected but no weight updates

**Solutions**:
1. Verify connection state is `connected`
2. Check weight stream subscription is active
3. Place weight on scale to trigger reading
4. Restart connection

### Permission Denied

**Problem**: BLE permissions denied

**Solutions**:
1. Request permissions before scanning
2. Explain permission purpose to user
3. Guide user to app settings
4. Show permission rationale dialog

---

## Next Steps

### Continue Learning

- **[API Integration](03_API_INTEGRATION.md)** - Backend integration, authentication, item management
- **[Cart & Transaction](04_CART_TRANSACTION.md)** - Shopping cart, checkout, payments
- **[Troubleshooting](05_TROUBLESHOOTING.md)** - Error codes, common issues, debugging

### Example Code

- **[Complete Example App](../example/kgiton_apps/)** - Full reference implementation

---

**Copyright © 2025 PT KGiTON. All Rights Reserved.**

For support, contact: support@kgiton.com
