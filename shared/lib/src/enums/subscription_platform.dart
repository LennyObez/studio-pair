import 'package:json_annotation/json_annotation.dart';

/// Platform for subscription purchases.
@JsonEnum(valueField: 'value')
enum SubscriptionPlatform {
  @JsonValue('ios')
  ios('ios', 'iOS'),

  @JsonValue('android')
  android('android', 'Android'),

  @JsonValue('web')
  web('web', 'Web');

  const SubscriptionPlatform(this.value, this.label);

  final String value;
  final String label;
}
