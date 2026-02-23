import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Calendar API service for managing events and invitations within a space.
class CalendarApi {
  CalendarApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Create a new calendar event.
  Future<Response> createEvent(
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
  }) {
    return _client.post(
      '/spaces/$spaceId/calendar/events',
      data: {
        'title': title,
        'event_type': eventType,
        'all_day': allDay,
        'start_at': startAt,
        'end_at': endAt,
        if (location != null) 'location': location,
        if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
        if (sourceModule != null) 'source_module': sourceModule,
        if (sourceEntityId != null) 'source_entity_id': sourceEntityId,
        if (alerts != null) 'alerts': alerts,
        if (invitees != null) 'invitees': invitees,
      },
    );
  }

  /// Get events within a date range.
  Future<Response> getEvents(
    String spaceId, {
    required String start,
    required String end,
  }) {
    return _client.get(
      '/spaces/$spaceId/calendar/events',
      queryParameters: {'start': start, 'end': end},
    );
  }

  /// Get upcoming events.
  Future<Response> getUpcomingEvents(String spaceId, {int? limit}) {
    return _client.get(
      '/spaces/$spaceId/calendar/events/upcoming',
      queryParameters: {if (limit != null) 'limit': limit},
    );
  }

  /// Get a specific event by ID.
  Future<Response> getEvent(String spaceId, String eventId) {
    return _client.get('/spaces/$spaceId/calendar/events/$eventId');
  }

  /// Update an existing event.
  Future<Response> updateEvent(
    String spaceId,
    String eventId,
    Map<String, dynamic> data,
  ) {
    return _client.patch(
      '/spaces/$spaceId/calendar/events/$eventId',
      data: data,
    );
  }

  /// Delete an event.
  Future<Response> deleteEvent(String spaceId, String eventId) {
    return _client.delete('/spaces/$spaceId/calendar/events/$eventId');
  }

  /// Respond to an event invitation with an RSVP status.
  Future<Response> respondToInvitation(
    String spaceId,
    String eventId,
    String status,
  ) {
    return _client.post(
      '/spaces/$spaceId/calendar/events/$eventId/rsvp',
      data: {'status': status},
    );
  }

  /// Get all invitations for an event.
  Future<Response> getInvitations(String spaceId, String eventId) {
    return _client.get('/spaces/$spaceId/calendar/events/$eventId/invitations');
  }

  /// Invite users to an event.
  Future<Response> inviteToEvent(
    String spaceId,
    String eventId,
    List<String> userIds,
  ) {
    return _client.post(
      '/spaces/$spaceId/calendar/events/$eventId/invite',
      data: {'user_ids': userIds},
    );
  }
}
