// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HealthProfile _$HealthProfileFromJson(Map<String, dynamic> json) =>
    _HealthProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      spaceId: json['space_id'] as String,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      topSize: json['top_size'] as String?,
      bottomSize: json['bottom_size'] as String?,
      underwearSize: json['underwear_size'] as String?,
      shoeSize: json['shoe_size'] as String?,
      sizeSystem: $enumDecodeNullable(_$SizeSystemEnumMap, json['size_system']),
      ringSize: json['ring_size'] as String?,
      ringSizeSystem: json['ring_size_system'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$HealthProfileToJson(_HealthProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'space_id': instance.spaceId,
      'height_cm': instance.heightCm,
      'weight_kg': instance.weightKg,
      'top_size': instance.topSize,
      'bottom_size': instance.bottomSize,
      'underwear_size': instance.underwearSize,
      'shoe_size': instance.shoeSize,
      'size_system': _$SizeSystemEnumMap[instance.sizeSystem],
      'ring_size': instance.ringSize,
      'ring_size_system': instance.ringSizeSystem,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$SizeSystemEnumMap = {
  SizeSystem.eu: 'eu',
  SizeSystem.us: 'us',
  SizeSystem.uk: 'uk',
  SizeSystem.jp: 'jp',
};
