import 'package:json_annotation/json_annotation.dart';

/// External calendar provider for syncing.
@JsonEnum(valueField: 'value')
enum CalendarProvider {
  @JsonValue('google')
  google('google', 'Google'),

  @JsonValue('icloud')
  icloud('icloud', 'iCloud'),

  @JsonValue('microsoft')
  microsoft('microsoft', 'Microsoft');

  const CalendarProvider(this.value, this.label);

  final String value;
  final String label;
}
