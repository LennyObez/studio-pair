import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder.g.dart';

/// Represents a reminder within a space.
@JsonSerializable()
class Reminder extends Equatable {
  const Reminder({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.message,
    required this.triggerAt,
    this.recurrenceRule,
    this.linkedModule,
    this.linkedEntityId,
    required this.isSent,
    this.sentAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'trigger_at')
  final DateTime triggerAt;

  @JsonKey(name: 'recurrence_rule')
  final String? recurrenceRule;

  @JsonKey(name: 'linked_module')
  final String? linkedModule;

  @JsonKey(name: 'linked_entity_id')
  final String? linkedEntityId;

  @JsonKey(name: 'is_sent')
  final bool isSent;

  @JsonKey(name: 'sent_at')
  final DateTime? sentAt;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$ReminderToJson(this);

  @override
  List<Object?> get props => [
    id,
    spaceId,
    createdBy,
    message,
    triggerAt,
    recurrenceRule,
    linkedModule,
    linkedEntityId,
    isSent,
    sentAt,
    createdAt,
    updatedAt,
  ];
}
