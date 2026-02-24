import 'package:json_annotation/json_annotation.dart';

/// Status of an activity.
@JsonEnum(valueField: 'value')
enum ActivityStatus {
  @JsonValue('active')
  active('active', 'Active'),

  @JsonValue('completed')
  completed('completed', 'Completed'),

  @JsonValue('deleted')
  deleted('deleted', 'Deleted');

  const ActivityStatus(this.value, this.label);

  final String value;
  final String label;
}
