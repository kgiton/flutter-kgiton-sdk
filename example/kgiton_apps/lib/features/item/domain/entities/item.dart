import 'package:equatable/equatable.dart';

/// Item entity representing a product/item in the application
class Item extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String unit;
  final double price;
  final double? pricePerPcs;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Item({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.unit,
    required this.price,
    this.pricePerPcs,
    this.description,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, ownerId, name, unit, price, pricePerPcs, description, isActive, createdAt, updatedAt];
}
