import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../services/notification_service.dart';
import '../spaces/spaces_repository.dart';
import 'calendar_repository.dart';

/// Custom exception for calendar-related errors.
class CalendarException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const CalendarException(
    this.message, {
    this.code = 'CALENDAR_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'CalendarException($code): $message';
}

/// Service containing all calendar-related business logic.
class CalendarService {
  final CalendarRepository _repo;
  final SpacesRepository _spacesRepo;
  final NotificationService _notificationService;
  final Logger _log = Logger('CalendarService');
  final Uuid _uuid = const Uuid();

  /// Valid event types.
  static const _validEventTypes = [
    'date',
    'appointment',
    'reminder',
    'activity',
    'finance',
    'custom',
  ];

  /// Valid invitation statuses.
  static const _validRsvpStatuses = ['accepted', 'declined', 'tentative'];

  CalendarService(this._repo, this._spacesRepo, this._notificationService);

  // ---------------------------------------------------------------------------
  // Event CRUD
  // ---------------------------------------------------------------------------

  /// Creates a new calendar event.
  ///
  /// Validates inputs, checks space membership, creates alerts and
  /// invitations if specified, and returns the complete event.
  Future<Map<String, dynamic>> createEvent({
    required String spaceId,
    required String userId,
    required String title,
    String? location,
    String eventType = 'custom',
    bool allDay = false,
    required DateTime startAt,
    required DateTime endAt,
    String? recurrenceRule,
    String? sourceModule,
    String? sourceEntityId,
    List<int>? alerts,
    List<String>? invitees,
  }) async {
    // Validate title
    if (title.trim().isEmpty) {
      throw const CalendarException(
        'Event title is required',
        code: 'INVALID_TITLE',
        statusCode: 422,
      );
    }

    if (title.trim().length > 200) {
      throw const CalendarException(
        'Event title must be at most 200 characters',
        code: 'INVALID_TITLE',
        statusCode: 422,
      );
    }

    // Validate event type
    if (!_validEventTypes.contains(eventType)) {
      throw CalendarException(
        'Invalid event type. Must be one of: ${_validEventTypes.join(", ")}',
        code: 'INVALID_EVENT_TYPE',
        statusCode: 422,
      );
    }

    // Validate dates
    if (endAt.isBefore(startAt)) {
      throw const CalendarException(
        'End date must be equal to or after start date',
        code: 'INVALID_DATE_RANGE',
        statusCode: 422,
      );
    }

    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Validate source module integration if specified
    if (sourceModule != null) {
      if (sourceModule != 'activity' &&
          sourceModule != 'finance' &&
          sourceModule != 'task') {
        throw const CalendarException(
          'Invalid source module. Must be "activity", "finance", or "task"',
          code: 'INVALID_SOURCE_MODULE',
          statusCode: 422,
        );
      }
      if (sourceEntityId == null || sourceEntityId.trim().isEmpty) {
        throw const CalendarException(
          'Source entity ID is required when source module is specified',
          code: 'MISSING_SOURCE_ENTITY_ID',
          statusCode: 422,
        );
      }
    }

    final eventId = _uuid.v4();

    // Create the event
    final event = await _repo.createEvent(
      id: eventId,
      spaceId: spaceId,
      createdBy: userId,
      title: title.trim(),
      location: location?.trim(),
      eventType: eventType,
      allDay: allDay,
      startAt: startAt,
      endAt: endAt,
      recurrenceRule: recurrenceRule,
      sourceModule: sourceModule,
      sourceEntityId: sourceEntityId,
    );

    // Create alerts if provided
    final createdAlerts = <Map<String, dynamic>>[];
    if (alerts != null && alerts.isNotEmpty) {
      for (final minutesBefore in alerts) {
        if (minutesBefore < 0) continue;
        final alert = await _repo.createAlert(
          id: _uuid.v4(),
          eventId: eventId,
          minutesBefore: minutesBefore,
        );
        createdAlerts.add(alert);
      }
    }
    event['alerts'] = createdAlerts;

    // Create invitations if provided
    final createdInvitations = <Map<String, dynamic>>[];
    if (invitees != null && invitees.isNotEmpty) {
      for (final inviteeId in invitees) {
        // Don't invite the creator
        if (inviteeId == userId) continue;

        // Verify invitee is a member of the space
        final membership = await _spacesRepo.getMember(spaceId, inviteeId);
        if (membership == null || membership['status'] != 'active') {
          _log.warning(
            'Skipping invitation for non-member $inviteeId in space $spaceId',
          );
          continue;
        }

        final invitation = await _repo.createInvitation(
          id: _uuid.v4(),
          eventId: eventId,
          userId: inviteeId,
        );
        createdInvitations.add(invitation);

        // Send notification to invitee
        await _notificationService.notify(
          userId: inviteeId,
          type: 'calendar.invitation',
          title: 'New event invitation',
          body: 'You have been invited to "$title"',
          spaceId: spaceId,
          data: {'event_id': eventId, 'event_title': title},
        );
      }
    }
    event['invitations'] = createdInvitations;

    _log.info('Event created: ${event['title']} ($eventId) in space $spaceId');

    return event;
  }

  /// Gets a single event by ID with alerts and invitations.
  ///
  /// Verifies the requesting user has access to the event's space.
  Future<Map<String, dynamic>> getEvent({
    required String eventId,
    required String spaceId,
    required String userId,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    final event = await _repo.getEventById(eventId);
    if (event == null) {
      throw const CalendarException(
        'Event not found',
        code: 'EVENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the event belongs to the requested space
    if (event['space_id'] != spaceId) {
      throw const CalendarException(
        'Event not found',
        code: 'EVENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    return event;
  }

  /// Gets events within a date range for a space.
  ///
  /// Validates the date range and verifies space access.
  Future<List<Map<String, dynamic>>> getEventsByRange({
    required String spaceId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Validate date range
    if (endDate.isBefore(startDate)) {
      throw const CalendarException(
        'End date must be after start date',
        code: 'INVALID_DATE_RANGE',
        statusCode: 422,
      );
    }

    // Limit range to at most 1 year to prevent excessive queries
    final rangeDuration = endDate.difference(startDate);
    if (rangeDuration.inDays > 366) {
      throw const CalendarException(
        'Date range must not exceed one year',
        code: 'DATE_RANGE_TOO_LARGE',
        statusCode: 422,
      );
    }

    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    return _repo.getEventsByDateRange(spaceId, startDate, endDate);
  }

  /// Updates an existing event.
  ///
  /// Verifies ownership or admin role before allowing the update.
  Future<Map<String, dynamic>> updateEvent({
    required String eventId,
    required String spaceId,
    required String userId,
    required String userRole,
    Map<String, dynamic> updates = const {},
    List<int>? alerts,
  }) async {
    // Fetch the existing event
    final existing = await _repo.getEventById(eventId);
    if (existing == null) {
      throw const CalendarException(
        'Event not found',
        code: 'EVENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the event belongs to the requested space
    if (existing['space_id'] != spaceId) {
      throw const CalendarException(
        'Event not found',
        code: 'EVENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify ownership or admin role
    final isCreator = existing['created_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdmin) {
      throw const CalendarException(
        'Only the event creator or a space admin can update this event',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Validate title if provided
    if (updates.containsKey('title')) {
      final title = updates['title'] as String?;
      if (title == null || title.trim().isEmpty) {
        throw const CalendarException(
          'Event title cannot be empty',
          code: 'INVALID_TITLE',
          statusCode: 422,
        );
      }
      if (title.trim().length > 200) {
        throw const CalendarException(
          'Event title must be at most 200 characters',
          code: 'INVALID_TITLE',
          statusCode: 422,
        );
      }
      updates['title'] = title.trim();
    }

    // Validate event_type if provided
    if (updates.containsKey('event_type')) {
      final eventType = updates['event_type'] as String?;
      if (eventType != null && !_validEventTypes.contains(eventType)) {
        throw CalendarException(
          'Invalid event type. Must be one of: ${_validEventTypes.join(", ")}',
          code: 'INVALID_EVENT_TYPE',
          statusCode: 422,
        );
      }
    }

    // Validate date range if dates are being updated
    final newStartAt = updates.containsKey('start_at')
        ? updates['start_at'] as DateTime
        : DateTime.parse(existing['start_at'] as String);
    final newEndAt = updates.containsKey('end_at')
        ? updates['end_at'] as DateTime
        : DateTime.parse(existing['end_at'] as String);

    if (newEndAt.isBefore(newStartAt)) {
      throw const CalendarException(
        'End date must be equal to or after start date',
        code: 'INVALID_DATE_RANGE',
        statusCode: 422,
      );
    }

    // Update the event
    final updated = await _repo.updateEvent(eventId, updates);
    if (updated == null) {
      throw const CalendarException(
        'Event not found',
        code: 'EVENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Update alerts if provided
    if (alerts != null) {
      await _repo.deleteAlerts(eventId);
      final createdAlerts = <Map<String, dynamic>>[];
      for (final minutesBefore in alerts) {
        if (minutesBefore < 0) continue;
        final alert = await _repo.createAlert(
          id: _uuid.v4(),
          eventId: eventId,
          minutesBefore: minutesBefore,
        );
        createdAlerts.add(alert);
      }
      updated['alerts'] = createdAlerts;
    }

    _log.info('Event updated: $eventId in space $spaceId by $userId');

    return updated;
  }

  /// Deletes an event (soft delete).
  ///
  /// Verifies ownership or admin role before allowing the deletion.
  Future<void> deleteEvent({
    required String eventId,
    required String spaceId,
    required String userId,
    required String userRole,
  }) async {
    // Fetch the existing event
    final existing = await _repo.getEventById(eventId);
    if (existing == null) {
      throw const CalendarException(
        'Event not found',
        code: 'EVENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the event belongs to the requested space
    if (existing['space_id'] != spaceId) {
      throw const CalendarException(
        'Event not found',
        code: 'EVENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify ownership or admin role
    final isCreator = existing['created_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdmin) {
      throw const CalendarException(
        'Only the event creator or a space admin can delete this event',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.softDeleteEvent(eventId);

    _log.info('Event deleted: $eventId in space $spaceId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Invitations / RSVP
  // ---------------------------------------------------------------------------

  /// Responds to an event invitation (accept/decline/tentative).
  ///
  /// Validates the invitation exists and notifies the event creator.
  Future<Map<String, dynamic>> respondToInvitation({
    required String eventId,
    required String spaceId,
    required String userId,
    required String status,
  }) async {
    // Validate status
    if (!_validRsvpStatuses.contains(status)) {
      throw CalendarException(
        'Invalid RSVP status. Must be one of: ${_validRsvpStatuses.join(", ")}',
        code: 'INVALID_RSVP_STATUS',
        statusCode: 422,
      );
    }

    // Verify the event exists
    final event = await _repo.getEventById(eventId);
    if (event == null) {
      throw const CalendarException(
        'Event not found',
        code: 'EVENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the event belongs to the requested space
    if (event['space_id'] != spaceId) {
      throw const CalendarException(
        'Event not found',
        code: 'EVENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify invitation exists for this user
    final existingInvitation = await _repo.findInvitation(eventId, userId);
    if (existingInvitation == null) {
      throw const CalendarException(
        'No invitation found for this event',
        code: 'INVITATION_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Update the invitation status
    final updated = await _repo.updateInvitationStatus(eventId, userId, status);
    if (updated == null) {
      throw const CalendarException(
        'Failed to update invitation',
        code: 'UPDATE_FAILED',
        statusCode: 500,
      );
    }

    // Notify the event creator
    final creatorId = event['created_by'] as String;
    if (creatorId != userId) {
      final statusLabel = status == 'accepted'
          ? 'accepted'
          : status == 'declined'
          ? 'declined'
          : 'tentatively accepted';

      await _notificationService.notify(
        userId: creatorId,
        type: 'calendar.rsvp',
        title: 'Event RSVP update',
        body: 'Someone $statusLabel your event "${event['title']}"',
        spaceId: spaceId,
        data: {
          'event_id': eventId,
          'event_title': event['title'],
          'rsvp_status': status,
          'responder_id': userId,
        },
      );
    }

    _log.info('RSVP updated: $eventId by $userId -> $status');

    return updated;
  }

  /// Gets all invitations for an event.
  Future<List<Map<String, dynamic>>> getInvitations({
    required String eventId,
    required String spaceId,
    required String userId,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Verify the event exists and belongs to the space
    final event = await _repo.getEventById(eventId);
    if (event == null) {
      throw const CalendarException(
        'Event not found',
        code: 'EVENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (event['space_id'] != spaceId) {
      throw const CalendarException(
        'Event not found',
        code: 'EVENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    return _repo.getInvitationsForEvent(eventId);
  }

  /// Invites users to an existing event.
  ///
  /// Only the event creator or a space admin can invite users.
  Future<List<Map<String, dynamic>>> inviteToEvent({
    required String eventId,
    required String spaceId,
    required String userId,
    required String userRole,
    required List<String> inviteeIds,
  }) async {
    // Fetch the existing event
    final event = await _repo.getEventById(eventId);
    if (event == null) {
      throw const CalendarException(
        'Event not found',
        code: 'EVENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the event belongs to the requested space
    if (event['space_id'] != spaceId) {
      throw const CalendarException(
        'Event not found',
        code: 'EVENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify permission: creator or admin
    final isCreator = event['created_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdmin) {
      throw const CalendarException(
        'Only the event creator or a space admin can invite users',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    final createdInvitations = <Map<String, dynamic>>[];

    for (final inviteeId in inviteeIds) {
      // Don't invite the creator
      if (inviteeId == event['created_by']) continue;

      // Check if already invited
      final existing = await _repo.findInvitation(eventId, inviteeId);
      if (existing != null) {
        _log.fine('User $inviteeId already invited to event $eventId');
        continue;
      }

      // Verify invitee is a space member
      final membership = await _spacesRepo.getMember(spaceId, inviteeId);
      if (membership == null || membership['status'] != 'active') {
        _log.warning(
          'Skipping invitation for non-member $inviteeId in space $spaceId',
        );
        continue;
      }

      final invitation = await _repo.createInvitation(
        id: _uuid.v4(),
        eventId: eventId,
        userId: inviteeId,
      );
      createdInvitations.add(invitation);

      // Send notification
      await _notificationService.notify(
        userId: inviteeId,
        type: 'calendar.invitation',
        title: 'New event invitation',
        body: 'You have been invited to "${event['title']}"',
        spaceId: spaceId,
        data: {'event_id': eventId, 'event_title': event['title']},
      );
    }

    _log.info('Invited ${createdInvitations.length} users to event $eventId');

    return createdInvitations;
  }

  // ---------------------------------------------------------------------------
  // Upcoming Events
  // ---------------------------------------------------------------------------

  /// Gets the next upcoming events for a space.
  Future<List<Map<String, dynamic>>> getUpcomingEvents({
    required String spaceId,
    required String userId,
    int limit = 10,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Clamp limit
    final clampedLimit = limit.clamp(1, 50);

    return _repo.getUpcomingEvents(spaceId, clampedLimit);
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Verifies that a user is an active member of a space.
  Future<Map<String, dynamic>> _verifySpaceMembership(
    String spaceId,
    String userId,
  ) async {
    final membership = await _spacesRepo.getMember(spaceId, userId);
    if (membership == null || membership['status'] != 'active') {
      throw const CalendarException(
        'You do not have access to this space',
        code: 'SPACE_ACCESS_DENIED',
        statusCode: 403,
      );
    }
    return membership;
  }
}
