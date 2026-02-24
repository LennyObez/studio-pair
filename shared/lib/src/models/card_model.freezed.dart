// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CardModel {

 String get id;@JsonKey(name: 'space_id') String get spaceId;@JsonKey(name: 'created_by') String get createdBy;@JsonKey(name: 'card_type') CardType get cardType;@JsonKey(name: 'display_name') String get displayName; CardProvider? get provider;@JsonKey(name: 'last_four') String? get lastFour;@JsonKey(name: 'expiry_month') int? get expiryMonth;@JsonKey(name: 'expiry_year') int? get expiryYear;@JsonKey(name: 'card_color') String? get cardColor;@JsonKey(name: 'loyalty_store_name') String? get loyaltyStoreName;@JsonKey(name: 'loyalty_store_logo_url') String? get loyaltyStoreLogoUrl;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardModelCopyWith<CardModel> get copyWith => _$CardModelCopyWithImpl<CardModel>(this as CardModel, _$identity);

  /// Serializes this CardModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardModel&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.cardType, cardType) || other.cardType == cardType)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.lastFour, lastFour) || other.lastFour == lastFour)&&(identical(other.expiryMonth, expiryMonth) || other.expiryMonth == expiryMonth)&&(identical(other.expiryYear, expiryYear) || other.expiryYear == expiryYear)&&(identical(other.cardColor, cardColor) || other.cardColor == cardColor)&&(identical(other.loyaltyStoreName, loyaltyStoreName) || other.loyaltyStoreName == loyaltyStoreName)&&(identical(other.loyaltyStoreLogoUrl, loyaltyStoreLogoUrl) || other.loyaltyStoreLogoUrl == loyaltyStoreLogoUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spaceId,createdBy,cardType,displayName,provider,lastFour,expiryMonth,expiryYear,cardColor,loyaltyStoreName,loyaltyStoreLogoUrl,createdAt,updatedAt);

