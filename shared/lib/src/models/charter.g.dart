// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Charter _$CharterFromJson(Map<String, dynamic> json) => _Charter(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  currentVersion: (json['current_version'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CharterToJson(_Charter instance) => <String, dynamic>{
  'id': instance.id,
  'space_id': instance.spaceId,
  'current_version': instance.currentVersion,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
