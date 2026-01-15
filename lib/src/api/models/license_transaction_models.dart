import 'license_models.dart';
import 'auth_models.dart';

/// License Transaction model - for purchase and subscription payments
class LicenseTransaction {
  final String id;
  final String licenseKey;
  final String userId;
  final String transactionType; // 'buy' or 'rent'
  final double amount;
  final String status;
  final String? paymentMethod;
  final String? paymentReference;

  // For rental: billing period
  final DateTime? billingPeriodStart;
  final DateTime? billingPeriodEnd;

  // Payment gateway fields
  final String? gatewayProvider;
  final String? gatewayTransactionId;
  final String? gatewayVaNumber;
  final String? gatewayChannel;
  final String? gatewayPaymentUrl;

  // Expiry & payment tracking
  final DateTime? expiresAt;
  final DateTime? paidAt;

  // Notes
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data
  final LicenseKey? licenseKeyData;
  final User? user;

  LicenseTransaction({
    required this.id,
    required this.licenseKey,
    required this.userId,
    required this.transactionType,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.paymentReference,
    this.billingPeriodStart,
    this.billingPeriodEnd,
    this.gatewayProvider,
    this.gatewayTransactionId,
    this.gatewayVaNumber,
    this.gatewayChannel,
    this.gatewayPaymentUrl,
    this.expiresAt,
    this.paidAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.licenseKeyData,
    this.user,
  });

  factory LicenseTransaction.fromJson(Map<String, dynamic> json) {
    return LicenseTransaction(
      id: json['id'] as String,
      licenseKey: json['license_key'] as String,
      userId: json['user_id'] as String,
      transactionType: (json['transaction_type'] as String?) ?? 'buy',
      amount: ((json['amount'] as num?) ?? 0).toDouble(),
      status: (json['status'] as String?) ?? 'pending',
      paymentMethod: json['payment_method'] as String?,
      paymentReference: json['payment_reference'] as String?,
      billingPeriodStart: json['billing_period_start'] != null ? DateTime.parse(json['billing_period_start'] as String) : null,
      billingPeriodEnd: json['billing_period_end'] != null ? DateTime.parse(json['billing_period_end'] as String) : null,
      gatewayProvider: json['gateway_provider'] as String?,
      gatewayTransactionId: json['gateway_transaction_id'] as String?,
      gatewayVaNumber: json['gateway_va_number'] as String?,
      gatewayChannel: json['gateway_channel'] as String?,
      gatewayPaymentUrl: json['gateway_payment_url'] as String?,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      licenseKeyData: json['license_key_data'] != null ? LicenseKey.fromJson(json['license_key_data'] as Map<String, dynamic>) : null,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'license_key': licenseKey,
      'user_id': userId,
      'transaction_type': transactionType,
      'amount': amount,
      'status': status,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentReference != null) 'payment_reference': paymentReference,
      if (billingPeriodStart != null) 'billing_period_start': billingPeriodStart!.toIso8601String(),
      if (billingPeriodEnd != null) 'billing_period_end': billingPeriodEnd!.toIso8601String(),
      if (gatewayProvider != null) 'gateway_provider': gatewayProvider,
      if (gatewayTransactionId != null) 'gateway_transaction_id': gatewayTransactionId,
      if (gatewayVaNumber != null) 'gateway_va_number': gatewayVaNumber,
      if (gatewayChannel != null) 'gateway_channel': gatewayChannel,
      if (gatewayPaymentUrl != null) 'gateway_payment_url': gatewayPaymentUrl,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
      if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
      if (notes != null) 'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (licenseKeyData != null) 'license_key_data': licenseKeyData!.toJson(),
      if (user != null) 'user': user!.toJson(),
    };
  }

  /// Check if transaction is for purchase (buy type)
  bool get isPurchase => transactionType == 'buy';

  /// Check if transaction is for subscription (rent type)
  bool get isSubscription => transactionType == 'rent';

  /// Check if transaction is pending
  bool get isPending => status == 'pending';

  /// Check if transaction is paid/success
  bool get isPaid => status == 'paid' || status == 'success';

  /// Check if transaction is expired
  bool get isExpired {
    if (status == 'expired') return true;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if transaction has payment URL
  bool get hasPaymentUrl => gatewayPaymentUrl != null && gatewayPaymentUrl!.isNotEmpty;
}

