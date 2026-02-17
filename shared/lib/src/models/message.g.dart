// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  conversationId: json['conversation_id'] as String,
  senderId: json['sender_id'] as String,
  contentType: $enumDecode(_$MessageContentTypeEnumMap, json['content_type']),
  replyToMessageId: json['reply_to_message_id'] as String?,
  isEdited: json['is_edited'] as bool,
  editDeadline: json['edit_deadline'] == null
      ? null
      : DateTime.parse(json['edit_deadline'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversation_id': instance.conversationId,
  'sender_id': instance.senderId,
  'content_type': _$MessageContentTypeEnumMap[instance.contentType]!,
  'reply_to_message_id': instance.replyToMessageId,
  'is_edited': instance.isEdited,
  'edit_deadline': instance.editDeadline?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$MessageContentTypeEnumMap = {
  MessageContentType.text: 'text',
  MessageContentType.image: 'image',
  MessageContentType.file: 'file',
  MessageContentType.system: 'system',
};
