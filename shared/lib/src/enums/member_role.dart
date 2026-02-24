import 'package:json_annotation/json_annotation.dart';

/// Role of a member within a space.
@JsonEnum(valueField: 'value')
enum MemberRole {
  @JsonValue('owner')
  owner('owner', 'Owner'),

  @JsonValue('admin')
  admin('admin', 'Admin'),

  @JsonValue('member')
  member('member', 'Member');

  const MemberRole(this.value, this.label);

  final String value;
  final String label;
}
