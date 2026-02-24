import 'package:json_annotation/json_annotation.dart';

/// Card payment network provider.
@JsonEnum(valueField: 'value')
enum CardProvider {
  @JsonValue('visa')
  visa('visa', 'Visa'),

  @JsonValue('mastercard')
  mastercard('mastercard', 'Mastercard'),

  @JsonValue('amex')
  amex('amex', 'American Express'),

  @JsonValue('maestro')
  maestro('maestro', 'Maestro'),

  @JsonValue('discover')
  discover('discover', 'Discover'),

  @JsonValue('diners_club')
  dinersClub('diners_club', 'Diners Club'),

  @JsonValue('jcb')
  jcb('jcb', 'JCB'),

  @JsonValue('union_pay')
  unionPay('union_pay', 'UnionPay'),

  @JsonValue('unknown')
  unknown('unknown', 'Unknown');

  const CardProvider(this.value, this.label);

  final String value;
  final String label;
}
