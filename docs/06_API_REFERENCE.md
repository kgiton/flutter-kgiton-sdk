# 📖 API Reference (Client Edition)

Referensi lengkap semua API yang tersedia di KGiTON SDK.

---

## 📋 Table of Contents

- [KgitonApiService](#kgitonapiservice)
- [Auth Service](#auth-service)
- [User Service](#user-service)
- [License Service](#license-service)
- [Topup Service](#topup-service)
- [License Transaction Service](#license-transaction-service)
- [Scale Service](#scale-service)
- [Models](#models)
- [Exceptions](#exceptions)

---

## KgitonApiService

Main API service facade yang menyediakan akses ke semua sub-services.

### Constructor

```dart
KgitonApiService({
  required String baseUrl,
  String? accessToken,
  String? apiKey,
})
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `auth` | `KgitonAuthService` | Authentication service |
| `user` | `KgitonUserService` | User operations service |
| `license` | `KgitonLicenseService` | License validation service |
| `topup` | `KgitonTopupService` | Token top-up service |
| `licenseTransaction` | `KgitonLicenseTransactionService` | License transactions service |
| `client` | `KgitonApiClient` | Underlying HTTP client |
| `baseUrl` | `String` | Current base URL |

### Methods

```dart
// Set credentials
void setAccessToken(String? token)
void setApiKey(String? key)
void clearCredentials()

// Configuration persistence
Future<void> saveConfiguration()
Future<void> loadConfiguration()
Future<void> clearConfiguration()

// Status
bool isAuthenticated()

// Cleanup
void dispose()
```

---

## Auth Service

`KgitonAuthService` - Handles authentication operations.

### register()

Register new user with license key.

```dart
Future<AuthData> register({
  required String email,
  required String password,
  required String confirmPassword,
  required String licenseKey,
  String? referralCode,
})
```

**Returns:** `AuthData` with access token and user info.

**Throws:**
- `KgitonApiException` with status 400 for invalid data
- `KgitonApiException` with status 409 for email already exists

---

### login()

Login with email and password.

```dart
Future<AuthData> login({
  required String email,
  required String password,
})
```

**Returns:** `AuthData` with access token and user info.

**Throws:**
- `KgitonApiException` with status 401 for invalid credentials

---

### logout()

Logout and invalidate session.

```dart
Future<void> logout()
```

---

### forgotPassword()

Request password reset email.

```dart
Future<Map<String, dynamic>> forgotPassword(String email)
```

**Returns:** Map with `message` field.

---

### resetPassword()

Reset password with token from email.

```dart
Future<Map<String, dynamic>> resetPassword({
  required String token,
  required String password,
  required String confirmPassword,
})
```

---

### isAuthenticated()

Check if client has valid token.

```dart
bool isAuthenticated()
```

---

## User Service

`KgitonUserService` - User profile and token operations.

### getProfile()

Get current user profile.

```dart
Future<User> getProfile()
```

---

### getTokenBalance()

Get token balance for all user's licenses.

```dart
Future<TokenBalanceData> getTokenBalance()
```

**Returns:** `TokenBalanceData` with total balance and per-license breakdown.

---

### useToken()

Use 1 token from a license (for weighing session).

```dart
Future<UseTokenResponse> useToken(String licenseKey)
```

**Returns:** `UseTokenResponse` with remaining balance.

**Throws:**
- `KgitonApiException` with status 400 if no tokens available

---

### assignLicense()

Assign additional license to user.

```dart
Future<LicenseKey> assignLicense(String licenseKey)
```

---

### regenerateApiKey()

Generate new API key (invalidates old one).

```dart
Future<String> regenerateApiKey()
```

**Returns:** New API key string.

---

### revokeApiKey()

Revoke current API key.

```dart
Future<void> revokeApiKey()
```

---

## License Service

`KgitonLicenseService` - License validation (public endpoints).

### validateLicense()

Validate a license key (no auth required).

```dart
Future<ValidateLicenseResponse> validateLicense(String licenseKey)
```

**Returns:** `ValidateLicenseResponse` with validation result.

---

## Topup Service

`KgitonTopupService` - Token top-up and payment.

### getPaymentMethods()

Get available payment methods.

```dart
Future<List<PaymentMethodInfo>> getPaymentMethods()
```

---

### requestTopup()

Request token top-up.

```dart
Future<TopupResponse> requestTopup({
  required int tokenCount,
  required String licenseKey,
  required String paymentMethod,
})
```

**Payment methods:** `checkout_page`, `qris`, `va_bri`, `va_bni`, `va_bca`, `va_mandiri`, `va_permata`, `va_bsi`, `va_cimb`

---

### checkTransactionStatusPublic()

Check transaction status (public, no auth).

```dart
Future<TransactionStatusResponse> checkTransactionStatusPublic(String transactionId)
```

---

### checkTransactionStatus()

Check transaction status (authenticated).

```dart
Future<TransactionStatusResponse> checkTransactionStatus(String transactionId)
```

---

### getTransactionHistory()

Get top-up transaction history.

```dart
Future<List<TopupTransaction>> getTransactionHistory({
  int page = 1,
  int limit = 20,
  String? status,
  String? licenseKey,
})
```

---

### cancelTransaction()

Cancel pending transaction.

```dart
Future<void> cancelTransaction(String transactionId)
```

---

## License Transaction Service

`KgitonLicenseTransactionService` - License purchase and subscription.

### getMyTransactions()

Get user's license transactions.

```dart
Future<List<LicenseTransaction>> getMyTransactions({
  int page = 1,
  int limit = 20,
  String? status,
})
```

---

### getMyLicenses()

Get user's active licenses.

```dart
Future<List<LicenseTransaction>> getMyLicenses()
```

---

### initiatePurchase()

Initiate license purchase payment.

```dart
Future<InitiatePaymentResponse> initiatePurchase({
  required String licenseKey,
  required String paymentMethod,
})
```

---

### initiateSubscription()

Initiate license subscription payment.

```dart
Future<InitiatePaymentResponse> initiateSubscription({
  required String licenseKey,
  required String paymentMethod,
})
```

---

## Scale Service

`KgitonScaleService` - BLE scale connection and control.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `devicesStream` | `Stream<List<ScaleDevice>>` | Discovered devices |
| `weightStream` | `Stream<WeightData>` | Real-time weight data |
| `connectionStateStream` | `Stream<ScaleConnectionState>` | Connection state changes |
| `isConnected` | `bool` | Current connection status |
| `connectedDevice` | `ScaleDevice?` | Currently connected device |

### startScan()

Start scanning for KGiTON devices.

```dart
Future<void> startScan({
  Duration timeout = const Duration(seconds: 10),
  int rssiThreshold = -100,
})
```

---

### stopScan()

Stop scanning.

```dart
Future<void> stopScan()
```

---

### connect()

Connect to device by license key.

```dart
Future<void> connect({
  required String licenseKey,
})
```

---

### connectToDevice()

Connect to specific device.

```dart
Future<void> connectToDevice(ScaleDevice device)
```

---

### disconnect()

Disconnect from device.

```dart
Future<void> disconnect()
```

---

### buzzer()

Send buzzer command.

```dart
Future<ControlResponse> buzzer(BuzzerCommand command)
```

**Commands:** `BuzzerCommand.beep`, `BuzzerCommand.buzz`, `BuzzerCommand.long`, `BuzzerCommand.off`

---

### dispose()

Clean up resources.

```dart
void dispose()
```

---

## Models

### AuthData

```dart
class AuthData {
  final User user;
  final String accessToken;
  final DateTime expiresAt;
}
```

### User

```dart
class User {
  final String id;
  final String email;
  final String? apiKey;
  final String? referralCode;
  final DateTime createdAt;
}
```

### TokenBalanceData

```dart
class TokenBalanceData {
  final int totalRemainingBalance;
  final List<LicenseKeyBalance> licenses;
}
```

### LicenseKeyBalance

```dart
class LicenseKeyBalance {
  final String licenseKey;
  final String status;
  final int remainingBalance;
  final int totalUsed;
  final int totalPurchased;
  final List<TokenUsage> recentUsage;
}
```

### UseTokenResponse

```dart
class UseTokenResponse {
  final bool success;
  final String message;
  final int remainingBalance;
  final DateTime usedAt;
}
```

### TopupTransaction

```dart
class TopupTransaction {
  final String id;
  final String licenseKey;
  final int tokenCount;
  final int amount;
  final String paymentMethod;
  final String status;
  final VirtualAccountInfo? virtualAccount;
  final String? qrisUrl;
  final DateTime? expiresAt;
  final DateTime? paidAt;
  final DateTime createdAt;
}
```

### TopupResponse

```dart
class TopupResponse {
  final String message;
  final TopupTransaction transaction;
  final String? checkoutPageUrl;
}
```

### PaymentMethodInfo

```dart
class PaymentMethodInfo {
  final String code;
  final String displayName;
  final String category;
  final int fee;
  final String feeFormatted;
  final int minAmount;
  final int maxAmount;
}
```

### ValidateLicenseResponse

```dart
class ValidateLicenseResponse {
  final String licenseKey;
  final bool valid;
  final String status;
  final String message;
}
```

### LicenseTransaction

```dart
class LicenseTransaction {
  final String id;
  final String licenseKey;
  final String type;  // 'buy' or 'rent'
  final String status;
  final int amount;
  final String paymentMethod;
  final DateTime? paidAt;
  final DateTime createdAt;
}
```

### ScaleDevice

```dart
class ScaleDevice {
  final String id;
  final String name;
  final String licenseKey;
  final int rssi;
}
```

### WeightData

```dart
class WeightData {
  final double value;
  final String unit;
  final String formatted;
  final bool isStable;
  final DateTime timestamp;
}
```

### ScaleConnectionState

```dart
enum ScaleConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}
```

### BuzzerCommand

```dart
enum BuzzerCommand {
  beep,
  buzz,
  long,
  off,
}
```

---

## Exceptions

### KgitonApiException

```dart
class KgitonApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
}
```

### BluetoothException

```dart
class BluetoothException implements Exception {
  final String message;
}
```

### DeviceNotFoundException

```dart
class DeviceNotFoundException implements Exception {
  final String message;
}
```

### AuthenticationException

```dart
class AuthenticationException implements Exception {
  final String message;
}
```

### ConnectionException

```dart
class ConnectionException implements Exception {
  final String message;
}
```

---

## Constants

### API Endpoints

```dart
class ApiEndpoints {
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  
  static const String userProfile = '/api/user/profile';
  static const String tokenBalance = '/api/user/token-balance';
  static const String useToken = '/api/user/use-token';
  static const String assignLicense = '/api/user/assign-license';
  
  static const String validateLicense = '/api/license/validate';
  
  static const String paymentMethods = '/api/topup/payment-methods';
  static const String requestTopup = '/api/topup/request';
  static const String topupHistory = '/api/topup/history';
  
  static const String myLicenses = '/api/license-transactions/my-licenses';
  static const String myTransactions = '/api/license-transactions/my-transactions';
}
```

### License Status

```dart
class LicenseStatus {
  static const String available = 'available';
  static const String assigned = 'assigned';
  static const String active = 'active';
  static const String inactive = 'inactive';
  static const String expired = 'expired';
}
```

### Transaction Status

```dart
class TransactionStatus {
  static const String pending = 'pending';
  static const String completed = 'completed';
  static const String failed = 'failed';
  static const String expired = 'expired';
  static const String cancelled = 'cancelled';
}
```

### Payment Methods

```dart
class PaymentMethod {
  static const String checkoutPage = 'checkout_page';
  static const String qris = 'qris';
  static const String vaBri = 'va_bri';
  static const String vaBni = 'va_bni';
  static const String vaBca = 'va_bca';
  static const String vaMandiri = 'va_mandiri';
  static const String vaPermata = 'va_permata';
  static const String vaBsi = 'va_bsi';
  static const String vaCimb = 'va_cimb';
}
```
