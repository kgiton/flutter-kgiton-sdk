import 'api_response.dart' show Pagination;

/// Transaction model
///
/// Represents a product sale transaction with payment details.
/// Supports multiple payment methods (QRIS, CASH, BANK_TRANSFER) and
/// payment gateways (external, xendit, midtrans, internal).
class Transaction {
  final String id;
  final String transactionNumber; // TRX-20251207-00001
  final String? externalId; // External payment reference
  final String licenseKey;
  final double totalAmount;
  final String paymentMethod; // QRIS, CASH, BANK_TRANSFER
  final String paymentGateway; // external, xendit, midtrans, internal
  final String paymentStatus; // PENDING, PAID, EXPIRED, CANCELLED, REFUNDED
  final String? qrisString; // QRIS code (only if payment_method = QRIS)
  final DateTime? qrisExpiredAt; // QRIS expiry time (2 minutes)
  final String? notes;
  final List<TransactionDetailItem>? items; // Transaction items (optional)
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.transactionNumber,
    this.externalId,
    required this.licenseKey,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentGateway,
    required this.paymentStatus,
    this.qrisString,
    this.qrisExpiredAt,
    this.notes,
    this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      transactionNumber: json['transaction_number'] as String,
      externalId: json['external_id'] as String?,
      licenseKey: json['license_key'] as String,
      totalAmount: ((json['total_amount'] as num?) ?? 0).toDouble(),
      paymentMethod: json['payment_method'] as String,
      paymentGateway: json['payment_gateway'] as String,
      paymentStatus: json['payment_status'] as String,
      qrisString: json['qris_string'] as String?,
      qrisExpiredAt: json['qris_expired_at'] != null ? DateTime.parse(json['qris_expired_at'] as String) : null,
      notes: json['notes'] as String?,
      items: json['items'] != null ? (json['items'] as List).map((e) => TransactionDetailItem.fromJson(e as Map<String, dynamic>)).toList() : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_number': transactionNumber,
      if (externalId != null) 'external_id': externalId,
      'license_key': licenseKey,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'payment_gateway': paymentGateway,
      'payment_status': paymentStatus,
      if (qrisString != null) 'qris_string': qrisString,
      if (qrisExpiredAt != null) 'qris_expired_at': qrisExpiredAt!.toIso8601String(),
      if (notes != null) 'notes': notes,
      if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if QRIS is available and not expired
  bool get hasValidQris {
    if (paymentMethod != 'QRIS' || qrisString == null || qrisExpiredAt == null) {
      return false;
    }
    return DateTime.now().isBefore(qrisExpiredAt!);
  }

  /// Get remaining seconds until QRIS expires
  int? get remainingSeconds {
    if (qrisExpiredAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(qrisExpiredAt!)) return 0;
    return qrisExpiredAt!.difference(now).inSeconds;
  }

  /// Deprecated fields for backwards compatibility
  @Deprecated('Use totalAmount instead')
  double get total => totalAmount;

  @Deprecated('Use licenseKey instead')
  String get licenseId => licenseKey;
}

/// Transaction detail item
///
/// Represents an item in a transaction with pricing details.
/// Supports dual quantity (weight + pieces) and dual pricing.
class TransactionDetailItem {
  final String id;
  final String transactionId;
  final String? itemId; // Optional: may be null for custom items
  final String itemName;
  final String unit;
  final double weight; // Weight/quantity in kg or unit
  final double pricePerUnit; // Price per kg/unit
  final int? quantityPcs; // Quantity in pieces (optional)
  final double? pricePerPcs; // Price per piece (optional)
  final double totalPrice;
  final String? notes;

  TransactionDetailItem({
    required this.id,
    required this.transactionId,
    this.itemId,
    required this.itemName,
    required this.unit,
    required this.weight,
    required this.pricePerUnit,
    this.quantityPcs,
    this.pricePerPcs,
    required this.totalPrice,
    this.notes,
  });

