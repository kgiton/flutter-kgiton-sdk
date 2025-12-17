import 'item_models.dart';

/// Cart item model
///
/// Represents an item in the shopping cart with stored prices at add time.
/// Uses cart_id for session-based grouping (device ID, session ID, etc).
class CartItem {
  final String id;
  final String cartId; // Cart session identifier
  final String userId;
  final String licenseKey;
  final String itemId;
  final double? quantity; // Nullable: at least one of quantity or quantityPcs required
  final int? quantityPcs;
  final double? pricePerKg; // Stored at add time (nullable: at least one price required)
  final double? pricePerPcs; // Stored at add time (nullable: at least one price required)
  final double totalPrice; // Calculated and stored at add time
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Item? item; // Optional item details

  CartItem({
    required this.id,
    required this.cartId,
    required this.userId,
    required this.licenseKey,
    required this.itemId,
    this.quantity,
    this.quantityPcs,
    this.pricePerKg,
    this.pricePerPcs,
    required this.totalPrice,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.item,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      cartId: json['cart_id'] as String,
      userId: json['user_id'] as String,
      licenseKey: json['license_key'] as String,
      itemId: json['item_id'] as String,
      quantity: json['quantity'] != null ? (json['quantity'] as num).toDouble() : null,
      quantityPcs: json['quantity_pcs'] as int?,
      pricePerKg: json['price_per_kg'] != null ? (json['price_per_kg'] as num).toDouble() : null,
      pricePerPcs: json['price_per_pcs'] != null ? (json['price_per_pcs'] as num).toDouble() : null,
      totalPrice: (json['total_price'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      item: json['item'] != null ? Item.fromJson(json['item'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'user_id': userId,
      'license_key': licenseKey,
      'item_id': itemId,
      if (quantity != null) 'quantity': quantity,
      if (quantityPcs != null) 'quantity_pcs': quantityPcs,
      if (pricePerKg != null) 'price_per_kg': pricePerKg,
      if (pricePerPcs != null) 'price_per_pcs': pricePerPcs,
      'total_price': totalPrice,
      if (notes != null) 'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (item != null) 'item': item!.toJson(),
    };
  }

  /// Get the stored total price
  /// Price is stored at add time for consistency
  double get storedTotalPrice => totalPrice;

  /// Calculate estimated price if item details are available
  /// Note: Use storedTotalPrice for accuracy. This is for reference only.
  @Deprecated('Use storedTotalPrice instead. Price is stored at add time.')
  double calculateEstimatedPrice() {
    return totalPrice;
  }
}

/// Cart summary model
///
/// Provides summary of cart items with total amount calculated from stored prices.
class CartSummary {
  final int totalItems;
  final double totalAmount; // Total from stored prices
  final List<CartItem> items;

  CartSummary({required this.totalItems, required this.totalAmount, required this.items});

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      totalItems: json['total_items'] as int,
      totalAmount: (json['total_amount'] as num).toDouble(),
      items: (json['items'] as List).map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'total_items': totalItems, 'total_amount': totalAmount, 'items': items.map((e) => e.toJson()).toList()};
  }

  /// Alias for backwards compatibility
  @Deprecated('Use totalAmount instead')
  double get estimatedTotal => totalAmount;
}

/// Add item to cart request
///
/// Request model for adding items to cart.
/// ALWAYS creates new entry (no duplicate check) - perfect for scale apps.
class AddCartRequest {
  final String cartId; // Cart session identifier (device ID, session ID, etc)
  final String licenseKey;
  final String itemId;
  final double? quantity; // Nullable: at least one of quantity or quantityPcs required
  final int? quantityPcs;
  final String? notes;

  AddCartRequest({required this.cartId, required this.licenseKey, required this.itemId, this.quantity, this.quantityPcs, this.notes});

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'license_key': licenseKey,
      'item_id': itemId,
      if (quantity != null) 'quantity': quantity,
      if (quantityPcs != null) 'quantity_pcs': quantityPcs,
      if (notes != null) 'notes': notes,
    };
  }

  /// Validate request data
  bool isValid() {
    // Basic validation
    if (cartId.isEmpty || licenseKey.isEmpty || itemId.isEmpty) return false;

    // At least one quantity must be provided
    if (quantity == null && quantityPcs == null) return false;

    // Validate quantity if provided (allow >= 0 for per-pcs items)
    if (quantity != null && quantity! < 0) return false;

    // Validate quantityPcs if provided (allow >= 0 for per-kg items)
    if (quantityPcs != null && quantityPcs! < 0) return false;

    // At least one quantity must be > 0
    final hasValidQuantity = quantity != null && quantity! > 0;
    final hasValidQuantityPcs = quantityPcs != null && quantityPcs! > 0;
    if (!hasValidQuantity && !hasValidQuantityPcs) return false;

    return true;
  }
}

/// Update cart item request
class UpdateCartRequest {
  final double? quantity;
  final int? quantityPcs;
  final String? notes;

  UpdateCartRequest({this.quantity, this.quantityPcs, this.notes});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (quantity != null) map['quantity'] = quantity;
    if (quantityPcs != null) map['quantity_pcs'] = quantityPcs;
    if (notes != null) map['notes'] = notes;

    return map;
  }

  /// Validate request data
  bool isValid() {
    // At least one field must be provided
    if (quantity == null && quantityPcs == null && notes == null) {
      return false;
    }

    // Validate quantity if provided (allow >= 0 for per-pcs items)
    if (quantity != null && quantity! < 0) {
      return false;
    }

    // Validate quantityPcs if provided (allow >= 0 for per-kg items)
    if (quantityPcs != null && quantityPcs! < 0) {
      return false;
    }

    // If updating quantities (not just notes), at least one must be > 0
    if ((quantity != null || quantityPcs != null) && notes == null) {
      final hasValidQuantity = quantity != null && quantity! > 0;
      final hasValidQuantityPcs = quantityPcs != null && quantityPcs! > 0;
      if (!hasValidQuantity && !hasValidQuantityPcs) {
        return false;
      }
    }

    return true;
  }

  /// Check if request has any updates
  bool hasUpdates() {
    return quantity != null || quantityPcs != null || notes != null;
  }
}

/// Checkout cart request
///
/// Request model for checking out cart to create transaction.
/// Supports multiple payment methods and payment gateways.
class CheckoutCartRequest {
  final String paymentMethod; // QRIS, CASH, BANK_TRANSFER
  final String paymentGateway; // external, xendit, midtrans, internal
  final String? notes;

  CheckoutCartRequest({
    required this.paymentMethod,
    this.paymentGateway = 'external', // Default to external
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {'payment_method': paymentMethod, 'payment_gateway': paymentGateway, if (notes != null) 'notes': notes};
  }

  /// Validate request data
  bool isValid() {
    final validPaymentMethods = ['QRIS', 'CASH', 'BANK_TRANSFER'];
    final validPaymentGateways = ['external', 'xendit', 'midtrans', 'internal'];

    return validPaymentMethods.contains(paymentMethod) && validPaymentGateways.contains(paymentGateway);
  }
}
