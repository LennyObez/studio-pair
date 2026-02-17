import 'package:json_annotation/json_annotation.dart';

/// Privacy level for an activity.
@JsonEnum(valueField: 'value')
enum ActivityPrivacy {
  @JsonValue('public')
  public_('public', 'Public'),

  @JsonValue('private')
  private_('private', 'Private');

  const ActivityPrivacy(this.value, this.label);

  final String value;
  final String label;
}
