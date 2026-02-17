import 'package:json_annotation/json_annotation.dart';

/// Type of conversation.
@JsonEnum(valueField: 'value')
enum ConversationType {
  @JsonValue('chat')
  chat('chat', 'Chat'),

  @JsonValue('mail')
  mail('mail', 'Mail'),

  @JsonValue('private_capsule')
  privateCapsule('private_capsule', 'Private Capsule');

  const ConversationType(this.value, this.label);

  final String value;
  final String label;
}
