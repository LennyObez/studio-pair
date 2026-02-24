import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';

// ── Filter state providers ──────────────────────────────────────────────

/// Filter by task status ('all' = no filter).
final taskStatusFilter = StateProvider<String>((ref) => 'all');

// ── Async notifier ──────────────────────────────────────────────────────

/// Tasks notifier backed by the [TasksRepository].
///
/// The [build] method fetches tasks from the repository (API + cache)
/// whenever the current space changes. Mutation methods delegate to the
/// repository and re-fetch the full list so the UI stays in sync.
class TasksNotifier extends AutoDisposeAsyncNotifier<List<CachedTask>> {
  @override
  Future<List<CachedTask>> build() async {
    final repo = ref.watch(tasksRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    if (spaceId == null) return [];
    return repo.getTasks(spaceId);
  }

  /// Create a new task and refresh the list.
  Future<bool> createTask(
    String spaceId, {
    required String title,
    String? description,
    String? priority,
    String? dueDate,
    List<String>? assignees,
    String? parentTaskId,
  }) async {
    final repo = ref.read(tasksRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.createTask(
        spaceId,
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        assignees: assignees,
        parentTaskId: parentTaskId,
      );
      return repo.getTasks(spaceId);
    });
    return !state.hasError;
  }

  /// Update a task and refresh the list.
  Future<bool> updateTask(
    String spaceId,
    String taskId,
    Map<String, dynamic> data,
  ) async {
    final repo = ref.read(tasksRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.updateTask(spaceId, taskId, data);
      return repo.getTasks(spaceId);
    });
    return !state.hasError;
  }

  /// Delete a task and refresh the list.
  Future<bool> deleteTask(String spaceId, String taskId) async {
    final repo = ref.read(tasksRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteTask(spaceId, taskId);
      return repo.getTasks(spaceId);
    });
    return !state.hasError;
  }

  /// Mark a task as complete and refresh the list.
  Future<bool> completeTask(String spaceId, String taskId) async {
    final repo = ref.read(tasksRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.completeTask(spaceId, taskId);
      return repo.getTasks(spaceId);
    });
    return !state.hasError;
  }

  /// Reopen a completed task and refresh the list.
  Future<bool> reopenTask(String spaceId, String taskId) async {
    final repo = ref.read(tasksRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.reopenTask(spaceId, taskId);
      return repo.getTasks(spaceId);
    });
    return !state.hasError;
  }

  /// Assign a user to a task and refresh the list.
  Future<bool> assignTask(String spaceId, String taskId, String userId) async {
    final repo = ref.read(tasksRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.assignTask(spaceId, taskId, userId);
      return repo.getTasks(spaceId);
    });
    return !state.hasError;
  }
}

/// Tasks async provider.
final tasksProvider =
    AsyncNotifierProvider.autoDispose<TasksNotifier, List<CachedTask>>(
      TasksNotifier.new,
    );

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for the filtered task list.
final taskListProvider = Provider<List<CachedTask>>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? [];
  final filter = ref.watch(taskStatusFilter);
  if (filter == 'all') return tasks;
  return tasks.where((t) => t.status == filter).toList();
});

/// Convenience provider for the count of pending (non-done) tasks.
final pendingTaskCountProvider = Provider<int>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? [];
  return tasks.where((t) => t.status != 'done').length;
});
