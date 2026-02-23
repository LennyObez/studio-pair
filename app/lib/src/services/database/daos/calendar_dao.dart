import 'package:drift/drift.dart';
import '../app_database.dart';

part 'calendar_dao.g.dart';

@DriftAccessor(tables: [CachedCalendarEvents])
class CalendarDao extends DatabaseAccessor<AppDatabase>
    with _$CalendarDaoMixin {
  CalendarDao(super.db);

  /// Inserts or updates a cached calendar event.
  Future<void> upsertEvent(CachedCalendarEventsCompanion event) {
    return into(cachedCalendarEvents).insertOnConflictUpdate(event);
  }

  /// Watches calendar events within a date range for a given space.
  Stream<List<CachedCalendarEvent>> getEventsByDateRange(
    String spaceId,
    DateTime start,
    DateTime end,
  ) {
    return (select(cachedCalendarEvents)
          ..where(
            (t) =>
                t.spaceId.equals(spaceId) &
                t.startAt.isSmallerOrEqualValue(end) &
                t.endAt.isBiggerOrEqualValue(start),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.startAt)]))
        .watch();
  }

  /// Retrieves a single calendar event by its ID, or null if not found.
  Future<CachedCalendarEvent?> getEventById(String id) {
    return (select(
      cachedCalendarEvents,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Deletes a calendar event from the local cache.
  Future<int> deleteEvent(String id) {
    return (delete(cachedCalendarEvents)..where((t) => t.id.equals(id))).go();
  }

  /// Watches all upcoming events for a space starting from now.
  Stream<List<CachedCalendarEvent>> getUpcomingEvents(
    String spaceId, {
    int limit = 10,
  }) {
    return (select(cachedCalendarEvents)
          ..where(
            (t) =>
                t.spaceId.equals(spaceId) &
                t.startAt.isBiggerOrEqualValue(DateTime.now()),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.startAt)])
          ..limit(limit))
        .watch();
  }

  /// Retrieves all events for a specific day in a space.
  Stream<List<CachedCalendarEvent>> getEventsForDay(
    String spaceId,
    DateTime day,
  ) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return getEventsByDateRange(spaceId, dayStart, dayEnd);
  }
}
