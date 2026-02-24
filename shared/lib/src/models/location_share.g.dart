// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_share.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationShare _$LocationShareFromJson(Map<String, dynamic> json) =>
    _LocationShare(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      spaceId: json['space_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      type: $enumDecode(_$LocationShareTypeEnumMap, json['type']),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      etaDestination: json['eta_destination'] as String?,
      etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$LocationShareToJson(_LocationShare instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'space_id': instance.spaceId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'type': _$LocationShareTypeEnumMap[instance.type]!,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'eta_destination': instance.etaDestination,
      'eta_minutes': instance.etaMinutes,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$LocationShareTypeEnumMap = {
  LocationShareType.temporary: 'temporary',
  LocationShareType.safePing: 'safe_ping',
  LocationShareType.eta: 'eta',
};
