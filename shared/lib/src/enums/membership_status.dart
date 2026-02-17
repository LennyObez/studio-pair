import 'package:json_annotation/json_annotation.dart';

/// Status of a space membership.
@JsonEnum(valueField: 'value')
enum MembershipStatus {
  @JsonValue('active')
  active('active', 'Active'),

  @JsonValue('invited')
  invited('invited', 'Invited'),

  @JsonValue('left')
  left('left', 'Left'),

  @JsonValue('removed')
  removed('removed', 'Removed');

  const MembershipStatus(this.value, this.label);

  final String value;
  final String label;
}
