// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationModel {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'space_id') String? get spaceId; String get type; String get title; String get body;@JsonKey(name: 'source_module') String? get sourceModule;@JsonKey(name: 'source_entity_id') String? get sourceEntityId; NotificationChannel get channel;@JsonKey(name: 'is_read') bool get isRead;@JsonKey(name: 'read_at') DateTime? get readAt; Map<String, dynamic>? get metadata;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationModelCopyWith<NotificationModel> get copyWith => _$NotificationModelCopyWithImpl<NotificationModel>(this as NotificationModel, _$identity);

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.sourceModule, sourceModule) || other.sourceModule == sourceModule)&&(identical(other.sourceEntityId, sourceEntityId) || other.sourceEntityId == sourceEntityId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,spaceId,type,title,body,sourceModule,sourceEntityId,channel,isRead,readAt,const DeepCollectionEquality().hash(metadata),createdAt);

@override
String toString() {
  return 'NotificationModel(id: $id, userId: $userId, spaceId: $spaceId, type: $type, title: $title, body: $body, sourceModule: $sourceModule, sourceEntityId: $sourceEntityId, channel: $channel, isRead: $isRead, readAt: $readAt, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $NotificationModelCopyWith<$Res>  {
  factory $NotificationModelCopyWith(NotificationModel value, $Res Function(NotificationModel) _then) = _$NotificationModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'space_id') String? spaceId, String type, String title, String body,@JsonKey(name: 'source_module') String? sourceModule,@JsonKey(name: 'source_entity_id') String? sourceEntityId, NotificationChannel channel,@JsonKey(name: 'is_read') bool isRead,@JsonKey(name: 'read_at') DateTime? readAt, Map<String, dynamic>? metadata,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$NotificationModelCopyWithImpl<$Res>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._self, this._then);

  final NotificationModel _self;
  final $Res Function(NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? spaceId = freezed,Object? type = null,Object? title = null,Object? body = null,Object? sourceModule = freezed,Object? sourceEntityId = freezed,Object? channel = null,Object? isRead = null,Object? readAt = freezed,Object? metadata = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,spaceId: freezed == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,sourceModule: freezed == sourceModule ? _self.sourceModule : sourceModule // ignore: cast_nullable_to_non_nullable
as String?,sourceEntityId: freezed == sourceEntityId ? _self.sourceEntityId : sourceEntityId // ignore: cast_nullable_to_non_nullable
as String?,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as NotificationChannel,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationModel].
extension NotificationModelPatterns on NotificationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationModel value)  $default,){
final _that = this;
switch (_that) {
case _NotificationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'space_id')  String? spaceId,  String type,  String title,  String body, @JsonKey(name: 'source_module')  String? sourceModule, @JsonKey(name: 'source_entity_id')  String? sourceEntityId,  NotificationChannel channel, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'read_at')  DateTime? readAt,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.id,_that.userId,_that.spaceId,_that.type,_that.title,_that.body,_that.sourceModule,_that.sourceEntityId,_that.channel,_that.isRead,_that.readAt,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'space_id')  String? spaceId,  String type,  String title,  String body, @JsonKey(name: 'source_module')  String? sourceModule, @JsonKey(name: 'source_entity_id')  String? sourceEntityId,  NotificationChannel channel, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'read_at')  DateTime? readAt,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationModel():
return $default(_that.id,_that.userId,_that.spaceId,_that.type,_that.title,_that.body,_that.sourceModule,_that.sourceEntityId,_that.channel,_that.isRead,_that.readAt,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'space_id')  String? spaceId,  String type,  String title,  String body, @JsonKey(name: 'source_module')  String? sourceModule, @JsonKey(name: 'source_entity_id')  String? sourceEntityId,  NotificationChannel channel, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'read_at')  DateTime? readAt,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.id,_that.userId,_that.spaceId,_that.type,_that.title,_that.body,_that.sourceModule,_that.sourceEntityId,_that.channel,_that.isRead,_that.readAt,_that.metadata,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationModel implements NotificationModel {
  const _NotificationModel({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'space_id') this.spaceId, required this.type, required this.title, required this.body, @JsonKey(name: 'source_module') this.sourceModule, @JsonKey(name: 'source_entity_id') this.sourceEntityId, required this.channel, @JsonKey(name: 'is_read') required this.isRead, @JsonKey(name: 'read_at') this.readAt, final  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at') required this.createdAt}): _metadata = metadata;
  factory _NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'space_id') final  String? spaceId;
@override final  String type;
@override final  String title;
@override final  String body;
@override@JsonKey(name: 'source_module') final  String? sourceModule;
@override@JsonKey(name: 'source_entity_id') final  String? sourceEntityId;
@override final  NotificationChannel channel;
@override@JsonKey(name: 'is_read') final  bool isRead;
@override@JsonKey(name: 'read_at') final  DateTime? readAt;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationModelCopyWith<_NotificationModel> get copyWith => __$NotificationModelCopyWithImpl<_NotificationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.sourceModule, sourceModule) || other.sourceModule == sourceModule)&&(identical(other.sourceEntityId, sourceEntityId) || other.sourceEntityId == sourceEntityId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,spaceId,type,title,body,sourceModule,sourceEntityId,channel,isRead,readAt,const DeepCollectionEquality().hash(_metadata),createdAt);

@override
String toString() {
  return 'NotificationModel(id: $id, userId: $userId, spaceId: $spaceId, type: $type, title: $title, body: $body, sourceModule: $sourceModule, sourceEntityId: $sourceEntityId, channel: $channel, isRead: $isRead, readAt: $readAt, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationModelCopyWith<$Res> implements $NotificationModelCopyWith<$Res> {
  factory _$NotificationModelCopyWith(_NotificationModel value, $Res Function(_NotificationModel) _then) = __$NotificationModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'space_id') String? spaceId, String type, String title, String body,@JsonKey(name: 'source_module') String? sourceModule,@JsonKey(name: 'source_entity_id') String? sourceEntityId, NotificationChannel channel,@JsonKey(name: 'is_read') bool isRead,@JsonKey(name: 'read_at') DateTime? readAt, Map<String, dynamic>? metadata,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$NotificationModelCopyWithImpl<$Res>
    implements _$NotificationModelCopyWith<$Res> {
  __$NotificationModelCopyWithImpl(this._self, this._then);

  final _NotificationModel _self;
  final $Res Function(_NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? spaceId = freezed,Object? type = null,Object? title = null,Object? body = null,Object? sourceModule = freezed,Object? sourceEntityId = freezed,Object? channel = null,Object? isRead = null,Object? readAt = freezed,Object? metadata = freezed,Object? createdAt = null,}) {
  return _then(_NotificationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,spaceId: freezed == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,sourceModule: freezed == sourceModule ? _self.sourceModule : sourceModule // ignore: cast_nullable_to_non_nullable
as String?,sourceEntityId: freezed == sourceEntityId ? _self.sourceEntityId : sourceEntityId // ignore: cast_nullable_to_non_nullable
as String?,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as NotificationChannel,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
