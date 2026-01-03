/// License Key model - All licenses use token system
/// 1 License = 1 Device (device info stored here)
class LicenseKey {
  final String id;
  final String key;

  // Token pricing & balance
  final double pricePerToken;
  final int tokenBalance;
  final String status;

  // User assignment
  final String? assignedTo;
  final String? referredByUserId;

  // Trial info
  final DateTime? trialExpiresAt;

  // Device info (1 license = 1 device)
  final String? deviceName;
  final String? deviceSerialNumber;
  final String? deviceModel;
  final String? deviceNotes;

  // Purchase info
  final String? purchaseType; // 'buy' or 'rent'
  final double? purchasePrice;
  final double? rentalPriceMonthly;

  // Subscription tracking (for rent type)
  final String? subscriptionStatus;
  final DateTime? subscriptionNextDueDate;
  final DateTime? subscriptionExpiresAt;

  // Purchase tracking (for buy type)
  final String? purchasePaymentStatus;
  final DateTime? purchasePaidAt;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  LicenseKey({
    required this.id,
    required this.key,
    required this.pricePerToken,
    required this.tokenBalance,
    required this.status,
    this.assignedTo,
    this.referredByUserId,
    this.trialExpiresAt,
    this.deviceName,
    this.deviceSerialNumber,
    this.deviceModel,
    this.deviceNotes,
    this.purchaseType,
    this.purchasePrice,
    this.rentalPriceMonthly,
    this.subscriptionStatus,
    this.subscriptionNextDueDate,
    this.subscriptionExpiresAt,
    this.purchasePaymentStatus,
    this.purchasePaidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LicenseKey.fromJson(Map<String, dynamic> json) {
    return LicenseKey(
      id: json['id'] as String,
      key: json['key'] as String,
      pricePerToken: ((json['price_per_token'] as num?) ?? 0).toDouble(),
      tokenBalance: (json['token_balance'] as int?) ?? 0,
      status: (json['status'] as String?) ?? 'inactive',
      assignedTo: json['assigned_to'] as String?,
      referredByUserId: json['referred_by_user_id'] as String?,
      trialExpiresAt: json['trial_expires_at'] != null ? DateTime.parse(json['trial_expires_at'] as String) : null,
      deviceName: json['device_name'] as String?,
      deviceSerialNumber: json['device_serial_number'] as String?,
      deviceModel: json['device_model'] as String?,
      deviceNotes: json['device_notes'] as String?,
      purchaseType: json['purchase_type'] as String?,
      purchasePrice: (json['purchase_price'] as num?)?.toDouble(),
      rentalPriceMonthly: (json['rental_price_monthly'] as num?)?.toDouble(),
      subscriptionStatus: json['subscription_status'] as String?,
      subscriptionNextDueDate: json['subscription_next_due_date'] != null ? DateTime.parse(json['subscription_next_due_date'] as String) : null,
      subscriptionExpiresAt: json['subscription_expires_at'] != null ? DateTime.parse(json['subscription_expires_at'] as String) : null,
      purchasePaymentStatus: json['purchase_payment_status'] as String?,
      purchasePaidAt: json['purchase_paid_at'] != null ? DateTime.parse(json['purchase_paid_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'price_per_token': pricePerToken,
      'token_balance': tokenBalance,
      'status': status,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (referredByUserId != null) 'referred_by_user_id': referredByUserId,
      if (trialExpiresAt != null) 'trial_expires_at': trialExpiresAt!.toIso8601String(),
      if (deviceName != null) 'device_name': deviceName,
      if (deviceSerialNumber != null) 'device_serial_number': deviceSerialNumber,
      if (deviceModel != null) 'device_model': deviceModel,
      if (deviceNotes != null) 'device_notes': deviceNotes,
      if (purchaseType != null) 'purchase_type': purchaseType,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (rentalPriceMonthly != null) 'rental_price_monthly': rentalPriceMonthly,
      if (subscriptionStatus != null) 'subscription_status': subscriptionStatus,
      if (subscriptionNextDueDate != null) 'subscription_next_due_date': subscriptionNextDueDate!.toIso8601String(),
      if (subscriptionExpiresAt != null) 'subscription_expires_at': subscriptionExpiresAt!.toIso8601String(),
      if (purchasePaymentStatus != null) 'purchase_payment_status': purchasePaymentStatus,
      if (purchasePaidAt != null) 'purchase_paid_at': purchasePaidAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if license is in trial mode
  bool get isTrial => status == 'trial';

  /// Check if license is active
  bool get isActive => status == 'active';

  /// Check if trial is expired
  bool get isTrialExpired {
    if (trialExpiresAt == null) return false;
    return DateTime.now().isAfter(trialExpiresAt!);
  }

  /// Check if subscription is expired
  bool get isSubscriptionExpired {
    if (subscriptionExpiresAt == null) return false;
    return DateTime.now().isAfter(subscriptionExpiresAt!);
  }

  /// Check if license is buy type
  bool get isBuyType => purchaseType == 'buy';

  /// Check if license is rent type
  bool get isRentType => purchaseType == 'rent';

  /// Check if purchase is paid (for buy type)
  bool get isPurchasePaid => purchasePaymentStatus == 'paid';

  /// Check if subscription is active (for rent type)
  bool get isSubscriptionActive => subscriptionStatus == 'active';
}

/// License key list data
class LicenseKeyListData {
  final List<LicenseKey> licenseKeys;
  final int total;

  LicenseKeyListData({required this.licenseKeys, required this.total});

  factory LicenseKeyListData.fromJson(dynamic json) {
    if (json is List) {
      final licenseKeys = json.map((e) => LicenseKey.fromJson(e as Map<String, dynamic>)).toList();
      return LicenseKeyListData(licenseKeys: licenseKeys, total: licenseKeys.length);
    }

    if (json is Map<String, dynamic>) {
      final licenseKeys = (json['license_keys'] as List? ?? json['data'] as List? ?? [])
          .map((e) => LicenseKey.fromJson(e as Map<String, dynamic>))
          .toList();
      return LicenseKeyListData(licenseKeys: licenseKeys, total: (json['total'] as int?) ?? licenseKeys.length);
    }

    throw FormatException('Invalid LicenseKeyListData format');
  }

  Map<String, dynamic> toJson() {
    return {'license_keys': licenseKeys.map((e) => e.toJson()).toList(), 'total': total};
  }
}

/// Token balance response
class TokenBalanceData {
  final List<LicenseKeyBalance> licenseKeys;
  final int totalBalance;

  TokenBalanceData({required this.licenseKeys, required this.totalBalance});

  factory TokenBalanceData.fromJson(Map<String, dynamic> json) {
    final licenseKeys = (json['license_keys'] as List? ?? []).map((e) => LicenseKeyBalance.fromJson(e as Map<String, dynamic>)).toList();
    return TokenBalanceData(licenseKeys: licenseKeys, totalBalance: (json['total_balance'] as int?) ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'license_keys': licenseKeys.map((e) => e.toJson()).toList(), 'total_balance': totalBalance};
  }
}

/// License key balance summary
class LicenseKeyBalance {
  final String id;
  final String licenseKey;
  final int tokenBalance;
  final double pricePerToken;
  final String status;

  LicenseKeyBalance({required this.id, required this.licenseKey, required this.tokenBalance, required this.pricePerToken, required this.status});

  factory LicenseKeyBalance.fromJson(Map<String, dynamic> json) {
    return LicenseKeyBalance(
      id: json['id'] as String,
      licenseKey: (json['license_key'] as String?) ?? (json['key'] as String?) ?? '',
      tokenBalance: (json['token_balance'] as int?) ?? 0,
      pricePerToken: ((json['price_per_token'] as num?) ?? 0).toDouble(),
      status: (json['status'] as String?) ?? 'inactive',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'license_key': licenseKey, 'token_balance': tokenBalance, 'price_per_token': pricePerToken, 'status': status};
  }
}

/// Token usage record
class TokenUsage {
  final String id;
  final String licenseKey;
  final String userId;
  final int previousBalance;
  final int newBalance;
  final String? purpose;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  TokenUsage({
    required this.id,
    required this.licenseKey,
    required this.userId,
    required this.previousBalance,
    required this.newBalance,
    this.purpose,
    this.metadata,
    required this.createdAt,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      id: json['id'] as String,
      licenseKey: json['license_key'] as String,
      userId: json['user_id'] as String,
      previousBalance: (json['previous_balance'] as int?) ?? 0,
      newBalance: (json['new_balance'] as int?) ?? 0,
      purpose: json['purpose'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'license_key': licenseKey,
      'user_id': userId,
      'previous_balance': previousBalance,
      'new_balance': newBalance,
      if (purpose != null) 'purpose': purpose,
      if (metadata != null) 'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get tokens used in this transaction
  int get tokensUsed => previousBalance - newBalance;
}

/// Use token request
class UseTokenRequest {
  final String? purpose;
  final Map<String, dynamic>? metadata;

  UseTokenRequest({this.purpose, this.metadata});

  Map<String, dynamic> toJson() {
    return {if (purpose != null) 'purpose': purpose, if (metadata != null) 'metadata': metadata};
  }
}

/// Use token response
class UseTokenResponse {
  final int previousBalance;
  final int newBalance;
  final TokenUsage? usage;

  UseTokenResponse({required this.previousBalance, required this.newBalance, this.usage});

  factory UseTokenResponse.fromJson(Map<String, dynamic> json) {
    return UseTokenResponse(
      previousBalance: (json['previous_balance'] as int?) ?? 0,
      newBalance: (json['new_balance'] as int?) ?? 0,
      usage: json['usage'] != null ? TokenUsage.fromJson(json['usage'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'previous_balance': previousBalance, 'new_balance': newBalance, if (usage != null) 'usage': usage!.toJson()};
  }
}

/// Validate license request
class ValidateLicenseRequest {
  final String licenseKey;

  ValidateLicenseRequest({required this.licenseKey});

  Map<String, dynamic> toJson() {
    return {'license_key': licenseKey};
  }
}

/// Validate license response
class ValidateLicenseResponse {
  final bool valid;
  final String? status;
  final String? message;
  final LicenseKey? licenseKey;

  ValidateLicenseResponse({required this.valid, this.status, this.message, this.licenseKey});

  factory ValidateLicenseResponse.fromJson(Map<String, dynamic> json) {
    return ValidateLicenseResponse(
      valid: (json['valid'] as bool?) ?? false,
      status: json['status'] as String?,
      message: json['message'] as String?,
      licenseKey: json['license_key'] != null ? LicenseKey.fromJson(json['license_key'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valid': valid,
      if (status != null) 'status': status,
      if (message != null) 'message': message,
      if (licenseKey != null) 'license_key': licenseKey!.toJson(),
    };
  }
}

/// Assign license request
class AssignLicenseRequest {
  final String licenseKey;

  AssignLicenseRequest({required this.licenseKey});

  Map<String, dynamic> toJson() {
    return {'license_key': licenseKey};
  }
}
