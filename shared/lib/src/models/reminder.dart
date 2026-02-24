import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

/// Represents a reminder within a space.
@freezed
abstract class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    @JsonKey(name: 'space_id') required String spaceId,
    @JsonKey(name: 'created_by') required String createdBy,
    required String message,
    @JsonKey(name: 'trigger_at') required DateTime triggerAt,
    @JsonKey(name: 'recurrence_rule') String? recurrenceRule,
    @JsonKey(name: 'linked_module') String? linkedModule,
    @JsonKey(name: 'linked_entity_id') String? linkedEntityId,
    @JsonKey(name: 'is_sent') required bool isSent,
    @JsonKey(name: 'sent_at') DateTime? sentAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}
