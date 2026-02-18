import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../services/notification_service.dart';
import 'reminders_repository.dart';

/// Custom exception for reminder-related errors.
class ReminderException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const ReminderException(
    this.message, {
    this.code = 'REMINDER_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'ReminderException($code): $message';
}

/// Service containing all reminder business logic.
class RemindersService {
  final RemindersRepository _repo;
  final NotificationService _notificationService;
  final Logger _log = Logger('RemindersService');
  final Uuid _uuid = const Uuid();

  RemindersService(this._repo, this._notificationService);

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  /// Creates a new reminder.
  Future<Map<String, dynamic>> createReminder({
    required String spaceId,
    required String createdBy,
    required String message,
    required DateTime triggerAt,
    String? recurrenceRule,
    String? linkedModule,
    String? linkedEntityId,
  }) async {
    // Validate message
    if (message.trim().isEmpty) {
      throw const ReminderException(
        'Reminder message is required',
        code: 'INVALID_MESSAGE',
        statusCode: 422,
      );
    }

    if (message.trim().length > 1000) {
      throw const ReminderException(
        'Reminder message must be at most 1000 characters',
        code: 'INVALID_MESSAGE',
        statusCode: 422,
      );
    }

    // Validate trigger time is in the future
    if (triggerAt.isBefore(DateTime.now().toUtc())) {
      throw const ReminderException(
        'Trigger time must be in the future',
        code: 'INVALID_TRIGGER_TIME',
        statusCode: 422,
      );
    }

    // Validate linked entity: if one is provided, both must be
    if ((linkedModule != null) != (linkedEntityId != null)) {
      throw const ReminderException(
        'Both linked_module and linked_entity_id must be provided together',
        code: 'INVALID_LINKED_ENTITY',
        statusCode: 422,
      );
    }

    final reminderId = _uuid.v4();
    final reminder = await _repo.createReminder(
      id: reminderId,
      spaceId: spaceId,
      createdBy: createdBy,
      message: message.trim(),
      triggerAt: triggerAt,
      recurrenceRule: recurrenceRule?.trim(),
      linkedModule: linkedModule?.trim(),
      linkedEntityId: linkedEntityId?.trim(),
    );

    _log.info('Reminder created: $reminderId in space $spaceId by $createdBy');
    return reminder;
  }

  /// Gets a reminder by ID.
  Future<Map<String, dynamic>> getReminder(String reminderId) async {
    final reminder = await _repo.getReminderById(reminderId);
    if (reminder == null) {
      throw const ReminderException(
        'Reminder not found',
        code: 'REMINDER_NOT_FOUND',
        statusCode: 404,
      );
    }
    return reminder;
  }

  /// Gets reminders for a space with optional filtering and pagination.
  Future<Map<String, dynamic>> getReminders(
    String spaceId, {
    bool? upcoming,
    bool? past,
    String? createdBy,
    String? cursor,
    int limit = 25,
  }) async {
    final clampedLimit = limit.clamp(1, 100);

    final reminders = await _repo.getReminders(
      spaceId,
      upcoming: upcoming,
      past: past,
      createdBy: createdBy,
      cursor: cursor,
      limit: clampedLimit + 1, // Fetch one extra to check hasMore
    );

    final hasMore = reminders.length > clampedLimit;
    final data = hasMore ? reminders.sublist(0, clampedLimit) : reminders;

    String? nextCursor;
    if (hasMore && data.isNotEmpty) {
      nextCursor = data.last['created_at'] as String;
    }

    return {
      'data': data,
      'pagination': {'cursor': nextCursor, 'has_more': hasMore},
    };
  }

  /// Updates a reminder. Only the creator can update.
  Future<Map<String, dynamic>> updateReminder({
    required String reminderId,
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    final existing = await _repo.getReminderById(reminderId);
    if (existing == null) {
      throw const ReminderException(
        'Reminder not found',
        code: 'REMINDER_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Only creator can update
    if (existing['created_by'] != userId) {
      throw const ReminderException(
        'Only the reminder creator can update it',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Validate message if provided
    if (updates.containsKey('message')) {
      final message = updates['message'] as String?;
      if (message == null || message.trim().isEmpty) {
        throw const ReminderException(
          'Reminder message cannot be empty',
          code: 'INVALID_MESSAGE',
          statusCode: 422,
        );
      }
      updates['message'] = message.trim();
    }

    // Validate trigger_at if provided
    if (updates.containsKey('trigger_at')) {
      final triggerAt = updates['trigger_at'];
      DateTime parsedTime;
      if (triggerAt is DateTime) {
        parsedTime = triggerAt;
      } else if (triggerAt is String) {
        parsedTime = DateTime.parse(triggerAt);
      } else {
        throw const ReminderException(
          'Invalid trigger_at format',
          code: 'INVALID_TRIGGER_TIME',
          statusCode: 422,
        );
      }

      if (parsedTime.isBefore(DateTime.now().toUtc())) {
        throw const ReminderException(
          'Trigger time must be in the future',
          code: 'INVALID_TRIGGER_TIME',
          statusCode: 422,
        );
      }
      updates['trigger_at'] = parsedTime;
    }

    final updated = await _repo.updateReminder(reminderId, updates);
    if (updated == null) {
      throw const ReminderException(
        'Failed to update reminder',
        code: 'UPDATE_FAILED',
        statusCode: 500,
      );
    }

    _log.info('Reminder updated: $reminderId by $userId');
    return updated;
  }

  /// Deletes a reminder. Only the creator or an admin can delete.
  Future<void> deleteReminder({
    required String reminderId,
    required String userId,
    String? userRole,
  }) async {
    final existing = await _repo.getReminderById(reminderId);
    if (existing == null) {
      throw const ReminderException(
        'Reminder not found',
        code: 'REMINDER_NOT_FOUND',
        statusCode: 404,
      );
    }

    final isCreator = existing['created_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdmin) {
      throw const ReminderException(
        'Only the reminder creator or an admin can delete it',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.softDeleteReminder(reminderId);
    _log.info('Reminder deleted: $reminderId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Snooze
  // ---------------------------------------------------------------------------

  /// Snoozes a reminder until the specified time.
  Future<Map<String, dynamic>> snoozeReminder({
    required String reminderId,
    required DateTime snoozedUntil,
  }) async {
    // Validate snooze time is in the future
    if (snoozedUntil.isBefore(DateTime.now().toUtc())) {
      throw const ReminderException(
        'Snooze time must be in the future',
        code: 'INVALID_SNOOZE_TIME',
        statusCode: 422,
      );
    }

    final existing = await _repo.getReminderById(reminderId);
    if (existing == null) {
      throw const ReminderException(
        'Reminder not found',
        code: 'REMINDER_NOT_FOUND',
        statusCode: 404,
      );
    }

    final updated = await _repo.snoozeReminder(reminderId, snoozedUntil);
    if (updated == null) {
      throw const ReminderException(
        'Failed to snooze reminder',
        code: 'SNOOZE_FAILED',
        statusCode: 500,
      );
    }

    _log.info('Reminder snoozed: $reminderId until $snoozedUntil');
    return updated;
  }

  // ---------------------------------------------------------------------------
  // Background Job
  // ---------------------------------------------------------------------------

  /// Processes all pending reminders: sends notifications and marks them as sent.
  Future<int> processPendingReminders() async {
    final pending = await _repo.getPendingReminders();
    var processedCount = 0;

    for (final reminder in pending) {
      try {
        final createdBy = reminder['created_by'] as String;
        final message = reminder['message'] as String;
        final spaceId = reminder['space_id'] as String;

        // Send notification to the reminder creator
        await _notificationService.notify(
          userId: createdBy,
          type: 'reminder.triggered',
          title: 'Reminder',
          body: message,
          spaceId: spaceId,
          data: {
            'reminder_id': reminder['id'],
            'linked_module': reminder['linked_module'],
            'linked_entity_id': reminder['linked_entity_id'],
          },
          channels: {NotificationChannel.inApp, NotificationChannel.push},
        );

        // Mark as sent
        await _repo.markSent(reminder['id'] as String);
        processedCount++;

        _log.fine('Processed reminder: ${reminder['id']}');
      } catch (e, stackTrace) {
        _log.severe(
          'Failed to process reminder: ${reminder['id']}',
          e,
          stackTrace,
        );
      }
    }

    if (processedCount > 0) {
      _log.info('Processed $processedCount pending reminders');
    }

    return processedCount;
  }
}
