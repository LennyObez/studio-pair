import 'package:json_annotation/json_annotation.dart';

/// Status of a subscription.
@JsonEnum(valueField: 'value')
enum SubscriptionStatus {
  @JsonValue('active')
  active('active', 'Active'),

  @JsonValue('past_due')
  pastDue('past_due', 'Past Due'),

  @JsonValue('canceled')
  canceled('canceled', 'Canceled'),

  @JsonValue('expired')
  expired('expired', 'Expired'),

  @JsonValue('trialing')
  trialing('trialing', 'Trialing');

  const SubscriptionStatus(this.value, this.label);

  final String value;
  final String label;
}
