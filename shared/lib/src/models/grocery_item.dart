import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/grocery_category.dart';

part 'grocery_item.g.dart';

/// Represents an item within a grocery list.
@JsonSerializable()
class GroceryItem extends Equatable {
  const GroceryItem({
    required this.id,
    required this.listId,
    required this.name,
    this.quantity,
    this.unit,
    required this.category,
    this.note,
    required this.isChecked,
    this.checkedBy,
    this.checkedAt,
    this.priceCents,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) =>
      _$GroceryItemFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'list_id')
  final String listId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'quantity')
  final double? quantity;

  @JsonKey(name: 'unit')
  final String? unit;

  @JsonKey(name: 'category')
  final GroceryCategory category;

  @JsonKey(name: 'note')
  final String? note;

  @JsonKey(name: 'is_checked')
  final bool isChecked;

  @JsonKey(name: 'checked_by')
  final String? checkedBy;

  @JsonKey(name: 'checked_at')
  final DateTime? checkedAt;

  @JsonKey(name: 'price_cents')
  final int? priceCents;

  @JsonKey(name: 'display_order')
  final int displayOrder;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$GroceryItemToJson(this);

  @override
  List<Object?> get props => [
    id,
    listId,
    name,
    quantity,
    unit,
    category,
    note,
    isChecked,
    checkedBy,
    checkedAt,
    priceCents,
    displayOrder,
    createdAt,
    updatedAt,
  ];
}
