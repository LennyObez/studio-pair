// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grocery_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroceryItem {

 String get id;@JsonKey(name: 'list_id') String get listId; String get name; double? get quantity; String? get unit; GroceryCategory get category; String? get note;@JsonKey(name: 'is_checked') bool get isChecked;@JsonKey(name: 'checked_by') String? get checkedBy;@JsonKey(name: 'checked_at') DateTime? get checkedAt;@JsonKey(name: 'price_cents') int? get priceCents;@JsonKey(name: 'display_order') int get displayOrder;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of GroceryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroceryItemCopyWith<GroceryItem> get copyWith => _$GroceryItemCopyWithImpl<GroceryItem>(this as GroceryItem, _$identity);

  /// Serializes this GroceryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroceryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.listId, listId) || other.listId == listId)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.category, category) || other.category == category)&&(identical(other.note, note) || other.note == note)&&(identical(other.isChecked, isChecked) || other.isChecked == isChecked)&&(identical(other.checkedBy, checkedBy) || other.checkedBy == checkedBy)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,listId,name,quantity,unit,category,note,isChecked,checkedBy,checkedAt,priceCents,displayOrder,createdAt,updatedAt);

@override
String toString() {
  return 'GroceryItem(id: $id, listId: $listId, name: $name, quantity: $quantity, unit: $unit, category: $category, note: $note, isChecked: $isChecked, checkedBy: $checkedBy, checkedAt: $checkedAt, priceCents: $priceCents, displayOrder: $displayOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GroceryItemCopyWith<$Res>  {
  factory $GroceryItemCopyWith(GroceryItem value, $Res Function(GroceryItem) _then) = _$GroceryItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'list_id') String listId, String name, double? quantity, String? unit, GroceryCategory category, String? note,@JsonKey(name: 'is_checked') bool isChecked,@JsonKey(name: 'checked_by') String? checkedBy,@JsonKey(name: 'checked_at') DateTime? checkedAt,@JsonKey(name: 'price_cents') int? priceCents,@JsonKey(name: 'display_order') int displayOrder,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$GroceryItemCopyWithImpl<$Res>
    implements $GroceryItemCopyWith<$Res> {
  _$GroceryItemCopyWithImpl(this._self, this._then);

  final GroceryItem _self;
  final $Res Function(GroceryItem) _then;

/// Create a copy of GroceryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? listId = null,Object? name = null,Object? quantity = freezed,Object? unit = freezed,Object? category = null,Object? note = freezed,Object? isChecked = null,Object? checkedBy = freezed,Object? checkedAt = freezed,Object? priceCents = freezed,Object? displayOrder = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listId: null == listId ? _self.listId : listId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as GroceryCategory,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isChecked: null == isChecked ? _self.isChecked : isChecked // ignore: cast_nullable_to_non_nullable
as bool,checkedBy: freezed == checkedBy ? _self.checkedBy : checkedBy // ignore: cast_nullable_to_non_nullable
as String?,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,priceCents: freezed == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GroceryItem].
extension GroceryItemPatterns on GroceryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroceryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroceryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroceryItem value)  $default,){
final _that = this;
switch (_that) {
case _GroceryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroceryItem value)?  $default,){
final _that = this;
switch (_that) {
case _GroceryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'list_id')  String listId,  String name,  double? quantity,  String? unit,  GroceryCategory category,  String? note, @JsonKey(name: 'is_checked')  bool isChecked, @JsonKey(name: 'checked_by')  String? checkedBy, @JsonKey(name: 'checked_at')  DateTime? checkedAt, @JsonKey(name: 'price_cents')  int? priceCents, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroceryItem() when $default != null:
return $default(_that.id,_that.listId,_that.name,_that.quantity,_that.unit,_that.category,_that.note,_that.isChecked,_that.checkedBy,_that.checkedAt,_that.priceCents,_that.displayOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'list_id')  String listId,  String name,  double? quantity,  String? unit,  GroceryCategory category,  String? note, @JsonKey(name: 'is_checked')  bool isChecked, @JsonKey(name: 'checked_by')  String? checkedBy, @JsonKey(name: 'checked_at')  DateTime? checkedAt, @JsonKey(name: 'price_cents')  int? priceCents, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GroceryItem():
return $default(_that.id,_that.listId,_that.name,_that.quantity,_that.unit,_that.category,_that.note,_that.isChecked,_that.checkedBy,_that.checkedAt,_that.priceCents,_that.displayOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'list_id')  String listId,  String name,  double? quantity,  String? unit,  GroceryCategory category,  String? note, @JsonKey(name: 'is_checked')  bool isChecked, @JsonKey(name: 'checked_by')  String? checkedBy, @JsonKey(name: 'checked_at')  DateTime? checkedAt, @JsonKey(name: 'price_cents')  int? priceCents, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GroceryItem() when $default != null:
return $default(_that.id,_that.listId,_that.name,_that.quantity,_that.unit,_that.category,_that.note,_that.isChecked,_that.checkedBy,_that.checkedAt,_that.priceCents,_that.displayOrder,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroceryItem implements GroceryItem {
  const _GroceryItem({required this.id, @JsonKey(name: 'list_id') required this.listId, required this.name, this.quantity, this.unit, required this.category, this.note, @JsonKey(name: 'is_checked') required this.isChecked, @JsonKey(name: 'checked_by') this.checkedBy, @JsonKey(name: 'checked_at') this.checkedAt, @JsonKey(name: 'price_cents') this.priceCents, @JsonKey(name: 'display_order') required this.displayOrder, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _GroceryItem.fromJson(Map<String, dynamic> json) => _$GroceryItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'list_id') final  String listId;
@override final  String name;
@override final  double? quantity;
@override final  String? unit;
@override final  GroceryCategory category;
@override final  String? note;
@override@JsonKey(name: 'is_checked') final  bool isChecked;
@override@JsonKey(name: 'checked_by') final  String? checkedBy;
@override@JsonKey(name: 'checked_at') final  DateTime? checkedAt;
@override@JsonKey(name: 'price_cents') final  int? priceCents;
@override@JsonKey(name: 'display_order') final  int displayOrder;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of GroceryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroceryItemCopyWith<_GroceryItem> get copyWith => __$GroceryItemCopyWithImpl<_GroceryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroceryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroceryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.listId, listId) || other.listId == listId)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.category, category) || other.category == category)&&(identical(other.note, note) || other.note == note)&&(identical(other.isChecked, isChecked) || other.isChecked == isChecked)&&(identical(other.checkedBy, checkedBy) || other.checkedBy == checkedBy)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,listId,name,quantity,unit,category,note,isChecked,checkedBy,checkedAt,priceCents,displayOrder,createdAt,updatedAt);

