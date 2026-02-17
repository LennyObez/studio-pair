// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalendarEvent {

 String get id;@JsonKey(name: 'space_id') String get spaceId;@JsonKey(name: 'created_by') String get createdBy; String get title; String? get location;@JsonKey(name: 'event_type') EventType get eventType;@JsonKey(name: 'all_day') bool get allDay;@JsonKey(name: 'start_at') DateTime get startAt;@JsonKey(name: 'end_at') DateTime get endAt;@JsonKey(name: 'recurrence_rule') String? get recurrenceRule;@JsonKey(name: 'source_module') String? get sourceModule;@JsonKey(name: 'source_entity_id') String? get sourceEntityId;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarEventCopyWith<CalendarEvent> get copyWith => _$CalendarEventCopyWithImpl<CalendarEvent>(this as CalendarEvent, _$identity);

  /// Serializes this CalendarEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.title, title) || other.title == title)&&(identical(other.location, location) || other.location == location)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.allDay, allDay) || other.allDay == allDay)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.recurrenceRule, recurrenceRule) || other.recurrenceRule == recurrenceRule)&&(identical(other.sourceModule, sourceModule) || other.sourceModule == sourceModule)&&(identical(other.sourceEntityId, sourceEntityId) || other.sourceEntityId == sourceEntityId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spaceId,createdBy,title,location,eventType,allDay,startAt,endAt,recurrenceRule,sourceModule,sourceEntityId,createdAt,updatedAt);

