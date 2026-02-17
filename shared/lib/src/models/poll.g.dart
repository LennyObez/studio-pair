// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Poll _$PollFromJson(Map<String, dynamic> json) => _Poll(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  createdBy: json['created_by'] as String,
  question: json['question'] as String,
  pollType: $enumDecode(_$PollTypeEnumMap, json['poll_type']),
  isAnonymous: json['is_anonymous'] as bool,
  deadline: json['deadline'] == null
      ? null
      : DateTime.parse(json['deadline'] as String),
  isClosed: json['is_closed'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PollToJson(_Poll instance) => <String, dynamic>{
  'id': instance.id,
  'space_id': instance.spaceId,
  'created_by': instance.createdBy,
  'question': instance.question,
  'poll_type': _$PollTypeEnumMap[instance.pollType]!,
  'is_anonymous': instance.isAnonymous,
  'deadline': instance.deadline?.toIso8601String(),
  'is_closed': instance.isClosed,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$PollTypeEnumMap = {
  PollType.singleChoice: 'single_choice',
  PollType.multipleChoice: 'multiple_choice',
  PollType.rankedChoice: 'ranked_choice',
};
