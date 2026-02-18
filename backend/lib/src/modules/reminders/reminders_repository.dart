import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for reminder-related database operations.
class RemindersRepository {
  final Database _db;
  // ignore: unused_field
  final Logger _log = Logger('RemindersRepository');

  RemindersRepository(this._db);

  // ---------------------------------------------------------------------------
  // Reminders
  // ---------------------------------------------------------------------------

  /// Creates a new reminder and returns the created reminder row.
  Future<Map<String, dynamic>> createReminder({
    required String id,
    required String spaceId,
    required String createdBy,
    required String message,
    required DateTime triggerAt,
    String? recurrenceRule,
    String? linkedModule,
    String? linkedEntityId,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO reminders (
        id, space_id, created_by, message, trigger_at,
        recurrence_rule, linked_module, linked_entity_id,
        is_sent, created_at, updated_at
      )
      VALUES (
        @id, @spaceId, @createdBy, @message, @triggerAt,
        @recurrenceRule, @linkedModule, @linkedEntityId,
        FALSE, NOW(), NOW()
      )
      RETURNING id, space_id, created_by, message, trigger_at,
                recurrence_rule, linked_module, linked_entity_id,
                is_sent, sent_at, snoozed_until, created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'spaceId': spaceId,
        'createdBy': createdBy,
        'message': message,
        'triggerAt': triggerAt,
        'recurrenceRule': recurrenceRule,
        'linkedModule': linkedModule,
        'linkedEntityId': linkedEntityId,
      },
    );

