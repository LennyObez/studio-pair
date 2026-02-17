// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poll.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Poll {

 String get id;@JsonKey(name: 'space_id') String get spaceId;@JsonKey(name: 'created_by') String get createdBy; String get question;@JsonKey(name: 'poll_type') PollType get pollType;@JsonKey(name: 'is_anonymous') bool get isAnonymous; DateTime? get deadline;@JsonKey(name: 'is_closed') bool get isClosed;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PollCopyWith<Poll> get copyWith => _$PollCopyWithImpl<Poll>(this as Poll, _$identity);

  /// Serializes this Poll to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Poll&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.question, question) || other.question == question)&&(identical(other.pollType, pollType) || other.pollType == pollType)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.isClosed, isClosed) || other.isClosed == isClosed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spaceId,createdBy,question,pollType,isAnonymous,deadline,isClosed,createdAt,updatedAt);

@override
String toString() {
  return 'Poll(id: $id, spaceId: $spaceId, createdBy: $createdBy, question: $question, pollType: $pollType, isAnonymous: $isAnonymous, deadline: $deadline, isClosed: $isClosed, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PollCopyWith<$Res>  {
  factory $PollCopyWith(Poll value, $Res Function(Poll) _then) = _$PollCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'created_by') String createdBy, String question,@JsonKey(name: 'poll_type') PollType pollType,@JsonKey(name: 'is_anonymous') bool isAnonymous, DateTime? deadline,@JsonKey(name: 'is_closed') bool isClosed,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$PollCopyWithImpl<$Res>
    implements $PollCopyWith<$Res> {
  _$PollCopyWithImpl(this._self, this._then);

  final Poll _self;
  final $Res Function(Poll) _then;

/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? spaceId = null,Object? createdBy = null,Object? question = null,Object? pollType = null,Object? isAnonymous = null,Object? deadline = freezed,Object? isClosed = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,pollType: null == pollType ? _self.pollType : pollType // ignore: cast_nullable_to_non_nullable
as PollType,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,isClosed: null == isClosed ? _self.isClosed : isClosed // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Poll].
extension PollPatterns on Poll {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Poll value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Poll() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Poll value)  $default,){
final _that = this;
switch (_that) {
case _Poll():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Poll value)?  $default,){
final _that = this;
switch (_that) {
case _Poll() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String question, @JsonKey(name: 'poll_type')  PollType pollType, @JsonKey(name: 'is_anonymous')  bool isAnonymous,  DateTime? deadline, @JsonKey(name: 'is_closed')  bool isClosed, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Poll() when $default != null:
return $default(_that.id,_that.spaceId,_that.createdBy,_that.question,_that.pollType,_that.isAnonymous,_that.deadline,_that.isClosed,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String question, @JsonKey(name: 'poll_type')  PollType pollType, @JsonKey(name: 'is_anonymous')  bool isAnonymous,  DateTime? deadline, @JsonKey(name: 'is_closed')  bool isClosed, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Poll():
return $default(_that.id,_that.spaceId,_that.createdBy,_that.question,_that.pollType,_that.isAnonymous,_that.deadline,_that.isClosed,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String question, @JsonKey(name: 'poll_type')  PollType pollType, @JsonKey(name: 'is_anonymous')  bool isAnonymous,  DateTime? deadline, @JsonKey(name: 'is_closed')  bool isClosed, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Poll() when $default != null:
return $default(_that.id,_that.spaceId,_that.createdBy,_that.question,_that.pollType,_that.isAnonymous,_that.deadline,_that.isClosed,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Poll implements Poll {
  const _Poll({required this.id, @JsonKey(name: 'space_id') required this.spaceId, @JsonKey(name: 'created_by') required this.createdBy, required this.question, @JsonKey(name: 'poll_type') required this.pollType, @JsonKey(name: 'is_anonymous') required this.isAnonymous, this.deadline, @JsonKey(name: 'is_closed') required this.isClosed, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);

@override final  String id;
@override@JsonKey(name: 'space_id') final  String spaceId;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override final  String question;
@override@JsonKey(name: 'poll_type') final  PollType pollType;
@override@JsonKey(name: 'is_anonymous') final  bool isAnonymous;
@override final  DateTime? deadline;
@override@JsonKey(name: 'is_closed') final  bool isClosed;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PollCopyWith<_Poll> get copyWith => __$PollCopyWithImpl<_Poll>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PollToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Poll&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.question, question) || other.question == question)&&(identical(other.pollType, pollType) || other.pollType == pollType)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.isClosed, isClosed) || other.isClosed == isClosed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spaceId,createdBy,question,pollType,isAnonymous,deadline,isClosed,createdAt,updatedAt);

@override
String toString() {
  return 'Poll(id: $id, spaceId: $spaceId, createdBy: $createdBy, question: $question, pollType: $pollType, isAnonymous: $isAnonymous, deadline: $deadline, isClosed: $isClosed, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PollCopyWith<$Res> implements $PollCopyWith<$Res> {
  factory _$PollCopyWith(_Poll value, $Res Function(_Poll) _then) = __$PollCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'created_by') String createdBy, String question,@JsonKey(name: 'poll_type') PollType pollType,@JsonKey(name: 'is_anonymous') bool isAnonymous, DateTime? deadline,@JsonKey(name: 'is_closed') bool isClosed,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$PollCopyWithImpl<$Res>
    implements _$PollCopyWith<$Res> {
  __$PollCopyWithImpl(this._self, this._then);

  final _Poll _self;
  final $Res Function(_Poll) _then;

/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? spaceId = null,Object? createdBy = null,Object? question = null,Object? pollType = null,Object? isAnonymous = null,Object? deadline = freezed,Object? isClosed = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Poll(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,pollType: null == pollType ? _self.pollType : pollType // ignore: cast_nullable_to_non_nullable
as PollType,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,isClosed: null == isClosed ? _self.isClosed : isClosed // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
