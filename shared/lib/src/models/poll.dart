import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/poll_type.dart';

part 'poll.freezed.dart';
part 'poll.g.dart';

/// Represents a poll within a space.
@freezed
abstract class Poll with _$Poll {
  const factory Poll({
    required String id,
    @JsonKey(name: 'space_id') required String spaceId,
    @JsonKey(name: 'created_by') required String createdBy,
    required String question,
    @JsonKey(name: 'poll_type') required PollType pollType,
    @JsonKey(name: 'is_anonymous') required bool isAnonymous,
    DateTime? deadline,
    @JsonKey(name: 'is_closed') required bool isClosed,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Poll;

  factory Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);
}
