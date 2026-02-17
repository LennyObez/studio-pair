import 'package:json_annotation/json_annotation.dart';

/// Mode for an activity (whether it's linked to a calendar date).
@JsonEnum(valueField: 'value')
enum ActivityMode {
  @JsonValue('unlinked')
  unlinked('unlinked', 'Unlinked'),

  @JsonValue('date_linked_personal')
  dateLinkedPersonal('date_linked_personal', 'Date Linked (Personal)'),

  @JsonValue('date_linked_space')
  dateLinkedSpace('date_linked_space', 'Date Linked (Space)');

  const ActivityMode(this.value, this.label);

  final String value;
  final String label;
}
