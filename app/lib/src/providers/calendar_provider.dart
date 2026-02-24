import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';

// ── View state providers ────────────────────────────────────────────────

/// Currently selected date on the calendar.
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Calendar view mode (day, week, month).
final calendarViewModeProvider = StateProvider<String>((ref) => 'month');

// ── Async notifier ──────────────────────────────────────────────────────

/// Calendar notifier backed by the [CalendarRepository].
///
/// The [build] method fetches events for the current month (or selected date
/// range) from the repository (API + cache) whenever the current space or
/// selected date changes.
class CalendarNotifier
    extends AutoDisposeAsyncNotifier<List<CachedCalendarEvent>> {
  @override
  Future<List<CachedCalendarEvent>> build() async {
    final repo = ref.watch(calendarRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    if (spaceId == null) return [];

    final selectedDate = ref.watch(selectedDateProvider);
    final start = DateTime(selectedDate.year, selectedDate.month);
    final end = DateTime(selectedDate.year, selectedDate.month + 1);

    return repo.getEvents(
      spaceId,
      start: start.toIso8601String(),
      end: end.toIso8601String(),
    );
  }

  /// Load events for an explicit date range.
  Future<void> loadEvents(String spaceId, DateTime start, DateTime end) async {
    final repo = ref.read(calendarRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.getEvents(
        spaceId,
        start: start.toIso8601String(),
        end: end.toIso8601String(),
      ),
    );
  }

  /// Create a new calendar event and refresh the list.
  Future<bool> createEvent(
    String spaceId, {
    required String title,
    String? location,
    required String eventType,
    required bool allDay,
    required DateTime startAt,
    required DateTime endAt,
    String? recurrenceRule,
  }) async {
    final repo = ref.read(calendarRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.createEvent(
        spaceId,
        title: title,
        location: location,
        eventType: eventType,
        allDay: allDay,
        startAt: startAt.toIso8601String(),
        endAt: endAt.toIso8601String(),
        recurrenceRule: recurrenceRule,
      );
      // Re-fetch the current month's events.
      final sel = ref.read(selectedDateProvider);
      final monthStart = DateTime(sel.year, sel.month);
      final monthEnd = DateTime(sel.year, sel.month + 1);
      return repo.getEvents(
        spaceId,
        start: monthStart.toIso8601String(),
        end: monthEnd.toIso8601String(),
      );
    });
    return !state.hasError;
  }

  /// Update a calendar event and refresh the list.
  Future<bool> updateEvent(
    String spaceId,
    String eventId,
    Map<String, dynamic> data,
  ) async {
    final repo = ref.read(calendarRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.updateEvent(spaceId, eventId, data);
      final sel = ref.read(selectedDateProvider);
      final monthStart = DateTime(sel.year, sel.month);
      final monthEnd = DateTime(sel.year, sel.month + 1);
      return repo.getEvents(
        spaceId,
        start: monthStart.toIso8601String(),
        end: monthEnd.toIso8601String(),
      );
    });
    return !state.hasError;
  }

  /// Delete a calendar event and refresh the list.
  Future<bool> deleteEvent(String spaceId, String eventId) async {
    final repo = ref.read(calendarRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteEvent(spaceId, eventId);
      final sel = ref.read(selectedDateProvider);
      final monthStart = DateTime(sel.year, sel.month);
      final monthEnd = DateTime(sel.year, sel.month + 1);
      return repo.getEvents(
        spaceId,
        start: monthStart.toIso8601String(),
        end: monthEnd.toIso8601String(),
      );
    });
    return !state.hasError;
  }
}

/// Calendar async provider.
final calendarProvider =
    AsyncNotifierProvider.autoDispose<
      CalendarNotifier,
      List<CachedCalendarEvent>
    >(CalendarNotifier.new);

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for the current list of calendar events.
final calendarEventsProvider = Provider<List<CachedCalendarEvent>>((ref) {
  return ref.watch(calendarProvider).valueOrNull ?? [];
});
