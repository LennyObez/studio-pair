// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entitlement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Entitlement {

@JsonKey(name: 'space_id') String get spaceId; SubscriptionTier get tier;@JsonKey(name: 'storage_bytes_used') int get storageBytesUsed;@JsonKey(name: 'storage_bytes_limit') int get storageBytesLimit;@JsonKey(name: 'max_members') int get maxMembers;@JsonKey(name: 'calendar_connections_count') int get calendarConnectionsCount;@JsonKey(name: 'calendar_connections_limit') int get calendarConnectionsLimit;@JsonKey(name: 'ai_credits_used_this_period') int get aiCreditsUsedThisPeriod;@JsonKey(name: 'ai_credits_limit') int get aiCreditsLimit;@JsonKey(name: 'history_retention_days') int get historyRetentionDays;@JsonKey(name: 'current_period_start') DateTime? get currentPeriodStart;@JsonKey(name: 'current_period_end') DateTime? get currentPeriodEnd;
/// Create a copy of Entitlement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntitlementCopyWith<Entitlement> get copyWith => _$EntitlementCopyWithImpl<Entitlement>(this as Entitlement, _$identity);

  /// Serializes this Entitlement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Entitlement&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.storageBytesUsed, storageBytesUsed) || other.storageBytesUsed == storageBytesUsed)&&(identical(other.storageBytesLimit, storageBytesLimit) || other.storageBytesLimit == storageBytesLimit)&&(identical(other.maxMembers, maxMembers) || other.maxMembers == maxMembers)&&(identical(other.calendarConnectionsCount, calendarConnectionsCount) || other.calendarConnectionsCount == calendarConnectionsCount)&&(identical(other.calendarConnectionsLimit, calendarConnectionsLimit) || other.calendarConnectionsLimit == calendarConnectionsLimit)&&(identical(other.aiCreditsUsedThisPeriod, aiCreditsUsedThisPeriod) || other.aiCreditsUsedThisPeriod == aiCreditsUsedThisPeriod)&&(identical(other.aiCreditsLimit, aiCreditsLimit) || other.aiCreditsLimit == aiCreditsLimit)&&(identical(other.historyRetentionDays, historyRetentionDays) || other.historyRetentionDays == historyRetentionDays)&&(identical(other.currentPeriodStart, currentPeriodStart) || other.currentPeriodStart == currentPeriodStart)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,spaceId,tier,storageBytesUsed,storageBytesLimit,maxMembers,calendarConnectionsCount,calendarConnectionsLimit,aiCreditsUsedThisPeriod,aiCreditsLimit,historyRetentionDays,currentPeriodStart,currentPeriodEnd);

@override
String toString() {
  return 'Entitlement(spaceId: $spaceId, tier: $tier, storageBytesUsed: $storageBytesUsed, storageBytesLimit: $storageBytesLimit, maxMembers: $maxMembers, calendarConnectionsCount: $calendarConnectionsCount, calendarConnectionsLimit: $calendarConnectionsLimit, aiCreditsUsedThisPeriod: $aiCreditsUsedThisPeriod, aiCreditsLimit: $aiCreditsLimit, historyRetentionDays: $historyRetentionDays, currentPeriodStart: $currentPeriodStart, currentPeriodEnd: $currentPeriodEnd)';
}


}