@override
String toString() {
  return 'CardModel(id: $id, spaceId: $spaceId, createdBy: $createdBy, cardType: $cardType, displayName: $displayName, provider: $provider, lastFour: $lastFour, expiryMonth: $expiryMonth, expiryYear: $expiryYear, cardColor: $cardColor, loyaltyStoreName: $loyaltyStoreName, loyaltyStoreLogoUrl: $loyaltyStoreLogoUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CardModelCopyWith<$Res>  {
  factory $CardModelCopyWith(CardModel value, $Res Function(CardModel) _then) = _$CardModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'card_type') CardType cardType,@JsonKey(name: 'display_name') String displayName, CardProvider? provider,@JsonKey(name: 'last_four') String? lastFour,@JsonKey(name: 'expiry_month') int? expiryMonth,@JsonKey(name: 'expiry_year') int? expiryYear,@JsonKey(name: 'card_color') String? cardColor,@JsonKey(name: 'loyalty_store_name') String? loyaltyStoreName,@JsonKey(name: 'loyalty_store_logo_url') String? loyaltyStoreLogoUrl,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$CardModelCopyWithImpl<$Res>
    implements $CardModelCopyWith<$Res> {
  _$CardModelCopyWithImpl(this._self, this._then);

  final CardModel _self;
  final $Res Function(CardModel) _then;

/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? spaceId = null,Object? createdBy = null,Object? cardType = null,Object? displayName = null,Object? provider = freezed,Object? lastFour = freezed,Object? expiryMonth = freezed,Object? expiryYear = freezed,Object? cardColor = freezed,Object? loyaltyStoreName = freezed,Object? loyaltyStoreLogoUrl = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as CardType,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as CardProvider?,lastFour: freezed == lastFour ? _self.lastFour : lastFour // ignore: cast_nullable_to_non_nullable
as String?,expiryMonth: freezed == expiryMonth ? _self.expiryMonth : expiryMonth // ignore: cast_nullable_to_non_nullable
as int?,expiryYear: freezed == expiryYear ? _self.expiryYear : expiryYear // ignore: cast_nullable_to_non_nullable
as int?,cardColor: freezed == cardColor ? _self.cardColor : cardColor // ignore: cast_nullable_to_non_nullable
as String?,loyaltyStoreName: freezed == loyaltyStoreName ? _self.loyaltyStoreName : loyaltyStoreName // ignore: cast_nullable_to_non_nullable
as String?,loyaltyStoreLogoUrl: freezed == loyaltyStoreLogoUrl ? _self.loyaltyStoreLogoUrl : loyaltyStoreLogoUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CardModel].
extension CardModelPatterns on CardModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardModel value)  $default,){
final _that = this;
switch (_that) {
case _CardModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardModel value)?  $default,){
final _that = this;
switch (_that) {
case _CardModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'card_type')  CardType cardType, @JsonKey(name: 'display_name')  String displayName,  CardProvider? provider, @JsonKey(name: 'last_four')  String? lastFour, @JsonKey(name: 'expiry_month')  int? expiryMonth, @JsonKey(name: 'expiry_year')  int? expiryYear, @JsonKey(name: 'card_color')  String? cardColor, @JsonKey(name: 'loyalty_store_name')  String? loyaltyStoreName, @JsonKey(name: 'loyalty_store_logo_url')  String? loyaltyStoreLogoUrl, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardModel() when $default != null:
return $default(_that.id,_that.spaceId,_that.createdBy,_that.cardType,_that.displayName,_that.provider,_that.lastFour,_that.expiryMonth,_that.expiryYear,_that.cardColor,_that.loyaltyStoreName,_that.loyaltyStoreLogoUrl,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'card_type')  CardType cardType, @JsonKey(name: 'display_name')  String displayName,  CardProvider? provider, @JsonKey(name: 'last_four')  String? lastFour, @JsonKey(name: 'expiry_month')  int? expiryMonth, @JsonKey(name: 'expiry_year')  int? expiryYear, @JsonKey(name: 'card_color')  String? cardColor, @JsonKey(name: 'loyalty_store_name')  String? loyaltyStoreName, @JsonKey(name: 'loyalty_store_logo_url')  String? loyaltyStoreLogoUrl, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CardModel():
return $default(_that.id,_that.spaceId,_that.createdBy,_that.cardType,_that.displayName,_that.provider,_that.lastFour,_that.expiryMonth,_that.expiryYear,_that.cardColor,_that.loyaltyStoreName,_that.loyaltyStoreLogoUrl,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'card_type')  CardType cardType, @JsonKey(name: 'display_name')  String displayName,  CardProvider? provider, @JsonKey(name: 'last_four')  String? lastFour, @JsonKey(name: 'expiry_month')  int? expiryMonth, @JsonKey(name: 'expiry_year')  int? expiryYear, @JsonKey(name: 'card_color')  String? cardColor, @JsonKey(name: 'loyalty_store_name')  String? loyaltyStoreName, @JsonKey(name: 'loyalty_store_logo_url')  String? loyaltyStoreLogoUrl, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CardModel() when $default != null:
return $default(_that.id,_that.spaceId,_that.createdBy,_that.cardType,_that.displayName,_that.provider,_that.lastFour,_that.expiryMonth,_that.expiryYear,_that.cardColor,_that.loyaltyStoreName,_that.loyaltyStoreLogoUrl,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardModel implements CardModel {
  const _CardModel({required this.id, @JsonKey(name: 'space_id') required this.spaceId, @JsonKey(name: 'created_by') required this.createdBy, @JsonKey(name: 'card_type') required this.cardType, @JsonKey(name: 'display_name') required this.displayName, this.provider, @JsonKey(name: 'last_four') this.lastFour, @JsonKey(name: 'expiry_month') this.expiryMonth, @JsonKey(name: 'expiry_year') this.expiryYear, @JsonKey(name: 'card_color') this.cardColor, @JsonKey(name: 'loyalty_store_name') this.loyaltyStoreName, @JsonKey(name: 'loyalty_store_logo_url') this.loyaltyStoreLogoUrl, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _CardModel.fromJson(Map<String, dynamic> json) => _$CardModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'space_id') final  String spaceId;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override@JsonKey(name: 'card_type') final  CardType cardType;
@override@JsonKey(name: 'display_name') final  String displayName;
@override final  CardProvider? provider;
@override@JsonKey(name: 'last_four') final  String? lastFour;
@override@JsonKey(name: 'expiry_month') final  int? expiryMonth;
@override@JsonKey(name: 'expiry_year') final  int? expiryYear;
@override@JsonKey(name: 'card_color') final  String? cardColor;
@override@JsonKey(name: 'loyalty_store_name') final  String? loyaltyStoreName;
@override@JsonKey(name: 'loyalty_store_logo_url') final  String? loyaltyStoreLogoUrl;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardModelCopyWith<_CardModel> get copyWith => __$CardModelCopyWithImpl<_CardModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardModel&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.cardType, cardType) || other.cardType == cardType)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.lastFour, lastFour) || other.lastFour == lastFour)&&(identical(other.expiryMonth, expiryMonth) || other.expiryMonth == expiryMonth)&&(identical(other.expiryYear, expiryYear) || other.expiryYear == expiryYear)&&(identical(other.cardColor, cardColor) || other.cardColor == cardColor)&&(identical(other.loyaltyStoreName, loyaltyStoreName) || other.loyaltyStoreName == loyaltyStoreName)&&(identical(other.loyaltyStoreLogoUrl, loyaltyStoreLogoUrl) || other.loyaltyStoreLogoUrl == loyaltyStoreLogoUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spaceId,createdBy,cardType,displayName,provider,lastFour,expiryMonth,expiryYear,cardColor,loyaltyStoreName,loyaltyStoreLogoUrl,createdAt,updatedAt);

