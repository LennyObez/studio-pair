// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FinanceEntry _$FinanceEntryFromJson(Map<String, dynamic> json) =>
    _FinanceEntry(
      id: json['id'] as String,
      spaceId: json['space_id'] as String,
      createdBy: json['created_by'] as String,
      entryType: $enumDecode(_$FinanceEntryTypeEnumMap, json['entry_type']),
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      description: json['description'] as String?,
      amountCents: (json['amount_cents'] as num).toInt(),
      currency: json['currency'] as String,
      isRecurring: json['is_recurring'] as bool,
      recurrenceRule: json['recurrence_rule'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$FinanceEntryToJson(_FinanceEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'space_id': instance.spaceId,
      'created_by': instance.createdBy,
      'entry_type': _$FinanceEntryTypeEnumMap[instance.entryType]!,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'description': instance.description,
      'amount_cents': instance.amountCents,
      'currency': instance.currency,
      'is_recurring': instance.isRecurring,
      'recurrence_rule': instance.recurrenceRule,
      'date': instance.date.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$FinanceEntryTypeEnumMap = {
  FinanceEntryType.income: 'income',
  FinanceEntryType.expense: 'expense',
};
