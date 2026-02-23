import 'package:drift/drift.dart';
import '../app_database.dart';

part 'reminders_dao.g.dart';

@DriftAccessor(tables: [CachedReminders])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);

  /// Inserts or updates a cached reminder.
  Future<void> upsertReminder(CachedRemindersCompanion reminder) {
    return into(cachedReminders).insertOnConflictUpdate(reminder);
  }

  /// Watches all reminders for a given space, ordered by trigger time ascending.
  Stream<List<CachedReminder>> getReminders(String spaceId) {
    return (select(cachedReminders)
          ..where((t) => t.spaceId.equals(spaceId))
          ..orderBy([(t) => OrderingTerm.asc(t.triggerAt)]))
        .watch();
  }

  /// Retrieves a single reminder by its ID, or null if not found.
  Future<CachedReminder?> getReminderById(String id) {
    return (select(
      cachedReminders,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Deletes a reminder from the local cache.
  Future<int> deleteReminder(String id) {
    return (delete(cachedReminders)..where((t) => t.id.equals(id))).go();
  }

  /// Retrieves upcoming unsent reminders for a space (triggerAt in the future, not yet sent).
  Future<List<CachedReminder>> getUpcomingReminders(String spaceId) {
    return (select(cachedReminders)
          ..where(
            (t) =>
                t.spaceId.equals(spaceId) &
                t.triggerAt.isBiggerThanValue(DateTime.now()) &
                t.isSent.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.triggerAt)]))
        .get();
  }
}