/// @nodoc
abstract mixin class $EntitlementCopyWith<$Res>  {
  factory $EntitlementCopyWith(Entitlement value, $Res Function(Entitlement) _then) = _$EntitlementCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'space_id') String spaceId, SubscriptionTier tier,@JsonKey(name: 'storage_bytes_used') int storageBytesUsed,@JsonKey(name: 'storage_bytes_limit') int storageBytesLimit,@JsonKey(name: 'max_members') int maxMembers,@JsonKey(name: 'calendar_connections_count') int calendarConnectionsCount,@JsonKey(name: 'calendar_connections_limit') int calendarConnectionsLimit,@JsonKey(name: 'ai_credits_used_this_period') int aiCreditsUsedThisPeriod,@JsonKey(name: 'ai_credits_limit') int aiCreditsLimit,@JsonKey(name: 'history_retention_days') int historyRetentionDays,@JsonKey(name: 'current_period_start') DateTime? currentPeriodStart,@JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd
});




}
/// @nodoc
class _$EntitlementCopyWithImpl<$Res>
    implements $EntitlementCopyWith<$Res> {
  _$EntitlementCopyWithImpl(this._self, this._then);

  final Entitlement _self;
  final $Res Function(Entitlement) _then;

/// Create a copy of Entitlement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? spaceId = null,Object? tier = null,Object? storageBytesUsed = null,Object? storageBytesLimit = null,Object? maxMembers = null,Object? calendarConnectionsCount = null,Object? calendarConnectionsLimit = null,Object? aiCreditsUsedThisPeriod = null,Object? aiCreditsLimit = null,Object? historyRetentionDays = null,Object? currentPeriodStart = freezed,Object? currentPeriodEnd = freezed,}) {
  return _then(_self.copyWith(
spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as SubscriptionTier,storageBytesUsed: null == storageBytesUsed ? _self.storageBytesUsed : storageBytesUsed // ignore: cast_nullable_to_non_nullable
as int,storageBytesLimit: null == storageBytesLimit ? _self.storageBytesLimit : storageBytesLimit // ignore: cast_nullable_to_non_nullable
as int,maxMembers: null == maxMembers ? _self.maxMembers : maxMembers // ignore: cast_nullable_to_non_nullable
as int,calendarConnectionsCount: null == calendarConnectionsCount ? _self.calendarConnectionsCount : calendarConnectionsCount // ignore: cast_nullable_to_non_nullable
as int,calendarConnectionsLimit: null == calendarConnectionsLimit ? _self.calendarConnectionsLimit : calendarConnectionsLimit // ignore: cast_nullable_to_non_nullable
as int,aiCreditsUsedThisPeriod: null == aiCreditsUsedThisPeriod ? _self.aiCreditsUsedThisPeriod : aiCreditsUsedThisPeriod // ignore: cast_nullable_to_non_nullable
as int,aiCreditsLimit: null == aiCreditsLimit ? _self.aiCreditsLimit : aiCreditsLimit // ignore: cast_nullable_to_non_nullable
as int,historyRetentionDays: null == historyRetentionDays ? _self.historyRetentionDays : historyRetentionDays // ignore: cast_nullable_to_non_nullable
as int,currentPeriodStart: freezed == currentPeriodStart ? _self.currentPeriodStart : currentPeriodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,currentPeriodEnd: freezed == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Entitlement].
extension EntitlementPatterns on Entitlement {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Entitlement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Entitlement() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Entitlement value)  $default,){
final _that = this;
switch (_that) {
case _Entitlement():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Entitlement value)?  $default,){
final _that = this;
switch (_that) {
case _Entitlement() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'space_id')  String spaceId,  SubscriptionTier tier, @JsonKey(name: 'storage_bytes_used')  int storageBytesUsed, @JsonKey(name: 'storage_bytes_limit')  int storageBytesLimit, @JsonKey(name: 'max_members')  int maxMembers, @JsonKey(name: 'calendar_connections_count')  int calendarConnectionsCount, @JsonKey(name: 'calendar_connections_limit')  int calendarConnectionsLimit, @JsonKey(name: 'ai_credits_used_this_period')  int aiCreditsUsedThisPeriod, @JsonKey(name: 'ai_credits_limit')  int aiCreditsLimit, @JsonKey(name: 'history_retention_days')  int historyRetentionDays, @JsonKey(name: 'current_period_start')  DateTime? currentPeriodStart, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Entitlement() when $default != null:
return $default(_that.spaceId,_that.tier,_that.storageBytesUsed,_that.storageBytesLimit,_that.maxMembers,_that.calendarConnectionsCount,_that.calendarConnectionsLimit,_that.aiCreditsUsedThisPeriod,_that.aiCreditsLimit,_that.historyRetentionDays,_that.currentPeriodStart,_that.currentPeriodEnd);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'space_id')  String spaceId,  SubscriptionTier tier, @JsonKey(name: 'storage_bytes_used')  int storageBytesUsed, @JsonKey(name: 'storage_bytes_limit')  int storageBytesLimit, @JsonKey(name: 'max_members')  int maxMembers, @JsonKey(name: 'calendar_connections_count')  int calendarConnectionsCount, @JsonKey(name: 'calendar_connections_limit')  int calendarConnectionsLimit, @JsonKey(name: 'ai_credits_used_this_period')  int aiCreditsUsedThisPeriod, @JsonKey(name: 'ai_credits_limit')  int aiCreditsLimit, @JsonKey(name: 'history_retention_days')  int historyRetentionDays, @JsonKey(name: 'current_period_start')  DateTime? currentPeriodStart, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd)  $default,) {final _that = this;
switch (_that) {
case _Entitlement():
return $default(_that.spaceId,_that.tier,_that.storageBytesUsed,_that.storageBytesLimit,_that.maxMembers,_that.calendarConnectionsCount,_that.calendarConnectionsLimit,_that.aiCreditsUsedThisPeriod,_that.aiCreditsLimit,_that.historyRetentionDays,_that.currentPeriodStart,_that.currentPeriodEnd);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'space_id')  String spaceId,  SubscriptionTier tier, @JsonKey(name: 'storage_bytes_used')  int storageBytesUsed, @JsonKey(name: 'storage_bytes_limit')  int storageBytesLimit, @JsonKey(name: 'max_members')  int maxMembers, @JsonKey(name: 'calendar_connections_count')  int calendarConnectionsCount, @JsonKey(name: 'calendar_connections_limit')  int calendarConnectionsLimit, @JsonKey(name: 'ai_credits_used_this_period')  int aiCreditsUsedThisPeriod, @JsonKey(name: 'ai_credits_limit')  int aiCreditsLimit, @JsonKey(name: 'history_retention_days')  int historyRetentionDays, @JsonKey(name: 'current_period_start')  DateTime? currentPeriodStart, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd)?  $default,) {final _that = this;
switch (_that) {
case _Entitlement() when $default != null:
return $default(_that.spaceId,_that.tier,_that.storageBytesUsed,_that.storageBytesLimit,_that.maxMembers,_that.calendarConnectionsCount,_that.calendarConnectionsLimit,_that.aiCreditsUsedThisPeriod,_that.aiCreditsLimit,_that.historyRetentionDays,_that.currentPeriodStart,_that.currentPeriodEnd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Entitlement implements Entitlement {
  const _Entitlement({@JsonKey(name: 'space_id') required this.spaceId, required this.tier, @JsonKey(name: 'storage_bytes_used') required this.storageBytesUsed, @JsonKey(name: 'storage_bytes_limit') required this.storageBytesLimit, @JsonKey(name: 'max_members') required this.maxMembers, @JsonKey(name: 'calendar_connections_count') required this.calendarConnectionsCount, @JsonKey(name: 'calendar_connections_limit') required this.calendarConnectionsLimit, @JsonKey(name: 'ai_credits_used_this_period') required this.aiCreditsUsedThisPeriod, @JsonKey(name: 'ai_credits_limit') required this.aiCreditsLimit, @JsonKey(name: 'history_retention_days') required this.historyRetentionDays, @JsonKey(name: 'current_period_start') this.currentPeriodStart, @JsonKey(name: 'current_period_end') this.currentPeriodEnd});
  factory _Entitlement.fromJson(Map<String, dynamic> json) => _$EntitlementFromJson(json);

@override@JsonKey(name: 'space_id') final  String spaceId;
@override final  SubscriptionTier tier;
@override@JsonKey(name: 'storage_bytes_used') final  int storageBytesUsed;
@override@JsonKey(name: 'storage_bytes_limit') final  int storageBytesLimit;
@override@JsonKey(name: 'max_members') final  int maxMembers;
@override@JsonKey(name: 'calendar_connections_count') final  int calendarConnectionsCount;
@override@JsonKey(name: 'calendar_connections_limit') final  int calendarConnectionsLimit;
@override@JsonKey(name: 'ai_credits_used_this_period') final  int aiCreditsUsedThisPeriod;
@override@JsonKey(name: 'ai_credits_limit') final  int aiCreditsLimit;
@override@JsonKey(name: 'history_retention_days') final  int historyRetentionDays;
@override@JsonKey(name: 'current_period_start') final  DateTime? currentPeriodStart;
@override@JsonKey(name: 'current_period_end') final  DateTime? currentPeriodEnd;

/// Create a copy of Entitlement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntitlementCopyWith<_Entitlement> get copyWith => __$EntitlementCopyWithImpl<_Entitlement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntitlementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Entitlement&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.storageBytesUsed, storageBytesUsed) || other.storageBytesUsed == storageBytesUsed)&&(identical(other.storageBytesLimit, storageBytesLimit) || other.storageBytesLimit == storageBytesLimit)&&(identical(other.maxMembers, maxMembers) || other.maxMembers == maxMembers)&&(identical(other.calendarConnectionsCount, calendarConnectionsCount) || other.calendarConnectionsCount == calendarConnectionsCount)&&(identical(other.calendarConnectionsLimit, calendarConnectionsLimit) || other.calendarConnectionsLimit == calendarConnectionsLimit)&&(identical(other.aiCreditsUsedThisPeriod, aiCreditsUsedThisPeriod) || other.aiCreditsUsedThisPeriod == aiCreditsUsedThisPeriod)&&(identical(other.aiCreditsLimit, aiCreditsLimit) || other.aiCreditsLimit == aiCreditsLimit)&&(identical(other.historyRetentionDays, historyRetentionDays) || other.historyRetentionDays == historyRetentionDays)&&(identical(other.currentPeriodStart, currentPeriodStart) || other.currentPeriodStart == currentPeriodStart)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,spaceId,tier,storageBytesUsed,storageBytesLimit,maxMembers,calendarConnectionsCount,calendarConnectionsLimit,aiCreditsUsedThisPeriod,aiCreditsLimit,historyRetentionDays,currentPeriodStart,currentPeriodEnd);

@override
String toString() {
  return 'Entitlement(spaceId: $spaceId, tier: $tier, storageBytesUsed: $storageBytesUsed, storageBytesLimit: $storageBytesLimit, maxMembers: $maxMembers, calendarConnectionsCount: $calendarConnectionsCount, calendarConnectionsLimit: $calendarConnectionsLimit, aiCreditsUsedThisPeriod: $aiCreditsUsedThisPeriod, aiCreditsLimit: $aiCreditsLimit, historyRetentionDays: $historyRetentionDays, currentPeriodStart: $currentPeriodStart, currentPeriodEnd: $currentPeriodEnd)';
}


}

/// @nodoc
abstract mixin class _$EntitlementCopyWith<$Res> implements $EntitlementCopyWith<$Res> {
  factory _$EntitlementCopyWith(_Entitlement value, $Res Function(_Entitlement) _then) = __$EntitlementCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'space_id') String spaceId, SubscriptionTier tier,@JsonKey(name: 'storage_bytes_used') int storageBytesUsed,@JsonKey(name: 'storage_bytes_limit') int storageBytesLimit,@JsonKey(name: 'max_members') int maxMembers,@JsonKey(name: 'calendar_connections_count') int calendarConnectionsCount,@JsonKey(name: 'calendar_connections_limit') int calendarConnectionsLimit,@JsonKey(name: 'ai_credits_used_this_period') int aiCreditsUsedThisPeriod,@JsonKey(name: 'ai_credits_limit') int aiCreditsLimit,@JsonKey(name: 'history_retention_days') int historyRetentionDays,@JsonKey(name: 'current_period_start') DateTime? currentPeriodStart,@JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd
});




}
/// @nodoc
class __$EntitlementCopyWithImpl<$Res>
    implements _$EntitlementCopyWith<$Res> {
  __$EntitlementCopyWithImpl(this._self, this._then);

  final _Entitlement _self;
  final $Res Function(_Entitlement) _then;

/// Create a copy of Entitlement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? spaceId = null,Object? tier = null,Object? storageBytesUsed = null,Object? storageBytesLimit = null,Object? maxMembers = null,Object? calendarConnectionsCount = null,Object? calendarConnectionsLimit = null,Object? aiCreditsUsedThisPeriod = null,Object? aiCreditsLimit = null,Object? historyRetentionDays = null,Object? currentPeriodStart = freezed,Object? currentPeriodEnd = freezed,}) {
  return _then(_Entitlement(
spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as SubscriptionTier,storageBytesUsed: null == storageBytesUsed ? _self.storageBytesUsed : storageBytesUsed // ignore: cast_nullable_to_non_nullable
as int,storageBytesLimit: null == storageBytesLimit ? _self.storageBytesLimit : storageBytesLimit // ignore: cast_nullable_to_non_nullable
as int,maxMembers: null == maxMembers ? _self.maxMembers : maxMembers // ignore: cast_nullable_to_non_nullable
as int,calendarConnectionsCount: null == calendarConnectionsCount ? _self.calendarConnectionsCount : calendarConnectionsCount // ignore: cast_nullable_to_non_nullable
as int,calendarConnectionsLimit: null == calendarConnectionsLimit ? _self.calendarConnectionsLimit : calendarConnectionsLimit // ignore: cast_nullable_to_non_nullable
as int,aiCreditsUsedThisPeriod: null == aiCreditsUsedThisPeriod ? _self.aiCreditsUsedThisPeriod : aiCreditsUsedThisPeriod // ignore: cast_nullable_to_non_nullable
as int,aiCreditsLimit: null == aiCreditsLimit ? _self.aiCreditsLimit : aiCreditsLimit // ignore: cast_nullable_to_non_nullable
as int,historyRetentionDays: null == historyRetentionDays ? _self.historyRetentionDays : historyRetentionDays // ignore: cast_nullable_to_non_nullable
as int,currentPeriodStart: freezed == currentPeriodStart ? _self.currentPeriodStart : currentPeriodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,currentPeriodEnd: freezed == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
