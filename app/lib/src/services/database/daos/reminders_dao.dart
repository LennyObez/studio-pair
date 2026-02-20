import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'reminders_dao.g.dart';

@DriftAccessor(tables: [CachedReminders])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);

  /// Inserts or updates a cached reminder.
  Future<void> upsertReminder(CachedRemindersCompanion reminder) {
    try {
      return into(cachedReminders).insertOnConflictUpdate(reminder);
    } catch (e) {
      throw StorageFailure('Failed to upsert reminder: $e');
    }
  }

  /// Watches all reminders for a given space, ordered by trigger time ascending.
  Stream<List<CachedReminder>> getReminders(String spaceId) {
    try {
      return (select(cachedReminders)
            ..where((t) => t.spaceId.equals(spaceId))
            ..orderBy([(t) => OrderingTerm.asc(t.triggerAt)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get reminders: $e');
    }
  }

  /// Retrieves a single reminder by its ID, or null if not found.
  Future<CachedReminder?> getReminderById(String id) {
    try {
      return (select(
        cachedReminders,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      throw StorageFailure('Failed to get reminder by id: $e');
    }
  }

  /// Deletes a reminder from the local cache.
  Future<int> deleteReminder(String id) {
    try {
      return (delete(cachedReminders)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete reminder: $e');
    }
  }

  /// Retrieves upcoming unsent reminders for a space (triggerAt in the future, not yet sent).
  Future<List<CachedReminder>> getUpcomingReminders(String spaceId) {
    try {
      return (select(cachedReminders)
            ..where(
              (t) =>
                  t.spaceId.equals(spaceId) &
                  t.triggerAt.isBiggerThanValue(DateTime.now()) &
                  t.isSent.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.triggerAt)]))
          .get();
    } catch (e) {
      throw StorageFailure('Failed to get upcoming reminders: $e');
    }
  }

  /// Batch upserts reminders into cache.
  Future<void> upsertReminders(List<CachedRemindersCompanion> reminders) {
    try {
      return batch((b) {
        b.insertAll(
          cachedReminders,
          reminders,
          mode: InsertMode.insertOrReplace,
        );
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert reminders: $e');
    }
  }
}
