import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'tasks_dao.g.dart';

@DriftAccessor(tables: [CachedTasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  /// Inserts or updates a cached task.
  Future<void> upsertTask(CachedTasksCompanion task) {
    try {
      return into(cachedTasks).insertOnConflictUpdate(task);
    } catch (e) {
      throw StorageFailure('Failed to upsert task: $e');
    }
  }

  /// Watches tasks for a given space with optional status and priority filters.
  Stream<List<CachedTask>> getTasks(
    String spaceId, {
    String? status,
    String? priority,
  }) {
    try {
      return (select(cachedTasks)
            ..where((t) {
              var condition = t.spaceId.equals(spaceId);
              if (status != null) {
                condition = condition & t.status.equals(status);
              }
              if (priority != null) {
                condition = condition & t.priority.equals(priority);
              }
              return condition;
            })
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get tasks: $e');
    }
  }

  /// Retrieves a single task by its ID, or null if not found.
  Future<CachedTask?> getTaskById(String id) {
    try {
      return (select(
        cachedTasks,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      throw StorageFailure('Failed to get task by id: $e');
    }
  }

  /// Deletes a task from the local cache.
  Future<int> deleteTask(String id) {
    try {
      return (delete(cachedTasks)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete task: $e');
    }
  }

  /// Retrieves overdue tasks for a space (due date in the past, not completed).
  Future<List<CachedTask>> getOverdueTasks(String spaceId) {
    try {
      return (select(cachedTasks)
            ..where(
              (t) =>
                  t.spaceId.equals(spaceId) &
                  t.dueDate.isSmallerThanValue(DateTime.now()) &
                  t.completedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .get();
    } catch (e) {
      throw StorageFailure('Failed to get overdue tasks: $e');
    }
  }

  /// Watches subtasks for a given parent task.
  Stream<List<CachedTask>> getSubtasks(String parentTaskId) {
    try {
      return (select(cachedTasks)
            ..where((t) => t.parentTaskId.equals(parentTaskId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get subtasks: $e');
    }
  }

  /// Watches tasks due today for a space.
  Stream<List<CachedTask>> getTasksDueToday(String spaceId) {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      return (select(cachedTasks)
            ..where(
              (t) =>
                  t.spaceId.equals(spaceId) &
                  t.dueDate.isBiggerOrEqualValue(todayStart) &
                  t.dueDate.isSmallerThanValue(todayEnd),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get tasks due today: $e');
    }
  }

  /// Batch upserts tasks into cache.
  Future<void> upsertTasks(List<CachedTasksCompanion> tasks) {
    try {
      return batch((b) {
        b.insertAll(cachedTasks, tasks, mode: InsertMode.insertOrReplace);
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert tasks: $e');
    }
  }
}
