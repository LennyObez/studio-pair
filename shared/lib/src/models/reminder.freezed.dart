// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reminder {

 String get id;@JsonKey(name: 'space_id') String get spaceId;@JsonKey(name: 'created_by') String get createdBy; String get message;@JsonKey(name: 'trigger_at') DateTime get triggerAt;@JsonKey(name: 'recurrence_rule') String? get recurrenceRule;@JsonKey(name: 'linked_module') String? get linkedModule;@JsonKey(name: 'linked_entity_id') String? get linkedEntityId;@JsonKey(name: 'is_sent') bool get isSent;@JsonKey(name: 'sent_at') DateTime? get sentAt;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReminderCopyWith<Reminder> get copyWith => _$ReminderCopyWithImpl<Reminder>(this as Reminder, _$identity);

  /// Serializes this Reminder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reminder&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.message, message) || other.message == message)&&(identical(other.triggerAt, triggerAt) || other.triggerAt == triggerAt)&&(identical(other.recurrenceRule, recurrenceRule) || other.recurrenceRule == recurrenceRule)&&(identical(other.linkedModule, linkedModule) || other.linkedModule == linkedModule)&&(identical(other.linkedEntityId, linkedEntityId) || other.linkedEntityId == linkedEntityId)&&(identical(other.isSent, isSent) || other.isSent == isSent)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spaceId,createdBy,message,triggerAt,recurrenceRule,linkedModule,linkedEntityId,isSent,sentAt,createdAt,updatedAt);

