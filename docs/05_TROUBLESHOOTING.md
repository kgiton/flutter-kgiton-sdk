# Troubleshooting Guide

**Comprehensive troubleshooting guide with error codes, solutions, and debugging tips**

> **Quick Help**: Use `Ctrl+F` / `Cmd+F` to search for your specific error message.

---

## Table of Contents

- [Error Code Reference](#error-code-reference)
- [HTTP Status Codes](#http-status-codes)
- [Permission Issues](#permission-issues)
- [BLE Connection Problems](#ble-connection-problems)
- [API Errors](#api-errors)
- [Weight Reading Issues](#weight-reading-issues)
- [Platform-Specific Issues](#platform-specific-issues)
- [Debug Tools & Tips](#debug-tools--tips)

---

## Error Code Reference

### SDK Error Codes

| Code | Message | Cause | Solution |
|------|---------|-------|----------|
| **BLE-001** | Bluetooth not enabled | Device Bluetooth is off | Enable Bluetooth in device settings |
| **BLE-002** | Permission denied | BLE permissions not granted | Request permissions via `PermissionHelper` |
| **BLE-003** | Device not found | Device not in range or powered off | Check device power, move closer, retry scan |
| **BLE-004** | Connection timeout | Failed to establish BLE connection | Restart device, move closer, check interference |
| **BLE-005** | Authentication failed | Invalid license key | Verify license key is correct and active |
| **BLE-006** | Device already connected | Another app/phone has connection | Disconnect from other device first |
| **API-001** | Invalid credentials | Wrong email/password | Check login credentials |
| **API-002** | Token expired | Authentication token no longer valid | Re-login to refresh token |
| **API-003** | Invalid license key | License key format or status invalid | Contact support for license verification |
| **API-004** | Network error | No internet connection | Check network connectivity |
| **API-005** | Server error | Backend server issue | Try again later or contact support |
| **CART-001** | Cart not found | Invalid cart ID | Verify cart ID generation |
| **CART-002** | Item not found | Item ID doesn't exist | Check item ID is valid |
| **CART-003** | Empty cart | Trying to checkout empty cart | Add items before checkout |

---

## HTTP Status Codes

### Success Codes (2xx)

| Code | Status | Meaning |
|------|--------|---------|
| **200** | OK | Request successful |
| **201** | Created | Resource created successfully |
| **204** | No Content | Success with no response body |

### Client Error Codes (4xx)

| Code | Status | Common Cause | Solution |
|------|--------|--------------|----------|
| **400** | Bad Request | Invalid request format or parameters | Check request data format and required fields |
| **401** | Unauthorized | Missing or invalid token | Login again to get new token |
| **403** | Forbidden | Insufficient permissions | Check user role and permissions |
| **404** | Not Found | Resource doesn't exist | Verify ID/URL is correct |
| **409** | Conflict | Duplicate resource | Email/SKU already exists, use different value |
| **422** | Validation Error | Input validation failed | Check error details for specific field errors |
| **429** | Too Many Requests | Rate limit exceeded | Wait before making more requests |

### Server Error Codes (5xx)

| Code | Status | Meaning | Solution |
|------|--------|---------|----------|
| **500** | Internal Server Error | Backend server error | Try again later, contact support if persists |
| **502** | Bad Gateway | Server is down | Wait for server recovery |
| **503** | Service Unavailable | Server maintenance | Check status page or try later |
| **504** | Gateway Timeout | Request took too long | Retry with shorter timeout |

---

## Permission Issues

### Problem: Permission Denied on Scan

**Error Message:**
```
Permission denied: BLUETOOTH_SCAN
```

**Symptoms:**
- Device scan doesn't start
- Empty device list
- Permission popup doesn't appear

**Solutions:**

**1. Request Permissions Properly:**
```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

Future<bool> setupPermissions() async {
  // Request BLE permissions
  final granted = await PermissionHelper.requestBLEPermissions();
  
  if (!granted) {
    print('❌ Permissions denied');
    
    // Guide user to settings
    await PermissionHelper.openAppSettings();
    
    return false;
  }
  
  print('✅ All permissions granted');
  return true;
}
```

**2. Check AndroidManifest.xml:**
```xml
<!-- Required permissions -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

<!-- Hardware feature -->
<uses-feature 
    android:name="android.hardware.bluetooth_le" 
    android:required="true" />
```

**3. Check Info.plist (iOS):**
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to connect to scale devices</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Required for device scanning</string>
```

### Problem: Permission Granted but Still Can't Scan

**Solutions:**

1. **Restart the app** after granting permissions
2. **Check Location Service** (Android 10-11):
   ```dart
   import 'package:permission_handler/permission_handler.dart';
   
   final locationEnabled = await Permission.location.serviceStatus.isEnabled;
   if (!locationEnabled) {
     // Guide user to enable location service
     print('⚠️ Location service must be enabled');
   }
   ```
3. **Verify runtime permissions**:
   ```dart
   final scanStatus = await Permission.bluetoothScan.status;
   final connectStatus = await Permission.bluetoothConnect.status;
   
   print('Scan: $scanStatus');
   print('Connect: $connectStatus');
   ```

---

## BLE Connection Problems

### Problem: Device Not Found During Scan

**Symptoms:**
- Scan completes but no devices found
- Device list remains empty
- Timeout without finding device

**Diagnostic Steps:**

1. **Verify Device Status:**
   ```
   ✓ Device is powered on
   ✓ Device is in pairing/advertising mode
   ✓ Device battery is charged
   ✓ No other phone is connected to device
   ```

2. **Check Distance:**
   - Move within 5-10 meters of device
   - Remove obstacles between phone and device
   - Avoid areas with heavy BLE interference

3. **Extend Scan Timeout:**
   ```dart
   // Increase timeout from 10s to 20s
   await scaleService.scanForDevices(
     timeout: Duration(seconds: 20),
   );
   ```

4. **Enable Debug Logging:**
   ```dart
   scaleService.devicesStream.listen((devices) {
     print('📡 Found ${devices.length} devices:');
     for (var device in devices) {
       print('  - ${device.name} (${device.deviceId}) RSSI: ${device.rssi}');
     }
   });
   ```

### Problem: Connection Timeout

**Error Message:**
```
Connection timeout after 30 seconds
```

**Causes:**
- Weak signal strength
- Device already connected elsewhere
- Bluetooth interference
- Device firmware issue

**Solutions:**

**1. Pre-connection Checklist:**
```dart
Future<bool> preConnectionCheck(ScaleDevice device) async {
  // Check signal strength
  if (device.rssi < -85) {
    print('⚠️ Weak signal (${device.rssi} dBm). Move closer.');
    return false;
  }
  
  // Check Bluetooth is enabled
  // Implementation depends on platform
  
  return true;
}
```

**2. Implement Retry Logic:**
```dart
Future<bool> connectWithRetry({
  required String deviceId,
  required String licenseKey,
  int maxRetries = 3,
}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    print('🔄 Connection attempt $attempt/$maxRetries');
    
    try {
      final response = await scaleService.connectWithLicenseKey(
        deviceId: deviceId,
        licenseKey: licenseKey,
      );
      
      if (response.success) {
        print('✅ Connected on attempt $attempt');
        return true;
      }
      
      print('❌ Attempt $attempt failed: ${response.message}');
      
      if (attempt < maxRetries) {
        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    } catch (e) {
      print('💥 Exception on attempt $attempt: $e');
    }
  }
  
  print('❌ Failed after $maxRetries attempts');
  return false;
}
```

**3. Reset Connection:**
```dart
Future<void> resetConnection() async {
  // Disconnect if connected
  await scaleService.disconnect();
  
  // Wait 2 seconds
  await Future.delayed(Duration(seconds: 2));
  
  // Try fresh connection
  await scaleService.connectWithLicenseKey(
    deviceId: deviceId,
    licenseKey: licenseKey,
  );
}
```

### Problem: Authentication Failed

**Error Message:**
```
Authentication failed: Invalid license key
```

**Causes:**
- Incorrect license key
- License key expired
- License key for different device
- License key format issues (spaces, lowercase)

**Solutions:**

**1. Verify License Key Format:**
```dart
String validateLicenseKey(String licenseKey) {
  // Remove spaces and convert to uppercase
  final cleaned = licenseKey.replaceAll(' ', '').toUpperCase().trim();
  
  // Expected format: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX (29 chars)
  if (cleaned.length != 29) {
    throw Exception('Invalid license key length');
  }
  
  if (!RegExp(r'^[A-Z0-9]{5}(-[A-Z0-9]{5}){4}$').hasMatch(cleaned)) {
    throw Exception('Invalid license key format');
  }
  
  return cleaned;
}

// Usage
try {
  final cleanedKey = validateLicenseKey(userInputKey);
  await scaleService.connectWithLicenseKey(
    deviceId: deviceId,
    licenseKey: cleanedKey,
  );
} catch (e) {
  print('❌ License key validation failed: $e');
}
```

**2. Check License Status:**
```dart
Future<void> checkLicenseStatus() async {
  final licensesData = await apiService.owner.listOwnLicenses();
  
  for (var license in licensesData.licenses) {
    print('License: ${license.licenseKey}');
    print('Entity: ${license.entityName}');
    print('Type: ${license.entityType}');
    print('Expires: ${license.expiresAt}');
    
    // Check if expired
    if (license.expiresAt != null) {
        final expiryDate = DateTime.parse(license.expiresAt!);
        if (expiryDate.isBefore(DateTime.now())) {
          print('⚠️ License expired!');
        }
      }
    }
  }
}
```

**3. Contact Support:**
If license is valid but authentication still fails:
- Email: support@kgiton.com
- Include: License key, device ID, error message

---

## API Errors

### Problem: 401 Unauthorized - Token Expired

**Error Response:**
```json
{
  "success": false,
  "message": "Token expired",
  "error": "UNAUTHORIZED"
}
```

**Solution:**

**1. Automatic Token Refresh:**
```dart
class AuthManager {
  final KgitonApiService api;
  
  AuthManager(this.api);
  
  Future<bool> ensureAuthenticated() async {
    try {
      // Try to get current user (validates token)
      await api.auth.getCurrentUser();
      return true;
    } catch (e) {
      if (e.toString().contains('401') || 
          e.toString().contains('Unauthorized')) {
        // Token expired - redirect to login
        return false;
      }
      rethrow;
    }
  }
  
  Future<void> handleUnauthorized(BuildContext context) async {
    // Clear token
    await api.auth.logout();
    
    // Redirect to login
    Navigator.pushReplacementNamed(context, '/login');
    
    // Show message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Session expired. Please login again.')),
    );
  }
}
```

**2. Global Error Handler:**
```dart
Future<T?> apiCall<T>(Future<Map<String, dynamic>> Function() request) async {
  try {
    final result = await request();
    
    if (result['success'] == true) {
      return result['data'] as T;
    } else {
      print('❌ API Error: ${result['message']}');
      return null;
    }
  } on SocketException {
    print('❌ No internet connection');
    return null;
  } on TimeoutException {
    print('❌ Request timeout');
    return null;
  } catch (e) {
    if (e.toString().contains('401')) {
      print('❌ Unauthorized - token expired');
      // Handle re-login
    }
    print('❌ Exception: $e');
    return null;
  }
}
```

### Problem: 422 Validation Error

**Error Response:**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["Email is required", "Invalid email format"],
    "password": ["Password must be at least 6 characters"]
  }
}
```

**Solution:**

**1. Display Field-Specific Errors:**
```dart
void handleValidationError(Map<String, dynamic> result) {
  if (result['errors'] != null) {
    final errors = result['errors'] as Map<String, dynamic>;
    
    errors.forEach((field, messages) {
      final messageList = messages as List;
      print('$field: ${messageList.join(', ')}');
      
      // Show error to user
      // e.g., set error text on TextField
    });
  }
}

// Usage
try {
  final authData = await apiService.auth.registerOwner(
    name: name,
    email: email,
    password: password,
    licenseKey: licenseKey,
    entityType: 'individual',
  );
  
  print('Registration successful!');
  print('User: ${authData.user.email}');
} catch (e) {
  print('Error: $e');
}
```

**2. Client-Side Validation:**
```dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    
    return null;
  }
  
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}

// Usage in Form
TextFormField(
  validator: Validators.email,
  decoration: InputDecoration(labelText: 'Email'),
)
```

### Problem: Network Connection Error

**Error Message:**
```
SocketException: Failed host lookup
```

**Diagnostic Steps:**

1. **Check Internet Connectivity:**
   ```dart
   import 'package:connectivity_plus/connectivity_plus.dart';
   
   Future<bool> hasInternetConnection() async {
     final connectivity = await Connectivity().checkConnectivity();
     
     if (connectivity == ConnectivityResult.none) {
       print('❌ No internet connection');
       return false;
     }
     
     // Verify actual connectivity with ping
     try {
       final result = await InternetAddress.lookup('google.com');
       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
     } catch (e) {
       return false;
     }
   }
   ```

2. **Show Connection Status:**
   ```dart
   class ConnectionStatusWidget extends StatefulWidget {
     @override
     State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
   }
   
   class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
     bool _isOnline = true;
     
     @override
     void initState() {
       super.initState();
       _checkConnection();
       
       // Listen to connectivity changes
       Connectivity().onConnectivityChanged.listen((result) {
         setState(() {
           _isOnline = result != ConnectivityResult.none;
         });
       });
     }
     
     Future<void> _checkConnection() async {
       final online = await hasInternetConnection();
       setState(() => _isOnline = online);
     }
     
     @override
     Widget build(BuildContext context) {
       if (_isOnline) return SizedBox.shrink();
       
       return Container(
         color: Colors.red,
         padding: EdgeInsets.all(8),
         child: Row(
           children: [
             Icon(Icons.wifi_off, color: Colors.white),
             SizedBox(width: 8),
             Text(
               'No internet connection',
               style: TextStyle(color: Colors.white),
             ),
           ],
         ),
       );
     }
   }
   ```

---

## Weight Reading Issues

### Problem: Unstable Weight Readings

**Symptoms:**
- Numbers constantly changing
- `isStable` never becomes `true`
- Erratic weight values

**Causes:**
- Vibration or movement
- Uneven surface
- Scale needs calibration
- Environmental factors (wind, AC)

**Solutions:**

**1. Wait for Stable Reading:**
```dart
class WeightMonitor {
  StreamSubscription? _subscription;
  Function(double)? onStableWeight;
  
  void startMonitoring(KGiTONScaleService scale) {
    _subscription = scale.weightStream.listen((weight) {
      if (weight.isStable && weight.value > 0) {
        // Only use stable weights
        onStableWeight?.call(weight.value);
      } else {
        print('⏳ Waiting for stable weight... (${weight.value} kg)');
      }
    });
  }
  
  void stop() {
    _subscription?.cancel();
  }
}
```

**2. Implement Debouncing:**
```dart
class DebounceWeight {
  Timer? _debounce;
  double? _lastWeight;
  
  void onWeightChanged(
    WeightData weight,
    Function(double) callback,
  ) {
    // Cancel previous timer
    _debounce?.cancel();
    
    if (weight.isStable) {
      // Only debounce stable weights
      _debounce = Timer(Duration(milliseconds: 500), () {
        if (_lastWeight != weight.value) {
          _lastWeight = weight.value;
          callback(weight.value);
        }
      });
    }
  }
  
  void dispose() {
    _debounce?.cancel();
  }
}
```

**3. Visual Indicator:**
```dart
Widget buildWeightDisplay(WeightData weight) {
  return Column(
    children: [
      Text(
        '${weight.value.toStringAsFixed(2)} kg',
        style: TextStyle(
          fontSize: 48,
          color: weight.isStable ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 8),
      AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: weight.isStable ? Colors.green : Colors.orange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              weight.isStable ? Icons.check_circle : Icons.pending,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              weight.isStable ? 'STABLE' : 'WEIGHING...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
```

### Problem: Weight Always Shows Zero

**Causes:**
- Scale needs calibration
- BLE connection issue
- Scale firmware problem
- No weight on scale

**Solutions:**

1. **Verify Connection:**
   ```dart
   final connectionState = await scaleService.connectionStateStream.first;
   
   if (connectionState != ScaleConnectionState.connected) {
     print('❌ Not connected to scale');
     // Reconnect
   }
   ```

2. **Check Weight Stream:**
   ```dart
   scaleService.weightStream.listen(
     (weight) {
       print('📊 Raw weight: ${weight.value} kg');
       print('   Is stable: ${weight.isStable}');
       print('   Unit: ${weight.unit}');
     },
     onError: (error) {
       print('❌ Weight stream error: $error');
     },
     onDone: () {
       print('⚠️ Weight stream closed');
     },
   );
   ```

3. **Restart Device:**
   ```dart
   Future<void> restartConnection() async {
     await scaleService.disconnect();
     await Future.delayed(Duration(seconds: 3));
     
     final response = await scaleService.connectWithLicenseKey(
       deviceId: deviceId,
       licenseKey: licenseKey,
     );
     
     if (response.success) {
       print('✅ Reconnected successfully');
     }
   }
   ```

---

## Platform-Specific Issues

### Android 10-11 Location Service

**Problem:** Scan fails on Android 10-11

**Error:**
```
Bluetooth scan requires location service to be enabled
```

**Solution:**

```dart
import 'package:location/location.dart';

Future<bool> ensureLocationEnabled() async {
  final location = Location();
  
  // Check if location service is enabled
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    // Request user to enable
    serviceEnabled = await location.requestService();
    
    if (!serviceEnabled) {
      // Show dialog explaining why location is needed
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Location Service Required'),
          content: Text(
            'Android 10-11 requires Location Service to be enabled '
            'for Bluetooth device scanning. This is an Android system '
            'requirement and does not track your location.\n\n'
            'Please enable Location Service in Settings.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Open location settings
                openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        ),
      );
      
      return false;
    }
  }
  
  return true;
}
```

### iOS Background Disconnection

**Problem:** BLE disconnects when app goes to background

**Solution:**

1. **Enable Background Modes** in `Info.plist`:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>bluetooth-central</string>
   </array>
   ```

2. **Handle App Lifecycle:**
   ```dart
   class AppLifecycleManager extends WidgetsBindingObserver {
     final KGiTONScaleService scale;
     
     AppLifecycleManager(this.scale) {
       WidgetsBinding.instance.addObserver(this);
     }
     
     @override
     void didChangeAppLifecycleState(AppLifecycleState state) {
       switch (state) {
         case AppLifecycleState.paused:
           print('⏸️ App paused - BLE may disconnect');
           break;
         case AppLifecycleState.resumed:
           print('▶️ App resumed - checking connection');
           _checkAndReconnect();
           break;
         default:
           break;
       }
     }
     
     Future<void> _checkAndReconnect() async {
       final state = await scale.connectionStateStream.first;
       
       if (state == ScaleConnectionState.disconnected) {
         print('⚠️ Connection lost - attempting reconnect');
         // Attempt reconnection
       }
     }
     
     void dispose() {
       WidgetsBinding.instance.removeObserver(this);
     }
   }
   ```

---

## Debug Tools & Tips

### Enable Debug Logging

```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: true,
  ),
);

// Usage
logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

### Network Debugging

```dart
class HttpLogger {
  static void logRequest(String method, String url, Map<String, dynamic>? body) {
    print('🌐 $method $url');
    if (body != null) {
      print('📤 Body: ${jsonEncode(body)}');
    }
  }
  
  static void logResponse(int statusCode, String body) {
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    print('$emoji Response ($statusCode): $body');
  }
}
```

### BLE Debugging

```dart
void debugBLEConnection(KGiTONScaleService scale) {
  // Monitor connection state
  scale.connectionStateStream.listen((state) {
    print('🔵 Connection State: $state');
  });
  
  // Monitor devices
  scale.devicesStream.listen((devices) {
    print('📡 Devices found: ${devices.length}');
    for (var device in devices) {
      print('  ${device.name} | ${device.deviceId} | RSSI: ${device.rssi}');
    }
  });
  
  // Monitor weight
  scale.weightStream.listen((weight) {
    print('⚖️ Weight: ${weight.value} kg | Stable: ${weight.isStable}');
  });
}
```

### Complete Debug Helper

```dart
class DebugHelper {
  static void logSystemInfo() async {
    print('=== System Information ===');
    print('Platform: ${Platform.operatingSystem}');
    print('Version: ${Platform.operatingSystemVersion}');
    
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      print('Android SDK: ${androidInfo.version.sdkInt}');
      print('Model: ${androidInfo.model}');
    } else if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      print('iOS Version: ${iosInfo.systemVersion}');
      print('Model: ${iosInfo.model}');
    }
    
    print('========================');
  }
  
  static void logSDKState(KGiTONScaleService scale, KgitonApiService api) async {
    print('=== SDK State ===');
    
    // Scale state
    final connectionState = await scale.connectionStateStream.first;
    print('Scale Connection: $connectionState');
    
    // API state
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('API Token: ${token != null ? 'Present' : 'Missing'}');
    
    print('=================');
  }
}
```

### Log Collection for Support

```dart
class LogCollector {
  static final List<String> _logs = [];
  
  static void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] $message';
    
    _logs.add(logEntry);
    print(logEntry);
    
    // Keep only last 1000 logs
    if (_logs.length > 1000) {
      _logs.removeAt(0);
    }
  }
  
  static String exportLogs() {
    return _logs.join('\n');
  }
  
  static Future<void> saveLogs() async {
    final logs = exportLogs();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/kgiton_logs.txt');
    await file.writeAsString(logs);
    print('✅ Logs saved to: ${file.path}');
  }
}
```

---

## Frequently Asked Questions

### General

**Q: Does the SDK support both Android and iOS?**  
A: Yes, the SDK supports Android 5.0+ (API 21+) and iOS 12.0+.

**Q: What is the maximum BLE connection range?**  
A: Optimal range is < 10 meters. Actual range depends on environment, obstacles, and interference.

**Q: Can I connect to multiple devices simultaneously?**  
A: Currently, the SDK supports one device connection per session.

**Q: Is weight data real-time?**  
A: Yes, weight data streams at approximately 10 Hz (10 updates per second).

**Q: How do I update the SDK?**  
A: Run `flutter pub upgrade` or update the version in `pubspec.yaml`.

### Troubleshooting

**Q: Why does my app crash on startup?**  
A: Check that all required permissions are declared in AndroidManifest.xml / Info.plist and that WidgetsFlutterBinding is initialized before using the SDK.

**Q: Weight readings are inconsistent. What should I do?**  
A: Ensure the scale is on a level, stable surface. Wait for `isStable: true` before using weight values.

**Q: I keep getting "Token expired" errors. Why?**  
A: Authentication tokens expire after a certain period. Implement automatic re-login when receiving 401 errors.

**Q: The app can't find my device. What's wrong?**  
A: Verify device is powered on, in range, permissions are granted, and (for Android 10-11) Location Service is enabled.

---

## Still Need Help?

### Contact Support

**For authorized SDK users:**

📧 **Email**: support@kgiton.com  
📞 **Phone**: +62 819-9479-0864
🌐 **Website**: https://www.kgiton.com

**When contacting support, please include:**

1. **SDK Version** (from `pubspec.yaml`)
2. **Platform & OS** (Android/iOS and version)
3. **Error Messages** (complete error logs)
4. **Steps to Reproduce** (detailed sequence)
5. **Screenshots/Videos** (if applicable)
6. **Debug Logs** (use LogCollector to export)

**Response Time**: < 24 hours (business days)

---

## Additional Resources

- 📘 [Getting Started Guide](01_GETTING_STARTED.md)
- 🔵 [Device Integration Guide](02_DEVICE_INTEGRATION.md)
- 🌐 [API Integration Guide](03_API_INTEGRATION.md)
- 🛒 [Cart & Transaction Guide](04_CART_TRANSACTION.md)
- 💻 [Example Application](../example/kgiton_apps/)

---

**Copyright © 2025 PT KGiTON. All Rights Reserved.**

For support, contact: support@kgiton.com
