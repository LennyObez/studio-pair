import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/subscription_tier.dart';

part 'entitlement.freezed.dart';
part 'entitlement.g.dart';

/// Represents a space's entitlements based on subscription tier.
@freezed
abstract class Entitlement with _$Entitlement {
  const factory Entitlement({
    @JsonKey(name: 'space_id') required String spaceId,
    required SubscriptionTier tier,
    @JsonKey(name: 'storage_bytes_used') required int storageBytesUsed,
    @JsonKey(name: 'storage_bytes_limit') required int storageBytesLimit,
    @JsonKey(name: 'max_members') required int maxMembers,
    @JsonKey(name: 'calendar_connections_count')
    required int calendarConnectionsCount,
    @JsonKey(name: 'calendar_connections_limit')
    required int calendarConnectionsLimit,
    @JsonKey(name: 'ai_credits_used_this_period')
    required int aiCreditsUsedThisPeriod,
    @JsonKey(name: 'ai_credits_limit') required int aiCreditsLimit,
    @JsonKey(name: 'history_retention_days') required int historyRetentionDays,
    @JsonKey(name: 'current_period_start') DateTime? currentPeriodStart,
    @JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,
  }) = _Entitlement;

  factory Entitlement.fromJson(Map<String, dynamic> json) =>
      _$EntitlementFromJson(json);
}
