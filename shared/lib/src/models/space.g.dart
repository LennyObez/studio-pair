// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Space _$SpaceFromJson(Map<String, dynamic> json) => _Space(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$SpaceTypeEnumMap, json['type']),
  avatarUrl: json['avatar_url'] as String?,
  inviteCode: json['invite_code'] as String?,
  maxMembers: (json['max_members'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SpaceToJson(_Space instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$SpaceTypeEnumMap[instance.type]!,
  'avatar_url': instance.avatarUrl,
  'invite_code': instance.inviteCode,
  'max_members': instance.maxMembers,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$SpaceTypeEnumMap = {
  SpaceType.couple: 'couple',
  SpaceType.family: 'family',
  SpaceType.polyamorous: 'polyamorous',
  SpaceType.friends: 'friends',
  SpaceType.roommates: 'roommates',
  SpaceType.colleagues: 'colleagues',
};
