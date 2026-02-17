import 'package:json_annotation/json_annotation.dart';

/// Type of message content.
@JsonEnum(valueField: 'value')
enum MessageContentType {
  @JsonValue('text')
  text('text', 'Text'),

  @JsonValue('image')
  image('image', 'Image'),

  @JsonValue('file')
  file('file', 'File'),

  @JsonValue('system')
  system('system', 'System');

  const MessageContentType(this.value, this.label);

  final String value;
  final String label;
}
