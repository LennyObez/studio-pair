// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HealthProfile {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'space_id') String get spaceId;@JsonKey(name: 'height_cm') double? get heightCm;@JsonKey(name: 'weight_kg') double? get weightKg;@JsonKey(name: 'top_size') String? get topSize;@JsonKey(name: 'bottom_size') String? get bottomSize;@JsonKey(name: 'underwear_size') String? get underwearSize;@JsonKey(name: 'shoe_size') String? get shoeSize;@JsonKey(name: 'size_system') SizeSystem? get sizeSystem;@JsonKey(name: 'ring_size') String? get ringSize;@JsonKey(name: 'ring_size_system') String? get ringSizeSystem;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of HealthProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthProfileCopyWith<HealthProfile> get copyWith => _$HealthProfileCopyWithImpl<HealthProfile>(this as HealthProfile, _$identity);

  /// Serializes this HealthProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.topSize, topSize) || other.topSize == topSize)&&(identical(other.bottomSize, bottomSize) || other.bottomSize == bottomSize)&&(identical(other.underwearSize, underwearSize) || other.underwearSize == underwearSize)&&(identical(other.shoeSize, shoeSize) || other.shoeSize == shoeSize)&&(identical(other.sizeSystem, sizeSystem) || other.sizeSystem == sizeSystem)&&(identical(other.ringSize, ringSize) || other.ringSize == ringSize)&&(identical(other.ringSizeSystem, ringSizeSystem) || other.ringSizeSystem == ringSizeSystem)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,spaceId,heightCm,weightKg,topSize,bottomSize,underwearSize,shoeSize,sizeSystem,ringSize,ringSizeSystem,createdAt,updatedAt);

