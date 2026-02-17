// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_vote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActivityVote _$ActivityVoteFromJson(Map<String, dynamic> json) =>
    _ActivityVote(
      id: json['id'] as String,
      activityId: json['activity_id'] as String,
      userId: json['user_id'] as String,
      score: (json['score'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ActivityVoteToJson(_ActivityVote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activity_id': instance.activityId,
      'user_id': instance.userId,
      'score': instance.score,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
