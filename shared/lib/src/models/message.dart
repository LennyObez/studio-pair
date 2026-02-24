import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/message_content_type.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// Represents a message within a conversation.
@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'sender_id') required String senderId,
    @JsonKey(name: 'content_type') required MessageContentType contentType,
    @JsonKey(name: 'reply_to_message_id') String? replyToMessageId,
    @JsonKey(name: 'is_edited') required bool isEdited,
    @JsonKey(name: 'edit_deadline') DateTime? editDeadline,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
