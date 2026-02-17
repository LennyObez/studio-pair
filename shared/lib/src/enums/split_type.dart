import 'package:json_annotation/json_annotation.dart';

/// Type of expense split between members.
@JsonEnum(valueField: 'value')
enum SplitType {
  @JsonValue('equal')
  equal('equal', 'Equal'),

  @JsonValue('percentage')
  percentage('percentage', 'Percentage'),

  @JsonValue('custom')
  custom('custom', 'Custom');

  const SplitType(this.value, this.label);

  final String value;
  final String label;
}
