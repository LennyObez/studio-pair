import 'package:drift/drift.dart';
import '../app_database.dart';

part 'tasks_dao.g.dart';

@DriftAccessor(tables: [CachedTasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  /// Inserts or updates a cached task.
  Future<void> upsertTask(CachedTasksCompanion task) {
    return into(cachedTasks).insertOnConflictUpdate(task);
  }

  /// Watches tasks for a given space with optional status and priority filters.
  Stream<List<CachedTask>> getTasks(
    String spaceId, {
    String? status,
    String? priority,
  }) {
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
  }

  /// Retrieves a single task by its ID, or null if not found.
  Future<CachedTask?> getTaskById(String id) {
    return (select(
      cachedTasks,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Deletes a task from the local cache.
  Future<int> deleteTask(String id) {
    return (delete(cachedTasks)..where((t) => t.id.equals(id))).go();
  }

  /// Retrieves overdue tasks for a space (due date in the past, not completed).
  Future<List<CachedTask>> getOverdueTasks(String spaceId) {
    return (select(cachedTasks)
          ..where(
            (t) =>
                t.spaceId.equals(spaceId) &
                t.dueDate.isSmallerThanValue(DateTime.now()) &
                t.completedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Watches subtasks for a given parent task.
  Stream<List<CachedTask>> getSubtasks(String parentTaskId) {
    return (select(cachedTasks)
          ..where((t) => t.parentTaskId.equals(parentTaskId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// Watches tasks due today for a space.
  Stream<List<CachedTask>> getTasksDueToday(String spaceId) {
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
  }
}
