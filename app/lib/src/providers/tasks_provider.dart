import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/tasks_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/tasks_dao.dart';

/// Parse a response that may be a List directly or a Map with a 'data' key.
/// Returns the list of items plus optional cursor and hasMore metadata.
({List<Map<String, dynamic>> items, String? cursor, bool hasMore})
_parseListResponse(dynamic data) {
  if (data is List) {
    return (
      items: data.cast<Map<String, dynamic>>(),
      cursor: null,
      hasMore: false,
    );
  }
  if (data is Map) {
    final itemsKey = data.containsKey('data')
        ? 'data'
        : (data.containsKey('items') ? 'items' : null);
    if (itemsKey != null) {
      return (
        items: (data[itemsKey] as List).cast<Map<String, dynamic>>(),
        cursor: data['cursor'] as String?,
        hasMore: data['has_more'] as bool? ?? data['hasMore'] as bool? ?? false,
      );
    }
  }
  return (items: <Map<String, dynamic>>[], cursor: null, hasMore: false);
}

/// Task item model.
class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.assignees = const [],
    this.createdBy,
    this.parentTaskId,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'todo',
      priority: json['priority'] as String? ?? 'medium',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      assignees: (json['assignees'] as List?)?.cast<String>() ?? [],
      createdBy: json['created_by'] as String?,
      parentTaskId: json['parent_task_id'] as String?,
    );
  }

  final String id;
  final String title;
  final String? description;
  final String status; // todo, in_progress, done
  final String priority; // low, medium, high, urgent
  final DateTime? dueDate;
  final List<String> assignees;
  final String? createdBy;
  final String? parentTaskId;
}

/// Tasks state.
class TasksState {
  const TasksState({
    this.tasks = const [],
    this.filter = 'all',
    this.isLoading = false,
    this.isCached = false,
    this.error,
    this.cursor,
    this.hasMore = false,
  });

  final List<TaskItem> tasks;
  final String filter;
  final bool isLoading;
  final bool isCached;
  final String? error;
  final String? cursor;
  final bool hasMore;

  TasksState copyWith({
    List<TaskItem>? tasks,
    String? filter,
    bool? isLoading,
    bool? isCached,
    String? error,
    String? cursor,
    bool? hasMore,
    bool clearError = false,
    bool clearCursor = false,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      error: clearError ? null : (error ?? this.error),
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Tasks state notifier managing task CRUD and filtering.
class TasksNotifier extends StateNotifier<TasksState> {
  TasksNotifier(this._api, this._dao) : super(const TasksState());

  final TasksApi _api;
  final TasksDao _dao;

  /// Load tasks for a space with optional filters.
  Future<void> loadTasks(
    String spaceId, {
    String? status,
    String? priority,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // 1. Load from cache first
    try {
      final cached = await _dao
          .getTasks(spaceId, status: status, priority: priority)
          .first;
      if (cached.isNotEmpty) {
        final tasks = cached
            .map(
              (c) => TaskItem(
                id: c.id,
                title: c.title,
                description: c.description,
                status: c.status,
                priority: c.priority,
                dueDate: c.dueDate,
                createdBy: c.createdBy,
                parentTaskId: c.parentTaskId,
              ),
            )
            .toList();
        state = state.copyWith(tasks: tasks, isLoading: false, isCached: true);
      }
    } catch (_) {
      // Cache read failed, continue to API
    }

    // 2. Try API in background
    try {
      final response = await _api.listTasks(
        spaceId,
        status: status,
        priority: priority,
      );
      final parsed = _parseListResponse(response.data);
      final tasks = parsed.items.map(TaskItem.fromJson).toList();

      // Upsert into cache
      for (final item in tasks) {
        await _dao.upsertTask(
          CachedTasksCompanion(
            id: Value(item.id),
            spaceId: Value(spaceId),
            createdBy: Value(item.createdBy ?? ''),
            title: Value(item.title),
            description: Value(item.description),
            status: Value(item.status),
            priority: Value(item.priority),
            dueDate: Value(item.dueDate),
            parentTaskId: Value(item.parentTaskId),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
            syncedAt: Value(DateTime.now()),
          ),
        );
      }

      state = state.copyWith(
        tasks: tasks,
        isLoading: false,
        isCached: false,
        cursor: parsed.cursor,
        hasMore: parsed.hasMore,
      );
    } catch (e) {
      if (state.tasks.isEmpty) {
        state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Create a new task.
  Future<bool> createTask(
    String spaceId, {
    required String title,
    String? description,
    required String priority,
    DateTime? dueDate,
    List<String>? assignees,
    String? parentTaskId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.createTask(
        spaceId,
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate?.toIso8601String(),
        assignees: assignees,
        parentTaskId: parentTaskId,
      );
      final newTask = TaskItem.fromJson(response.data as Map<String, dynamic>);

      state = state.copyWith(
        tasks: [newTask, ...state.tasks],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Update an existing task.
  Future<bool> updateTask(
    String spaceId,
    String taskId,
    Map<String, dynamic> data,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.updateTask(spaceId, taskId, data);
      final updatedTask = TaskItem.fromJson(
        response.data as Map<String, dynamic>,
      );

      final updatedTasks = state.tasks.map((task) {
        if (task.id == taskId) return updatedTask;
        return task;
      }).toList();

      state = state.copyWith(tasks: updatedTasks, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Delete a task.
  Future<bool> deleteTask(String spaceId, String taskId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.deleteTask(spaceId, taskId);

      state = state.copyWith(
        tasks: state.tasks.where((t) => t.id != taskId).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Mark a task as done.
  Future<bool> completeTask(String spaceId, String taskId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.completeTask(spaceId, taskId);

      final updatedTasks = state.tasks.map((task) {
        if (task.id == taskId) {
          return TaskItem(
            id: task.id,
            title: task.title,
            description: task.description,
            status: 'done',
            priority: task.priority,
            dueDate: task.dueDate,
            assignees: task.assignees,
            createdBy: task.createdBy,
            parentTaskId: task.parentTaskId,
          );
        }
        return task;
      }).toList();

      state = state.copyWith(tasks: updatedTasks, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Reopen a completed task.
  Future<bool> reopenTask(String spaceId, String taskId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.reopenTask(spaceId, taskId);

      final updatedTasks = state.tasks.map((task) {
        if (task.id == taskId) {
          return TaskItem(
            id: task.id,
            title: task.title,
            description: task.description,
            status: 'todo',
            priority: task.priority,
            dueDate: task.dueDate,
            assignees: task.assignees,
            createdBy: task.createdBy,
            parentTaskId: task.parentTaskId,
          );
        }
        return task;
      }).toList();

      state = state.copyWith(tasks: updatedTasks, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Set the current filter.
  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Tasks state provider.
final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  return TasksNotifier(
    ref.watch(tasksApiProvider),
    ref.watch(tasksDaoProvider),
  );
});

/// Convenience provider for the filtered task list.
final taskListProvider = Provider<List<TaskItem>>((ref) {
  final tasksState = ref.watch(tasksProvider);
  if (tasksState.filter == 'all') return tasksState.tasks;
  return tasksState.tasks.where((t) => t.status == tasksState.filter).toList();
});

/// Convenience provider for the count of pending (non-done) tasks.
final pendingTaskCountProvider = Provider<int>((ref) {
  return ref.watch(tasksProvider).tasks.where((t) => t.status != 'done').length;
});