@override
String toString() {
  return 'HealthProfile(id: $id, userId: $userId, spaceId: $spaceId, heightCm: $heightCm, weightKg: $weightKg, topSize: $topSize, bottomSize: $bottomSize, underwearSize: $underwearSize, shoeSize: $shoeSize, sizeSystem: $sizeSystem, ringSize: $ringSize, ringSizeSystem: $ringSizeSystem, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $HealthProfileCopyWith<$Res>  {
  factory $HealthProfileCopyWith(HealthProfile value, $Res Function(HealthProfile) _then) = _$HealthProfileCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'height_cm') double? heightCm,@JsonKey(name: 'weight_kg') double? weightKg,@JsonKey(name: 'top_size') String? topSize,@JsonKey(name: 'bottom_size') String? bottomSize,@JsonKey(name: 'underwear_size') String? underwearSize,@JsonKey(name: 'shoe_size') String? shoeSize,@JsonKey(name: 'size_system') SizeSystem? sizeSystem,@JsonKey(name: 'ring_size') String? ringSize,@JsonKey(name: 'ring_size_system') String? ringSizeSystem,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$HealthProfileCopyWithImpl<$Res>
    implements $HealthProfileCopyWith<$Res> {
  _$HealthProfileCopyWithImpl(this._self, this._then);

  final HealthProfile _self;
  final $Res Function(HealthProfile) _then;

/// Create a copy of HealthProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? spaceId = null,Object? heightCm = freezed,Object? weightKg = freezed,Object? topSize = freezed,Object? bottomSize = freezed,Object? underwearSize = freezed,Object? shoeSize = freezed,Object? sizeSystem = freezed,Object? ringSize = freezed,Object? ringSizeSystem = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,topSize: freezed == topSize ? _self.topSize : topSize // ignore: cast_nullable_to_non_nullable
as String?,bottomSize: freezed == bottomSize ? _self.bottomSize : bottomSize // ignore: cast_nullable_to_non_nullable
as String?,underwearSize: freezed == underwearSize ? _self.underwearSize : underwearSize // ignore: cast_nullable_to_non_nullable
as String?,shoeSize: freezed == shoeSize ? _self.shoeSize : shoeSize // ignore: cast_nullable_to_non_nullable
as String?,sizeSystem: freezed == sizeSystem ? _self.sizeSystem : sizeSystem // ignore: cast_nullable_to_non_nullable
as SizeSystem?,ringSize: freezed == ringSize ? _self.ringSize : ringSize // ignore: cast_nullable_to_non_nullable
as String?,ringSizeSystem: freezed == ringSizeSystem ? _self.ringSizeSystem : ringSizeSystem // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthProfile].
extension HealthProfilePatterns on HealthProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthProfile value)  $default,){
final _that = this;
switch (_that) {
case _HealthProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthProfile value)?  $default,){
final _that = this;
switch (_that) {
case _HealthProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'height_cm')  double? heightCm, @JsonKey(name: 'weight_kg')  double? weightKg, @JsonKey(name: 'top_size')  String? topSize, @JsonKey(name: 'bottom_size')  String? bottomSize, @JsonKey(name: 'underwear_size')  String? underwearSize, @JsonKey(name: 'shoe_size')  String? shoeSize, @JsonKey(name: 'size_system')  SizeSystem? sizeSystem, @JsonKey(name: 'ring_size')  String? ringSize, @JsonKey(name: 'ring_size_system')  String? ringSizeSystem, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthProfile() when $default != null:
return $default(_that.id,_that.userId,_that.spaceId,_that.heightCm,_that.weightKg,_that.topSize,_that.bottomSize,_that.underwearSize,_that.shoeSize,_that.sizeSystem,_that.ringSize,_that.ringSizeSystem,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'height_cm')  double? heightCm, @JsonKey(name: 'weight_kg')  double? weightKg, @JsonKey(name: 'top_size')  String? topSize, @JsonKey(name: 'bottom_size')  String? bottomSize, @JsonKey(name: 'underwear_size')  String? underwearSize, @JsonKey(name: 'shoe_size')  String? shoeSize, @JsonKey(name: 'size_system')  SizeSystem? sizeSystem, @JsonKey(name: 'ring_size')  String? ringSize, @JsonKey(name: 'ring_size_system')  String? ringSizeSystem, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _HealthProfile():
return $default(_that.id,_that.userId,_that.spaceId,_that.heightCm,_that.weightKg,_that.topSize,_that.bottomSize,_that.underwearSize,_that.shoeSize,_that.sizeSystem,_that.ringSize,_that.ringSizeSystem,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'height_cm')  double? heightCm, @JsonKey(name: 'weight_kg')  double? weightKg, @JsonKey(name: 'top_size')  String? topSize, @JsonKey(name: 'bottom_size')  String? bottomSize, @JsonKey(name: 'underwear_size')  String? underwearSize, @JsonKey(name: 'shoe_size')  String? shoeSize, @JsonKey(name: 'size_system')  SizeSystem? sizeSystem, @JsonKey(name: 'ring_size')  String? ringSize, @JsonKey(name: 'ring_size_system')  String? ringSizeSystem, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _HealthProfile() when $default != null:
return $default(_that.id,_that.userId,_that.spaceId,_that.heightCm,_that.weightKg,_that.topSize,_that.bottomSize,_that.underwearSize,_that.shoeSize,_that.sizeSystem,_that.ringSize,_that.ringSizeSystem,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthProfile implements HealthProfile {
  const _HealthProfile({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'space_id') required this.spaceId, @JsonKey(name: 'height_cm') this.heightCm, @JsonKey(name: 'weight_kg') this.weightKg, @JsonKey(name: 'top_size') this.topSize, @JsonKey(name: 'bottom_size') this.bottomSize, @JsonKey(name: 'underwear_size') this.underwearSize, @JsonKey(name: 'shoe_size') this.shoeSize, @JsonKey(name: 'size_system') this.sizeSystem, @JsonKey(name: 'ring_size') this.ringSize, @JsonKey(name: 'ring_size_system') this.ringSizeSystem, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _HealthProfile.fromJson(Map<String, dynamic> json) => _$HealthProfileFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'space_id') final  String spaceId;
@override@JsonKey(name: 'height_cm') final  double? heightCm;
@override@JsonKey(name: 'weight_kg') final  double? weightKg;
@override@JsonKey(name: 'top_size') final  String? topSize;
@override@JsonKey(name: 'bottom_size') final  String? bottomSize;
@override@JsonKey(name: 'underwear_size') final  String? underwearSize;
@override@JsonKey(name: 'shoe_size') final  String? shoeSize;
@override@JsonKey(name: 'size_system') final  SizeSystem? sizeSystem;
@override@JsonKey(name: 'ring_size') final  String? ringSize;
@override@JsonKey(name: 'ring_size_system') final  String? ringSizeSystem;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of HealthProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthProfileCopyWith<_HealthProfile> get copyWith => __$HealthProfileCopyWithImpl<_HealthProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.topSize, topSize) || other.topSize == topSize)&&(identical(other.bottomSize, bottomSize) || other.bottomSize == bottomSize)&&(identical(other.underwearSize, underwearSize) || other.underwearSize == underwearSize)&&(identical(other.shoeSize, shoeSize) || other.shoeSize == shoeSize)&&(identical(other.sizeSystem, sizeSystem) || other.sizeSystem == sizeSystem)&&(identical(other.ringSize, ringSize) || other.ringSize == ringSize)&&(identical(other.ringSizeSystem, ringSizeSystem) || other.ringSizeSystem == ringSizeSystem)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,spaceId,heightCm,weightKg,topSize,bottomSize,underwearSize,shoeSize,sizeSystem,ringSize,ringSizeSystem,createdAt,updatedAt);

