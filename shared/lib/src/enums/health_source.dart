import 'package:json_annotation/json_annotation.dart';

/// Source of health data.
@JsonEnum(valueField: 'value')
enum HealthSource {
  @JsonValue('manual')
  manual('manual', 'Manual'),

  @JsonValue('healthkit')
  healthkit('healthkit', 'HealthKit'),

  @JsonValue('google_fit')
  googleFit('google_fit', 'Google Fit'),

  @JsonValue('samsung_health')
  samsungHealth('samsung_health', 'Samsung Health');

  const HealthSource(this.value, this.label);

  final String value;
  final String label;
}
