/// KGiTON BLE Scale SDK
///
/// Flutter SDK untuk integrasi timbangan berbasis ESP32 via BLE.
/// Mendukung autentikasi license key, kontrol buzzer, dan streaming data berat realtime.
/// Juga menyediakan API client untuk berkomunikasi dengan backend KGiTON.
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

// ==================== API Services ====================
// API Client & Main Service
export 'src/api/kgiton_api_client.dart';
export 'src/api/kgiton_api_service.dart';

// API Constants
export 'src/api/api_constants.dart';

// API Services
export 'src/api/services/auth_service.dart';
export 'src/api/services/owner_service.dart';
export 'src/api/services/cart_service.dart';
export 'src/api/services/transaction_service.dart';

// API Models
export 'src/api/models/api_response.dart';
export 'src/api/models/auth_models.dart';
export 'src/api/models/license_models.dart';
export 'src/api/models/item_models.dart';
export 'src/api/models/cart_models.dart';
export 'src/api/models/transaction_models.dart';

// API Exceptions
export 'src/api/exceptions/api_exceptions.dart';

// ==================== Helpers ====================
// Simplified helpers for common operations
export 'src/helpers/kgiton_auth_helper.dart';
export 'src/helpers/kgiton_cart_helper.dart';
export 'src/helpers/kgiton_license_helper.dart';
