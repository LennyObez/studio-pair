import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/event_type.dart';

part 'calendar_event.freezed.dart';
part 'calendar_event.g.dart';

/// Represents a calendar event within a space.
@freezed
abstract class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent({
    required String id,
    @JsonKey(name: 'space_id') required String spaceId,
    @JsonKey(name: 'created_by') required String createdBy,
    required String title,
    String? location,
    @JsonKey(name: 'event_type') required EventType eventType,
    @JsonKey(name: 'all_day') required bool allDay,
    @JsonKey(name: 'start_at') required DateTime startAt,
    @JsonKey(name: 'end_at') required DateTime endAt,
    @JsonKey(name: 'recurrence_rule') String? recurrenceRule,
    @JsonKey(name: 'source_module') String? sourceModule,
    @JsonKey(name: 'source_entity_id') String? sourceEntityId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CalendarEvent;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);
}
