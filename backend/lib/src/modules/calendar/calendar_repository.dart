import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for calendar-related database operations.
class CalendarRepository {
  final Database _db;
  // ignore: unused_field
  final Logger _log = Logger('CalendarRepository');

  CalendarRepository(this._db);

  // ---------------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------------

  /// Creates a new calendar event and returns the created event row.
  Future<Map<String, dynamic>> createEvent({
    required String id,
    required String spaceId,
    required String createdBy,
    required String title,
    String? location,
    required String eventType,
    required bool allDay,
    required DateTime startAt,
    required DateTime endAt,
    String? recurrenceRule,
    String? sourceModule,
    String? sourceEntityId,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO calendar_events (
        id, space_id, created_by, title, location, event_type,
        all_day, start_at, end_at, recurrence_rule,
        source_module, source_entity_id, created_at, updated_at
      )
      VALUES (
        @id, @spaceId, @createdBy, @title, @location, @eventType,
        @allDay, @startAt, @endAt, @recurrenceRule,
        @sourceModule, @sourceEntityId, NOW(), NOW()
      )
      RETURNING id, space_id, created_by, title, location, event_type,
                all_day, start_at, end_at, recurrence_rule,
                source_module, source_entity_id, created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'spaceId': spaceId,
        'createdBy': createdBy,
        'title': title,
        'location': location,
        'eventType': eventType,
        'allDay': allDay,
        'startAt': startAt,
        'endAt': endAt,
        'recurrenceRule': recurrenceRule,
        'sourceModule': sourceModule,
        'sourceEntityId': sourceEntityId,
      },
    );

