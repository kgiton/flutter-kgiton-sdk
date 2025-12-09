# Device Integration

## 1. Request Permissions

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// Simple
final granted = await PermissionHelper.requestBLEPermissions();
if (!granted) {
  await PermissionHelper.openAppSettings();
}
```

---

## 2. Scan Devices

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

## Next

- [API Integration](03_API_INTEGRATION.md)
- [Cart & Transaction](04_CART_TRANSACTION.md)
- [Troubleshooting](05_TROUBLESHOOTING.md)
