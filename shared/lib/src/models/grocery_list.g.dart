// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroceryList _$GroceryListFromJson(Map<String, dynamic> json) => _GroceryList(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  name: json['name'] as String,
  createdBy: json['created_by'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$GroceryListToJson(_GroceryList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'space_id': instance.spaceId,
      'name': instance.name,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
