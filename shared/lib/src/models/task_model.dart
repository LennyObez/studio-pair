import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/task_priority.dart';
import '../enums/task_status.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

/// Represents a task within a space.
@freezed
abstract class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    @JsonKey(name: 'space_id') required String spaceId,
    @JsonKey(name: 'created_by') required String createdBy,
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'parent_task_id') String? parentTaskId,
    @JsonKey(name: 'is_recurring') required bool isRecurring,
    @JsonKey(name: 'recurrence_rule') String? recurrenceRule,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
}
