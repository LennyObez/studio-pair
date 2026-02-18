import '../../config/database.dart';

/// Repository for notification database operations.
class NotificationsRepository {
  final Database _db;

  NotificationsRepository(this._db);

  /// Lists notifications for a user with cursor-based pagination.
  Future<List<Map<String, dynamic>>> listNotifications({
    required String userId,
    String? cursor,
    int limit = 25,
    bool unreadOnly = false,
  }) async {
    final params = <String, dynamic>{'userId': userId, 'limit': limit};

    var whereClause = 'WHERE n.user_id = @userId';
    if (unreadOnly) {
      whereClause += ' AND n.read_at IS NULL';
    }
    if (cursor != null) {
      whereClause += ' AND n.created_at < @cursor';
      params['cursor'] = DateTime.parse(cursor);
    }

    final result = await _db.query('''
      SELECT n.id, n.user_id, n.type, n.title, n.body,
             n.space_id, n.source_module, n.source_entity_id,
             n.data, n.read_at, n.created_at
      FROM notifications n
      $whereClause
      ORDER BY n.created_at DESC
      LIMIT @limit
      ''', parameters: params);

    return result.map((row) => row.toColumnMap()).toList();
  }

  /// Creates a new in-app notification.
  Future<Map<String, dynamic>> create({
    required String id,
    required String userId,
    required String type,
    required String title,
    required String body,
    String? spaceId,
    String? sourceModule,
    String? sourceEntityId,
    String? data,
  }) async {
    final result = await _db.query(
      '''
      INSERT INTO notifications (id, user_id, type, title, body, space_id,
                                 source_module, source_entity_id, data, created_at)
      VALUES (@id, @userId, @type, @title, @body, @spaceId,
              @sourceModule, @sourceEntityId, @data, NOW())
      RETURNING id, user_id, type, title, body, space_id,
                source_module, source_entity_id, data, read_at, created_at
      ''',
      parameters: {
        'id': id,
        'userId': userId,
        'type': type,
        'title': title,
        'body': body,
        'spaceId': spaceId,
        'sourceModule': sourceModule,
        'sourceEntityId': sourceEntityId,
        'data': data,
      },
    );

    return result.first.toColumnMap();
  }

  /// Marks a specific notification as read.
  Future<bool> markRead(String notificationId, String userId) async {
    final affected = await _db.execute(
      '''
      UPDATE notifications
      SET read_at = NOW()
      WHERE id = @id AND user_id = @userId AND read_at IS NULL
      ''',
      parameters: {'id': notificationId, 'userId': userId},
    );
    return affected > 0;
  }

  /// Marks all notifications as read for a user.
  Future<int> markAllRead(String userId, {String? spaceId}) async {
    final params = <String, dynamic>{'userId': userId};
    var sql = '''
      UPDATE notifications
      SET read_at = NOW()
      WHERE user_id = @userId AND read_at IS NULL
    ''';
    if (spaceId != null) {
      sql += ' AND space_id = @spaceId';
      params['spaceId'] = spaceId;
    }
    return _db.execute(sql, parameters: params);
  }

  /// Gets notification preferences for a user.
  Future<Map<String, dynamic>?> getPreferences(String userId) async {
    final row = await _db.queryOne(
      '''
      SELECT user_id, push_enabled, email_enabled,
             quiet_hours_enabled, quiet_hours_start, quiet_hours_end,
             channel_preferences, updated_at
      FROM notification_preferences
      WHERE user_id = @userId
      ''',
      parameters: {'userId': userId},
    );
    return row?.toColumnMap();
  }

  /// Upserts notification preferences for a user.
  Future<Map<String, dynamic>> upsertPreferences({
    required String userId,
    required bool pushEnabled,
    required bool emailEnabled,
    required bool quietHoursEnabled,
    required String quietHoursStart,
    required String quietHoursEnd,
    String? channelPreferences,
  }) async {
    final result = await _db.query(
      '''
      INSERT INTO notification_preferences
        (user_id, push_enabled, email_enabled, quiet_hours_enabled,
         quiet_hours_start, quiet_hours_end, channel_preferences, updated_at)
      VALUES
        (@userId, @pushEnabled, @emailEnabled, @quietHoursEnabled,
         @quietHoursStart, @quietHoursEnd, @channelPreferences, NOW())
      ON CONFLICT (user_id) DO UPDATE SET
        push_enabled = @pushEnabled,
        email_enabled = @emailEnabled,
        quiet_hours_enabled = @quietHoursEnabled,
        quiet_hours_start = @quietHoursStart,
        quiet_hours_end = @quietHoursEnd,
        channel_preferences = @channelPreferences,
        updated_at = NOW()
      RETURNING user_id, push_enabled, email_enabled,
                quiet_hours_enabled, quiet_hours_start, quiet_hours_end,
                channel_preferences, updated_at
      ''',
      parameters: {
        'userId': userId,
        'pushEnabled': pushEnabled,
        'emailEnabled': emailEnabled,
        'quietHoursEnabled': quietHoursEnabled,
        'quietHoursStart': quietHoursStart,
        'quietHoursEnd': quietHoursEnd,
        'channelPreferences': channelPreferences,
      },
    );

    return result.first.toColumnMap();
  }
}
