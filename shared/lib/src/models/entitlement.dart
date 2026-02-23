import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/subscription_tier.dart';

part 'entitlement.g.dart';

/// Represents a space's entitlements based on subscription tier.
@JsonSerializable()
class Entitlement extends Equatable {
  const Entitlement({
    required this.spaceId,
    required this.tier,
    required this.storageBytesUsed,
    required this.storageBytesLimit,
    required this.maxMembers,
    required this.calendarConnectionsCount,
    required this.calendarConnectionsLimit,
    required this.aiCreditsUsedThisPeriod,
    required this.aiCreditsLimit,
    required this.historyRetentionDays,
    this.currentPeriodStart,
    this.currentPeriodEnd,
  });

  factory Entitlement.fromJson(Map<String, dynamic> json) =>
      _$EntitlementFromJson(json);

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'tier')
  final SubscriptionTier tier;

  @JsonKey(name: 'storage_bytes_used')
  final int storageBytesUsed;

  @JsonKey(name: 'storage_bytes_limit')
  final int storageBytesLimit;

  @JsonKey(name: 'max_members')
  final int maxMembers;

  @JsonKey(name: 'calendar_connections_count')
  final int calendarConnectionsCount;

  @JsonKey(name: 'calendar_connections_limit')
  final int calendarConnectionsLimit;

  @JsonKey(name: 'ai_credits_used_this_period')
  final int aiCreditsUsedThisPeriod;

  @JsonKey(name: 'ai_credits_limit')
  final int aiCreditsLimit;

  @JsonKey(name: 'history_retention_days')
  final int historyRetentionDays;

  @JsonKey(name: 'current_period_start')
  final DateTime? currentPeriodStart;

  @JsonKey(name: 'current_period_end')
  final DateTime? currentPeriodEnd;

  Map<String, dynamic> toJson() => _$EntitlementToJson(this);

  @override
  List<Object?> get props => [
    spaceId,
    tier,
    storageBytesUsed,
    storageBytesLimit,
    maxMembers,
    calendarConnectionsCount,
    calendarConnectionsLimit,
    aiCreditsUsedThisPeriod,
    aiCreditsLimit,
    historyRetentionDays,
    currentPeriodStart,
    currentPeriodEnd,
  ];
}
