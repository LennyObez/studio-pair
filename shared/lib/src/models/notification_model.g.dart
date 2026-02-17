// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    _NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      spaceId: json['space_id'] as String?,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      sourceModule: json['source_module'] as String?,
      sourceEntityId: json['source_entity_id'] as String?,
      channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
      isRead: json['is_read'] as bool,
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'space_id': instance.spaceId,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'source_module': instance.sourceModule,
      'source_entity_id': instance.sourceEntityId,
      'channel': _$NotificationChannelEnumMap[instance.channel]!,
      'is_read': instance.isRead,
      'read_at': instance.readAt?.toIso8601String(),
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$NotificationChannelEnumMap = {
  NotificationChannel.inApp: 'in_app',
  NotificationChannel.push: 'push',
  NotificationChannel.email: 'email',
};
