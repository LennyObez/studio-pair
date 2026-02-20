import 'package:drift/drift.dart';
import 'package:studio_pair/src/services/api/calendar_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/calendar_dao.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Repository that wraps the Calendar API and DAO to provide an
/// offline-first data layer with batch cache upserts.
class CalendarRepository {
  CalendarRepository(this._api, this._dao);

  final CalendarApi _api;
  final CalendarDao _dao;

  /// Returns cached calendar events within a date range, fetches fresh from API
  /// and updates cache.
  Future<List<CachedCalendarEvent>> getEvents(
    String spaceId, {
    required String start,
    required String end,
  }) async {
    try {
      final response = await _api.getEvents(spaceId, start: start, end: end);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedCalendarEvents,
          jsonList
              .map(
                (json) => CachedCalendarEventsCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  createdBy: json['created_by'] as String? ?? '',
                  title: json['title'] as String,
                  location: Value(json['location'] as String?),
                  eventType: json['event_type'] as String? ?? 'general',
                  startAt:
                      DateTime.tryParse(json['start_at'] as String? ?? '') ??
                      DateTime.now(),
                  endAt:
                      DateTime.tryParse(json['end_at'] as String? ?? '') ??
                      DateTime.now(),
                  recurrenceRule: Value(json['recurrence_rule'] as String?),
                  sourceModule: Value(json['source_module'] as String?),
                  sourceEntityId: Value(json['source_entity_id'] as String?),
                  createdAt:
                      DateTime.tryParse(json['created_at'] as String? ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(json['updated_at'] as String? ?? '') ??
                      DateTime.now(),
                  syncedAt: DateTime.now(),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
      final startDt = DateTime.tryParse(start) ?? DateTime.now();
      final endDt = DateTime.tryParse(end) ?? DateTime.now();
      return _dao.getEventsByDateRange(spaceId, startDt, endDt).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final startDt = DateTime.tryParse(start) ?? DateTime.now();
      final endDt = DateTime.tryParse(end) ?? DateTime.now();
      final cached = await _dao
          .getEventsByDateRange(spaceId, startDt, endDt)
          .first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load calendar events: $e');
    }
  }

  /// Gets upcoming events, with cache fallback.
  Future<List<CachedCalendarEvent>> getUpcomingEvents(
    String spaceId, {
    int? limit,
  }) async {
    try {
      final response = await _api.getUpcomingEvents(spaceId, limit: limit);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedCalendarEvents,
          jsonList
              .map(
                (json) => CachedCalendarEventsCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  createdBy: json['created_by'] as String? ?? '',
                  title: json['title'] as String,
                  location: Value(json['location'] as String?),
                  eventType: json['event_type'] as String? ?? 'general',
                  startAt:
                      DateTime.tryParse(json['start_at'] as String? ?? '') ??
                      DateTime.now(),
                  endAt:
                      DateTime.tryParse(json['end_at'] as String? ?? '') ??
                      DateTime.now(),
                  recurrenceRule: Value(json['recurrence_rule'] as String?),
                  sourceModule: Value(json['source_module'] as String?),
                  sourceEntityId: Value(json['source_entity_id'] as String?),
                  createdAt:
                      DateTime.tryParse(json['created_at'] as String? ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(json['updated_at'] as String? ?? '') ??
                      DateTime.now(),
                  syncedAt: DateTime.now(),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
      return _dao.getUpcomingEvents(spaceId, limit: limit ?? 10).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao
          .getUpcomingEvents(spaceId, limit: limit ?? 10)
          .first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load upcoming events: $e');
    }
  }

  /// Creates a new calendar event via the API.
  Future<Map<String, dynamic>> createEvent(
    String spaceId, {
    required String title,
    String? location,
    required String eventType,
    required bool allDay,
    required String startAt,
    required String endAt,
    String? recurrenceRule,
    String? sourceModule,
    String? sourceEntityId,
    List<int>? alerts,
    List<String>? invitees,
  }) async {
    try {
      final response = await _api.createEvent(
        spaceId,
        title: title,
        location: location,
        eventType: eventType,
        allDay: allDay,
        startAt: startAt,
        endAt: endAt,
        recurrenceRule: recurrenceRule,
        sourceModule: sourceModule,
        sourceEntityId: sourceEntityId,
        alerts: alerts,
        invitees: invitees,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to create event: $e');
    }
  }

  /// Gets a specific event by ID, with cache fallback.
  Future<Map<String, dynamic>> getEvent(String spaceId, String eventId) async {
    try {
      final response = await _api.getEvent(spaceId, eventId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getEventById(eventId);
      if (cached != null) return {'id': cached.id, 'title': cached.title};
      throw UnknownFailure('Failed to get event: $e');
    }
  }

  /// Updates a calendar event via the API.
  Future<Map<String, dynamic>> updateEvent(
    String spaceId,
    String eventId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _api.updateEvent(spaceId, eventId, data);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update event: $e');
    }
  }

  /// Deletes a calendar event via the API and removes from cache.
  Future<void> deleteEvent(String spaceId, String eventId) async {
    try {
      await _api.deleteEvent(spaceId, eventId);
      await _dao.deleteEvent(eventId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete event: $e');
    }
  }

  /// Responds to an event invitation with an RSVP status.
  Future<Map<String, dynamic>> respondToInvitation(
    String spaceId,
    String eventId,
    String status,
  ) async {
    try {
      final response = await _api.respondToInvitation(spaceId, eventId, status);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to respond to invitation: $e');
    }
  }

  /// Gets all invitations for an event.
  Future<List<Map<String, dynamic>>> getInvitations(
    String spaceId,
    String eventId,
  ) async {
    try {
      final response = await _api.getInvitations(spaceId, eventId);
      return _parseList(response.data);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get invitations: $e');
    }
  }

  /// Invites users to an event.
  Future<Map<String, dynamic>> inviteToEvent(
    String spaceId,
    String eventId,
    List<String> userIds,
  ) async {
    try {
      final response = await _api.inviteToEvent(spaceId, eventId, userIds);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to invite to event: $e');
    }
  }

  /// Watches cached calendar events for a date range (reactive stream).
  Stream<List<CachedCalendarEvent>> watchEvents(
    String spaceId,
    DateTime start,
    DateTime end,
  ) {
    return _dao.getEventsByDateRange(spaceId, start, end);
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
