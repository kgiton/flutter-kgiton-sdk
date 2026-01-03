# KGiTON SDK - API Module

REST API client untuk integrasi backend KGiTON.

## 📦 Module Structure

```
lib/src/api/
├── api_constants.dart            # API endpoints & constants
├── kgiton_api_client.dart        # HTTP client with token management
├── kgiton_api_service.dart       # Main API service facade
├── exceptions/
│   └── api_exceptions.dart       # Custom API exceptions
├── models/
│   ├── api_response.dart         # Generic response wrapper
│   ├── auth_models.dart          # Authentication models
│   ├── license_models.dart       # License & token models
│   ├── topup_models.dart         # Top-up transaction models
│   ├── license_transaction_models.dart  # License purchase models
│   └── models.dart               # Barrel export
└── services/
    ├── auth_service.dart         # Authentication service
    ├── user_service.dart         # User & token operations
    ├── license_service.dart      # License validation (public)
    ├── topup_service.dart        # Token top-up service
    ├── license_transaction_service.dart  # License purchase
    └── services.dart             # Barrel export
```

## 🎯 Features

### Core Features
- ✅ HTTP client with automatic token management
- ✅ JWT token + API key authentication
- ✅ Token persistence via SharedPreferences
- ✅ Automatic token injection in headers
- ✅ Comprehensive error handling
- ✅ Type-safe models with JSON serialization

### Services Available

| Service | Description |
|---------|-------------|
| `auth` | Register, login, logout, password reset |
| `user` | Profile, token balance, use token, API key |
| `license` | Validate license (public endpoint) |
| `topup` | Payment methods, request top-up, history |
| `licenseTransaction` | Purchase/subscription payments |

## 🚀 Quick Start

### Import

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';
```

### Initialize

```dart
final api = KgitonApiService(baseUrl: 'https://api.kgiton.com');
```

### Login

```dart
final authData = await api.auth.login(
  email: 'user@example.com',
  password: 'password',
);
// Token automatically injected for subsequent requests
```

### Check Token Balance

```dart
final balance = await api.user.getTokenBalance();
print('Total: ${balance.totalRemainingBalance} tokens');
```

### Use Token

```dart
final result = await api.user.useToken('LICENSE-KEY');
print('Remaining: ${result.remainingBalance}');
```

### Top-up Tokens

```dart
final response = await api.topup.requestTopup(
  tokenCount: 100,
  licenseKey: 'LICENSE-KEY',
  paymentMethod: 'checkout_page',
);
// Open response.checkoutPageUrl in browser
```

## 📡 API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register with license key |
| POST | `/api/auth/login` | Login |
| POST | `/api/auth/logout` | Logout |
| POST | `/api/auth/forgot-password` | Request reset email |
| POST | `/api/auth/reset-password` | Reset password |

### User
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/user/profile` | Get user profile |
| GET | `/api/user/token-balance` | Get token balance |
| POST | `/api/user/use-token` | Use 1 token |
| POST | `/api/user/assign-license` | Assign new license |
| POST | `/api/user/regenerate-api-key` | Regenerate API key |
| DELETE | `/api/user/revoke-api-key` | Revoke API key |

### License (Public)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/license/validate/:key` | Validate license key |

### Top-up
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/topup/payment-methods` | Available methods |
| POST | `/api/topup/request` | Request top-up |
| GET | `/api/topup/status/:id` | Check status |
| GET | `/api/topup/history` | Transaction history |
| POST | `/api/topup/cancel/:id` | Cancel transaction |

### License Transactions
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/license-transactions/my-licenses` | My licenses |
| GET | `/api/license-transactions/my-transactions` | My transactions |
| POST | `/api/license-transactions/initiate-purchase` | Initiate purchase |
| POST | `/api/license-transactions/initiate-subscription` | Initiate subscription |

## ⚠️ Error Handling

```dart
try {
  await api.auth.login(email: email, password: password);
} on KgitonApiException catch (e) {
  print('Error ${e.statusCode}: ${e.message}');
}
```

## 📚 More Information

See [API Reference](../../docs/06_API_REFERENCE.md) for complete documentation.