@override
String toString() {
  return 'GroceryItem(id: $id, listId: $listId, name: $name, quantity: $quantity, unit: $unit, category: $category, note: $note, isChecked: $isChecked, checkedBy: $checkedBy, checkedAt: $checkedAt, priceCents: $priceCents, displayOrder: $displayOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GroceryItemCopyWith<$Res> implements $GroceryItemCopyWith<$Res> {
  factory _$GroceryItemCopyWith(_GroceryItem value, $Res Function(_GroceryItem) _then) = __$GroceryItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'list_id') String listId, String name, double? quantity, String? unit, GroceryCategory category, String? note,@JsonKey(name: 'is_checked') bool isChecked,@JsonKey(name: 'checked_by') String? checkedBy,@JsonKey(name: 'checked_at') DateTime? checkedAt,@JsonKey(name: 'price_cents') int? priceCents,@JsonKey(name: 'display_order') int displayOrder,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$GroceryItemCopyWithImpl<$Res>
    implements _$GroceryItemCopyWith<$Res> {
  __$GroceryItemCopyWithImpl(this._self, this._then);

  final _GroceryItem _self;
  final $Res Function(_GroceryItem) _then;

/// Create a copy of GroceryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? listId = null,Object? name = null,Object? quantity = freezed,Object? unit = freezed,Object? category = null,Object? note = freezed,Object? isChecked = null,Object? checkedBy = freezed,Object? checkedAt = freezed,Object? priceCents = freezed,Object? displayOrder = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_GroceryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listId: null == listId ? _self.listId : listId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as GroceryCategory,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isChecked: null == isChecked ? _self.isChecked : isChecked // ignore: cast_nullable_to_non_nullable
as bool,checkedBy: freezed == checkedBy ? _self.checkedBy : checkedBy // ignore: cast_nullable_to_non_nullable
as String?,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,priceCents: freezed == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
