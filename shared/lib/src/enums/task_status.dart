import 'package:json_annotation/json_annotation.dart';

/// Status of a task.
@JsonEnum(valueField: 'value')
enum TaskStatus {
  @JsonValue('todo')
  todo('todo', 'To Do'),

  @JsonValue('in_progress')
  inProgress('in_progress', 'In Progress'),

  @JsonValue('done')
  done('done', 'Done');

  const TaskStatus(this.value, this.label);

  final String value;
  final String label;
}
