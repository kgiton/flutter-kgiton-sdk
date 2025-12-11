/// Item model
class Item {
  final String id;
  final String ownerId;
  final String name;
  final String unit;
  final double price;
  final double? pricePerPcs;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.unit,
    required this.price,
    this.pricePerPcs,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: (json['id'] as String?) ?? '',
      ownerId: (json['owner_id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      unit: (json['unit'] as String?) ?? '',
      price: ((json['price'] as num?) ?? 0).toDouble(),
      pricePerPcs: (json['price_per_pcs'] as num?)?.toDouble(),
      description: json['description'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: DateTime.parse((json['created_at'] as String?) ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse((json['updated_at'] as String?) ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'unit': unit,
      'price': price,
      if (pricePerPcs != null) 'price_per_pcs': pricePerPcs,
      if (description != null) 'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Item list data
class ItemListData {
  final List<Item> items;
  final int count;

  ItemListData({required this.items, required this.count});

  factory ItemListData.fromJson(dynamic json) {
    // Handle if response is a List directly
    if (json is List) {
      final items = json.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
      return ItemListData(items: items, count: items.length);
    }

    // Handle if response is an Object with 'items' property
    if (json is Map<String, dynamic>) {
      return ItemListData(items: (json['items'] as List).map((e) => Item.fromJson(e as Map<String, dynamic>)).toList(), count: json['count'] as int);
    }

    throw FormatException('Invalid ItemListData format');
  }

  Map<String, dynamic> toJson() {
    return {'items': items.map((e) => e.toJson()).toList(), 'count': count};
  }
}

/// Create item request
class CreateItemRequest {
  final String name;
  final String unit;
  final double price;
  final double? pricePerPcs;
  final String? description;

  CreateItemRequest({required this.name, required this.unit, required this.price, this.pricePerPcs, this.description});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'price': price,
      if (pricePerPcs != null) 'price_per_pcs': pricePerPcs,
      if (description != null) 'description': description,
    };
  }
}

/// Update item request
class UpdateItemRequest {
  final String? name;
  final String? unit;
  final double? price;
  final double? pricePerPcs;
  final String? description;

  UpdateItemRequest({this.name, this.unit, this.price, this.pricePerPcs, this.description});

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (price != null) 'price': price,
      if (pricePerPcs != null) 'price_per_pcs': pricePerPcs,
      if (description != null) 'description': description,
    };
  }
}
