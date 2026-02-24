// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Memory _$MemoryFromJson(Map<String, dynamic> json) => _Memory(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  createdBy: json['created_by'] as String,
  title: json['title'] as String,
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  location: json['location'] as String?,
  locationLat: (json['location_lat'] as num?)?.toDouble(),
  locationLng: (json['location_lng'] as num?)?.toDouble(),
  description: json['description'] as String?,
  linkedActivityId: json['linked_activity_id'] as String?,
  isMilestone: json['is_milestone'] as bool,
  milestoneType: json['milestone_type'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$MemoryToJson(_Memory instance) => <String, dynamic>{
  'id': instance.id,
  'space_id': instance.spaceId,
  'created_by': instance.createdBy,
  'title': instance.title,
  'date': instance.date?.toIso8601String(),
  'location': instance.location,
  'location_lat': instance.locationLat,
  'location_lng': instance.locationLng,
  'description': instance.description,
  'linked_activity_id': instance.linkedActivityId,
  'is_milestone': instance.isMilestone,
  'milestone_type': instance.milestoneType,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
