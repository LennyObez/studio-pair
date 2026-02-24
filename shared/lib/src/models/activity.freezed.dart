// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Activity {

 String get id;@JsonKey(name: 'space_id') String get spaceId;@JsonKey(name: 'created_by') String get createdBy; String get title; String? get description; ActivityCategory get category;@JsonKey(name: 'thumbnail_url') String? get thumbnailUrl;@JsonKey(name: 'trailer_url') String? get trailerUrl;@JsonKey(name: 'external_id') String? get externalId;@JsonKey(name: 'external_source') String? get externalSource; ActivityPrivacy get privacy; ActivityStatus get status; ActivityMode get mode;@JsonKey(name: 'linked_calendar_event_id') String? get linkedCalendarEventId;@JsonKey(name: 'linked_task_id') String? get linkedTaskId;@JsonKey(name: 'completed_at') DateTime? get completedAt;@JsonKey(name: 'completed_notes') String? get completedNotes; Map<String, dynamic>? get metadata;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityCopyWith<Activity> get copyWith => _$ActivityCopyWithImpl<Activity>(this as Activity, _$identity);

  /// Serializes this Activity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Activity&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.trailerUrl, trailerUrl) || other.trailerUrl == trailerUrl)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.externalSource, externalSource) || other.externalSource == externalSource)&&(identical(other.privacy, privacy) || other.privacy == privacy)&&(identical(other.status, status) || other.status == status)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.linkedCalendarEventId, linkedCalendarEventId) || other.linkedCalendarEventId == linkedCalendarEventId)&&(identical(other.linkedTaskId, linkedTaskId) || other.linkedTaskId == linkedTaskId)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.completedNotes, completedNotes) || other.completedNotes == completedNotes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,spaceId,createdBy,title,description,category,thumbnailUrl,trailerUrl,externalId,externalSource,privacy,status,mode,linkedCalendarEventId,linkedTaskId,completedAt,completedNotes,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'Activity(id: $id, spaceId: $spaceId, createdBy: $createdBy, title: $title, description: $description, category: $category, thumbnailUrl: $thumbnailUrl, trailerUrl: $trailerUrl, externalId: $externalId, externalSource: $externalSource, privacy: $privacy, status: $status, mode: $mode, linkedCalendarEventId: $linkedCalendarEventId, linkedTaskId: $linkedTaskId, completedAt: $completedAt, completedNotes: $completedNotes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ActivityCopyWith<$Res>  {
  factory $ActivityCopyWith(Activity value, $Res Function(Activity) _then) = _$ActivityCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'created_by') String createdBy, String title, String? description, ActivityCategory category,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'trailer_url') String? trailerUrl,@JsonKey(name: 'external_id') String? externalId,@JsonKey(name: 'external_source') String? externalSource, ActivityPrivacy privacy, ActivityStatus status, ActivityMode mode,@JsonKey(name: 'linked_calendar_event_id') String? linkedCalendarEventId,@JsonKey(name: 'linked_task_id') String? linkedTaskId,@JsonKey(name: 'completed_at') DateTime? completedAt,@JsonKey(name: 'completed_notes') String? completedNotes, Map<String, dynamic>? metadata,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$ActivityCopyWithImpl<$Res>
    implements $ActivityCopyWith<$Res> {
  _$ActivityCopyWithImpl(this._self, this._then);

  final Activity _self;
  final $Res Function(Activity) _then;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? spaceId = null,Object? createdBy = null,Object? title = null,Object? description = freezed,Object? category = null,Object? thumbnailUrl = freezed,Object? trailerUrl = freezed,Object? externalId = freezed,Object? externalSource = freezed,Object? privacy = null,Object? status = null,Object? mode = null,Object? linkedCalendarEventId = freezed,Object? linkedTaskId = freezed,Object? completedAt = freezed,Object? completedNotes = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ActivityCategory,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,trailerUrl: freezed == trailerUrl ? _self.trailerUrl : trailerUrl // ignore: cast_nullable_to_non_nullable
as String?,externalId: freezed == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String?,externalSource: freezed == externalSource ? _self.externalSource : externalSource // ignore: cast_nullable_to_non_nullable
as String?,privacy: null == privacy ? _self.privacy : privacy // ignore: cast_nullable_to_non_nullable
as ActivityPrivacy,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ActivityStatus,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ActivityMode,linkedCalendarEventId: freezed == linkedCalendarEventId ? _self.linkedCalendarEventId : linkedCalendarEventId // ignore: cast_nullable_to_non_nullable
as String?,linkedTaskId: freezed == linkedTaskId ? _self.linkedTaskId : linkedTaskId // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedNotes: freezed == completedNotes ? _self.completedNotes : completedNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Activity].
extension ActivityPatterns on Activity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Activity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Activity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Activity value)  $default,){
final _that = this;
switch (_that) {
case _Activity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Activity value)?  $default,){
final _that = this;
switch (_that) {
case _Activity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String title,  String? description,  ActivityCategory category, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'trailer_url')  String? trailerUrl, @JsonKey(name: 'external_id')  String? externalId, @JsonKey(name: 'external_source')  String? externalSource,  ActivityPrivacy privacy,  ActivityStatus status,  ActivityMode mode, @JsonKey(name: 'linked_calendar_event_id')  String? linkedCalendarEventId, @JsonKey(name: 'linked_task_id')  String? linkedTaskId, @JsonKey(name: 'completed_at')  DateTime? completedAt, @JsonKey(name: 'completed_notes')  String? completedNotes,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Activity() when $default != null:
return $default(_that.id,_that.spaceId,_that.createdBy,_that.title,_that.description,_that.category,_that.thumbnailUrl,_that.trailerUrl,_that.externalId,_that.externalSource,_that.privacy,_that.status,_that.mode,_that.linkedCalendarEventId,_that.linkedTaskId,_that.completedAt,_that.completedNotes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String title,  String? description,  ActivityCategory category, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'trailer_url')  String? trailerUrl, @JsonKey(name: 'external_id')  String? externalId, @JsonKey(name: 'external_source')  String? externalSource,  ActivityPrivacy privacy,  ActivityStatus status,  ActivityMode mode, @JsonKey(name: 'linked_calendar_event_id')  String? linkedCalendarEventId, @JsonKey(name: 'linked_task_id')  String? linkedTaskId, @JsonKey(name: 'completed_at')  DateTime? completedAt, @JsonKey(name: 'completed_notes')  String? completedNotes,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Activity():
return $default(_that.id,_that.spaceId,_that.createdBy,_that.title,_that.description,_that.category,_that.thumbnailUrl,_that.trailerUrl,_that.externalId,_that.externalSource,_that.privacy,_that.status,_that.mode,_that.linkedCalendarEventId,_that.linkedTaskId,_that.completedAt,_that.completedNotes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String title,  String? description,  ActivityCategory category, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'trailer_url')  String? trailerUrl, @JsonKey(name: 'external_id')  String? externalId, @JsonKey(name: 'external_source')  String? externalSource,  ActivityPrivacy privacy,  ActivityStatus status,  ActivityMode mode, @JsonKey(name: 'linked_calendar_event_id')  String? linkedCalendarEventId, @JsonKey(name: 'linked_task_id')  String? linkedTaskId, @JsonKey(name: 'completed_at')  DateTime? completedAt, @JsonKey(name: 'completed_notes')  String? completedNotes,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Activity() when $default != null:
return $default(_that.id,_that.spaceId,_that.createdBy,_that.title,_that.description,_that.category,_that.thumbnailUrl,_that.trailerUrl,_that.externalId,_that.externalSource,_that.privacy,_that.status,_that.mode,_that.linkedCalendarEventId,_that.linkedTaskId,_that.completedAt,_that.completedNotes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Activity implements Activity {
  const _Activity({required this.id, @JsonKey(name: 'space_id') required this.spaceId, @JsonKey(name: 'created_by') required this.createdBy, required this.title, this.description, required this.category, @JsonKey(name: 'thumbnail_url') this.thumbnailUrl, @JsonKey(name: 'trailer_url') this.trailerUrl, @JsonKey(name: 'external_id') this.externalId, @JsonKey(name: 'external_source') this.externalSource, required this.privacy, required this.status, required this.mode, @JsonKey(name: 'linked_calendar_event_id') this.linkedCalendarEventId, @JsonKey(name: 'linked_task_id') this.linkedTaskId, @JsonKey(name: 'completed_at') this.completedAt, @JsonKey(name: 'completed_notes') this.completedNotes, final  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): _metadata = metadata;
  factory _Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);

@override final  String id;
@override@JsonKey(name: 'space_id') final  String spaceId;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override final  String title;
@override final  String? description;
@override final  ActivityCategory category;
@override@JsonKey(name: 'thumbnail_url') final  String? thumbnailUrl;
@override@JsonKey(name: 'trailer_url') final  String? trailerUrl;
@override@JsonKey(name: 'external_id') final  String? externalId;
@override@JsonKey(name: 'external_source') final  String? externalSource;
@override final  ActivityPrivacy privacy;
@override final  ActivityStatus status;
@override final  ActivityMode mode;
@override@JsonKey(name: 'linked_calendar_event_id') final  String? linkedCalendarEventId;
@override@JsonKey(name: 'linked_task_id') final  String? linkedTaskId;
@override@JsonKey(name: 'completed_at') final  DateTime? completedAt;
@override@JsonKey(name: 'completed_notes') final  String? completedNotes;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityCopyWith<_Activity> get copyWith => __$ActivityCopyWithImpl<_Activity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Activity&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.trailerUrl, trailerUrl) || other.trailerUrl == trailerUrl)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.externalSource, externalSource) || other.externalSource == externalSource)&&(identical(other.privacy, privacy) || other.privacy == privacy)&&(identical(other.status, status) || other.status == status)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.linkedCalendarEventId, linkedCalendarEventId) || other.linkedCalendarEventId == linkedCalendarEventId)&&(identical(other.linkedTaskId, linkedTaskId) || other.linkedTaskId == linkedTaskId)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.completedNotes, completedNotes) || other.completedNotes == completedNotes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,spaceId,createdBy,title,description,category,thumbnailUrl,trailerUrl,externalId,externalSource,privacy,status,mode,linkedCalendarEventId,linkedTaskId,completedAt,completedNotes,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'Activity(id: $id, spaceId: $spaceId, createdBy: $createdBy, title: $title, description: $description, category: $category, thumbnailUrl: $thumbnailUrl, trailerUrl: $trailerUrl, externalId: $externalId, externalSource: $externalSource, privacy: $privacy, status: $status, mode: $mode, linkedCalendarEventId: $linkedCalendarEventId, linkedTaskId: $linkedTaskId, completedAt: $completedAt, completedNotes: $completedNotes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ActivityCopyWith<$Res> implements $ActivityCopyWith<$Res> {
  factory _$ActivityCopyWith(_Activity value, $Res Function(_Activity) _then) = __$ActivityCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'created_by') String createdBy, String title, String? description, ActivityCategory category,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'trailer_url') String? trailerUrl,@JsonKey(name: 'external_id') String? externalId,@JsonKey(name: 'external_source') String? externalSource, ActivityPrivacy privacy, ActivityStatus status, ActivityMode mode,@JsonKey(name: 'linked_calendar_event_id') String? linkedCalendarEventId,@JsonKey(name: 'linked_task_id') String? linkedTaskId,@JsonKey(name: 'completed_at') DateTime? completedAt,@JsonKey(name: 'completed_notes') String? completedNotes, Map<String, dynamic>? metadata,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$ActivityCopyWithImpl<$Res>
    implements _$ActivityCopyWith<$Res> {
  __$ActivityCopyWithImpl(this._self, this._then);

  final _Activity _self;
  final $Res Function(_Activity) _then;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? spaceId = null,Object? createdBy = null,Object? title = null,Object? description = freezed,Object? category = null,Object? thumbnailUrl = freezed,Object? trailerUrl = freezed,Object? externalId = freezed,Object? externalSource = freezed,Object? privacy = null,Object? status = null,Object? mode = null,Object? linkedCalendarEventId = freezed,Object? linkedTaskId = freezed,Object? completedAt = freezed,Object? completedNotes = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Activity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ActivityCategory,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,trailerUrl: freezed == trailerUrl ? _self.trailerUrl : trailerUrl // ignore: cast_nullable_to_non_nullable
as String?,externalId: freezed == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String?,externalSource: freezed == externalSource ? _self.externalSource : externalSource // ignore: cast_nullable_to_non_nullable
as String?,privacy: null == privacy ? _self.privacy : privacy // ignore: cast_nullable_to_non_nullable
as ActivityPrivacy,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ActivityStatus,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ActivityMode,linkedCalendarEventId: freezed == linkedCalendarEventId ? _self.linkedCalendarEventId : linkedCalendarEventId // ignore: cast_nullable_to_non_nullable
as String?,linkedTaskId: freezed == linkedTaskId ? _self.linkedTaskId : linkedTaskId // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedNotes: freezed == completedNotes ? _self.completedNotes : completedNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
