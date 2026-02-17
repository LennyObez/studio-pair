// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'space_membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SpaceMembership {

 String get id;@JsonKey(name: 'space_id') String get spaceId;@JsonKey(name: 'user_id') String get userId; MemberRole get role;@JsonKey(name: 'access_level') AccessLevel get accessLevel; MembershipStatus get status;@JsonKey(name: 'invited_by') String? get invitedBy;@JsonKey(name: 'joined_at') DateTime? get joinedAt;@JsonKey(name: 'left_at') DateTime? get leftAt;
/// Create a copy of SpaceMembership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceMembershipCopyWith<SpaceMembership> get copyWith => _$SpaceMembershipCopyWithImpl<SpaceMembership>(this as SpaceMembership, _$identity);

  /// Serializes this SpaceMembership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceMembership&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.accessLevel, accessLevel) || other.accessLevel == accessLevel)&&(identical(other.status, status) || other.status == status)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.leftAt, leftAt) || other.leftAt == leftAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spaceId,userId,role,accessLevel,status,invitedBy,joinedAt,leftAt);

@override
String toString() {
  return 'SpaceMembership(id: $id, spaceId: $spaceId, userId: $userId, role: $role, accessLevel: $accessLevel, status: $status, invitedBy: $invitedBy, joinedAt: $joinedAt, leftAt: $leftAt)';
}


}

