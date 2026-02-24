// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PollOption _$PollOptionFromJson(Map<String, dynamic> json) => _PollOption(
  id: json['id'] as String,
  pollId: json['poll_id'] as String,
  label: json['label'] as String,
  imageUrl: json['image_url'] as String?,
  displayOrder: (json['display_order'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PollOptionToJson(_PollOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'poll_id': instance.pollId,
      'label': instance.label,
      'image_url': instance.imageUrl,
      'display_order': instance.displayOrder,
      'created_at': instance.createdAt.toIso8601String(),
    };
