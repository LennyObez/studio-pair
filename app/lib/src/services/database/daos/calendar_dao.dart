import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'calendar_dao.g.dart';

@DriftAccessor(tables: [CachedCalendarEvents])
class CalendarDao extends DatabaseAccessor<AppDatabase>
    with _$CalendarDaoMixin {
  CalendarDao(super.db);

  /// Inserts or updates a cached calendar event.
  Future<void> upsertEvent(CachedCalendarEventsCompanion event) {
    try {
      return into(cachedCalendarEvents).insertOnConflictUpdate(event);
    } catch (e) {
      throw StorageFailure('Failed to upsert calendar event: $e');
    }
  }

  /// Watches calendar events within a date range for a given space.
  Stream<List<CachedCalendarEvent>> getEventsByDateRange(
    String spaceId,
    DateTime start,
    DateTime end,
  ) {
    try {
      return (select(cachedCalendarEvents)
            ..where(
              (t) =>
                  t.spaceId.equals(spaceId) &
                  t.startAt.isSmallerOrEqualValue(end) &
                  t.endAt.isBiggerOrEqualValue(start),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.startAt)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get events by date range: $e');
    }
  }

  /// Retrieves a single calendar event by its ID, or null if not found.
  Future<CachedCalendarEvent?> getEventById(String id) {
    try {
      return (select(
        cachedCalendarEvents,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      throw StorageFailure('Failed to get event by id: $e');
    }
  }

  /// Deletes a calendar event from the local cache.
  Future<int> deleteEvent(String id) {
    try {
      return (delete(cachedCalendarEvents)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete calendar event: $e');
    }
  }

  /// Watches all upcoming events for a space starting from now.
  Stream<List<CachedCalendarEvent>> getUpcomingEvents(
    String spaceId, {
    int limit = 10,
  }) {
    try {
      return (select(cachedCalendarEvents)
            ..where(
              (t) =>
                  t.spaceId.equals(spaceId) &
                  t.startAt.isBiggerOrEqualValue(DateTime.now()),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.startAt)])
            ..limit(limit))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get upcoming events: $e');
    }
  }

  /// Retrieves all events for a specific day in a space.
  Stream<List<CachedCalendarEvent>> getEventsForDay(
    String spaceId,
    DateTime day,
  ) {
    try {
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      return getEventsByDateRange(spaceId, dayStart, dayEnd);
    } catch (e) {
      throw StorageFailure('Failed to get events for day: $e');
    }
  }

  /// Batch upserts calendar events into cache.
  Future<void> upsertEvents(List<CachedCalendarEventsCompanion> events) {
    try {
      return batch((b) {
        b.insertAll(
          cachedCalendarEvents,
          events,
          mode: InsertMode.insertOrReplace,
        );
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert calendar events: $e');
    }
  }
}