@override
String toString() {
  return 'HealthProfile(id: $id, userId: $userId, spaceId: $spaceId, heightCm: $heightCm, weightKg: $weightKg, topSize: $topSize, bottomSize: $bottomSize, underwearSize: $underwearSize, shoeSize: $shoeSize, sizeSystem: $sizeSystem, ringSize: $ringSize, ringSizeSystem: $ringSizeSystem, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$HealthProfileCopyWith<$Res> implements $HealthProfileCopyWith<$Res> {
  factory _$HealthProfileCopyWith(_HealthProfile value, $Res Function(_HealthProfile) _then) = __$HealthProfileCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'height_cm') double? heightCm,@JsonKey(name: 'weight_kg') double? weightKg,@JsonKey(name: 'top_size') String? topSize,@JsonKey(name: 'bottom_size') String? bottomSize,@JsonKey(name: 'underwear_size') String? underwearSize,@JsonKey(name: 'shoe_size') String? shoeSize,@JsonKey(name: 'size_system') SizeSystem? sizeSystem,@JsonKey(name: 'ring_size') String? ringSize,@JsonKey(name: 'ring_size_system') String? ringSizeSystem,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$HealthProfileCopyWithImpl<$Res>
    implements _$HealthProfileCopyWith<$Res> {
  __$HealthProfileCopyWithImpl(this._self, this._then);

  final _HealthProfile _self;
  final $Res Function(_HealthProfile) _then;

/// Create a copy of HealthProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? spaceId = null,Object? heightCm = freezed,Object? weightKg = freezed,Object? topSize = freezed,Object? bottomSize = freezed,Object? underwearSize = freezed,Object? shoeSize = freezed,Object? sizeSystem = freezed,Object? ringSize = freezed,Object? ringSizeSystem = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_HealthProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,topSize: freezed == topSize ? _self.topSize : topSize // ignore: cast_nullable_to_non_nullable
as String?,bottomSize: freezed == bottomSize ? _self.bottomSize : bottomSize // ignore: cast_nullable_to_non_nullable
as String?,underwearSize: freezed == underwearSize ? _self.underwearSize : underwearSize // ignore: cast_nullable_to_non_nullable
as String?,shoeSize: freezed == shoeSize ? _self.shoeSize : shoeSize // ignore: cast_nullable_to_non_nullable
as String?,sizeSystem: freezed == sizeSystem ? _self.sizeSystem : sizeSystem // ignore: cast_nullable_to_non_nullable
as SizeSystem?,ringSize: freezed == ringSize ? _self.ringSize : ringSize // ignore: cast_nullable_to_non_nullable
as String?,ringSizeSystem: freezed == ringSizeSystem ? _self.ringSizeSystem : ringSizeSystem // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
