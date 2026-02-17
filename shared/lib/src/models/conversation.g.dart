// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Conversation _$ConversationFromJson(Map<String, dynamic> json) =>
    _Conversation(
      id: json['id'] as String,
      spaceId: json['space_id'] as String,
      type: $enumDecode(_$ConversationTypeEnumMap, json['type']),
      title: json['title'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ConversationToJson(_Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'space_id': instance.spaceId,
      'type': _$ConversationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$ConversationTypeEnumMap = {
  ConversationType.chat: 'chat',
  ConversationType.mail: 'mail',
  ConversationType.privateCapsule: 'private_capsule',
};
