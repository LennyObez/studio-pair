import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/task_priority.dart';
import '../enums/task_status.dart';

part 'task_model.g.dart';

/// Represents a task within a space.
@JsonSerializable()
class TaskModel extends Equatable {
  const TaskModel({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.parentTaskId,
    required this.isRecurring,
    this.recurrenceRule,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

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

  @JsonKey(name: 'status')
  final TaskStatus status;

  @JsonKey(name: 'priority')
  final TaskPriority priority;

  @JsonKey(name: 'due_date')
  final DateTime? dueDate;

  @JsonKey(name: 'parent_task_id')
  final String? parentTaskId;

  @JsonKey(name: 'is_recurring')
  final bool isRecurring;

  @JsonKey(name: 'recurrence_rule')
  final String? recurrenceRule;

  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    spaceId,
    createdBy,
    title,
    description,
    status,
    priority,
    dueDate,
    parentTaskId,
    isRecurring,
    recurrenceRule,
    completedAt,
    createdAt,
    updatedAt,
  ];
}
