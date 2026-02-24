import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'reminders_service.dart';

/// Controller for reminder endpoints.
class RemindersController {
  final RemindersService _service;
  final Logger _log = Logger('RemindersController');

  RemindersController(this._service);

  /// Returns the router with all reminder routes.
  Router get router {
    final router = Router();

    router.post('/', _createReminder);
    router.get('/', _listReminders);
    router.get('/<reminderId>', _getReminder);
    router.patch('/<reminderId>', _updateReminder);
    router.delete('/<reminderId>', _deleteReminder);

    // Snooze
    router.post('/<reminderId>/snooze', _snoozeReminder);

    // Dismiss (soft delete)
    router.post('/<reminderId>/dismiss', _dismissReminder);

    return router;
  }

  /// POST /api/v1/reminders
  ///
  /// Creates a new reminder.
  /// Body: { "space_id": "...", "message": "...", "trigger_at": "...",
  ///         "recurrence_rule": "...", "linked_module": "...", "linked_entity_id": "..." }
  Future<Response> _createReminder(Request request) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);

      final spaceId = body['space_id'] as String?;
      final message = body['message'] as String?;
      final triggerAtStr = body['trigger_at'] as String?;

      if (spaceId == null || message == null || triggerAtStr == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (spaceId == null)
              {'field': 'space_id', 'message': 'Space ID is required'},
            if (message == null)
              {'field': 'message', 'message': 'Message is required'},
            if (triggerAtStr == null)
              {'field': 'trigger_at', 'message': 'Trigger time is required'},
          ],
        );
      }

      DateTime triggerAt;
      try {
        triggerAt = DateTime.parse(triggerAtStr);
      } catch (_) {
        return validationErrorResponse(
          'Invalid trigger_at format. Use ISO 8601.',
        );
      }

      final result = await _service.createReminder(
        spaceId: spaceId,
        createdBy: userId,
        message: message,
        triggerAt: triggerAt,
        recurrenceRule: body['recurrence_rule'] as String?,
        linkedModule: body['linked_module'] as String?,
        linkedEntityId: body['linked_entity_id'] as String?,
      );

      return createdResponse(result);
    } on ReminderException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create reminder error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/reminders?space_id=&upcoming=true&cursor=&limit=
  ///
  /// Lists reminders with optional filtering and pagination.
  Future<Response> _listReminders(Request request) async {
    try {
      final spaceId = request.url.queryParameters['space_id'];
      if (spaceId == null || spaceId.isEmpty) {
        return validationErrorResponse('space_id query parameter is required');
      }

      final upcomingStr = request.url.queryParameters['upcoming'];
      final pastStr = request.url.queryParameters['past'];
      final createdBy = request.url.queryParameters['created_by'];
      final pagination = getPaginationParams(request);

      final upcoming = upcomingStr == 'true' ? true : null;
      final past = pastStr == 'true' ? true : null;

      final result = await _service.getReminders(
        spaceId,
        upcoming: upcoming,
        past: past,
        createdBy: createdBy,
        cursor: pagination.cursor,
        limit: pagination.limit,
      );

      return jsonResponse(result);
    } catch (e, stackTrace) {
      _log.severe('List reminders error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/reminders/<reminderId>
  ///
  /// Gets a single reminder.
  Future<Response> _getReminder(Request request, String reminderId) async {
    try {
      final reminder = await _service.getReminder(reminderId);
      return jsonResponse(reminder);
    } on ReminderException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get reminder error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /api/v1/reminders/<reminderId>
  ///
  /// Updates a reminder.
  /// Body: { "message": "...", "trigger_at": "...", "recurrence_rule": "...",
  ///         "linked_module": "...", "linked_entity_id": "..." }
  Future<Response> _updateReminder(Request request, String reminderId) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);

      final updates = <String, dynamic>{};
      if (body.containsKey('message')) updates['message'] = body['message'];
      if (body.containsKey('trigger_at')) {
        final triggerAtStr = body['trigger_at'] as String?;
        if (triggerAtStr != null) {
          try {
            updates['trigger_at'] = DateTime.parse(triggerAtStr);
          } catch (_) {
            return validationErrorResponse(
              'Invalid trigger_at format. Use ISO 8601.',
            );
          }
        }
      }
      if (body.containsKey('recurrence_rule')) {
        updates['recurrence_rule'] = body['recurrence_rule'];
      }
      if (body.containsKey('linked_module')) {
        updates['linked_module'] = body['linked_module'];
      }
      if (body.containsKey('linked_entity_id')) {
        updates['linked_entity_id'] = body['linked_entity_id'];
      }

      final result = await _service.updateReminder(
        reminderId: reminderId,
        userId: userId,
        updates: updates,
      );

      return jsonResponse(result);
    } on ReminderException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update reminder error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /api/v1/reminders/<reminderId>
  ///
  /// Deletes a reminder.
  Future<Response> _deleteReminder(Request request, String reminderId) async {
    try {
      final userId = getUserId(request);

      await _service.deleteReminder(reminderId: reminderId, userId: userId);

      return noContentResponse();
    } on ReminderException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete reminder error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/reminders/<reminderId>/snooze
  ///
  /// Snoozes a reminder.
  /// Body: { "snoozed_until": "2025-01-15T10:00:00Z" }
  Future<Response> _snoozeReminder(Request request, String reminderId) async {
    try {
      final body = await readJsonBody(request);

      final snoozedUntilStr = body['snoozed_until'] as String?;
      if (snoozedUntilStr == null || snoozedUntilStr.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'snoozed_until', 'message': 'Snooze time is required'},
          ],
        );
      }

      DateTime snoozedUntil;
      try {
        snoozedUntil = DateTime.parse(snoozedUntilStr);
      } catch (_) {
        return validationErrorResponse(
          'Invalid snoozed_until format. Use ISO 8601.',
        );
      }

      final result = await _service.snoozeReminder(
        reminderId: reminderId,
        snoozedUntil: snoozedUntil,
      );

      return jsonResponse(result);
    } on ReminderException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Snooze reminder error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/reminders/<reminderId>/dismiss
  ///
  /// Dismisses (soft-deletes) a reminder.
  Future<Response> _dismissReminder(Request request, String reminderId) async {
    try {
      final userId = getUserId(request);

      await _service.deleteReminder(reminderId: reminderId, userId: userId);

      return jsonResponse({'message': 'Reminder dismissed'});
    } on ReminderException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Dismiss reminder error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
