import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_vote.g.dart';

/// Represents a user's vote/score on an activity.
@JsonSerializable()
class ActivityVote extends Equatable {
  const ActivityVote({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.score,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityVote.fromJson(Map<String, dynamic> json) =>
      _$ActivityVoteFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'activity_id')
  final String activityId;

  @JsonKey(name: 'user_id')
  final String userId;

  /// Score from 1 to 5.
  @JsonKey(name: 'score')
  final int score;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$ActivityVoteToJson(this);

  @override
  List<Object?> get props => [
    id,
    activityId,
    userId,
    score,
    createdAt,
    updatedAt,
  ];
}
