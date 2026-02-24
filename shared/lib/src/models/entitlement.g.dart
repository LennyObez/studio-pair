// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Entitlement _$EntitlementFromJson(Map<String, dynamic> json) => _Entitlement(
  spaceId: json['space_id'] as String,
  tier: $enumDecode(_$SubscriptionTierEnumMap, json['tier']),
  storageBytesUsed: (json['storage_bytes_used'] as num).toInt(),
  storageBytesLimit: (json['storage_bytes_limit'] as num).toInt(),
  maxMembers: (json['max_members'] as num).toInt(),
  calendarConnectionsCount: (json['calendar_connections_count'] as num).toInt(),
  calendarConnectionsLimit: (json['calendar_connections_limit'] as num).toInt(),
  aiCreditsUsedThisPeriod: (json['ai_credits_used_this_period'] as num).toInt(),
  aiCreditsLimit: (json['ai_credits_limit'] as num).toInt(),
  historyRetentionDays: (json['history_retention_days'] as num).toInt(),
  currentPeriodStart: json['current_period_start'] == null
      ? null
      : DateTime.parse(json['current_period_start'] as String),
  currentPeriodEnd: json['current_period_end'] == null
      ? null
      : DateTime.parse(json['current_period_end'] as String),
);

Map<String, dynamic> _$EntitlementToJson(_Entitlement instance) =>
    <String, dynamic>{
      'space_id': instance.spaceId,
      'tier': _$SubscriptionTierEnumMap[instance.tier]!,
      'storage_bytes_used': instance.storageBytesUsed,
      'storage_bytes_limit': instance.storageBytesLimit,
      'max_members': instance.maxMembers,
      'calendar_connections_count': instance.calendarConnectionsCount,
      'calendar_connections_limit': instance.calendarConnectionsLimit,
      'ai_credits_used_this_period': instance.aiCreditsUsedThisPeriod,
      'ai_credits_limit': instance.aiCreditsLimit,
      'history_retention_days': instance.historyRetentionDays,
      'current_period_start': instance.currentPeriodStart?.toIso8601String(),
      'current_period_end': instance.currentPeriodEnd?.toIso8601String(),
    };

const _$SubscriptionTierEnumMap = {
  SubscriptionTier.free: 'free',
  SubscriptionTier.premium: 'premium',
};
