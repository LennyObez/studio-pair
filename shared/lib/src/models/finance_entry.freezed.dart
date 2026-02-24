// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'finance_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FinanceEntry {

 String get id;@JsonKey(name: 'space_id') String get spaceId;@JsonKey(name: 'created_by') String get createdBy;@JsonKey(name: 'entry_type') FinanceEntryType get entryType; String get category; String? get subcategory; String? get description;@JsonKey(name: 'amount_cents') int get amountCents; String get currency;@JsonKey(name: 'is_recurring') bool get isRecurring;@JsonKey(name: 'recurrence_rule') String? get recurrenceRule; DateTime get date;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of FinanceEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinanceEntryCopyWith<FinanceEntry> get copyWith => _$FinanceEntryCopyWithImpl<FinanceEntry>(this as FinanceEntry, _$identity);

  /// Serializes this FinanceEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinanceEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.entryType, entryType) || other.entryType == entryType)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.description, description) || other.description == description)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurrenceRule, recurrenceRule) || other.recurrenceRule == recurrenceRule)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spaceId,createdBy,entryType,category,subcategory,description,amountCents,currency,isRecurring,recurrenceRule,date,createdAt,updatedAt);

@override
String toString() {
  return 'FinanceEntry(id: $id, spaceId: $spaceId, createdBy: $createdBy, entryType: $entryType, category: $category, subcategory: $subcategory, description: $description, amountCents: $amountCents, currency: $currency, isRecurring: $isRecurring, recurrenceRule: $recurrenceRule, date: $date, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FinanceEntryCopyWith<$Res>  {
  factory $FinanceEntryCopyWith(FinanceEntry value, $Res Function(FinanceEntry) _then) = _$FinanceEntryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'entry_type') FinanceEntryType entryType, String category, String? subcategory, String? description,@JsonKey(name: 'amount_cents') int amountCents, String currency,@JsonKey(name: 'is_recurring') bool isRecurring,@JsonKey(name: 'recurrence_rule') String? recurrenceRule, DateTime date,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$FinanceEntryCopyWithImpl<$Res>
    implements $FinanceEntryCopyWith<$Res> {
  _$FinanceEntryCopyWithImpl(this._self, this._then);

  final FinanceEntry _self;
  final $Res Function(FinanceEntry) _then;

/// Create a copy of FinanceEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? spaceId = null,Object? createdBy = null,Object? entryType = null,Object? category = null,Object? subcategory = freezed,Object? description = freezed,Object? amountCents = null,Object? currency = null,Object? isRecurring = null,Object? recurrenceRule = freezed,Object? date = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,entryType: null == entryType ? _self.entryType : entryType // ignore: cast_nullable_to_non_nullable
as FinanceEntryType,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subcategory: freezed == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurrenceRule: freezed == recurrenceRule ? _self.recurrenceRule : recurrenceRule // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FinanceEntry].
extension FinanceEntryPatterns on FinanceEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinanceEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinanceEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinanceEntry value)  $default,){
final _that = this;
switch (_that) {
case _FinanceEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinanceEntry value)?  $default,){
final _that = this;
switch (_that) {
case _FinanceEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'entry_type')  FinanceEntryType entryType,  String category,  String? subcategory,  String? description, @JsonKey(name: 'amount_cents')  int amountCents,  String currency, @JsonKey(name: 'is_recurring')  bool isRecurring, @JsonKey(name: 'recurrence_rule')  String? recurrenceRule,  DateTime date, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinanceEntry() when $default != null:
return $default(_that.id,_that.spaceId,_that.createdBy,_that.entryType,_that.category,_that.subcategory,_that.description,_that.amountCents,_that.currency,_that.isRecurring,_that.recurrenceRule,_that.date,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'entry_type')  FinanceEntryType entryType,  String category,  String? subcategory,  String? description, @JsonKey(name: 'amount_cents')  int amountCents,  String currency, @JsonKey(name: 'is_recurring')  bool isRecurring, @JsonKey(name: 'recurrence_rule')  String? recurrenceRule,  DateTime date, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FinanceEntry():
return $default(_that.id,_that.spaceId,_that.createdBy,_that.entryType,_that.category,_that.subcategory,_that.description,_that.amountCents,_that.currency,_that.isRecurring,_that.recurrenceRule,_that.date,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'space_id')  String spaceId, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'entry_type')  FinanceEntryType entryType,  String category,  String? subcategory,  String? description, @JsonKey(name: 'amount_cents')  int amountCents,  String currency, @JsonKey(name: 'is_recurring')  bool isRecurring, @JsonKey(name: 'recurrence_rule')  String? recurrenceRule,  DateTime date, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FinanceEntry() when $default != null:
return $default(_that.id,_that.spaceId,_that.createdBy,_that.entryType,_that.category,_that.subcategory,_that.description,_that.amountCents,_that.currency,_that.isRecurring,_that.recurrenceRule,_that.date,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinanceEntry implements FinanceEntry {
  const _FinanceEntry({required this.id, @JsonKey(name: 'space_id') required this.spaceId, @JsonKey(name: 'created_by') required this.createdBy, @JsonKey(name: 'entry_type') required this.entryType, required this.category, this.subcategory, this.description, @JsonKey(name: 'amount_cents') required this.amountCents, required this.currency, @JsonKey(name: 'is_recurring') required this.isRecurring, @JsonKey(name: 'recurrence_rule') this.recurrenceRule, required this.date, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _FinanceEntry.fromJson(Map<String, dynamic> json) => _$FinanceEntryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'space_id') final  String spaceId;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override@JsonKey(name: 'entry_type') final  FinanceEntryType entryType;
@override final  String category;
@override final  String? subcategory;
@override final  String? description;
@override@JsonKey(name: 'amount_cents') final  int amountCents;
@override final  String currency;
@override@JsonKey(name: 'is_recurring') final  bool isRecurring;
@override@JsonKey(name: 'recurrence_rule') final  String? recurrenceRule;
@override final  DateTime date;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of FinanceEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinanceEntryCopyWith<_FinanceEntry> get copyWith => __$FinanceEntryCopyWithImpl<_FinanceEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinanceEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinanceEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.entryType, entryType) || other.entryType == entryType)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.description, description) || other.description == description)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurrenceRule, recurrenceRule) || other.recurrenceRule == recurrenceRule)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spaceId,createdBy,entryType,category,subcategory,description,amountCents,currency,isRecurring,recurrenceRule,date,createdAt,updatedAt);

