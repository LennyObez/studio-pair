import 'package:freezed_annotation/freezed_annotation.dart';

part 'poll_option.freezed.dart';
part 'poll_option.g.dart';

/// Represents an option within a poll.
@freezed
abstract class PollOption with _$PollOption {
  const factory PollOption({
    required String id,
    @JsonKey(name: 'poll_id') required String pollId,
    required String label,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'display_order') required int displayOrder,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PollOption;

  factory PollOption.fromJson(Map<String, dynamic> json) =>
      _$PollOptionFromJson(json);
}
