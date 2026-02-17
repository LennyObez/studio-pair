// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_share.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationShare {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'space_id') String get spaceId; double get latitude; double get longitude; LocationShareType get type;@JsonKey(name: 'expires_at') DateTime? get expiresAt;@JsonKey(name: 'eta_destination') String? get etaDestination;@JsonKey(name: 'eta_minutes') int? get etaMinutes;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of LocationShare
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationShareCopyWith<LocationShare> get copyWith => _$LocationShareCopyWithImpl<LocationShare>(this as LocationShare, _$identity);

  /// Serializes this LocationShare to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationShare&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.type, type) || other.type == type)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.etaDestination, etaDestination) || other.etaDestination == etaDestination)&&(identical(other.etaMinutes, etaMinutes) || other.etaMinutes == etaMinutes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,spaceId,latitude,longitude,type,expiresAt,etaDestination,etaMinutes,createdAt);

@override
String toString() {
  return 'LocationShare(id: $id, userId: $userId, spaceId: $spaceId, latitude: $latitude, longitude: $longitude, type: $type, expiresAt: $expiresAt, etaDestination: $etaDestination, etaMinutes: $etaMinutes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $LocationShareCopyWith<$Res>  {
  factory $LocationShareCopyWith(LocationShare value, $Res Function(LocationShare) _then) = _$LocationShareCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'space_id') String spaceId, double latitude, double longitude, LocationShareType type,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'eta_destination') String? etaDestination,@JsonKey(name: 'eta_minutes') int? etaMinutes,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$LocationShareCopyWithImpl<$Res>
    implements $LocationShareCopyWith<$Res> {
  _$LocationShareCopyWithImpl(this._self, this._then);

  final LocationShare _self;
  final $Res Function(LocationShare) _then;

/// Create a copy of LocationShare
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? spaceId = null,Object? latitude = null,Object? longitude = null,Object? type = null,Object? expiresAt = freezed,Object? etaDestination = freezed,Object? etaMinutes = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LocationShareType,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,etaDestination: freezed == etaDestination ? _self.etaDestination : etaDestination // ignore: cast_nullable_to_non_nullable
as String?,etaMinutes: freezed == etaMinutes ? _self.etaMinutes : etaMinutes // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationShare].
extension LocationSharePatterns on LocationShare {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationShare value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationShare() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationShare value)  $default,){
final _that = this;
switch (_that) {
case _LocationShare():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationShare value)?  $default,){
final _that = this;
switch (_that) {
case _LocationShare() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'space_id')  String spaceId,  double latitude,  double longitude,  LocationShareType type, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'eta_destination')  String? etaDestination, @JsonKey(name: 'eta_minutes')  int? etaMinutes, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationShare() when $default != null:
return $default(_that.id,_that.userId,_that.spaceId,_that.latitude,_that.longitude,_that.type,_that.expiresAt,_that.etaDestination,_that.etaMinutes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'space_id')  String spaceId,  double latitude,  double longitude,  LocationShareType type, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'eta_destination')  String? etaDestination, @JsonKey(name: 'eta_minutes')  int? etaMinutes, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _LocationShare():
return $default(_that.id,_that.userId,_that.spaceId,_that.latitude,_that.longitude,_that.type,_that.expiresAt,_that.etaDestination,_that.etaMinutes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'space_id')  String spaceId,  double latitude,  double longitude,  LocationShareType type, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'eta_destination')  String? etaDestination, @JsonKey(name: 'eta_minutes')  int? etaMinutes, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LocationShare() when $default != null:
return $default(_that.id,_that.userId,_that.spaceId,_that.latitude,_that.longitude,_that.type,_that.expiresAt,_that.etaDestination,_that.etaMinutes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocationShare implements LocationShare {
  const _LocationShare({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'space_id') required this.spaceId, required this.latitude, required this.longitude, required this.type, @JsonKey(name: 'expires_at') this.expiresAt, @JsonKey(name: 'eta_destination') this.etaDestination, @JsonKey(name: 'eta_minutes') this.etaMinutes, @JsonKey(name: 'created_at') required this.createdAt});
  factory _LocationShare.fromJson(Map<String, dynamic> json) => _$LocationShareFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'space_id') final  String spaceId;
@override final  double latitude;
@override final  double longitude;
@override final  LocationShareType type;
@override@JsonKey(name: 'expires_at') final  DateTime? expiresAt;
@override@JsonKey(name: 'eta_destination') final  String? etaDestination;
@override@JsonKey(name: 'eta_minutes') final  int? etaMinutes;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of LocationShare
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationShareCopyWith<_LocationShare> get copyWith => __$LocationShareCopyWithImpl<_LocationShare>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationShareToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationShare&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.type, type) || other.type == type)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.etaDestination, etaDestination) || other.etaDestination == etaDestination)&&(identical(other.etaMinutes, etaMinutes) || other.etaMinutes == etaMinutes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,spaceId,latitude,longitude,type,expiresAt,etaDestination,etaMinutes,createdAt);

@override
String toString() {
  return 'LocationShare(id: $id, userId: $userId, spaceId: $spaceId, latitude: $latitude, longitude: $longitude, type: $type, expiresAt: $expiresAt, etaDestination: $etaDestination, etaMinutes: $etaMinutes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LocationShareCopyWith<$Res> implements $LocationShareCopyWith<$Res> {
  factory _$LocationShareCopyWith(_LocationShare value, $Res Function(_LocationShare) _then) = __$LocationShareCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'space_id') String spaceId, double latitude, double longitude, LocationShareType type,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'eta_destination') String? etaDestination,@JsonKey(name: 'eta_minutes') int? etaMinutes,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$LocationShareCopyWithImpl<$Res>
    implements _$LocationShareCopyWith<$Res> {
  __$LocationShareCopyWithImpl(this._self, this._then);

  final _LocationShare _self;
  final $Res Function(_LocationShare) _then;

/// Create a copy of LocationShare
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? spaceId = null,Object? latitude = null,Object? longitude = null,Object? type = null,Object? expiresAt = freezed,Object? etaDestination = freezed,Object? etaMinutes = freezed,Object? createdAt = null,}) {
  return _then(_LocationShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LocationShareType,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,etaDestination: freezed == etaDestination ? _self.etaDestination : etaDestination // ignore: cast_nullable_to_non_nullable
as String?,etaMinutes: freezed == etaMinutes ? _self.etaMinutes : etaMinutes // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
