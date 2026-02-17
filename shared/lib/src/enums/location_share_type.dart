import 'package:json_annotation/json_annotation.dart';

/// Type of location sharing.
@JsonEnum(valueField: 'value')
enum LocationShareType {
  @JsonValue('temporary')
  temporary('temporary', 'Temporary'),

  @JsonValue('safe_ping')
  safePing('safe_ping', 'Safe Ping'),

  @JsonValue('eta')
  eta('eta', 'ETA');

  const LocationShareType(this.value, this.label);

  final String value;
  final String label;
}
