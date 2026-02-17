import 'package:json_annotation/json_annotation.dart';

/// Subscription tier for a space.
@JsonEnum(valueField: 'value')
enum SubscriptionTier {
  @JsonValue('free')
  free('free', 'Free'),

  @JsonValue('premium')
  premium('premium', 'Premium');

  const SubscriptionTier(this.value, this.label);

  final String value;
  final String label;
}