@override
String toString() {
  return 'CalendarEvent(id: $id, spaceId: $spaceId, createdBy: $createdBy, title: $title, location: $location, eventType: $eventType, allDay: $allDay, startAt: $startAt, endAt: $endAt, recurrenceRule: $recurrenceRule, sourceModule: $sourceModule, sourceEntityId: $sourceEntityId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CalendarEventCopyWith<$Res>  {
  factory $CalendarEventCopyWith(CalendarEvent value, $Res Function(CalendarEvent) _then) = _$CalendarEventCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'created_by') String createdBy, String title, String? location,@JsonKey(name: 'event_type') EventType eventType,@JsonKey(name: 'all_day') bool allDay,@JsonKey(name: 'start_at') DateTime startAt,@JsonKey(name: 'end_at') DateTime endAt,@JsonKey(name: 'recurrence_rule') String? recurrenceRule,@JsonKey(name: 'source_module') String? sourceModule,@JsonKey(name: 'source_entity_id') String? sourceEntityId,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$CalendarEventCopyWithImpl<$Res>
    implements $CalendarEventCopyWith<$Res> {
  _$CalendarEventCopyWithImpl(this._self, this._then);

  final CalendarEvent _self;
  final $Res Function(CalendarEvent) _then;

/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? spaceId = null,Object? createdBy = null,Object? title = null,Object? location = freezed,Object? eventType = null,Object? allDay = null,Object? startAt = null,Object? endAt = null,Object? recurrenceRule = freezed,Object? sourceModule = freezed,Object? sourceEntityId = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as EventType,allDay: null == allDay ? _self.allDay : allDay // ignore: cast_nullable_to_non_nullable
as bool,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,recurrenceRule: freezed == recurrenceRule ? _self.recurrenceRule : recurrenceRule // ignore: cast_nullable_to_non_nullable
as String?,sourceModule: freezed == sourceModule ? _self.sourceModule : sourceModule // ignore: cast_nullable_to_non_nullable
as String?,sourceEntityId: freezed == sourceEntityId ? _self.sourceEntityId : sourceEntityId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarEvent].
extension CalendarEventPatterns on CalendarEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarEvent value)  $default,){
final _that = this;
switch (_that) {
case _CalendarEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarEvent value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String title,  String? location, @JsonKey(name: 'event_type')  EventType eventType, @JsonKey(name: 'all_day')  bool allDay, @JsonKey(name: 'start_at')  DateTime startAt, @JsonKey(name: 'end_at')  DateTime endAt, @JsonKey(name: 'recurrence_rule')  String? recurrenceRule, @JsonKey(name: 'source_module')  String? sourceModule, @JsonKey(name: 'source_entity_id')  String? sourceEntityId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarEvent() when $default != null:
return $default(_that.id,_that.spaceId,_that.createdBy,_that.title,_that.location,_that.eventType,_that.allDay,_that.startAt,_that.endAt,_that.recurrenceRule,_that.sourceModule,_that.sourceEntityId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String title,  String? location, @JsonKey(name: 'event_type')  EventType eventType, @JsonKey(name: 'all_day')  bool allDay, @JsonKey(name: 'start_at')  DateTime startAt, @JsonKey(name: 'end_at')  DateTime endAt, @JsonKey(name: 'recurrence_rule')  String? recurrenceRule, @JsonKey(name: 'source_module')  String? sourceModule, @JsonKey(name: 'source_entity_id')  String? sourceEntityId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CalendarEvent():
return $default(_that.id,_that.spaceId,_that.createdBy,_that.title,_that.location,_that.eventType,_that.allDay,_that.startAt,_that.endAt,_that.recurrenceRule,_that.sourceModule,_that.sourceEntityId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String title,  String? location, @JsonKey(name: 'event_type')  EventType eventType, @JsonKey(name: 'all_day')  bool allDay, @JsonKey(name: 'start_at')  DateTime startAt, @JsonKey(name: 'end_at')  DateTime endAt, @JsonKey(name: 'recurrence_rule')  String? recurrenceRule, @JsonKey(name: 'source_module')  String? sourceModule, @JsonKey(name: 'source_entity_id')  String? sourceEntityId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CalendarEvent() when $default != null:
return $default(_that.id,_that.spaceId,_that.createdBy,_that.title,_that.location,_that.eventType,_that.allDay,_that.startAt,_that.endAt,_that.recurrenceRule,_that.sourceModule,_that.sourceEntityId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalendarEvent implements CalendarEvent {
  const _CalendarEvent({required this.id, @JsonKey(name: 'space_id') required this.spaceId, @JsonKey(name: 'created_by') required this.createdBy, required this.title, this.location, @JsonKey(name: 'event_type') required this.eventType, @JsonKey(name: 'all_day') required this.allDay, @JsonKey(name: 'start_at') required this.startAt, @JsonKey(name: 'end_at') required this.endAt, @JsonKey(name: 'recurrence_rule') this.recurrenceRule, @JsonKey(name: 'source_module') this.sourceModule, @JsonKey(name: 'source_entity_id') this.sourceEntityId, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _CalendarEvent.fromJson(Map<String, dynamic> json) => _$CalendarEventFromJson(json);

@override final  String id;
@override@JsonKey(name: 'space_id') final  String spaceId;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override final  String title;
@override final  String? location;
@override@JsonKey(name: 'event_type') final  EventType eventType;
@override@JsonKey(name: 'all_day') final  bool allDay;
@override@JsonKey(name: 'start_at') final  DateTime startAt;
@override@JsonKey(name: 'end_at') final  DateTime endAt;
@override@JsonKey(name: 'recurrence_rule') final  String? recurrenceRule;
@override@JsonKey(name: 'source_module') final  String? sourceModule;
@override@JsonKey(name: 'source_entity_id') final  String? sourceEntityId;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarEventCopyWith<_CalendarEvent> get copyWith => __$CalendarEventCopyWithImpl<_CalendarEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.title, title) || other.title == title)&&(identical(other.location, location) || other.location == location)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.allDay, allDay) || other.allDay == allDay)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.recurrenceRule, recurrenceRule) || other.recurrenceRule == recurrenceRule)&&(identical(other.sourceModule, sourceModule) || other.sourceModule == sourceModule)&&(identical(other.sourceEntityId, sourceEntityId) || other.sourceEntityId == sourceEntityId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spaceId,createdBy,title,location,eventType,allDay,startAt,endAt,recurrenceRule,sourceModule,sourceEntityId,createdAt,updatedAt);

@override
String toString() {
  return 'CalendarEvent(id: $id, spaceId: $spaceId, createdBy: $createdBy, title: $title, location: $location, eventType: $eventType, allDay: $allDay, startAt: $startAt, endAt: $endAt, recurrenceRule: $recurrenceRule, sourceModule: $sourceModule, sourceEntityId: $sourceEntityId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CalendarEventCopyWith<$Res> implements $CalendarEventCopyWith<$Res> {
  factory _$CalendarEventCopyWith(_CalendarEvent value, $Res Function(_CalendarEvent) _then) = __$CalendarEventCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'created_by') String createdBy, String title, String? location,@JsonKey(name: 'event_type') EventType eventType,@JsonKey(name: 'all_day') bool allDay,@JsonKey(name: 'start_at') DateTime startAt,@JsonKey(name: 'end_at') DateTime endAt,@JsonKey(name: 'recurrence_rule') String? recurrenceRule,@JsonKey(name: 'source_module') String? sourceModule,@JsonKey(name: 'source_entity_id') String? sourceEntityId,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$CalendarEventCopyWithImpl<$Res>
    implements _$CalendarEventCopyWith<$Res> {
  __$CalendarEventCopyWithImpl(this._self, this._then);

  final _CalendarEvent _self;
  final $Res Function(_CalendarEvent) _then;

/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? spaceId = null,Object? createdBy = null,Object? title = null,Object? location = freezed,Object? eventType = null,Object? allDay = null,Object? startAt = null,Object? endAt = null,Object? recurrenceRule = freezed,Object? sourceModule = freezed,Object? sourceEntityId = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CalendarEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as EventType,allDay: null == allDay ? _self.allDay : allDay // ignore: cast_nullable_to_non_nullable
as bool,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,recurrenceRule: freezed == recurrenceRule ? _self.recurrenceRule : recurrenceRule // ignore: cast_nullable_to_non_nullable
as String?,sourceModule: freezed == sourceModule ? _self.sourceModule : sourceModule // ignore: cast_nullable_to_non_nullable
as String?,sourceEntityId: freezed == sourceEntityId ? _self.sourceEntityId : sourceEntityId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
