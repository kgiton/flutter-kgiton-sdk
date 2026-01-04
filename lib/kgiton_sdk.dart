/// KGiTON BLE Scale SDK
///
/// Flutter SDK untuk integrasi timbangan berbasis ESP32 via BLE.
/// Mendukung autentikasi license key, kontrol buzzer, dan streaming data berat realtime.
/// Juga menyediakan API client untuk berkomunikasi dengan backend KGiTON.
///
/// # Features
/// - BLE connection to KGiTON Scale devices
/// - Real-time weight streaming
/// - License key validation and management
/// - Token-based usage system
/// - Top-up tokens via various payment methods
///
/// # Usage
/// ```dart
/// import 'package:kgiton_sdk/kgiton_sdk.dart';
///
/// // Initialize API service
/// final api = KgitonApiService(baseUrl: 'https://api.kgiton.com');
///
/// // Login
/// final authData = await api.auth.login(
///   email: 'user@example.com',
///   password: 'password',
/// );
///
/// // Get token balance
/// final balance = await api.user.getTokenBalance();
///
/// // Use token for weighing session
/// final result = await api.user.useToken('LICENSE-KEY');
///
/// // Connect to BLE scale
/// final scale = KgitonScaleService();
/// await scale.connect('LICENSE-KEY');
/// scale.weightStream.listen((weight) {
///   print('Weight: ${weight.value} ${weight.unit}');
/// });
/// ```
library kgiton_sdk;

// ==================== BLE Services ====================
// Core Services
export 'src/kgiton_scale_service.dart';

// BLE Models
export 'src/models/scale_device.dart';
export 'src/models/scale_connection_state.dart';
export 'src/models/weight_data.dart';
export 'src/models/control_response.dart';

// Constants
export 'src/constants/ble_constants.dart';

// BLE Exceptions
export 'src/exceptions/kgiton_exceptions.dart';

// Utils
export 'src/utils/permission_helper.dart';
export 'src/utils/debug_logger.dart';

// ==================== API Services ====================
// API Client & Main Service
export 'src/api/kgiton_api_client.dart';
export 'src/api/kgiton_api_service.dart';

// API Constants
export 'src/api/api_constants.dart';

// API Services
export 'src/api/services/auth_service.dart';
export 'src/api/services/user_service.dart';
export 'src/api/services/license_service.dart';
export 'src/api/services/topup_service.dart';
export 'src/api/services/license_transaction_service.dart';

// API Models
export 'src/api/models/api_response.dart';
export 'src/api/models/auth_models.dart';
export 'src/api/models/license_models.dart';
export 'src/api/models/topup_models.dart';
export 'src/api/models/license_transaction_models.dart';

// API Exceptions
export 'src/api/exceptions/api_exceptions.dart';

// ==================== Helpers ====================
// Simplified helpers for common operations
export 'src/helpers/kgiton_auth_helper.dart';
export 'src/helpers/kgiton_license_helper.dart';
export 'src/helpers/kgiton_topup_helper.dart';
