import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/message_content_type.dart';

part 'message.g.dart';

/// Represents a message within a conversation.
@JsonSerializable()
class Message extends Equatable {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.contentType,
    this.replyToMessageId,
    required this.isEdited,
    this.editDeadline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'conversation_id')
  final String conversationId;

  @JsonKey(name: 'sender_id')
  final String senderId;

  @JsonKey(name: 'content_type')
  final MessageContentType contentType;

  @JsonKey(name: 'reply_to_message_id')
  final String? replyToMessageId;

  @JsonKey(name: 'is_edited')
  final bool isEdited;

  @JsonKey(name: 'edit_deadline')
  final DateTime? editDeadline;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    contentType,
    replyToMessageId,
    isEdited,
    editDeadline,
    createdAt,
    updatedAt,
  ];
}
