import 'package:json_annotation/json_annotation.dart';

/// Status of an invitation (e.g., to a calendar event).
@JsonEnum(valueField: 'value')
enum InvitationStatus {
  @JsonValue('pending')
  pending('pending', 'Pending'),

  @JsonValue('accepted')
  accepted('accepted', 'Accepted'),

  @JsonValue('declined')
  declined('declined', 'Declined'),

  @JsonValue('tentative')
  tentative('tentative', 'Tentative');

  const InvitationStatus(this.value, this.label);

  final String value;
  final String label;
}