  factory TransactionDetailItem.fromJson(Map<String, dynamic> json) {
    return TransactionDetailItem(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      itemId: json['item_id'] as String?,
      itemName: json['item_name'] as String,
      unit: json['unit'] as String,
      weight: ((json['weight'] as num?) ?? 0).toDouble(),
      pricePerUnit: ((json['price_per_unit'] as num?) ?? 0).toDouble(),
      quantityPcs: json['quantity_pcs'] as int?,
      pricePerPcs: json['price_per_pcs'] != null ? ((json['price_per_pcs'] as num).toDouble()) : null,
      totalPrice: ((json['total_price'] as num?) ?? 0).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      if (itemId != null) 'item_id': itemId,
      'item_name': itemName,
      'unit': unit,
      'weight': weight,
      'price_per_unit': pricePerUnit,
      if (quantityPcs != null) 'quantity_pcs': quantityPcs,
      if (pricePerPcs != null) 'price_per_pcs': pricePerPcs,
      'total_price': totalPrice,
      if (notes != null) 'notes': notes,
    };
  }

  /// Deprecated fields for backwards compatibility
  @Deprecated('Use weight instead')
  double get quantity => weight;

  @Deprecated('Use pricePerUnit instead')
  double get unitPrice => pricePerUnit;
}

/// Transaction detail (full transaction with items)
class TransactionDetail {
  final Transaction transaction;
  final List<TransactionDetailItem> items;

  TransactionDetail({required this.transaction, required this.items});

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      transaction: Transaction.fromJson(json['transaction'] as Map<String, dynamic>),
      items: (json['items'] as List).map((e) => TransactionDetailItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'transaction': transaction.toJson(), 'items': items.map((e) => e.toJson()).toList()};
  }
}

/// Transaction list data with pagination
class TransactionListData {
  final List<Transaction> transactions;
  final Pagination? pagination;

  TransactionListData({required this.transactions, this.pagination});

  factory TransactionListData.fromJson(dynamic json) {
    // Handle if response is a List directly
    if (json is List) {
      final transactions = json.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
      return TransactionListData(transactions: transactions, pagination: null);
    }

    // Handle if response is an Object with 'transactions' property
    if (json is Map<String, dynamic>) {
      return TransactionListData(
        transactions: (json['transactions'] as List).map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList(),
        pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
      );
    }

    throw FormatException('Invalid TransactionListData format');
  }

  Map<String, dynamic> toJson() {
    return {'transactions': transactions.map((e) => e.toJson()).toList(), if (pagination != null) 'pagination': pagination!.toJson()};
  }
}

// Pagination is exported from api_response.dart
// No need to duplicate here

/// Checkout item request model for creating transaction
class CheckoutItemRequest {
  final String? itemId; // Optional: can be null for custom items
  final String itemName;
  final double weight;
  final String unit;
  final double pricePerUnit;
  final int? quantityPcs;
  final double? pricePerPcs;
  final double totalPrice;

  CheckoutItemRequest({
    this.itemId,
    required this.itemName,
    required this.weight,
    required this.unit,
    required this.pricePerUnit,
    this.quantityPcs,
    this.pricePerPcs,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      if (itemId != null) 'item_id': itemId,
      'item_name': itemName,
      'weight': weight,
      'unit': unit,
      'price_per_unit': pricePerUnit,
      if (quantityPcs != null) 'quantity_pcs': quantityPcs,
      if (pricePerPcs != null) 'price_per_pcs': pricePerPcs,
      'total_price': totalPrice,
    };
  }
}

/// Checkout request model for creating transaction (direct, not from cart)
///
/// @deprecated Use cart checkout instead (CartService.checkoutCart)
/// This method is for creating transactions directly without cart
@Deprecated('Use cart checkout instead. Create cart items then use CartService.checkoutCart()')
class CheckoutRequest {
  final String licenseKey;
  final List<CheckoutItemRequest> items;
  final double totalAmount;
  final String paymentMethod; // QRIS, CASH, BANK_TRANSFER
  final String paymentGateway; // external, xendit, midtrans, internal
  final String? notes;

  CheckoutRequest({
    required this.licenseKey,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    this.paymentGateway = 'external',
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'license_key': licenseKey,
      'items': items.map((e) => e.toJson()).toList(),
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'payment_gateway': paymentGateway,
      if (notes != null) 'notes': notes,
    };
  }

