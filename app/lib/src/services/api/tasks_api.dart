import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Tasks API service for managing tasks and assignments within a space.
class TasksApi {
  TasksApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Create a new task.
  Future<Response> createTask(
    String spaceId, {
    required String title,
    String? description,
    String? status,
    String? priority,
    String? dueDate,
    List<String>? assignees,
    String? parentTaskId,
    bool? isRecurring,
    String? recurrenceRule,
    String? sourceModule,
    String? sourceEntityId,
  }) {
    return _client.post(
      '/spaces/$spaceId/tasks/',
      data: {
        'title': title,
        if (description != null) 'description': description,
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
        if (dueDate != null) 'due_date': dueDate,
        if (assignees != null) 'assignees': assignees,
        if (parentTaskId != null) 'parent_task_id': parentTaskId,
        if (isRecurring != null) 'is_recurring': isRecurring,
        if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
        if (sourceModule != null) 'source_module': sourceModule,
        if (sourceEntityId != null) 'source_entity_id': sourceEntityId,
      },
    );
  }

  /// List tasks with optional filters.
  Future<Response> listTasks(
    String spaceId, {
    String? status,
    String? priority,
    String? assignedTo,
    String? cursor,
    int? limit,
  }) {
    return _client.get(
      '/spaces/$spaceId/tasks/',
      queryParameters: {
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
        if (assignedTo != null) 'assigned_to': assignedTo,
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
  }

  /// Get a specific task by ID.
  Future<Response> getTask(String spaceId, String taskId) {
    return _client.get('/spaces/$spaceId/tasks/$taskId');
  }

  /// Update an existing task.
  Future<Response> updateTask(
    String spaceId,
    String taskId,
    Map<String, dynamic> data,
  ) {
    return _client.patch('/spaces/$spaceId/tasks/$taskId', data: data);
  }

  /// Delete a task.
  Future<Response> deleteTask(String spaceId, String taskId) {
    return _client.delete('/spaces/$spaceId/tasks/$taskId');
  }

  /// Assign a user to a task.
  Future<Response> assignTask(String spaceId, String taskId, String userId) {
    return _client.post(
      '/spaces/$spaceId/tasks/$taskId/assign',
      data: {'user_id': userId},
    );
  }

  /// Unassign a user from a task.
  Future<Response> unassignTask(String spaceId, String taskId, String userId) {
    return _client.delete('/spaces/$spaceId/tasks/$taskId/assign/$userId');
  }

  /// Mark a task as complete.
  Future<Response> completeTask(String spaceId, String taskId) {
    return _client.post('/spaces/$spaceId/tasks/$taskId/complete');
  }

  /// Reopen a completed task.
  Future<Response> reopenTask(String spaceId, String taskId) {
    return _client.post('/spaces/$spaceId/tasks/$taskId/reopen');
  }

  /// Get subtasks of a task.
  Future<Response> getSubtasks(String spaceId, String taskId) {
    return _client.get('/spaces/$spaceId/tasks/$taskId/subtasks');
  }

  /// Get all overdue tasks in the space.
  Future<Response> getOverdueTasks(String spaceId) {
    return _client.get('/spaces/$spaceId/tasks/overdue');
  }

  /// Get tasks due today in the space.
  Future<Response> getTasksDueToday(String spaceId) {
    return _client.get('/spaces/$spaceId/tasks/today');
  }
}
