import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'poll_option.g.dart';

/// Represents an option within a poll.
@JsonSerializable()
class PollOption extends Equatable {
  const PollOption({
    required this.id,
    required this.pollId,
    required this.label,
    this.imageUrl,
    required this.displayOrder,
    required this.createdAt,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) =>
      _$PollOptionFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'poll_id')
  final String pollId;

  @JsonKey(name: 'label')
  final String label;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @JsonKey(name: 'display_order')
  final int displayOrder;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$PollOptionToJson(this);

  @override
  List<Object?> get props => [
    id,
    pollId,
    label,
    imageUrl,
    displayOrder,
    createdAt,
  ];
}