@override
String toString() {
  return 'Reminder(id: $id, spaceId: $spaceId, createdBy: $createdBy, message: $message, triggerAt: $triggerAt, recurrenceRule: $recurrenceRule, linkedModule: $linkedModule, linkedEntityId: $linkedEntityId, isSent: $isSent, sentAt: $sentAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ReminderCopyWith<$Res>  {
  factory $ReminderCopyWith(Reminder value, $Res Function(Reminder) _then) = _$ReminderCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'created_by') String createdBy, String message,@JsonKey(name: 'trigger_at') DateTime triggerAt,@JsonKey(name: 'recurrence_rule') String? recurrenceRule,@JsonKey(name: 'linked_module') String? linkedModule,@JsonKey(name: 'linked_entity_id') String? linkedEntityId,@JsonKey(name: 'is_sent') bool isSent,@JsonKey(name: 'sent_at') DateTime? sentAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$ReminderCopyWithImpl<$Res>
    implements $ReminderCopyWith<$Res> {
  _$ReminderCopyWithImpl(this._self, this._then);

  final Reminder _self;
  final $Res Function(Reminder) _then;

/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? spaceId = null,Object? createdBy = null,Object? message = null,Object? triggerAt = null,Object? recurrenceRule = freezed,Object? linkedModule = freezed,Object? linkedEntityId = freezed,Object? isSent = null,Object? sentAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,triggerAt: null == triggerAt ? _self.triggerAt : triggerAt // ignore: cast_nullable_to_non_nullable
as DateTime,recurrenceRule: freezed == recurrenceRule ? _self.recurrenceRule : recurrenceRule // ignore: cast_nullable_to_non_nullable
as String?,linkedModule: freezed == linkedModule ? _self.linkedModule : linkedModule // ignore: cast_nullable_to_non_nullable
as String?,linkedEntityId: freezed == linkedEntityId ? _self.linkedEntityId : linkedEntityId // ignore: cast_nullable_to_non_nullable
as String?,isSent: null == isSent ? _self.isSent : isSent // ignore: cast_nullable_to_non_nullable
as bool,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Reminder].
extension ReminderPatterns on Reminder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reminder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reminder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reminder value)  $default,){
final _that = this;
switch (_that) {
case _Reminder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reminder value)?  $default,){
final _that = this;
switch (_that) {
case _Reminder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String message, @JsonKey(name: 'trigger_at')  DateTime triggerAt, @JsonKey(name: 'recurrence_rule')  String? recurrenceRule, @JsonKey(name: 'linked_module')  String? linkedModule, @JsonKey(name: 'linked_entity_id')  String? linkedEntityId, @JsonKey(name: 'is_sent')  bool isSent, @JsonKey(name: 'sent_at')  DateTime? sentAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reminder() when $default != null:
return $default(_that.id,_that.spaceId,_that.createdBy,_that.message,_that.triggerAt,_that.recurrenceRule,_that.linkedModule,_that.linkedEntityId,_that.isSent,_that.sentAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String message, @JsonKey(name: 'trigger_at')  DateTime triggerAt, @JsonKey(name: 'recurrence_rule')  String? recurrenceRule, @JsonKey(name: 'linked_module')  String? linkedModule, @JsonKey(name: 'linked_entity_id')  String? linkedEntityId, @JsonKey(name: 'is_sent')  bool isSent, @JsonKey(name: 'sent_at')  DateTime? sentAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Reminder():
return $default(_that.id,_that.spaceId,_that.createdBy,_that.message,_that.triggerAt,_that.recurrenceRule,_that.linkedModule,_that.linkedEntityId,_that.isSent,_that.sentAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String message, @JsonKey(name: 'trigger_at')  DateTime triggerAt, @JsonKey(name: 'recurrence_rule')  String? recurrenceRule, @JsonKey(name: 'linked_module')  String? linkedModule, @JsonKey(name: 'linked_entity_id')  String? linkedEntityId, @JsonKey(name: 'is_sent')  bool isSent, @JsonKey(name: 'sent_at')  DateTime? sentAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Reminder() when $default != null:
return $default(_that.id,_that.spaceId,_that.createdBy,_that.message,_that.triggerAt,_that.recurrenceRule,_that.linkedModule,_that.linkedEntityId,_that.isSent,_that.sentAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reminder implements Reminder {
  const _Reminder({required this.id, @JsonKey(name: 'space_id') required this.spaceId, @JsonKey(name: 'created_by') required this.createdBy, required this.message, @JsonKey(name: 'trigger_at') required this.triggerAt, @JsonKey(name: 'recurrence_rule') this.recurrenceRule, @JsonKey(name: 'linked_module') this.linkedModule, @JsonKey(name: 'linked_entity_id') this.linkedEntityId, @JsonKey(name: 'is_sent') required this.isSent, @JsonKey(name: 'sent_at') this.sentAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _Reminder.fromJson(Map<String, dynamic> json) => _$ReminderFromJson(json);

@override final  String id;
@override@JsonKey(name: 'space_id') final  String spaceId;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override final  String message;
@override@JsonKey(name: 'trigger_at') final  DateTime triggerAt;
@override@JsonKey(name: 'recurrence_rule') final  String? recurrenceRule;
@override@JsonKey(name: 'linked_module') final  String? linkedModule;
@override@JsonKey(name: 'linked_entity_id') final  String? linkedEntityId;
@override@JsonKey(name: 'is_sent') final  bool isSent;
@override@JsonKey(name: 'sent_at') final  DateTime? sentAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReminderCopyWith<_Reminder> get copyWith => __$ReminderCopyWithImpl<_Reminder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReminderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reminder&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.message, message) || other.message == message)&&(identical(other.triggerAt, triggerAt) || other.triggerAt == triggerAt)&&(identical(other.recurrenceRule, recurrenceRule) || other.recurrenceRule == recurrenceRule)&&(identical(other.linkedModule, linkedModule) || other.linkedModule == linkedModule)&&(identical(other.linkedEntityId, linkedEntityId) || other.linkedEntityId == linkedEntityId)&&(identical(other.isSent, isSent) || other.isSent == isSent)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spaceId,createdBy,message,triggerAt,recurrenceRule,linkedModule,linkedEntityId,isSent,sentAt,createdAt,updatedAt);

@override
String toString() {
  return 'Reminder(id: $id, spaceId: $spaceId, createdBy: $createdBy, message: $message, triggerAt: $triggerAt, recurrenceRule: $recurrenceRule, linkedModule: $linkedModule, linkedEntityId: $linkedEntityId, isSent: $isSent, sentAt: $sentAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReminderCopyWith<$Res> implements $ReminderCopyWith<$Res> {
  factory _$ReminderCopyWith(_Reminder value, $Res Function(_Reminder) _then) = __$ReminderCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'created_by') String createdBy, String message,@JsonKey(name: 'trigger_at') DateTime triggerAt,@JsonKey(name: 'recurrence_rule') String? recurrenceRule,@JsonKey(name: 'linked_module') String? linkedModule,@JsonKey(name: 'linked_entity_id') String? linkedEntityId,@JsonKey(name: 'is_sent') bool isSent,@JsonKey(name: 'sent_at') DateTime? sentAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$ReminderCopyWithImpl<$Res>
    implements _$ReminderCopyWith<$Res> {
  __$ReminderCopyWithImpl(this._self, this._then);

  final _Reminder _self;
  final $Res Function(_Reminder) _then;

/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? spaceId = null,Object? createdBy = null,Object? message = null,Object? triggerAt = null,Object? recurrenceRule = freezed,Object? linkedModule = freezed,Object? linkedEntityId = freezed,Object? isSent = null,Object? sentAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Reminder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,triggerAt: null == triggerAt ? _self.triggerAt : triggerAt // ignore: cast_nullable_to_non_nullable
as DateTime,recurrenceRule: freezed == recurrenceRule ? _self.recurrenceRule : recurrenceRule // ignore: cast_nullable_to_non_nullable
as String?,linkedModule: freezed == linkedModule ? _self.linkedModule : linkedModule // ignore: cast_nullable_to_non_nullable
as String?,linkedEntityId: freezed == linkedEntityId ? _self.linkedEntityId : linkedEntityId // ignore: cast_nullable_to_non_nullable
as String?,isSent: null == isSent ? _self.isSent : isSent // ignore: cast_nullable_to_non_nullable
as bool,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
