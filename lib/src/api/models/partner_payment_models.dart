/// Partner Payment Models for KGiTON SDK
///
/// Models for generating payments through partner API

/// Partner payment type
enum PartnerPaymentType {
  qris,
  checkoutPage;

  String get value {
    switch (this) {
      case PartnerPaymentType.qris:
        return 'qris';
      case PartnerPaymentType.checkoutPage:
        return 'checkout_page';
    }
  }

  static PartnerPaymentType fromString(String value) {
    switch (value) {
      case 'qris':
        return PartnerPaymentType.qris;
      case 'checkout_page':
        return PartnerPaymentType.checkoutPage;
      default:
        return PartnerPaymentType.checkoutPage;
    }
  }
}

/// Partner payment item
class PartnerPaymentItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  PartnerPaymentItem({required this.id, required this.name, required this.price, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price, 'quantity': quantity};
  }

  factory PartnerPaymentItem.fromJson(Map<String, dynamic> json) {
    return PartnerPaymentItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: ((json['price'] as num?) ?? 0).toDouble(),
      quantity: (json['quantity'] as int?) ?? 1,
    );
  }
}

/// Partner payment request
class PartnerPaymentRequest {
  /// Partner's unique transaction ID
  final String transactionId;

  /// Amount to charge in IDR
  final double amount;

  /// KGiTON license key
  final String licenseKey;

  /// Payment method type (qris or checkout_page)
  final PartnerPaymentType paymentType;

  /// Transaction description
  final String? description;

  /// URL to redirect after payment (for checkout_page)
  final String? backUrl;

  /// Expiry in minutes (default 30 for QRIS, 120 for checkout_page)
  final int? expiryMinutes;

  /// List of items
  final List<PartnerPaymentItem>? items;

  /// Customer name
  final String? customerName;

  /// Customer email
  final String? customerEmail;

  /// Customer phone
  final String? customerPhone;

  /// URL to receive payment status callback
  final String? webhookUrl;

  PartnerPaymentRequest({
    required this.transactionId,
    required this.amount,
    required this.licenseKey,
    this.paymentType = PartnerPaymentType.checkoutPage,
    this.description,
    this.backUrl,
    this.expiryMinutes,
    this.items,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.webhookUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'amount': amount,
      'license_key': licenseKey,
      'payment_type': paymentType.value,
      if (description != null) 'description': description,
      if (backUrl != null) 'back_url': backUrl,
      if (expiryMinutes != null) 'expiry_minutes': expiryMinutes,
      if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
      if (customerName != null) 'customer_name': customerName,
      if (customerEmail != null) 'customer_email': customerEmail,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (webhookUrl != null) 'webhook_url': webhookUrl,
    };
  }

  /// Validate request
  bool isValid() {
    return transactionId.isNotEmpty && amount > 0 && licenseKey.isNotEmpty;
  }
}

/// QRIS response data
class PartnerQrisData {
  final String? qrContent;
  final String qrImageUrl;

  PartnerQrisData({this.qrContent, required this.qrImageUrl});

  factory PartnerQrisData.fromJson(Map<String, dynamic> json) {
    return PartnerQrisData(qrContent: json['qr_content'] as String?, qrImageUrl: (json['qr_image_url'] as String?) ?? '');
  }

  Map<String, dynamic> toJson() {
    return {if (qrContent != null) 'qr_content': qrContent, 'qr_image_url': qrImageUrl};
  }
}

/// Partner payment response
class PartnerPaymentResponse {
  final String transactionId;
  final PartnerPaymentType paymentType;
  final double amount;
  final String gatewayProvider;
  final String? gatewayTransactionId;
  final String? paymentUrl;
  final PartnerQrisData? qris;
  final DateTime expiresAt;

  PartnerPaymentResponse({
    required this.transactionId,
    required this.paymentType,
    required this.amount,
    required this.gatewayProvider,
    this.gatewayTransactionId,
    this.paymentUrl,
    this.qris,
    required this.expiresAt,
  });

  factory PartnerPaymentResponse.fromJson(Map<String, dynamic> json) {
    return PartnerPaymentResponse(
      transactionId: (json['transaction_id'] as String?) ?? '',
      paymentType: PartnerPaymentType.fromString((json['payment_type'] as String?) ?? 'checkout_page'),
      amount: ((json['amount'] as num?) ?? 0).toDouble(),
      gatewayProvider: (json['gateway_provider'] as String?) ?? '',
      gatewayTransactionId: json['gateway_transaction_id'] as String?,
      paymentUrl: json['payment_url'] as String?,
      qris: json['qris'] != null ? PartnerQrisData.fromJson(json['qris'] as Map<String, dynamic>) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'payment_type': paymentType.value,
      'amount': amount,
      'gateway_provider': gatewayProvider,
      if (gatewayTransactionId != null) 'gateway_transaction_id': gatewayTransactionId,
      if (paymentUrl != null) 'payment_url': paymentUrl,
      if (qris != null) 'qris': qris!.toJson(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  /// Check if this is a QRIS payment
  bool get isQris => paymentType == PartnerPaymentType.qris;

  /// Check if this is a checkout page payment
  bool get isCheckoutPage => paymentType == PartnerPaymentType.checkoutPage;

  /// Get the URL to open for payment
  /// For QRIS, returns the QR image URL
  /// For checkout page, returns the payment URL
  String? get actionUrl {
    if (isQris) {
      return qris?.qrImageUrl;
    }
    return paymentUrl;
  }
}