  bool isValid() {
    final validPaymentMethods = ['QRIS', 'CASH', 'BANK_TRANSFER'];
    final validPaymentGateways = ['external', 'xendit', 'midtrans', 'internal'];

    return licenseKey.isNotEmpty &&
        items.isNotEmpty &&
        totalAmount > 0 &&
        validPaymentMethods.contains(paymentMethod) &&
        validPaymentGateways.contains(paymentGateway);
  }
}

/// Transaction statistics model
class TransactionStatistics {
  final int totalTransactions;
  final double totalAmount;
  final int successCount;
  final int pendingCount;
  final int cancelledCount;
  final double successAmount;

  TransactionStatistics({
    required this.totalTransactions,
    required this.totalAmount,
    required this.successCount,
    required this.pendingCount,
    required this.cancelledCount,
    required this.successAmount,
  });

  factory TransactionStatistics.fromJson(Map<String, dynamic> json) {
    return TransactionStatistics(
      totalTransactions: json['total_transactions'] as int,
      totalAmount: ((json['total_amount'] as num?) ?? 0).toDouble(),
      successCount: json['success_count'] as int,
      pendingCount: json['pending_count'] as int,
      cancelledCount: json['cancelled_count'] as int,
      successAmount: ((json['success_amount'] as num?) ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_transactions': totalTransactions,
      'total_amount': totalAmount,
      'success_count': successCount,
      'pending_count': pendingCount,
      'cancelled_count': cancelledCount,
      'success_amount': successAmount,
    };
  }
}

/// License transaction statistics model
class LicenseTransactionStatistics {
  final String licenseKey;
  final int totalTransactions;
  final int totalPaid;
  final int totalPending;
  final double totalRevenue;
  final double totalPendingAmount;
  final double grossTransactionValue;
  final double totalWeight;
  final double totalPaidWeight;
  final double avgTransactionValue;

  LicenseTransactionStatistics({
    required this.licenseKey,
    required this.totalTransactions,
    required this.totalPaid,
    required this.totalPending,
    required this.totalRevenue,
    required this.totalPendingAmount,
    required this.grossTransactionValue,
    required this.totalWeight,
    required this.totalPaidWeight,
    required this.avgTransactionValue,
  });

  factory LicenseTransactionStatistics.fromJson(Map<String, dynamic> json) {
    return LicenseTransactionStatistics(
      licenseKey: json['license_key'] as String,
      totalTransactions: json['total_transactions'] as int,
      totalPaid: json['total_paid'] as int,
      totalPending: json['total_pending'] as int,
      totalRevenue: ((json['total_revenue'] as num?) ?? 0).toDouble(),
      totalPendingAmount: ((json['total_pending_amount'] as num?) ?? 0).toDouble(),
      grossTransactionValue: ((json['gross_transaction_value'] as num?) ?? 0).toDouble(),
      totalWeight: ((json['total_weight'] as num?) ?? 0).toDouble(),
      totalPaidWeight: ((json['total_paid_weight'] as num?) ?? 0).toDouble(),
      avgTransactionValue: ((json['avg_transaction_value'] as num?) ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'license_key': licenseKey,
      'total_transactions': totalTransactions,
      'total_paid': totalPaid,
      'total_pending': totalPending,
      'total_revenue': totalRevenue,
      'total_pending_amount': totalPendingAmount,
      'gross_transaction_value': grossTransactionValue,
      'total_weight': totalWeight,
      'total_paid_weight': totalPaidWeight,
      'avg_transaction_value': avgTransactionValue,
    };
  }
}

/// Payment method constants
class PaymentMethod {
  static const String qris = 'QRIS';
  static const String cash = 'CASH';
  static const String bankTransfer = 'BANK_TRANSFER';
}

/// Payment gateway constants
class PaymentGateway {
  static const String external = 'external';
  static const String xendit = 'xendit';
  static const String midtrans = 'midtrans';
  static const String internal = 'internal';
}

/// Payment status constants
class PaymentStatus {
  static const String pending = 'PENDING';
  static const String paid = 'PAID';
  static const String expired = 'EXPIRED';
  static const String cancelled = 'CANCELLED';
  static const String refunded = 'REFUNDED';
}
