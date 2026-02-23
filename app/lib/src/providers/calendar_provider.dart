import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/calendar_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/calendar_dao.dart';

/// Calendar event model.
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    this.location,
    required this.eventType,
    required this.allDay,
    required this.startAt,
    required this.endAt,
    this.recurrenceRule,
    this.sourceModule,
    this.sourceEntityId,
    this.createdBy,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String?,
      eventType: json['event_type'] as String? ?? 'personal',
      allDay: json['all_day'] as bool? ?? false,
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: DateTime.parse(json['end_at'] as String),
      recurrenceRule: json['recurrence_rule'] as String?,
      sourceModule: json['source_module'] as String?,
      sourceEntityId: json['source_entity_id'] as String?,
      createdBy: json['created_by'] as String?,
    );
  }

  final String id;
  final String title;
  final String? location;
  final String eventType;
  final bool allDay;
  final DateTime startAt;
  final DateTime endAt;
  final String? recurrenceRule;
  final String? sourceModule;
  final String? sourceEntityId;
  final String? createdBy;
}

/// Calendar state.
class CalendarState {
  const CalendarState({
    this.events = const [],
    this.selectedDate,
    this.viewMode = 'month',
    this.isLoading = false,
    this.isCached = false,
    this.error,
  });

  final List<CalendarEvent> events;
  final DateTime? selectedDate;
  final String viewMode;
  final bool isLoading;
  final bool isCached;
  final String? error;

  CalendarState copyWith({
    List<CalendarEvent>? events,
    DateTime? selectedDate,
    String? viewMode,
    bool? isLoading,
    bool? isCached,
    String? error,
    bool clearError = false,
  }) {
    return CalendarState(
      events: events ?? this.events,
      selectedDate: selectedDate ?? this.selectedDate,
      viewMode: viewMode ?? this.viewMode,
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Calendar state notifier managing events and calendar view.
class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier(this._api, this._dao)
    : super(CalendarState(selectedDate: DateTime.now()));

  final CalendarApi _api;
  final CalendarDao _dao;

  /// Load events for a space within a date range.
  Future<void> loadEvents(String spaceId, DateTime start, DateTime end) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // 1. Load from cache first
    try {
      final cached = await _dao.getEventsByDateRange(spaceId, start, end).first;
      if (cached.isNotEmpty) {
        final events = cached
            .map(
              (c) => CalendarEvent(
                id: c.id,
                title: c.title,
                location: c.location,
                eventType: c.eventType,
                allDay: c.allDay,
                startAt: c.startAt,
                endAt: c.endAt,
                recurrenceRule: c.recurrenceRule,
                sourceModule: c.sourceModule,
                sourceEntityId: c.sourceEntityId,
                createdBy: c.createdBy,
              ),
            )
            .toList();
        state = state.copyWith(
          events: events,
          isLoading: false,
          isCached: true,
        );
      }
    } catch (_) {
      // Cache read failed, continue to API
    }

    // 2. Try API in background
    try {
      final response = await _api.getEvents(
        spaceId,
        start: start.toIso8601String(),
        end: end.toIso8601String(),
      );
      final jsonList = parseList(response.data);
      final events = jsonList.map(CalendarEvent.fromJson).toList();

      // Upsert into cache
      for (final item in events) {
        await _dao.upsertEvent(
          CachedCalendarEventsCompanion(
            id: Value(item.id),
            spaceId: Value(spaceId),
            createdBy: Value(item.createdBy ?? ''),
            title: Value(item.title),
            location: Value(item.location),
            eventType: Value(item.eventType),
            allDay: Value(item.allDay),
            startAt: Value(item.startAt),
            endAt: Value(item.endAt),
            recurrenceRule: Value(item.recurrenceRule),
            sourceModule: Value(item.sourceModule),
            sourceEntityId: Value(item.sourceEntityId),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
            syncedAt: Value(DateTime.now()),
          ),
        );
      }

      state = state.copyWith(events: events, isLoading: false, isCached: false);
    } catch (e) {
      if (state.events.isEmpty) {
        state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Select a date on the calendar.
  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// Set the calendar view mode (day, week, month).
  void setViewMode(String mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// Create a new calendar event.
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
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.createEvent(
        spaceId,
        title: title,
        location: location,
        eventType: eventType,
        allDay: allDay,
        startAt: startAt.toIso8601String(),
        endAt: endAt.toIso8601String(),
        recurrenceRule: recurrenceRule,
      );
      final newEvent = CalendarEvent.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        events: [...state.events, newEvent],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Update an existing calendar event.
  Future<bool> updateEvent(
    String spaceId,
    String eventId,
    Map<String, dynamic> data,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.updateEvent(spaceId, eventId, data);
      final updatedEvent = CalendarEvent.fromJson(
        response.data as Map<String, dynamic>,
      );

      final updatedEvents = state.events.map((event) {
        if (event.id == eventId) return updatedEvent;
        return event;
      }).toList();

      state = state.copyWith(events: updatedEvents, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Delete a calendar event.
  Future<bool> deleteEvent(String spaceId, String eventId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.deleteEvent(spaceId, eventId);

      state = state.copyWith(
        events: state.events.where((e) => e.id != eventId).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Calendar state provider.
final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>(
  (ref) {
    return CalendarNotifier(
      ref.watch(calendarApiProvider),
      ref.watch(calendarDaoProvider),
    );
  },
);

/// Convenience provider for calendar events.
final calendarEventsProvider = Provider<List<CalendarEvent>>((ref) {
  return ref.watch(calendarProvider).events;
});

/// Convenience provider for the selected date.
final selectedDateProvider = Provider<DateTime?>((ref) {
  return ref.watch(calendarProvider).selectedDate;
});
