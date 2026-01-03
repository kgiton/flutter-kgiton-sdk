/// Token top-up transaction model
class TopupTransaction {
  final String id;
  final String userId;
  final String licenseKey;
  final double amount;
  final int tokensAdded;
  final String status;
  final String? paymentReference;
  final String? paymentMethod;

  // Payment gateway fields
  final String? gatewayProvider;
  final String? gatewayTransactionId;
  final String? gatewayVaNumber;
  final String? gatewayChannel;
  final String? gatewayPaymentUrl;

  // Winpay specific fields
  final String? winpayContractId;
  final String? winpayInvoiceId;
  final String? winpayVaNumber;
  final String? winpayChannel;

  final DateTime? expiresAt;
  final DateTime createdAt;

  TopupTransaction({
    required this.id,
    required this.userId,
    required this.licenseKey,
    required this.amount,
    required this.tokensAdded,
    required this.status,
    this.paymentReference,
    this.paymentMethod,
    this.gatewayProvider,
    this.gatewayTransactionId,
    this.gatewayVaNumber,
    this.gatewayChannel,
    this.gatewayPaymentUrl,
    this.winpayContractId,
    this.winpayInvoiceId,
    this.winpayVaNumber,
    this.winpayChannel,
    this.expiresAt,
    required this.createdAt,
  });

