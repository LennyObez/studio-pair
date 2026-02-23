import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/finance_entry_type.dart';

part 'finance_entry.g.dart';

/// Represents a financial entry (income or expense) within a space.
@JsonSerializable()
class FinanceEntry extends Equatable {
  const FinanceEntry({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.entryType,
    required this.category,
    this.subcategory,
    this.description,
    required this.amountCents,
    required this.currency,
    required this.isRecurring,
    this.recurrenceRule,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinanceEntry.fromJson(Map<String, dynamic> json) =>
      _$FinanceEntryFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'entry_type')
  final FinanceEntryType entryType;

  @JsonKey(name: 'category')
  final String category;

  @JsonKey(name: 'subcategory')
  final String? subcategory;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'amount_cents')
  final int amountCents;

  @JsonKey(name: 'currency')
  final String currency;

  @JsonKey(name: 'is_recurring')
  final bool isRecurring;

  @JsonKey(name: 'recurrence_rule')
  final String? recurrenceRule;

  @JsonKey(name: 'date')
  final DateTime date;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$FinanceEntryToJson(this);

  @override
  List<Object?> get props => [
    id,
    spaceId,
    createdBy,
    entryType,
    category,
    subcategory,
    description,
    amountCents,
    currency,
    isRecurring,
    recurrenceRule,
    date,
    createdAt,
    updatedAt,
  ];
}
