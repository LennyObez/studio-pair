import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Reminders API service for managing user-level reminders.
class RemindersApi {
  RemindersApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Create a new reminder.
  Future<Response> createReminder({
    required String message,
    required String triggerAt,
    String? recurrenceRule,
    String? linkedModule,
    String? linkedEntityId,
  }) {
    return _client.post(
      '/reminders/',
      data: {
        'message': message,
        'trigger_at': triggerAt,
        if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
        if (linkedModule != null) 'linked_module': linkedModule,
        if (linkedEntityId != null) 'linked_entity_id': linkedEntityId,
      },
    );
  }

  /// List reminders with optional pagination.
  Future<Response> listReminders({String? cursor, int? limit}) {
    return _client.get(
      '/reminders/',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
  }

  /// Get a specific reminder by ID.
  Future<Response> getReminder(String reminderId) {
    return _client.get('/reminders/$reminderId');
  }

  /// Update an existing reminder.
  Future<Response> updateReminder(
    String reminderId,
    Map<String, dynamic> data,
  ) {
    return _client.patch('/reminders/$reminderId', data: data);
  }

  /// Delete a reminder.
  Future<Response> deleteReminder(String reminderId) {
    return _client.delete('/reminders/$reminderId');
  }

  /// Snooze a reminder for a specified number of minutes.
  Future<Response> snoozeReminder(String reminderId, int minutes) {
    return _client.post(
      '/reminders/$reminderId/snooze',
      data: {'minutes': minutes},
    );
  }
}