    return _eventRowToMap(row!);
  }

  /// Gets an event by ID, including its alerts and invitations.
  Future<Map<String, dynamic>?> getEventById(String eventId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, created_by, title, location, event_type,
             all_day, start_at, end_at, recurrence_rule,
             source_module, source_entity_id,
             created_at, updated_at, deleted_at
      FROM calendar_events
      WHERE id = @eventId AND deleted_at IS NULL
      ''',
      parameters: {'eventId': eventId},
    );

    if (row == null) return null;

    final event = _eventRowWithDeletedToMap(row);

    // Fetch alerts
    final alertRows = await _db.query(
      '''
      SELECT id, event_id, minutes_before, created_at
      FROM calendar_event_alerts
      WHERE event_id = @eventId
      ORDER BY minutes_before ASC
      ''',
      parameters: {'eventId': eventId},
    );

    event['alerts'] = alertRows.map(_alertRowToMap).toList();

    // Fetch invitations with user info
    final invitationRows = await _db.query(
      '''
      SELECT ci.id, ci.event_id, ci.user_id, ci.status, ci.responded_at,
             ci.created_at, u.display_name, u.email, u.avatar_url
      FROM calendar_invitations ci
      JOIN users u ON u.id = ci.user_id
      WHERE ci.event_id = @eventId
      ORDER BY ci.created_at ASC
      ''',
      parameters: {'eventId': eventId},
    );

    event['invitations'] = invitationRows
        .map(_invitationWithUserRowToMap)
        .toList();

    return event;
  }

  /// Gets events within a date range for a space.
  Future<List<Map<String, dynamic>>> getEventsByDateRange(
    String spaceId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final result = await _db.query(
      '''
      SELECT id, space_id, created_by, title, location, event_type,
             all_day, start_at, end_at, recurrence_rule,
             source_module, source_entity_id, created_at, updated_at
      FROM calendar_events
      WHERE space_id = @spaceId
        AND deleted_at IS NULL
        AND start_at < @endDate
        AND end_at > @startDate
      ORDER BY start_at ASC
      ''',
      parameters: {
        'spaceId': spaceId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );

    return result.map(_eventRowToMap).toList();
  }

  /// Gets events for a specific day in a space.
  Future<List<Map<String, dynamic>>> getEventsByDay(
    String spaceId,
    DateTime date,
  ) async {
    final dayStart = DateTime.utc(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return getEventsByDateRange(spaceId, dayStart, dayEnd);
  }

  /// Updates an event with the given fields.
  Future<Map<String, dynamic>?> updateEvent(
    String eventId,
    Map<String, dynamic> updates,
  ) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'eventId': eventId};

    if (updates.containsKey('title')) {
      setClauses.add('title = @title');
      params['title'] = updates['title'];
    }
    if (updates.containsKey('location')) {
      setClauses.add('location = @location');
      params['location'] = updates['location'];
    }
    if (updates.containsKey('event_type')) {
      setClauses.add('event_type = @eventType');
      params['eventType'] = updates['event_type'];
    }
    if (updates.containsKey('all_day')) {
      setClauses.add('all_day = @allDay');
      params['allDay'] = updates['all_day'];
    }
    if (updates.containsKey('start_at')) {
      setClauses.add('start_at = @startAt');
      params['startAt'] = updates['start_at'];
    }
    if (updates.containsKey('end_at')) {
      setClauses.add('end_at = @endAt');
      params['endAt'] = updates['end_at'];
    }
    if (updates.containsKey('recurrence_rule')) {
      setClauses.add('recurrence_rule = @recurrenceRule');
      params['recurrenceRule'] = updates['recurrence_rule'];
    }

    if (setClauses.isEmpty) return getEventById(eventId);

    setClauses.add('updated_at = NOW()');

    final row = await _db.queryOne('''
      UPDATE calendar_events
      SET ${setClauses.join(', ')}
      WHERE id = @eventId AND deleted_at IS NULL
      RETURNING id, space_id, created_by, title, location, event_type,
                all_day, start_at, end_at, recurrence_rule,
                source_module, source_entity_id, created_at, updated_at
      ''', parameters: params);

    if (row == null) return null;
    return _eventRowToMap(row);
  }

  /// Soft-deletes an event.
  Future<void> softDeleteEvent(String eventId) async {
    await _db.execute(
      '''
      UPDATE calendar_events
      SET deleted_at = NOW(), updated_at = NOW()
      WHERE id = @eventId AND deleted_at IS NULL
      ''',
      parameters: {'eventId': eventId},
    );
  }

  /// Gets upcoming events for a space, ordered by start time.
  Future<List<Map<String, dynamic>>> getUpcomingEvents(
    String spaceId,
    int limit,
  ) async {
    final result = await _db.query(
      '''
      SELECT id, space_id, created_by, title, location, event_type,
             all_day, start_at, end_at, recurrence_rule,
             source_module, source_entity_id, created_at, updated_at
      FROM calendar_events
      WHERE space_id = @spaceId
        AND deleted_at IS NULL
        AND end_at >= NOW()
      ORDER BY start_at ASC
      LIMIT @limit
      ''',
      parameters: {'spaceId': spaceId, 'limit': limit},
    );

    return result.map(_eventRowToMap).toList();
  }

  /// Gets events where the user is the creator or an invitee within a date range.
  Future<List<Map<String, dynamic>>> getEventsForUser(
    String userId,
    String spaceId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final result = await _db.query(
      '''
      SELECT DISTINCT e.id, e.space_id, e.created_by, e.title, e.location,
             e.event_type, e.all_day, e.start_at, e.end_at, e.recurrence_rule,
             e.source_module, e.source_entity_id, e.created_at, e.updated_at
      FROM calendar_events e
      LEFT JOIN calendar_invitations ci ON ci.event_id = e.id AND ci.user_id = @userId
      WHERE e.space_id = @spaceId
        AND e.deleted_at IS NULL
        AND e.start_at < @endDate
        AND e.end_at > @startDate
        AND (e.created_by = @userId OR ci.user_id IS NOT NULL)
      ORDER BY e.start_at ASC
      ''',
      parameters: {
        'userId': userId,
        'spaceId': spaceId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );

    return result.map(_eventRowToMap).toList();
  }

  /// Counts events in a date range for a space.
  Future<int> countEventsInRange(
    String spaceId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final row = await _db.queryOne(
      '''
      SELECT COUNT(*)
      FROM calendar_events
      WHERE space_id = @spaceId
        AND deleted_at IS NULL
        AND start_at < @endDate
        AND end_at > @startDate
      ''',
      parameters: {
        'spaceId': spaceId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    return (row?[0] as int?) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Alerts
  // ---------------------------------------------------------------------------

  /// Creates an alert for an event.
  Future<Map<String, dynamic>> createAlert({
    required String id,
    required String eventId,
    required int minutesBefore,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO calendar_event_alerts (id, event_id, minutes_before, created_at)
      VALUES (@id, @eventId, @minutesBefore, NOW())
      RETURNING id, event_id, minutes_before, created_at
      ''',
      parameters: {
        'id': id,
        'eventId': eventId,
        'minutesBefore': minutesBefore,
      },
    );

    return _alertRowToMap(row!);
  }

  /// Deletes all alerts for an event.
  Future<void> deleteAlerts(String eventId) async {
    await _db.execute(
      '''
      DELETE FROM calendar_event_alerts
      WHERE event_id = @eventId
      ''',
      parameters: {'eventId': eventId},
    );
  }

  // ---------------------------------------------------------------------------
  // Invitations
  // ---------------------------------------------------------------------------

  /// Creates an invitation for a user to an event.
  Future<Map<String, dynamic>> createInvitation({
    required String id,
    required String eventId,
    required String userId,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO calendar_invitations (id, event_id, user_id, status, created_at)
      VALUES (@id, @eventId, @userId, 'pending', NOW())
      RETURNING id, event_id, user_id, status, responded_at, created_at
      ''',
      parameters: {'id': id, 'eventId': eventId, 'userId': userId},
    );

    return _invitationRowToMap(row!);
  }

  /// Updates the RSVP status of an invitation.
  Future<Map<String, dynamic>?> updateInvitationStatus(
    String eventId,
    String userId,
    String status,
  ) async {
    final row = await _db.queryOne(
      '''
      UPDATE calendar_invitations
      SET status = @status, responded_at = NOW()
      WHERE event_id = @eventId AND user_id = @userId
      RETURNING id, event_id, user_id, status, responded_at, created_at
      ''',
      parameters: {'eventId': eventId, 'userId': userId, 'status': status},
    );

    if (row == null) return null;
    return _invitationRowToMap(row);
  }

  /// Gets all invitations for an event with user info.
  Future<List<Map<String, dynamic>>> getInvitationsForEvent(
    String eventId,
  ) async {
    final result = await _db.query(
      '''
      SELECT ci.id, ci.event_id, ci.user_id, ci.status, ci.responded_at,
             ci.created_at, u.display_name, u.email, u.avatar_url
      FROM calendar_invitations ci
      JOIN users u ON u.id = ci.user_id
      WHERE ci.event_id = @eventId
      ORDER BY ci.created_at ASC
      ''',
      parameters: {'eventId': eventId},
    );

    return result.map(_invitationWithUserRowToMap).toList();
  }

  /// Finds a specific invitation for a user and event.
  Future<Map<String, dynamic>?> findInvitation(
    String eventId,
    String userId,
  ) async {
    final row = await _db.queryOne(
      '''
      SELECT id, event_id, user_id, status, responded_at, created_at
      FROM calendar_invitations
      WHERE event_id = @eventId AND user_id = @userId
      ''',
      parameters: {'eventId': eventId, 'userId': userId},
    );

    if (row == null) return null;
    return _invitationRowToMap(row);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _eventRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_by': row[2] as String,
      'title': row[3] as String,
      'location': row[4] as String?,
      'event_type': row[5] as String,
      'all_day': row[6] as bool,
      'start_at': (row[7] as DateTime).toIso8601String(),
      'end_at': (row[8] as DateTime).toIso8601String(),
      'recurrence_rule': row[9] as String?,
      'source_module': row[10] as String?,
      'source_entity_id': row[11] as String?,
      'created_at': (row[12] as DateTime).toIso8601String(),
      'updated_at': (row[13] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _eventRowWithDeletedToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_by': row[2] as String,
      'title': row[3] as String,
      'location': row[4] as String?,
      'event_type': row[5] as String,
      'all_day': row[6] as bool,
      'start_at': (row[7] as DateTime).toIso8601String(),
      'end_at': (row[8] as DateTime).toIso8601String(),
      'recurrence_rule': row[9] as String?,
      'source_module': row[10] as String?,
      'source_entity_id': row[11] as String?,
      'created_at': (row[12] as DateTime).toIso8601String(),
      'updated_at': (row[13] as DateTime).toIso8601String(),
      'deleted_at': row[14] != null
          ? (row[14] as DateTime).toIso8601String()
          : null,
    };
  }

  Map<String, dynamic> _alertRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'event_id': row[1] as String,
      'minutes_before': row[2] as int,
      'created_at': (row[3] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _invitationRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'event_id': row[1] as String,
      'user_id': row[2] as String,
      'status': row[3] as String,
      'responded_at': row[4] != null
          ? (row[4] as DateTime).toIso8601String()
          : null,
      'created_at': (row[5] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _invitationWithUserRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'event_id': row[1] as String,
      'user_id': row[2] as String,
      'status': row[3] as String,
      'responded_at': row[4] != null
          ? (row[4] as DateTime).toIso8601String()
          : null,
      'created_at': (row[5] as DateTime).toIso8601String(),
      'user': {
        'display_name': row[6] as String,
        'email': row[7] as String,
        'avatar_url': row[8] as String?,
      },
    };
  }
}
