import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/poll_type.dart';

part 'poll.g.dart';

/// Represents a poll within a space.
@JsonSerializable()
class Poll extends Equatable {
  const Poll({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.question,
    required this.pollType,
    required this.isAnonymous,
    this.deadline,
    required this.isClosed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'question')
  final String question;

  @JsonKey(name: 'poll_type')
  final PollType pollType;

  @JsonKey(name: 'is_anonymous')
  final bool isAnonymous;

  @JsonKey(name: 'deadline')
  final DateTime? deadline;

  @JsonKey(name: 'is_closed')
  final bool isClosed;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$PollToJson(this);

  @override
  List<Object?> get props => [
    id,
    spaceId,
    createdBy,
    question,
    pollType,
    isAnonymous,
    deadline,
    isClosed,
    createdAt,
    updatedAt,
  ];
}