/// License transaction list data
class LicenseTransactionListData {
  final List<LicenseTransaction> transactions;
  final int total;

  LicenseTransactionListData({required this.transactions, required this.total});

  factory LicenseTransactionListData.fromJson(dynamic json) {
    if (json is List) {
      final transactions = json.map((e) => LicenseTransaction.fromJson(e as Map<String, dynamic>)).toList();
      return LicenseTransactionListData(transactions: transactions, total: transactions.length);
    }

    if (json is Map<String, dynamic>) {
      final transactions = (json['transactions'] as List? ?? json['data'] as List? ?? [])
          .map((e) => LicenseTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
      return LicenseTransactionListData(transactions: transactions, total: (json['total'] as int?) ?? transactions.length);
    }

    throw FormatException('Invalid LicenseTransactionListData format');
  }

  Map<String, dynamic> toJson() {
    return {'transactions': transactions.map((e) => e.toJson()).toList(), 'total': total};
  }
}

/// Initiate purchase/subscription request
class InitiatePaymentRequest {
  final String licenseKey;
  final String? paymentMethod;
  final String? customerPhone;

  InitiatePaymentRequest({required this.licenseKey, this.paymentMethod, this.customerPhone});

  Map<String, dynamic> toJson() {
    return {
      'license_key': licenseKey,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (customerPhone != null) 'customer_phone': customerPhone,
    };
  }
}

/// Initiate payment response
class InitiatePaymentResponse {
  final String transactionId;
  final String licenseKey;
  final String transactionType;
  final double amount;
  final String status;
  final String? paymentMethod;
  final String? gatewayProvider;
  final String? paymentUrl;
  final String? vaNumber;
  final String? vaName;
  final String? vaBank;
  final QRISPaymentInfo? qris;
  final BillingPeriod? billingPeriod;
  final DateTime? expiresAt;

  InitiatePaymentResponse({
    required this.transactionId,
    required this.licenseKey,
    required this.transactionType,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.gatewayProvider,
    this.paymentUrl,
    this.vaNumber,
    this.vaName,
    this.vaBank,
    this.qris,
    this.billingPeriod,
    this.expiresAt,
  });

  factory InitiatePaymentResponse.fromJson(Map<String, dynamic> json) {
    return InitiatePaymentResponse(
      transactionId: json['transaction_id'] as String,
      licenseKey: json['license_key'] as String,
      transactionType: (json['transaction_type'] as String?) ?? 'buy',
      amount: ((json['amount'] as num?) ?? 0).toDouble(),
      status: (json['status'] as String?) ?? 'pending',
      paymentMethod: json['payment_method'] as String?,
      gatewayProvider: json['gateway_provider'] as String?,
      paymentUrl: json['payment_url'] as String?,
      vaNumber: json['va_number'] as String?,
      vaName: json['va_name'] as String?,
      vaBank: json['va_bank'] as String?,
      qris: json['qris'] != null ? QRISPaymentInfo.fromJson(json['qris'] as Map<String, dynamic>) : null,
      billingPeriod: json['billing_period'] != null ? BillingPeriod.fromJson(json['billing_period'] as Map<String, dynamic>) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'license_key': licenseKey,
      'transaction_type': transactionType,
      'amount': amount,
      'status': status,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (gatewayProvider != null) 'gateway_provider': gatewayProvider,
      if (paymentUrl != null) 'payment_url': paymentUrl,
      if (vaNumber != null) 'va_number': vaNumber,
      if (vaName != null) 'va_name': vaName,
      if (vaBank != null) 'va_bank': vaBank,
      if (qris != null) 'qris': qris!.toJson(),
      if (billingPeriod != null) 'billing_period': billingPeriod!.toJson(),
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }

  /// Check if payment uses checkout page
  bool get isCheckoutPage => paymentUrl != null && paymentUrl!.isNotEmpty;

  /// Check if payment uses virtual account
  bool get isVirtualAccount => vaNumber != null && vaNumber!.isNotEmpty;

  /// Check if payment uses QRIS
  bool get isQRIS => qris != null;
}

/// QRIS payment info for license transactions
class QRISPaymentInfo {
  final String? qrString;
  final String? qrImageUrl;

