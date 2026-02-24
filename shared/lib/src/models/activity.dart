import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/activity_category.dart';
import '../enums/activity_mode.dart';
import '../enums/activity_privacy.dart';
import '../enums/activity_status.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

/// Represents an activity suggestion within a space.
@freezed
abstract class Activity with _$Activity {
  const factory Activity({
    required String id,
    @JsonKey(name: 'space_id') required String spaceId,
    @JsonKey(name: 'created_by') required String createdBy,
    required String title,
    String? description,
    required ActivityCategory category,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'trailer_url') String? trailerUrl,
    @JsonKey(name: 'external_id') String? externalId,
    @JsonKey(name: 'external_source') String? externalSource,
    required ActivityPrivacy privacy,
    required ActivityStatus status,
    required ActivityMode mode,
    @JsonKey(name: 'linked_calendar_event_id') String? linkedCalendarEventId,
    @JsonKey(name: 'linked_task_id') String? linkedTaskId,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'completed_notes') String? completedNotes,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
}
