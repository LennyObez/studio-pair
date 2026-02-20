import 'package:drift/drift.dart';
import 'package:studio_pair/src/services/api/tasks_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/tasks_dao.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Repository that wraps the Tasks API and DAO to provide an
/// offline-first data layer with batch cache upserts.
class TasksRepository {
  TasksRepository(this._api, this._dao);

  final TasksApi _api;
  final TasksDao _dao;

  /// Returns cached tasks, then fetches fresh from API and updates cache.
  Future<List<CachedTask>> getTasks(
    String spaceId, {
    String? status,
    String? priority,
  }) async {
    try {
      final response = await _api.listTasks(
        spaceId,
        status: status,
        priority: priority,
      );
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedTasks,
          jsonList
              .map(
                (json) => CachedTasksCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  createdBy: json['created_by'] as String? ?? '',
                  title: json['title'] as String,
                  description: Value(json['description'] as String?),
                  status: json['status'] as String? ?? 'open',
                  priority: json['priority'] as String? ?? 'medium',
                  dueDate: Value(
                    DateTime.tryParse(json['due_date'] as String? ?? ''),
                  ),
                  parentTaskId: Value(json['parent_task_id'] as String?),
                  recurrenceRule: Value(json['recurrence_rule'] as String?),
                  createdAt:
                      DateTime.tryParse(json['created_at'] as String? ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(json['updated_at'] as String? ?? '') ??
                      DateTime.now(),
                  syncedAt: DateTime.now(),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
      return _dao.getTasks(spaceId, status: status, priority: priority).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao
          .getTasks(spaceId, status: status, priority: priority)
          .first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load tasks: $e');
    }
  }

  /// Creates a new task via the API.
  Future<Map<String, dynamic>> createTask(
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
  }) async {
    try {
      final response = await _api.createTask(
        spaceId,
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate,
        assignees: assignees,
        parentTaskId: parentTaskId,
        isRecurring: isRecurring,
        recurrenceRule: recurrenceRule,
        sourceModule: sourceModule,
        sourceEntityId: sourceEntityId,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to create task: $e');
    }
  }

  /// Gets a specific task by ID, with cache fallback.
  Future<Map<String, dynamic>> getTask(String spaceId, String taskId) async {
    try {
      final response = await _api.getTask(spaceId, taskId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getTaskById(taskId);
      if (cached != null) return {'id': cached.id, 'title': cached.title};
      throw UnknownFailure('Failed to get task: $e');
    }
  }

  /// Updates a task via the API.
  Future<Map<String, dynamic>> updateTask(
    String spaceId,
    String taskId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _api.updateTask(spaceId, taskId, data);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update task: $e');
    }
  }

  /// Deletes a task via the API and removes from cache.
  Future<void> deleteTask(String spaceId, String taskId) async {
    try {
      await _api.deleteTask(spaceId, taskId);
      await _dao.deleteTask(taskId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete task: $e');
    }
  }

  /// Assigns a user to a task.
  Future<Map<String, dynamic>> assignTask(
    String spaceId,
    String taskId,
    String userId,
  ) async {
    try {
      final response = await _api.assignTask(spaceId, taskId, userId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to assign task: $e');
    }
  }

  /// Unassigns a user from a task.
  Future<void> unassignTask(
    String spaceId,
    String taskId,
    String userId,
  ) async {
    try {
      await _api.unassignTask(spaceId, taskId, userId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to unassign task: $e');
    }
  }

  /// Marks a task as complete.
  Future<Map<String, dynamic>> completeTask(
    String spaceId,
    String taskId,
  ) async {
    try {
      final response = await _api.completeTask(spaceId, taskId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to complete task: $e');
    }
  }

  /// Reopens a completed task.
  Future<Map<String, dynamic>> reopenTask(String spaceId, String taskId) async {
    try {
      final response = await _api.reopenTask(spaceId, taskId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to reopen task: $e');
    }
  }

  /// Gets subtasks of a task, with cache fallback.
  Future<List<CachedTask>> getSubtasks(String spaceId, String taskId) async {
    try {
      final response = await _api.getSubtasks(spaceId, taskId);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedTasks,
          jsonList
              .map(
                (json) => CachedTasksCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  createdBy: json['created_by'] as String? ?? '',
                  title: json['title'] as String,
                  description: Value(json['description'] as String?),
                  status: json['status'] as String? ?? 'open',
                  priority: json['priority'] as String? ?? 'medium',
                  dueDate: Value(
                    DateTime.tryParse(json['due_date'] as String? ?? ''),
                  ),
                  parentTaskId: Value(json['parent_task_id'] as String?),
                  recurrenceRule: Value(json['recurrence_rule'] as String?),
                  createdAt:
                      DateTime.tryParse(json['created_at'] as String? ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(json['updated_at'] as String? ?? '') ??
                      DateTime.now(),
                  syncedAt: DateTime.now(),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
      return _dao.getSubtasks(taskId).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getSubtasks(taskId).first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to get subtasks: $e');
    }
  }

  /// Gets overdue tasks, with cache fallback.
  Future<List<CachedTask>> getOverdueTasks(String spaceId) async {
    try {
      final response = await _api.getOverdueTasks(spaceId);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedTasks,
          jsonList
              .map(
                (json) => CachedTasksCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  createdBy: json['created_by'] as String? ?? '',
                  title: json['title'] as String,
                  description: Value(json['description'] as String?),
                  status: json['status'] as String? ?? 'open',
                  priority: json['priority'] as String? ?? 'medium',
                  dueDate: Value(
                    DateTime.tryParse(json['due_date'] as String? ?? ''),
                  ),
                  parentTaskId: Value(json['parent_task_id'] as String?),
                  recurrenceRule: Value(json['recurrence_rule'] as String?),
                  createdAt:
                      DateTime.tryParse(json['created_at'] as String? ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(json['updated_at'] as String? ?? '') ??
                      DateTime.now(),
                  syncedAt: DateTime.now(),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
      return _dao.getOverdueTasks(spaceId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getOverdueTasks(spaceId);
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to get overdue tasks: $e');
    }
  }

  /// Gets tasks due today, with cache fallback.
  Future<List<CachedTask>> getTasksDueToday(String spaceId) async {
    try {
      final response = await _api.getTasksDueToday(spaceId);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedTasks,
          jsonList
              .map(
                (json) => CachedTasksCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  createdBy: json['created_by'] as String? ?? '',
                  title: json['title'] as String,
                  description: Value(json['description'] as String?),
                  status: json['status'] as String? ?? 'open',
                  priority: json['priority'] as String? ?? 'medium',
                  dueDate: Value(
                    DateTime.tryParse(json['due_date'] as String? ?? ''),
                  ),
                  parentTaskId: Value(json['parent_task_id'] as String?),
                  recurrenceRule: Value(json['recurrence_rule'] as String?),
                  createdAt:
                      DateTime.tryParse(json['created_at'] as String? ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(json['updated_at'] as String? ?? '') ??
                      DateTime.now(),
                  syncedAt: DateTime.now(),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
      return _dao.getTasksDueToday(spaceId).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getTasksDueToday(spaceId).first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to get tasks due today: $e');
    }
  }

  /// Watches cached tasks for a space (reactive stream).
  Stream<List<CachedTask>> watchTasks(
    String spaceId, {
    String? status,
    String? priority,
  }) {
    return _dao.getTasks(spaceId, status: status, priority: priority);
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
