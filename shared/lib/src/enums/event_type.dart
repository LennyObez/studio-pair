import 'package:json_annotation/json_annotation.dart';

/// Type of calendar event.
@JsonEnum(valueField: 'value')
enum EventType {
  @JsonValue('personal')
  personal('personal', 'Personal'),

  @JsonValue('space')
  space('space', 'Space'),

  @JsonValue('holiday')
  holiday('holiday', 'Holiday'),

  @JsonValue('finance')
  finance('finance', 'Finance'),

  @JsonValue('task')
  task('task', 'Task'),

  @JsonValue('activity')
  activity('activity', 'Activity');

  const EventType(this.value, this.label);

  final String value;
  final String label;
}