@override
String toString() {
  return 'CardModel(id: $id, spaceId: $spaceId, createdBy: $createdBy, cardType: $cardType, displayName: $displayName, provider: $provider, lastFour: $lastFour, expiryMonth: $expiryMonth, expiryYear: $expiryYear, cardColor: $cardColor, loyaltyStoreName: $loyaltyStoreName, loyaltyStoreLogoUrl: $loyaltyStoreLogoUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CardModelCopyWith<$Res> implements $CardModelCopyWith<$Res> {
  factory _$CardModelCopyWith(_CardModel value, $Res Function(_CardModel) _then) = __$CardModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'card_type') CardType cardType,@JsonKey(name: 'display_name') String displayName, CardProvider? provider,@JsonKey(name: 'last_four') String? lastFour,@JsonKey(name: 'expiry_month') int? expiryMonth,@JsonKey(name: 'expiry_year') int? expiryYear,@JsonKey(name: 'card_color') String? cardColor,@JsonKey(name: 'loyalty_store_name') String? loyaltyStoreName,@JsonKey(name: 'loyalty_store_logo_url') String? loyaltyStoreLogoUrl,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$CardModelCopyWithImpl<$Res>
    implements _$CardModelCopyWith<$Res> {
  __$CardModelCopyWithImpl(this._self, this._then);

  final _CardModel _self;
  final $Res Function(_CardModel) _then;

/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? spaceId = null,Object? createdBy = null,Object? cardType = null,Object? displayName = null,Object? provider = freezed,Object? lastFour = freezed,Object? expiryMonth = freezed,Object? expiryYear = freezed,Object? cardColor = freezed,Object? loyaltyStoreName = freezed,Object? loyaltyStoreLogoUrl = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CardModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as CardType,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as CardProvider?,lastFour: freezed == lastFour ? _self.lastFour : lastFour // ignore: cast_nullable_to_non_nullable
as String?,expiryMonth: freezed == expiryMonth ? _self.expiryMonth : expiryMonth // ignore: cast_nullable_to_non_nullable
as int?,expiryYear: freezed == expiryYear ? _self.expiryYear : expiryYear // ignore: cast_nullable_to_non_nullable
as int?,cardColor: freezed == cardColor ? _self.cardColor : cardColor // ignore: cast_nullable_to_non_nullable
as String?,loyaltyStoreName: freezed == loyaltyStoreName ? _self.loyaltyStoreName : loyaltyStoreName // ignore: cast_nullable_to_non_nullable
as String?,loyaltyStoreLogoUrl: freezed == loyaltyStoreLogoUrl ? _self.loyaltyStoreLogoUrl : loyaltyStoreLogoUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
