import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_vote.freezed.dart';
part 'activity_vote.g.dart';

/// Represents a user's vote/score on an activity.
@freezed
abstract class ActivityVote with _$ActivityVote {
  const factory ActivityVote({
    required String id,
    @JsonKey(name: 'activity_id') required String activityId,
    @JsonKey(name: 'user_id') required String userId,

    /// Score from 1 to 5.
    required int score,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ActivityVote;

  factory ActivityVote.fromJson(Map<String, dynamic> json) =>
      _$ActivityVoteFromJson(json);
}
