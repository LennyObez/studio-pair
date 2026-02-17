// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroceryItem _$GroceryItemFromJson(Map<String, dynamic> json) => _GroceryItem(
  id: json['id'] as String,
  listId: json['list_id'] as String,
  name: json['name'] as String,
  quantity: (json['quantity'] as num?)?.toDouble(),
  unit: json['unit'] as String?,
  category: $enumDecode(_$GroceryCategoryEnumMap, json['category']),
  note: json['note'] as String?,
  isChecked: json['is_checked'] as bool,
  checkedBy: json['checked_by'] as String?,
  checkedAt: json['checked_at'] == null
      ? null
      : DateTime.parse(json['checked_at'] as String),
  priceCents: (json['price_cents'] as num?)?.toInt(),
  displayOrder: (json['display_order'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$GroceryItemToJson(_GroceryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'list_id': instance.listId,
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'category': _$GroceryCategoryEnumMap[instance.category]!,
      'note': instance.note,
      'is_checked': instance.isChecked,
      'checked_by': instance.checkedBy,
      'checked_at': instance.checkedAt?.toIso8601String(),
      'price_cents': instance.priceCents,
      'display_order': instance.displayOrder,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$GroceryCategoryEnumMap = {
  GroceryCategory.produce: 'produce',
  GroceryCategory.dairy: 'dairy',
  GroceryCategory.meat: 'meat',
  GroceryCategory.frozen: 'frozen',
  GroceryCategory.bakery: 'bakery',
  GroceryCategory.beverages: 'beverages',
  GroceryCategory.snacks: 'snacks',
  GroceryCategory.cannedGoods: 'canned_goods',
  GroceryCategory.condiments: 'condiments',
  GroceryCategory.household: 'household',
  GroceryCategory.personalCare: 'personal_care',
  GroceryCategory.other: 'other',
};
