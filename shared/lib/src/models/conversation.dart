import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/conversation_type.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

/// Represents a conversation within a space.
@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    @JsonKey(name: 'space_id') required String spaceId,
    required ConversationType type,
    String? title,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}