  QRISPaymentInfo({this.qrString, this.qrImageUrl});

  factory QRISPaymentInfo.fromJson(Map<String, dynamic> json) {
    return QRISPaymentInfo(qrString: json['qr_string'] as String?, qrImageUrl: json['qr_image_url'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {if (qrString != null) 'qr_string': qrString, if (qrImageUrl != null) 'qr_image_url': qrImageUrl};
  }
}

/// Billing period for subscription transactions
class BillingPeriod {
  final DateTime start;
  final DateTime end;

  BillingPeriod({required this.start, required this.end});

  factory BillingPeriod.fromJson(Map<String, dynamic> json) {
    return BillingPeriod(start: DateTime.parse(json['start'] as String), end: DateTime.parse(json['end'] as String));
  }

  Map<String, dynamic> toJson() {
    return {'start': start.toIso8601String(), 'end': end.toIso8601String()};
  }
}

/// License status summary (admin)
class LicenseStatusSummary {
  final int totalLicenses;
  final int activeLicenses;
  final int inactiveLicenses;
  final int trialLicenses;
  final int buyTypeLicenses;
  final int rentTypeLicenses;
  final int paidLicenses;
  final int pendingPaymentLicenses;
  final int activeSubscriptions;
  final int expiredSubscriptions;

  LicenseStatusSummary({
    required this.totalLicenses,
    required this.activeLicenses,
    required this.inactiveLicenses,
    required this.trialLicenses,
    required this.buyTypeLicenses,
    required this.rentTypeLicenses,
    required this.paidLicenses,
    required this.pendingPaymentLicenses,
    required this.activeSubscriptions,
    required this.expiredSubscriptions,
  });

  factory LicenseStatusSummary.fromJson(Map<String, dynamic> json) {
    return LicenseStatusSummary(
      totalLicenses: (json['total_licenses'] as int?) ?? 0,
      activeLicenses: (json['active_licenses'] as int?) ?? 0,
      inactiveLicenses: (json['inactive_licenses'] as int?) ?? 0,
      trialLicenses: (json['trial_licenses'] as int?) ?? 0,
      buyTypeLicenses: (json['buy_type_licenses'] as int?) ?? 0,
      rentTypeLicenses: (json['rent_type_licenses'] as int?) ?? 0,
      paidLicenses: (json['paid_licenses'] as int?) ?? 0,
      pendingPaymentLicenses: (json['pending_payment_licenses'] as int?) ?? 0,
      activeSubscriptions: (json['active_subscriptions'] as int?) ?? 0,
      expiredSubscriptions: (json['expired_subscriptions'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_licenses': totalLicenses,
      'active_licenses': activeLicenses,
      'inactive_licenses': inactiveLicenses,
      'trial_licenses': trialLicenses,
      'buy_type_licenses': buyTypeLicenses,
      'rent_type_licenses': rentTypeLicenses,
      'paid_licenses': paidLicenses,
      'pending_payment_licenses': pendingPaymentLicenses,
      'active_subscriptions': activeSubscriptions,
      'expired_subscriptions': expiredSubscriptions,
    };
  }
}

/// User profile data with license keys
class UserProfileData {
  final String id;
  final String name;
  final String email;
  final String role;
  final String apiKey;
  final DateTime createdAt;
  final List<LicenseKey> licenseKeys;

  UserProfileData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.apiKey,
    required this.createdAt,
    required this.licenseKeys,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    final licenseKeys = (json['license_keys'] as List? ?? []).map((e) => LicenseKey.fromJson(e as Map<String, dynamic>)).toList();

    return UserProfileData(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'user',
      apiKey: (json['api_key'] as String?) ?? '',
      createdAt: DateTime.parse((json['created_at'] as String?) ?? DateTime.now().toIso8601String()),
      licenseKeys: licenseKeys,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'api_key': apiKey,
      'created_at': createdAt.toIso8601String(),
      'license_keys': licenseKeys.map((e) => e.toJson()).toList(),
    };
  }

  /// Check if user is super admin
  bool get isSuperAdmin => role == 'super_admin';

  /// Get total token balance from all licenses
  int get totalTokenBalance {
    return licenseKeys.fold(0, (sum, license) => sum + license.tokenBalance);
  }
}
