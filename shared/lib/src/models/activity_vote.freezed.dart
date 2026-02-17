// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_vote.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActivityVote {

 String get id;@JsonKey(name: 'activity_id') String get activityId;@JsonKey(name: 'user_id') String get userId;/// Score from 1 to 5.
 int get score;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of ActivityVote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityVoteCopyWith<ActivityVote> get copyWith => _$ActivityVoteCopyWithImpl<ActivityVote>(this as ActivityVote, _$identity);

  /// Serializes this ActivityVote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityVote&&(identical(other.id, id) || other.id == id)&&(identical(other.activityId, activityId) || other.activityId == activityId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.score, score) || other.score == score)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,activityId,userId,score,createdAt,updatedAt);

@override
String toString() {
  return 'ActivityVote(id: $id, activityId: $activityId, userId: $userId, score: $score, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ActivityVoteCopyWith<$Res>  {
  factory $ActivityVoteCopyWith(ActivityVote value, $Res Function(ActivityVote) _then) = _$ActivityVoteCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'activity_id') String activityId,@JsonKey(name: 'user_id') String userId, int score,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$ActivityVoteCopyWithImpl<$Res>
    implements $ActivityVoteCopyWith<$Res> {
  _$ActivityVoteCopyWithImpl(this._self, this._then);

  final ActivityVote _self;
  final $Res Function(ActivityVote) _then;

/// Create a copy of ActivityVote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? activityId = null,Object? userId = null,Object? score = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activityId: null == activityId ? _self.activityId : activityId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityVote].
extension ActivityVotePatterns on ActivityVote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityVote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityVote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityVote value)  $default,){
final _that = this;
switch (_that) {
case _ActivityVote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityVote value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityVote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'activity_id')  String activityId, @JsonKey(name: 'user_id')  String userId,  int score, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityVote() when $default != null:
return $default(_that.id,_that.activityId,_that.userId,_that.score,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'activity_id')  String activityId, @JsonKey(name: 'user_id')  String userId,  int score, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ActivityVote():
return $default(_that.id,_that.activityId,_that.userId,_that.score,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'activity_id')  String activityId, @JsonKey(name: 'user_id')  String userId,  int score, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ActivityVote() when $default != null:
return $default(_that.id,_that.activityId,_that.userId,_that.score,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityVote implements ActivityVote {
  const _ActivityVote({required this.id, @JsonKey(name: 'activity_id') required this.activityId, @JsonKey(name: 'user_id') required this.userId, required this.score, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _ActivityVote.fromJson(Map<String, dynamic> json) => _$ActivityVoteFromJson(json);

@override final  String id;
@override@JsonKey(name: 'activity_id') final  String activityId;
@override@JsonKey(name: 'user_id') final  String userId;
/// Score from 1 to 5.
@override final  int score;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of ActivityVote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityVoteCopyWith<_ActivityVote> get copyWith => __$ActivityVoteCopyWithImpl<_ActivityVote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityVoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityVote&&(identical(other.id, id) || other.id == id)&&(identical(other.activityId, activityId) || other.activityId == activityId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.score, score) || other.score == score)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,activityId,userId,score,createdAt,updatedAt);

@override
String toString() {
  return 'ActivityVote(id: $id, activityId: $activityId, userId: $userId, score: $score, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ActivityVoteCopyWith<$Res> implements $ActivityVoteCopyWith<$Res> {
  factory _$ActivityVoteCopyWith(_ActivityVote value, $Res Function(_ActivityVote) _then) = __$ActivityVoteCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'activity_id') String activityId,@JsonKey(name: 'user_id') String userId, int score,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$ActivityVoteCopyWithImpl<$Res>
    implements _$ActivityVoteCopyWith<$Res> {
  __$ActivityVoteCopyWithImpl(this._self, this._then);

  final _ActivityVote _self;
  final $Res Function(_ActivityVote) _then;

/// Create a copy of ActivityVote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? activityId = null,Object? userId = null,Object? score = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ActivityVote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activityId: null == activityId ? _self.activityId : activityId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
