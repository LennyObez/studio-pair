import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/event_type.dart';

part 'calendar_event.g.dart';

/// Represents a calendar event within a space.
@JsonSerializable()
class CalendarEvent extends Equatable {
  const CalendarEvent({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.title,
    this.location,
    required this.eventType,
    required this.allDay,
    required this.startAt,
    required this.endAt,
    this.recurrenceRule,
    this.sourceModule,
    this.sourceEntityId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'location')
  final String? location;

  @JsonKey(name: 'event_type')
  final EventType eventType;

  @JsonKey(name: 'all_day')
  final bool allDay;

  @JsonKey(name: 'start_at')
  final DateTime startAt;

  @JsonKey(name: 'end_at')
  final DateTime endAt;

  @JsonKey(name: 'recurrence_rule')
  final String? recurrenceRule;

  @JsonKey(name: 'source_module')
  final String? sourceModule;

  @JsonKey(name: 'source_entity_id')
  final String? sourceEntityId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$CalendarEventToJson(this);

  @override
  List<Object?> get props => [
    id,
    spaceId,
    createdBy,
    title,
    location,
    eventType,
    allDay,
    startAt,
    endAt,
    recurrenceRule,
    sourceModule,
    sourceEntityId,
    createdAt,
    updatedAt,
  ];
}
