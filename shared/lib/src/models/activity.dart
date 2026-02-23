import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/activity_category.dart';
import '../enums/activity_mode.dart';
import '../enums/activity_privacy.dart';
import '../enums/activity_status.dart';

part 'activity.g.dart';

/// Represents an activity suggestion within a space.
@JsonSerializable()
class Activity extends Equatable {
  const Activity({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.title,
    this.description,
    required this.category,
    this.thumbnailUrl,
    this.trailerUrl,
    this.externalId,
    this.externalSource,
    required this.privacy,
    required this.status,
    required this.mode,
    this.linkedCalendarEventId,
    this.linkedTaskId,
    this.completedAt,
    this.completedNotes,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'category')
  final ActivityCategory category;

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @JsonKey(name: 'trailer_url')
  final String? trailerUrl;

  @JsonKey(name: 'external_id')
  final String? externalId;

  @JsonKey(name: 'external_source')
  final String? externalSource;

  @JsonKey(name: 'privacy')
  final ActivityPrivacy privacy;

  @JsonKey(name: 'status')
  final ActivityStatus status;

  @JsonKey(name: 'mode')
  final ActivityMode mode;

  @JsonKey(name: 'linked_calendar_event_id')
  final String? linkedCalendarEventId;

  @JsonKey(name: 'linked_task_id')
  final String? linkedTaskId;

  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;

  @JsonKey(name: 'completed_notes')
  final String? completedNotes;

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  @override
  List<Object?> get props => [
    id,
    spaceId,
    createdBy,
    title,
    description,
    category,
    thumbnailUrl,
    trailerUrl,
    externalId,
    externalSource,
    privacy,
    status,
    mode,
    linkedCalendarEventId,
    linkedTaskId,
    completedAt,
    completedNotes,
    metadata,
    createdAt,
    updatedAt,
  ];
}