/// @nodoc
abstract mixin class $SpaceMembershipCopyWith<$Res>  {
  factory $SpaceMembershipCopyWith(SpaceMembership value, $Res Function(SpaceMembership) _then) = _$SpaceMembershipCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'user_id') String userId, MemberRole role,@JsonKey(name: 'access_level') AccessLevel accessLevel, MembershipStatus status,@JsonKey(name: 'invited_by') String? invitedBy,@JsonKey(name: 'joined_at') DateTime? joinedAt,@JsonKey(name: 'left_at') DateTime? leftAt
});




}
/// @nodoc
class _$SpaceMembershipCopyWithImpl<$Res>
    implements $SpaceMembershipCopyWith<$Res> {
  _$SpaceMembershipCopyWithImpl(this._self, this._then);

  final SpaceMembership _self;
  final $Res Function(SpaceMembership) _then;

/// Create a copy of SpaceMembership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? spaceId = null,Object? userId = null,Object? role = null,Object? accessLevel = null,Object? status = null,Object? invitedBy = freezed,Object? joinedAt = freezed,Object? leftAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,accessLevel: null == accessLevel ? _self.accessLevel : accessLevel // ignore: cast_nullable_to_non_nullable
as AccessLevel,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,invitedBy: freezed == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,leftAt: freezed == leftAt ? _self.leftAt : leftAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SpaceMembership].
extension SpaceMembershipPatterns on SpaceMembership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpaceMembership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpaceMembership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpaceMembership value)  $default,){
final _that = this;
switch (_that) {
case _SpaceMembership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpaceMembership value)?  $default,){
final _that = this;
switch (_that) {
case _SpaceMembership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'user_id')  String userId,  MemberRole role, @JsonKey(name: 'access_level')  AccessLevel accessLevel,  MembershipStatus status, @JsonKey(name: 'invited_by')  String? invitedBy, @JsonKey(name: 'joined_at')  DateTime? joinedAt, @JsonKey(name: 'left_at')  DateTime? leftAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpaceMembership() when $default != null:
return $default(_that.id,_that.spaceId,_that.userId,_that.role,_that.accessLevel,_that.status,_that.invitedBy,_that.joinedAt,_that.leftAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'user_id')  String userId,  MemberRole role, @JsonKey(name: 'access_level')  AccessLevel accessLevel,  MembershipStatus status, @JsonKey(name: 'invited_by')  String? invitedBy, @JsonKey(name: 'joined_at')  DateTime? joinedAt, @JsonKey(name: 'left_at')  DateTime? leftAt)  $default,) {final _that = this;
switch (_that) {
case _SpaceMembership():
return $default(_that.id,_that.spaceId,_that.userId,_that.role,_that.accessLevel,_that.status,_that.invitedBy,_that.joinedAt,_that.leftAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'user_id')  String userId,  MemberRole role, @JsonKey(name: 'access_level')  AccessLevel accessLevel,  MembershipStatus status, @JsonKey(name: 'invited_by')  String? invitedBy, @JsonKey(name: 'joined_at')  DateTime? joinedAt, @JsonKey(name: 'left_at')  DateTime? leftAt)?  $default,) {final _that = this;
switch (_that) {
case _SpaceMembership() when $default != null:
return $default(_that.id,_that.spaceId,_that.userId,_that.role,_that.accessLevel,_that.status,_that.invitedBy,_that.joinedAt,_that.leftAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpaceMembership implements SpaceMembership {
  const _SpaceMembership({required this.id, @JsonKey(name: 'space_id') required this.spaceId, @JsonKey(name: 'user_id') required this.userId, required this.role, @JsonKey(name: 'access_level') required this.accessLevel, required this.status, @JsonKey(name: 'invited_by') this.invitedBy, @JsonKey(name: 'joined_at') this.joinedAt, @JsonKey(name: 'left_at') this.leftAt});
  factory _SpaceMembership.fromJson(Map<String, dynamic> json) => _$SpaceMembershipFromJson(json);

@override final  String id;
@override@JsonKey(name: 'space_id') final  String spaceId;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  MemberRole role;
@override@JsonKey(name: 'access_level') final  AccessLevel accessLevel;
@override final  MembershipStatus status;
@override@JsonKey(name: 'invited_by') final  String? invitedBy;
@override@JsonKey(name: 'joined_at') final  DateTime? joinedAt;
@override@JsonKey(name: 'left_at') final  DateTime? leftAt;

/// Create a copy of SpaceMembership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpaceMembershipCopyWith<_SpaceMembership> get copyWith => __$SpaceMembershipCopyWithImpl<_SpaceMembership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpaceMembershipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpaceMembership&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.accessLevel, accessLevel) || other.accessLevel == accessLevel)&&(identical(other.status, status) || other.status == status)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.leftAt, leftAt) || other.leftAt == leftAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spaceId,userId,role,accessLevel,status,invitedBy,joinedAt,leftAt);

@override
String toString() {
  return 'SpaceMembership(id: $id, spaceId: $spaceId, userId: $userId, role: $role, accessLevel: $accessLevel, status: $status, invitedBy: $invitedBy, joinedAt: $joinedAt, leftAt: $leftAt)';
}


}

/// @nodoc
abstract mixin class _$SpaceMembershipCopyWith<$Res> implements $SpaceMembershipCopyWith<$Res> {
  factory _$SpaceMembershipCopyWith(_SpaceMembership value, $Res Function(_SpaceMembership) _then) = __$SpaceMembershipCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'user_id') String userId, MemberRole role,@JsonKey(name: 'access_level') AccessLevel accessLevel, MembershipStatus status,@JsonKey(name: 'invited_by') String? invitedBy,@JsonKey(name: 'joined_at') DateTime? joinedAt,@JsonKey(name: 'left_at') DateTime? leftAt
});




}
/// @nodoc
class __$SpaceMembershipCopyWithImpl<$Res>
    implements _$SpaceMembershipCopyWith<$Res> {
  __$SpaceMembershipCopyWithImpl(this._self, this._then);

  final _SpaceMembership _self;
  final $Res Function(_SpaceMembership) _then;

/// Create a copy of SpaceMembership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? spaceId = null,Object? userId = null,Object? role = null,Object? accessLevel = null,Object? status = null,Object? invitedBy = freezed,Object? joinedAt = freezed,Object? leftAt = freezed,}) {
  return _then(_SpaceMembership(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,accessLevel: null == accessLevel ? _self.accessLevel : accessLevel // ignore: cast_nullable_to_non_nullable
as AccessLevel,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,invitedBy: freezed == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,leftAt: freezed == leftAt ? _self.leftAt : leftAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
