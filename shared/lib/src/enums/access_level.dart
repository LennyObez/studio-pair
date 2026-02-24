import 'package:json_annotation/json_annotation.dart';

/// Access level for a space member.
@JsonEnum(valueField: 'value')
enum AccessLevel {
  @JsonValue('read_only')
  readOnly('read_only', 'Read Only'),

  @JsonValue('read_write')
  readWrite('read_write', 'Read Write');

  const AccessLevel(this.value, this.label);

  final String value;
  final String label;
}
