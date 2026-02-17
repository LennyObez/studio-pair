import 'package:json_annotation/json_annotation.dart';

/// Priority level for a task.
@JsonEnum(valueField: 'value')
enum TaskPriority {
  @JsonValue('low')
  low('low', 'Low'),

  @JsonValue('medium')
  medium('medium', 'Medium'),

  @JsonValue('high')
  high('high', 'High'),

  @JsonValue('urgent')
  urgent('urgent', 'Urgent');

  const TaskPriority(this.value, this.label);

  final String value;
  final String label;
}
