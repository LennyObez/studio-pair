// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memory.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Memory {

 String get id;@JsonKey(name: 'space_id') String get spaceId;@JsonKey(name: 'created_by') String get createdBy; String get title; DateTime? get date; String? get location;@JsonKey(name: 'location_lat') double? get locationLat;@JsonKey(name: 'location_lng') double? get locationLng; String? get description;@JsonKey(name: 'linked_activity_id') String? get linkedActivityId;@JsonKey(name: 'is_milestone') bool get isMilestone;@JsonKey(name: 'milestone_type') String? get milestoneType;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of Memory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemoryCopyWith<Memory> get copyWith => _$MemoryCopyWithImpl<Memory>(this as Memory, _$identity);

  /// Serializes this Memory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Memory&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.location, location) || other.location == location)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng)&&(identical(other.description, description) || other.description == description)&&(identical(other.linkedActivityId, linkedActivityId) || other.linkedActivityId == linkedActivityId)&&(identical(other.isMilestone, isMilestone) || other.isMilestone == isMilestone)&&(identical(other.milestoneType, milestoneType) || other.milestoneType == milestoneType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spaceId,createdBy,title,date,location,locationLat,locationLng,description,linkedActivityId,isMilestone,milestoneType,createdAt,updatedAt);

@override
String toString() {
  return 'Memory(id: $id, spaceId: $spaceId, createdBy: $createdBy, title: $title, date: $date, location: $location, locationLat: $locationLat, locationLng: $locationLng, description: $description, linkedActivityId: $linkedActivityId, isMilestone: $isMilestone, milestoneType: $milestoneType, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MemoryCopyWith<$Res>  {
  factory $MemoryCopyWith(Memory value, $Res Function(Memory) _then) = _$MemoryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'created_by') String createdBy, String title, DateTime? date, String? location,@JsonKey(name: 'location_lat') double? locationLat,@JsonKey(name: 'location_lng') double? locationLng, String? description,@JsonKey(name: 'linked_activity_id') String? linkedActivityId,@JsonKey(name: 'is_milestone') bool isMilestone,@JsonKey(name: 'milestone_type') String? milestoneType,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$MemoryCopyWithImpl<$Res>
    implements $MemoryCopyWith<$Res> {
  _$MemoryCopyWithImpl(this._self, this._then);

  final Memory _self;
  final $Res Function(Memory) _then;

/// Create a copy of Memory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? spaceId = null,Object? createdBy = null,Object? title = null,Object? date = freezed,Object? location = freezed,Object? locationLat = freezed,Object? locationLng = freezed,Object? description = freezed,Object? linkedActivityId = freezed,Object? isMilestone = null,Object? milestoneType = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,linkedActivityId: freezed == linkedActivityId ? _self.linkedActivityId : linkedActivityId // ignore: cast_nullable_to_non_nullable
as String?,isMilestone: null == isMilestone ? _self.isMilestone : isMilestone // ignore: cast_nullable_to_non_nullable
as bool,milestoneType: freezed == milestoneType ? _self.milestoneType : milestoneType // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Memory].
extension MemoryPatterns on Memory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Memory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Memory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Memory value)  $default,){
final _that = this;
switch (_that) {
case _Memory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Memory value)?  $default,){
final _that = this;
switch (_that) {
case _Memory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String title,  DateTime? date,  String? location, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng,  String? description, @JsonKey(name: 'linked_activity_id')  String? linkedActivityId, @JsonKey(name: 'is_milestone')  bool isMilestone, @JsonKey(name: 'milestone_type')  String? milestoneType, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Memory() when $default != null:
return $default(_that.id,_that.spaceId,_that.createdBy,_that.title,_that.date,_that.location,_that.locationLat,_that.locationLng,_that.description,_that.linkedActivityId,_that.isMilestone,_that.milestoneType,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String title,  DateTime? date,  String? location, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng,  String? description, @JsonKey(name: 'linked_activity_id')  String? linkedActivityId, @JsonKey(name: 'is_milestone')  bool isMilestone, @JsonKey(name: 'milestone_type')  String? milestoneType, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Memory():
return $default(_that.id,_that.spaceId,_that.createdBy,_that.title,_that.date,_that.location,_that.locationLat,_that.locationLng,_that.description,_that.linkedActivityId,_that.isMilestone,_that.milestoneType,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy,  String title,  DateTime? date,  String? location, @JsonKey(name: 'location_lat')  double? locationLat, @JsonKey(name: 'location_lng')  double? locationLng,  String? description, @JsonKey(name: 'linked_activity_id')  String? linkedActivityId, @JsonKey(name: 'is_milestone')  bool isMilestone, @JsonKey(name: 'milestone_type')  String? milestoneType, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Memory() when $default != null:
return $default(_that.id,_that.spaceId,_that.createdBy,_that.title,_that.date,_that.location,_that.locationLat,_that.locationLng,_that.description,_that.linkedActivityId,_that.isMilestone,_that.milestoneType,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Memory implements Memory {
  const _Memory({required this.id, @JsonKey(name: 'space_id') required this.spaceId, @JsonKey(name: 'created_by') required this.createdBy, required this.title, this.date, this.location, @JsonKey(name: 'location_lat') this.locationLat, @JsonKey(name: 'location_lng') this.locationLng, this.description, @JsonKey(name: 'linked_activity_id') this.linkedActivityId, @JsonKey(name: 'is_milestone') required this.isMilestone, @JsonKey(name: 'milestone_type') this.milestoneType, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _Memory.fromJson(Map<String, dynamic> json) => _$MemoryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'space_id') final  String spaceId;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override final  String title;
@override final  DateTime? date;
@override final  String? location;
@override@JsonKey(name: 'location_lat') final  double? locationLat;
@override@JsonKey(name: 'location_lng') final  double? locationLng;
@override final  String? description;
@override@JsonKey(name: 'linked_activity_id') final  String? linkedActivityId;
@override@JsonKey(name: 'is_milestone') final  bool isMilestone;
@override@JsonKey(name: 'milestone_type') final  String? milestoneType;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of Memory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemoryCopyWith<_Memory> get copyWith => __$MemoryCopyWithImpl<_Memory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Memory&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.location, location) || other.location == location)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng)&&(identical(other.description, description) || other.description == description)&&(identical(other.linkedActivityId, linkedActivityId) || other.linkedActivityId == linkedActivityId)&&(identical(other.isMilestone, isMilestone) || other.isMilestone == isMilestone)&&(identical(other.milestoneType, milestoneType) || other.milestoneType == milestoneType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spaceId,createdBy,title,date,location,locationLat,locationLng,description,linkedActivityId,isMilestone,milestoneType,createdAt,updatedAt);

@override
String toString() {
  return 'Memory(id: $id, spaceId: $spaceId, createdBy: $createdBy, title: $title, date: $date, location: $location, locationLat: $locationLat, locationLng: $locationLng, description: $description, linkedActivityId: $linkedActivityId, isMilestone: $isMilestone, milestoneType: $milestoneType, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MemoryCopyWith<$Res> implements $MemoryCopyWith<$Res> {
  factory _$MemoryCopyWith(_Memory value, $Res Function(_Memory) _then) = __$MemoryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'created_by') String createdBy, String title, DateTime? date, String? location,@JsonKey(name: 'location_lat') double? locationLat,@JsonKey(name: 'location_lng') double? locationLng, String? description,@JsonKey(name: 'linked_activity_id') String? linkedActivityId,@JsonKey(name: 'is_milestone') bool isMilestone,@JsonKey(name: 'milestone_type') String? milestoneType,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$MemoryCopyWithImpl<$Res>
    implements _$MemoryCopyWith<$Res> {
  __$MemoryCopyWithImpl(this._self, this._then);

  final _Memory _self;
  final $Res Function(_Memory) _then;

/// Create a copy of Memory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? spaceId = null,Object? createdBy = null,Object? title = null,Object? date = freezed,Object? location = freezed,Object? locationLat = freezed,Object? locationLng = freezed,Object? description = freezed,Object? linkedActivityId = freezed,Object? isMilestone = null,Object? milestoneType = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Memory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,linkedActivityId: freezed == linkedActivityId ? _self.linkedActivityId : linkedActivityId // ignore: cast_nullable_to_non_nullable
as String?,isMilestone: null == isMilestone ? _self.isMilestone : isMilestone // ignore: cast_nullable_to_non_nullable
as bool,milestoneType: freezed == milestoneType ? _self.milestoneType : milestoneType // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
