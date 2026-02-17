import 'package:json_annotation/json_annotation.dart';

/// Clothing/shoe size system by region.
@JsonEnum(valueField: 'value')
enum SizeSystem {
  @JsonValue('eu')
  eu('eu', 'EU'),

  @JsonValue('us')
  us('us', 'US'),

  @JsonValue('uk')
  uk('uk', 'UK'),

  @JsonValue('jp')
  jp('jp', 'JP');

  const SizeSystem(this.value, this.label);

  final String value;
  final String label;
}
