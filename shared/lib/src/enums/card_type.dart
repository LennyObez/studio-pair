import 'package:json_annotation/json_annotation.dart';

/// Type of card (payment or loyalty).
@JsonEnum(valueField: 'value')
enum CardType {
  @JsonValue('debit')
  debit('debit', 'Debit'),

  @JsonValue('credit')
  credit('credit', 'Credit'),

  @JsonValue('loyalty')
  loyalty('loyalty', 'Loyalty');

  const CardType(this.value, this.label);

  final String value;
  final String label;
}
