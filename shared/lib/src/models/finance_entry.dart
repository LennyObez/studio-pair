import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/finance_entry_type.dart';

part 'finance_entry.freezed.dart';
part 'finance_entry.g.dart';

/// Represents a financial entry (income or expense) within a space.
@freezed
abstract class FinanceEntry with _$FinanceEntry {
  const factory FinanceEntry({
    required String id,
    @JsonKey(name: 'space_id') required String spaceId,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'entry_type') required FinanceEntryType entryType,
    required String category,
    String? subcategory,
    String? description,
    @JsonKey(name: 'amount_cents') required int amountCents,
    required String currency,
    @JsonKey(name: 'is_recurring') required bool isRecurring,
    @JsonKey(name: 'recurrence_rule') String? recurrenceRule,
    required DateTime date,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _FinanceEntry;

  factory FinanceEntry.fromJson(Map<String, dynamic> json) =>
      _$FinanceEntryFromJson(json);
}
