// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reminder _$ReminderFromJson(Map<String, dynamic> json) => _Reminder(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  createdBy: json['created_by'] as String,
  message: json['message'] as String,
  triggerAt: DateTime.parse(json['trigger_at'] as String),
  recurrenceRule: json['recurrence_rule'] as String?,
  linkedModule: json['linked_module'] as String?,
  linkedEntityId: json['linked_entity_id'] as String?,
  isSent: json['is_sent'] as bool,
  sentAt: json['sent_at'] == null
      ? null
      : DateTime.parse(json['sent_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ReminderToJson(_Reminder instance) => <String, dynamic>{
  'id': instance.id,
  'space_id': instance.spaceId,
  'created_by': instance.createdBy,
  'message': instance.message,
  'trigger_at': instance.triggerAt.toIso8601String(),
  'recurrence_rule': instance.recurrenceRule,
  'linked_module': instance.linkedModule,
  'linked_entity_id': instance.linkedEntityId,
  'is_sent': instance.isSent,
  'sent_at': instance.sentAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
