import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'calendar_service.dart';

/// Controller for calendar and event endpoints.
class CalendarController {
  final CalendarService _service;
  final Logger _log = Logger('CalendarController');

  CalendarController(this._service);

  /// Returns the router with all calendar routes.
  Router get router {
    final router = Router();

    // Upcoming events (must be registered before /events/<eventId> to avoid
    // "upcoming" being captured as an eventId parameter)
    router.get('/events/upcoming', _getUpcomingEvents);

    // Events CRUD
    router.post('/events', _createEvent);
    router.get('/events', _getEventsByRange);
    router.get('/events/<eventId>', _getEvent);
    router.patch('/events/<eventId>', _updateEvent);
    router.delete('/events/<eventId>', _deleteEvent);

    // RSVP / Invitations
    router.post('/events/<eventId>/rsvp', _respondToInvitation);
    router.get('/events/<eventId>/invitations', _getInvitations);
    router.post('/events/<eventId>/invite', _inviteToEvent);

    return router;
  }

  /// POST /events
  ///
  /// Creates a new calendar event.
  /// Body: {
  ///   "title": "...",
  ///   "location": "...",
  ///   "event_type": "date|appointment|reminder|activity|finance|custom",
  ///   "all_day": false,
  ///   "start_at": "ISO 8601",
  ///   "end_at": "ISO 8601",
  ///   "recurrence_rule": "RRULE string",
  ///   "source_module": "activity|finance",
  ///   "source_entity_id": "...",
  ///   "alerts": [15, 60],
  ///   "invitees": ["userId1", "userId2"]
  /// }
  Future<Response> _createEvent(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final title = body['title'] as String?;
      final startAtStr = body['start_at'] as String?;
      final endAtStr = body['end_at'] as String?;

      if (title == null || startAtStr == null || endAtStr == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (title == null)
              {'field': 'title', 'message': 'Title is required'},
            if (startAtStr == null)
              {'field': 'start_at', 'message': 'Start date is required'},
            if (endAtStr == null)
              {'field': 'end_at', 'message': 'End date is required'},
          ],
        );
      }

      final startAt = DateTime.tryParse(startAtStr);
      final endAt = DateTime.tryParse(endAtStr);

      if (startAt == null || endAt == null) {
        return validationErrorResponse(
          'Invalid date format. Use ISO 8601 format.',
          errors: [
            if (startAt == null)
              {'field': 'start_at', 'message': 'Invalid date format'},
            if (endAt == null)
              {'field': 'end_at', 'message': 'Invalid date format'},
          ],
        );
      }

      // Parse optional alerts list
      List<int>? alerts;
      if (body['alerts'] != null) {
        final rawAlerts = body['alerts'] as List<dynamic>;
        alerts = rawAlerts.map((e) => (e as num).toInt()).toList();
      }

      // Parse optional invitees list
      List<String>? invitees;
      if (body['invitees'] != null) {
        final rawInvitees = body['invitees'] as List<dynamic>;
        invitees = rawInvitees.map((e) => e as String).toList();
      }

      final result = await _service.createEvent(
        spaceId: spaceId,
        userId: userId,
        title: title,
        location: body['location'] as String?,
        eventType: body['event_type'] as String? ?? 'custom',
        allDay: body['all_day'] as bool? ?? false,
        startAt: startAt,
        endAt: endAt,
        recurrenceRule: body['recurrence_rule'] as String?,
        sourceModule: body['source_module'] as String?,
        sourceEntityId: body['source_entity_id'] as String?,
        alerts: alerts,
        invitees: invitees,
      );

      return createdResponse(result);
    } on CalendarException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create event error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /events?start=<ISO8601>&end=<ISO8601>
  ///
  /// Gets events within a date range for the current space.
  Future<Response> _getEventsByRange(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final startStr = request.url.queryParameters['start'];
      final endStr = request.url.queryParameters['end'];

      if (startStr == null || endStr == null) {
        return validationErrorResponse(
          'Missing required query parameters',
          errors: [
            if (startStr == null)
              {
                'field': 'start',
                'message': 'Start date query parameter is required',
              },
            if (endStr == null)
              {
                'field': 'end',
                'message': 'End date query parameter is required',
              },
          ],
        );
      }

      final startDate = DateTime.tryParse(startStr);
      final endDate = DateTime.tryParse(endStr);

      if (startDate == null || endDate == null) {
        return validationErrorResponse(
          'Invalid date format. Use ISO 8601 format.',
          errors: [
            if (startDate == null)
              {'field': 'start', 'message': 'Invalid date format'},
            if (endDate == null)
              {'field': 'end', 'message': 'Invalid date format'},
          ],
        );
      }

      final events = await _service.getEventsByRange(
        spaceId: spaceId,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return jsonResponse({'data': events});
    } on CalendarException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get events by range error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /events/<eventId>
  ///
  /// Gets a single event by ID with alerts and invitations.
  Future<Response> _getEvent(Request request, String eventId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final event = await _service.getEvent(
        eventId: eventId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(event);
    } on CalendarException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get event error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /events/<eventId>
  ///
  /// Partially updates a calendar event.
  /// Body: any subset of { title, location, event_type, all_day, start_at,
  ///   end_at, recurrence_rule, alerts }
  Future<Response> _updateEvent(Request request, String eventId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final membership = getMembership(request);
      final userRole = membership?.role ?? 'member';
      final body = await readJsonBody(request);

      // Build the updates map, converting date strings to DateTime
      final updates = <String, dynamic>{};

      if (body.containsKey('title')) {
        updates['title'] = body['title'];
      }
      if (body.containsKey('location')) {
        updates['location'] = body['location'];
      }
      if (body.containsKey('event_type')) {
        updates['event_type'] = body['event_type'];
      }
      if (body.containsKey('all_day')) {
        updates['all_day'] = body['all_day'];
      }
      if (body.containsKey('start_at')) {
        final startAt = DateTime.tryParse(body['start_at'] as String);
        if (startAt == null) {
          return validationErrorResponse(
            'Invalid start_at date format. Use ISO 8601 format.',
          );
        }
        updates['start_at'] = startAt;
      }
      if (body.containsKey('end_at')) {
        final endAt = DateTime.tryParse(body['end_at'] as String);
        if (endAt == null) {
          return validationErrorResponse(
            'Invalid end_at date format. Use ISO 8601 format.',
          );
        }
        updates['end_at'] = endAt;
      }
      if (body.containsKey('recurrence_rule')) {
        updates['recurrence_rule'] = body['recurrence_rule'];
      }

      // Parse optional alerts list
      List<int>? alerts;
      if (body.containsKey('alerts')) {
        if (body['alerts'] != null) {
          final rawAlerts = body['alerts'] as List<dynamic>;
          alerts = rawAlerts.map((e) => (e as num).toInt()).toList();
        } else {
          // null means clear all alerts
          alerts = [];
        }
      }

      final result = await _service.updateEvent(
        eventId: eventId,
        spaceId: spaceId,
        userId: userId,
        userRole: userRole,
        updates: updates,
        alerts: alerts,
      );

      return jsonResponse(result);
    } on CalendarException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update event error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /events/<eventId>
  ///
  /// Soft-deletes a calendar event.
  Future<Response> _deleteEvent(Request request, String eventId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final membership = getMembership(request);
      final userRole = membership?.role ?? 'member';

      await _service.deleteEvent(
        eventId: eventId,
        spaceId: spaceId,
        userId: userId,
        userRole: userRole,
      );

      return noContentResponse();
    } on CalendarException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete event error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /events/<eventId>/rsvp
  ///
  /// Responds to an event invitation.
  /// Body: { "status": "accepted" | "declined" | "tentative" }
  Future<Response> _respondToInvitation(Request request, String eventId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final status = body['status'] as String?;
      if (status == null || status.isEmpty) {
        return validationErrorResponse(
          'RSVP status is required',
          errors: [
            {
              'field': 'status',
              'message': 'Status is required (accepted, declined, tentative)',
            },
          ],
        );
      }

      final result = await _service.respondToInvitation(
        eventId: eventId,
        spaceId: spaceId,
        userId: userId,
        status: status,
      );

      return jsonResponse(result);
    } on CalendarException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('RSVP error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /events/<eventId>/invitations
  ///
  /// Lists all invitations for an event.
  Future<Response> _getInvitations(Request request, String eventId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final invitations = await _service.getInvitations(
        eventId: eventId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse({'data': invitations});
    } on CalendarException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get invitations error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /events/<eventId>/invite
  ///
  /// Invites users to an event.
  /// Body: { "user_ids": ["userId1", "userId2"] }
  Future<Response> _inviteToEvent(Request request, String eventId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final membership = getMembership(request);
      final userRole = membership?.role ?? 'member';
      final body = await readJsonBody(request);

      final rawUserIds = body['user_ids'] as List<dynamic>?;
      if (rawUserIds == null || rawUserIds.isEmpty) {
        return validationErrorResponse(
          'At least one user ID is required',
          errors: [
            {
              'field': 'user_ids',
              'message': 'User IDs list is required and cannot be empty',
            },
          ],
        );
      }

      final userIds = rawUserIds.map((e) => e as String).toList();

      final invitations = await _service.inviteToEvent(
        eventId: eventId,
        spaceId: spaceId,
        userId: userId,
        userRole: userRole,
        inviteeIds: userIds,
      );

      return createdResponse({'data': invitations});
    } on CalendarException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Invite to event error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /events/upcoming?limit=10
  ///
  /// Gets the next upcoming events for the current space.
  Future<Response> _getUpcomingEvents(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final limitStr = request.url.queryParameters['limit'];
      final limit = limitStr != null ? (int.tryParse(limitStr) ?? 10) : 10;

      final events = await _service.getUpcomingEvents(
        spaceId: spaceId,
        userId: userId,
        limit: limit,
      );

      return jsonResponse({'data': events});
    } on CalendarException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get upcoming events error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