@override
String toString() {
  return 'FinanceEntry(id: $id, spaceId: $spaceId, createdBy: $createdBy, entryType: $entryType, category: $category, subcategory: $subcategory, description: $description, amountCents: $amountCents, currency: $currency, isRecurring: $isRecurring, recurrenceRule: $recurrenceRule, date: $date, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FinanceEntryCopyWith<$Res> implements $FinanceEntryCopyWith<$Res> {
  factory _$FinanceEntryCopyWith(_FinanceEntry value, $Res Function(_FinanceEntry) _then) = __$FinanceEntryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'space_id') String spaceId,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'entry_type') FinanceEntryType entryType, String category, String? subcategory, String? description,@JsonKey(name: 'amount_cents') int amountCents, String currency,@JsonKey(name: 'is_recurring') bool isRecurring,@JsonKey(name: 'recurrence_rule') String? recurrenceRule, DateTime date,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$FinanceEntryCopyWithImpl<$Res>
    implements _$FinanceEntryCopyWith<$Res> {
  __$FinanceEntryCopyWithImpl(this._self, this._then);

  final _FinanceEntry _self;
  final $Res Function(_FinanceEntry) _then;

/// Create a copy of FinanceEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? spaceId = null,Object? createdBy = null,Object? entryType = null,Object? category = null,Object? subcategory = freezed,Object? description = freezed,Object? amountCents = null,Object? currency = null,Object? isRecurring = null,Object? recurrenceRule = freezed,Object? date = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FinanceEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,entryType: null == entryType ? _self.entryType : entryType // ignore: cast_nullable_to_non_nullable
as FinanceEntryType,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subcategory: freezed == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurrenceRule: freezed == recurrenceRule ? _self.recurrenceRule : recurrenceRule // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