  factory TopupTransaction.fromJson(Map<String, dynamic> json) {
    return TopupTransaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      licenseKey: json['license_key'] as String,
      amount: ((json['amount'] as num?) ?? 0).toDouble(),
      tokensAdded: (json['tokens_added'] as int?) ?? 0,
      status: (json['status'] as String?) ?? 'pending',
      paymentReference: json['payment_reference'] as String?,
      paymentMethod: json['payment_method'] as String?,
      gatewayProvider: json['gateway_provider'] as String?,
      gatewayTransactionId: json['gateway_transaction_id'] as String?,
      gatewayVaNumber: json['gateway_va_number'] as String?,
      gatewayChannel: json['gateway_channel'] as String?,
      gatewayPaymentUrl: json['gateway_payment_url'] as String?,
      winpayContractId: json['winpay_contract_id'] as String?,
      winpayInvoiceId: json['winpay_invoice_id'] as String?,
      winpayVaNumber: json['winpay_va_number'] as String?,
      winpayChannel: json['winpay_channel'] as String?,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'license_key': licenseKey,
      'amount': amount,
      'tokens_added': tokensAdded,
      'status': status,
      if (paymentReference != null) 'payment_reference': paymentReference,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (gatewayProvider != null) 'gateway_provider': gatewayProvider,
      if (gatewayTransactionId != null) 'gateway_transaction_id': gatewayTransactionId,
      if (gatewayVaNumber != null) 'gateway_va_number': gatewayVaNumber,
      if (gatewayChannel != null) 'gateway_channel': gatewayChannel,
      if (gatewayPaymentUrl != null) 'gateway_payment_url': gatewayPaymentUrl,
      if (winpayContractId != null) 'winpay_contract_id': winpayContractId,
      if (winpayInvoiceId != null) 'winpay_invoice_id': winpayInvoiceId,
      if (winpayVaNumber != null) 'winpay_va_number': winpayVaNumber,
      if (winpayChannel != null) 'winpay_channel': winpayChannel,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Check if transaction is pending
  bool get isPending => status == 'pending';

  /// Check if transaction is successful
  bool get isSuccess => status == 'success';

  /// Check if transaction is expired
  bool get isExpired {
    if (status == 'expired') return true;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if transaction has payment URL
  bool get hasPaymentUrl => gatewayPaymentUrl != null && gatewayPaymentUrl!.isNotEmpty;

  /// Check if transaction has VA number
  bool get hasVaNumber => (gatewayVaNumber != null && gatewayVaNumber!.isNotEmpty) || (winpayVaNumber != null && winpayVaNumber!.isNotEmpty);

  /// Get VA number (from either gateway or winpay)
  String? get vaNumber => gatewayVaNumber ?? winpayVaNumber;
}

/// Topup request model
class TopupRequest {
  final int tokenCount;
  final String licenseKey;
  final String? paymentMethod;
  final String? customerPhone;

  TopupRequest({required this.tokenCount, required this.licenseKey, this.paymentMethod, this.customerPhone});

  Map<String, dynamic> toJson() {
    return {
      'token_count': tokenCount,
      'license_key': licenseKey,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (customerPhone != null) 'customer_phone': customerPhone,
    };
  }

  /// Validate request
  bool isValid() {
    return tokenCount > 0 && licenseKey.isNotEmpty;
  }
}

/// Topup response model
class TopupResponse {
  final String transactionId;
  final String licenseKey;
  final int tokensRequested;
  final double amountToPay;
  final double pricePerToken;
  final String status;
  final String? paymentMethod;
  final String? gatewayProvider;
  final String? paymentUrl;
  final VirtualAccountInfo? virtualAccount;
  final DateTime? expiresAt;

  TopupResponse({
    required this.transactionId,
    required this.licenseKey,
    required this.tokensRequested,
    required this.amountToPay,
    required this.pricePerToken,
    required this.status,
    this.paymentMethod,
    this.gatewayProvider,
    this.paymentUrl,
    this.virtualAccount,
    this.expiresAt,
  });

  factory TopupResponse.fromJson(Map<String, dynamic> json) {
    return TopupResponse(
      transactionId: json['transaction_id'] as String,
      licenseKey: json['license_key'] as String,
      tokensRequested: (json['tokens_requested'] as int?) ?? 0,
      amountToPay: ((json['amount_to_pay'] as num?) ?? 0).toDouble(),
      pricePerToken: ((json['price_per_token'] as num?) ?? 0).toDouble(),
      status: (json['status'] as String?) ?? 'PENDING',
      paymentMethod: json['payment_method'] as String?,
      gatewayProvider: json['gateway_provider'] as String?,
      paymentUrl: json['payment_url'] as String?,
      virtualAccount: json['virtual_account'] != null ? VirtualAccountInfo.fromJson(json['virtual_account'] as Map<String, dynamic>) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'license_key': licenseKey,
      'tokens_requested': tokensRequested,
      'amount_to_pay': amountToPay,
      'price_per_token': pricePerToken,
      'status': status,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (gatewayProvider != null) 'gateway_provider': gatewayProvider,
      if (paymentUrl != null) 'payment_url': paymentUrl,
      if (virtualAccount != null) 'virtual_account': virtualAccount!.toJson(),
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }

  /// Check if payment uses checkout page
  bool get isCheckoutPage => paymentMethod == 'checkout_page';

  /// Check if payment uses virtual account
  bool get isVirtualAccount => virtualAccount != null;
}

/// Virtual account info
class VirtualAccountInfo {
  final String number;
  final String name;
  final String bank;

  VirtualAccountInfo({required this.number, required this.name, required this.bank});

  factory VirtualAccountInfo.fromJson(Map<String, dynamic> json) {
    return VirtualAccountInfo(
      number: (json['number'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      bank: (json['bank'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'number': number, 'name': name, 'bank': bank};
  }
}

/// Payment method info
class PaymentMethodInfo {
  final String id;
  final String name;
  final String? description;
  final String type; // 'checkout' or 'va'
  final bool enabled;

  PaymentMethodInfo({required this.id, required this.name, this.description, required this.type, required this.enabled});

  factory PaymentMethodInfo.fromJson(Map<String, dynamic> json) {
    return PaymentMethodInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: (json['type'] as String?) ?? 'checkout',
      enabled: (json['enabled'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, if (description != null) 'description': description, 'type': type, 'enabled': enabled};
  }
}

/// Transaction status check response
class TransactionStatusResponse {
  final String transactionId;
  final double amount;
  final int tokensAdded;
  final String status;

  TransactionStatusResponse({required this.transactionId, required this.amount, required this.tokensAdded, required this.status});

  factory TransactionStatusResponse.fromJson(Map<String, dynamic> json) {
    return TransactionStatusResponse(
      transactionId: json['transaction_id'] as String,
      amount: ((json['amount'] as num?) ?? 0).toDouble(),
      tokensAdded: (json['tokens_added'] as int?) ?? 0,
      status: (json['status'] as String?) ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {'transaction_id': transactionId, 'amount': amount, 'tokens_added': tokensAdded, 'status': status};
  }

  /// Check if payment is successful
  bool get isSuccess => status == 'SUCCESS' || status == 'success';

  /// Check if payment is pending
  bool get isPending => status == 'PENDING' || status == 'pending';

  /// Check if payment is expired
  bool get isExpired => status == 'EXPIRED' || status == 'expired';

  /// Check if payment is cancelled
  bool get isCancelled => status == 'CANCELLED' || status == 'cancelled';
}
