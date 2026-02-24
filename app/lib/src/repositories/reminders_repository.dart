import 'package:drift/drift.dart';
import 'package:studio_pair/src/services/api/reminders_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/reminders_dao.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Repository that wraps the Reminders API and DAO to provide an
/// offline-first data layer with batch cache upserts.
class RemindersRepository {
  RemindersRepository(this._api, this._dao);

  final RemindersApi _api;
  final RemindersDao _dao;

  /// Returns cached reminders, then fetches fresh from API and updates cache.
  /// Note: The API is user-scoped, but the DAO stores by spaceId.
  Future<List<CachedReminder>> getReminders(String spaceId) async {
    try {
      final response = await _api.listReminders();
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedReminders,
          jsonList
              .map(
                (json) => CachedRemindersCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  createdBy: json['created_by'] as String? ?? '',
                  message: json['message'] as String,
                  triggerAt:
                      DateTime.tryParse(json['trigger_at'] as String? ?? '') ??
                      DateTime.now(),
                  recurrenceRule: Value(json['recurrence_rule'] as String?),
                  linkedModule: Value(json['linked_module'] as String?),
                  linkedEntityId: Value(json['linked_entity_id'] as String?),
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
      return _dao.getReminders(spaceId).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getReminders(spaceId).first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load reminders: $e');
    }
  }

  /// Creates a new reminder via the API.
  Future<Map<String, dynamic>> createReminder({
    required String message,
    required String triggerAt,
    String? recurrenceRule,
    String? linkedModule,
    String? linkedEntityId,
  }) async {
    try {
      final response = await _api.createReminder(
        message: message,
        triggerAt: triggerAt,
        recurrenceRule: recurrenceRule,
        linkedModule: linkedModule,
        linkedEntityId: linkedEntityId,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to create reminder: $e');
    }
  }

  /// Gets a specific reminder by ID, with cache fallback.
  Future<Map<String, dynamic>> getReminder(String reminderId) async {
    try {
      final response = await _api.getReminder(reminderId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getReminderById(reminderId);
      if (cached != null) return {'id': cached.id, 'message': cached.message};
      throw UnknownFailure('Failed to get reminder: $e');
    }
  }

  /// Updates a reminder via the API.
  Future<Map<String, dynamic>> updateReminder(
    String reminderId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _api.updateReminder(reminderId, data);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update reminder: $e');
    }
  }

  /// Deletes a reminder via the API and removes from cache.
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _api.deleteReminder(reminderId);
      await _dao.deleteReminder(reminderId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete reminder: $e');
    }
  }

  /// Snoozes a reminder for a specified number of minutes.
  Future<Map<String, dynamic>> snoozeReminder(
    String reminderId,
    int minutes,
  ) async {
    try {
      final response = await _api.snoozeReminder(reminderId, minutes);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to snooze reminder: $e');
    }
  }

  /// Watches cached reminders for a space (reactive stream).
  Stream<List<CachedReminder>> watchReminders(String spaceId) {
    return _dao.getReminders(spaceId);
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
