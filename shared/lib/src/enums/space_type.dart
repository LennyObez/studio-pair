import 'package:json_annotation/json_annotation.dart';

/// The type of shared space.
@JsonEnum(valueField: 'value')
enum SpaceType {
  @JsonValue('couple')
  couple('couple', 'Couple'),

  @JsonValue('family')
  family('family', 'Family'),

  @JsonValue('polyamorous')
  polyamorous('polyamorous', 'Polyamorous'),

  @JsonValue('friends')
  friends('friends', 'Friends'),

  @JsonValue('roommates')
  roommates('roommates', 'Roommates'),

  @JsonValue('colleagues')
  colleagues('colleagues', 'Colleagues');

  const SpaceType(this.value, this.label);

  final String value;
  final String label;
}
