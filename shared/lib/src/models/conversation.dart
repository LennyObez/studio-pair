import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/conversation_type.dart';

part 'conversation.g.dart';

/// Represents a conversation within a space.
@JsonSerializable()
class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.spaceId,
    required this.type,
    this.title,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'type')
  final ConversationType type;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  @override
  List<Object?> get props => [
    id,
    spaceId,
    type,
    title,
    createdBy,
    createdAt,
    updatedAt,
  ];
}
