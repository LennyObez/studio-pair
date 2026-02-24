// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalendarEvent _$CalendarEventFromJson(Map<String, dynamic> json) =>
    _CalendarEvent(
      id: json['id'] as String,
      spaceId: json['space_id'] as String,
      createdBy: json['created_by'] as String,
      title: json['title'] as String,
      location: json['location'] as String?,
      eventType: $enumDecode(_$EventTypeEnumMap, json['event_type']),
      allDay: json['all_day'] as bool,
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: DateTime.parse(json['end_at'] as String),
      recurrenceRule: json['recurrence_rule'] as String?,
      sourceModule: json['source_module'] as String?,
      sourceEntityId: json['source_entity_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CalendarEventToJson(_CalendarEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'space_id': instance.spaceId,
      'created_by': instance.createdBy,
      'title': instance.title,
      'location': instance.location,
      'event_type': _$EventTypeEnumMap[instance.eventType]!,
      'all_day': instance.allDay,
      'start_at': instance.startAt.toIso8601String(),
      'end_at': instance.endAt.toIso8601String(),
      'recurrence_rule': instance.recurrenceRule,
      'source_module': instance.sourceModule,
      'source_entity_id': instance.sourceEntityId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$EventTypeEnumMap = {
  EventType.personal: 'personal',
  EventType.space: 'space',
  EventType.holiday: 'holiday',
  EventType.finance: 'finance',
  EventType.task: 'task',
  EventType.activity: 'activity',
};
