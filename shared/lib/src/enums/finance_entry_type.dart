import 'package:json_annotation/json_annotation.dart';

/// Type of finance entry.
@JsonEnum(valueField: 'value')
enum FinanceEntryType {
  @JsonValue('income')
  income('income', 'Income'),

  @JsonValue('expense')
  expense('expense', 'Expense');

  const FinanceEntryType(this.value, this.label);

  final String value;
  final String label;
}