    return _reminderRowToMap(row!);
  }

  /// Gets a reminder by ID.
  Future<Map<String, dynamic>?> getReminderById(String reminderId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, created_by, message, trigger_at,
             recurrence_rule, linked_module, linked_entity_id,
             is_sent, sent_at, snoozed_until, created_at, updated_at
      FROM reminders
      WHERE id = @reminderId AND deleted_at IS NULL
      ''',
      parameters: {'reminderId': reminderId},
    );

    if (row == null) return null;
    return _reminderRowToMap(row);
  }

  /// Gets reminders for a space with optional filtering and cursor pagination.
  Future<List<Map<String, dynamic>>> getReminders(
    String spaceId, {
    bool? upcoming,
    bool? past,
    String? createdBy,
    String? cursor,
    int limit = 25,
  }) async {
    final whereClauses = <String>['space_id = @spaceId', 'deleted_at IS NULL'];
    final params = <String, dynamic>{'spaceId': spaceId, 'limit': limit};

    if (upcoming == true) {
      whereClauses.add('trigger_at > NOW()');
    } else if (past == true) {
      whereClauses.add('trigger_at <= NOW()');
    }

    if (createdBy != null) {
      whereClauses.add('created_by = @createdBy');
      params['createdBy'] = createdBy;
    }

    if (cursor != null) {
      whereClauses.add('created_at < @cursor');
      params['cursor'] = DateTime.parse(cursor);
    }

    final result = await _db.query('''
      SELECT id, space_id, created_by, message, trigger_at,
             recurrence_rule, linked_module, linked_entity_id,
             is_sent, sent_at, snoozed_until, created_at, updated_at
      FROM reminders
      WHERE ${whereClauses.join(' AND ')}
      ORDER BY trigger_at ASC
      LIMIT @limit
      ''', parameters: params);

    return result.map(_reminderRowToMap).toList();
  }

  /// Gets upcoming reminders for a space ordered by trigger time.
  Future<List<Map<String, dynamic>>> getUpcomingReminders(
    String spaceId,
  ) async {
    final result = await _db.query(
      '''
      SELECT id, space_id, created_by, message, trigger_at,
             recurrence_rule, linked_module, linked_entity_id,
             is_sent, sent_at, snoozed_until, created_at, updated_at
      FROM reminders
      WHERE space_id = @spaceId
        AND deleted_at IS NULL
        AND trigger_at > NOW()
      ORDER BY trigger_at ASC
      ''',
      parameters: {'spaceId': spaceId},
    );

    return result.map(_reminderRowToMap).toList();
  }

  /// Gets all unsent reminders where trigger time has passed (for background job).
  Future<List<Map<String, dynamic>>> getPendingReminders() async {
    final result = await _db.query('''
      SELECT id, space_id, created_by, message, trigger_at,
             recurrence_rule, linked_module, linked_entity_id,
             is_sent, sent_at, snoozed_until, created_at, updated_at
      FROM reminders
      WHERE is_sent = FALSE
        AND deleted_at IS NULL
        AND trigger_at <= NOW()
        AND (snoozed_until IS NULL OR snoozed_until <= NOW())
      ORDER BY trigger_at ASC
      ''');

    return result.map(_reminderRowToMap).toList();
  }

  /// Updates a reminder with the given field updates.
  Future<Map<String, dynamic>?> updateReminder(
    String reminderId,
    Map<String, dynamic> updates,
  ) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'reminderId': reminderId};

    if (updates.containsKey('message')) {
      setClauses.add('message = @message');
      params['message'] = updates['message'];
    }
    if (updates.containsKey('trigger_at')) {
      setClauses.add('trigger_at = @triggerAt');
      params['triggerAt'] = updates['trigger_at'];
    }
    if (updates.containsKey('recurrence_rule')) {
      setClauses.add('recurrence_rule = @recurrenceRule');
      params['recurrenceRule'] = updates['recurrence_rule'];
    }
    if (updates.containsKey('linked_module')) {
      setClauses.add('linked_module = @linkedModule');
      params['linkedModule'] = updates['linked_module'];
    }
    if (updates.containsKey('linked_entity_id')) {
      setClauses.add('linked_entity_id = @linkedEntityId');
      params['linkedEntityId'] = updates['linked_entity_id'];
    }

    if (setClauses.isEmpty) {
      return getReminderById(reminderId);
    }

    setClauses.add('updated_at = NOW()');

    final row = await _db.queryOne('''
      UPDATE reminders
      SET ${setClauses.join(', ')}
      WHERE id = @reminderId AND deleted_at IS NULL
      RETURNING id, space_id, created_by, message, trigger_at,
                recurrence_rule, linked_module, linked_entity_id,
                is_sent, sent_at, snoozed_until, created_at, updated_at
      ''', parameters: params);

    if (row == null) return null;
    return _reminderRowToMap(row);
  }

  /// Soft-deletes a reminder.
  Future<void> softDeleteReminder(String reminderId) async {
    await _db.execute(
      '''
      UPDATE reminders
      SET deleted_at = NOW(), updated_at = NOW()
      WHERE id = @reminderId
      ''',
      parameters: {'reminderId': reminderId},
    );
  }

  /// Marks a reminder as sent.
  Future<void> markSent(String reminderId) async {
    await _db.execute(
      '''
      UPDATE reminders
      SET is_sent = TRUE, sent_at = NOW(), updated_at = NOW()
      WHERE id = @reminderId
      ''',
      parameters: {'reminderId': reminderId},
    );
  }

  /// Snoozes a reminder until the specified time.
  Future<Map<String, dynamic>?> snoozeReminder(
    String reminderId,
    DateTime snoozedUntil,
  ) async {
    final row = await _db.queryOne(
      '''
      UPDATE reminders
      SET snoozed_until = @snoozedUntil, is_sent = FALSE,
          updated_at = NOW()
      WHERE id = @reminderId AND deleted_at IS NULL
      RETURNING id, space_id, created_by, message, trigger_at,
                recurrence_rule, linked_module, linked_entity_id,
                is_sent, sent_at, snoozed_until, created_at, updated_at
      ''',
      parameters: {'reminderId': reminderId, 'snoozedUntil': snoozedUntil},
    );

    if (row == null) return null;
    return _reminderRowToMap(row);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _reminderRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_by': row[2] as String,
      'message': row[3] as String,
      'trigger_at': (row[4] as DateTime).toIso8601String(),
      'recurrence_rule': row[5] as String?,
      'linked_module': row[6] as String?,
      'linked_entity_id': row[7] as String?,
      'is_sent': row[8] as bool,
      'sent_at': row[9] != null ? (row[9] as DateTime).toIso8601String() : null,
      'snoozed_until': row[10] != null
          ? (row[10] as DateTime).toIso8601String()
          : null,
      'created_at': (row[11] as DateTime).toIso8601String(),
      'updated_at': (row[12] as DateTime).toIso8601String(),
    };
  }
}
