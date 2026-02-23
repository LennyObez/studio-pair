import '../../config/database.dart';

/// Repository for gathering all user data for GDPR export.
class ExportRepository {
  final Database _db;

  ExportRepository(this._db);

  /// Get user profile data.
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, email, display_name, avatar_url, preferred_language,
             timezone, created_at, updated_at
      FROM users
      WHERE id = @userId AND deleted_at IS NULL
      ''',
      parameters: {'userId': userId},
    );
    return row?.toColumnMap();
  }

  /// Get all spaces the user belongs to.
  Future<List<Map<String, dynamic>>> getUserSpaces(String userId) async {
    final result = await _db.query(
      '''
      SELECT s.id, s.name, s.type, sm.role, sm.joined_at
      FROM spaces s
      JOIN space_memberships sm ON sm.space_id = s.id
      WHERE sm.user_id = @userId AND sm.status = 'active'
      ''',
      parameters: {'userId': userId},
    );
    return result.map((r) => r.toColumnMap()).toList();
  }

  /// Get all activities created by the user.
  Future<List<Map<String, dynamic>>> getUserActivities(String userId) async {
    final result = await _db.query(
      '''
      SELECT id, space_id, title, description, category, status, mode,
             created_at, updated_at
      FROM activities
      WHERE created_by = @userId AND deleted_at IS NULL
      ''',
      parameters: {'userId': userId},
    );
    return result.map((r) => r.toColumnMap()).toList();
  }

  /// Get all calendar events created by the user.
  Future<List<Map<String, dynamic>>> getUserCalendarEvents(
    String userId,
  ) async {
    final result = await _db.query(
      '''
      SELECT id, space_id, title, location, event_type, all_day,
             start_at, end_at, created_at
      FROM calendar_events
      WHERE created_by = @userId AND deleted_at IS NULL
      ''',
      parameters: {'userId': userId},
    );
    return result.map((r) => r.toColumnMap()).toList();
  }

  /// Get all tasks created by or assigned to the user.
  Future<List<Map<String, dynamic>>> getUserTasks(String userId) async {
    final result = await _db.query(
      '''
      SELECT DISTINCT t.id, t.space_id, t.title, t.description, t.status,
             t.priority, t.due_date, t.created_at
      FROM tasks t
      LEFT JOIN task_assignments ta ON ta.task_id = t.id
      WHERE (t.created_by = @userId OR ta.user_id = @userId)
        AND t.deleted_at IS NULL
      ''',
      parameters: {'userId': userId},
    );
    return result.map((r) => r.toColumnMap()).toList();
  }

  /// Get all messages sent by the user.
  Future<List<Map<String, dynamic>>> getUserMessages(String userId) async {
    final result = await _db.query(
      '''
      SELECT id, conversation_id, content, content_type, created_at
      FROM messages
      WHERE sender_id = @userId AND deleted_at IS NULL
      ORDER BY created_at DESC
      ''',
      parameters: {'userId': userId},
    );
    return result.map((r) => r.toColumnMap()).toList();
  }

  /// Get all finance entries created by the user.
  Future<List<Map<String, dynamic>>> getUserFinances(String userId) async {
    final result = await _db.query(
      '''
      SELECT id, space_id, title, amount_cents, currency, category,
             entry_type, date, created_at
      FROM finance_entries
      WHERE created_by = @userId AND deleted_at IS NULL
      ''',
      parameters: {'userId': userId},
    );
    return result.map((r) => r.toColumnMap()).toList();
  }

  /// Get user's health data.
  Future<List<Map<String, dynamic>>> getUserHealthData(String userId) async {
    final result = await _db.query(
      '''
      SELECT id, measurement_type, value, unit, measured_at, source
      FROM health_measurements
      WHERE user_id = @userId
      ORDER BY measured_at DESC
      ''',
      parameters: {'userId': userId},
    );
    return result.map((r) => r.toColumnMap()).toList();
  }

  /// Get file metadata for files uploaded by the user.
  Future<List<Map<String, dynamic>>> getUserFiles(String userId) async {
    final result = await _db.query(
      '''
      SELECT id, space_id, filename, content_type, size_bytes, created_at
      FROM files
      WHERE uploaded_by = @userId AND deleted_at IS NULL
      ''',
      parameters: {'userId': userId},
    );
    return result.map((r) => r.toColumnMap()).toList();
  }

  /// Get user's notification preferences.
  Future<Map<String, dynamic>?> getUserNotificationPreferences(
    String userId,
  ) async {
    final row = await _db.queryOne(
      '''
      SELECT push_enabled, email_enabled, quiet_hours_enabled,
             quiet_hours_start, quiet_hours_end
      FROM notification_preferences
      WHERE user_id = @userId
      ''',
      parameters: {'userId': userId},
    );
    return row?.toColumnMap();
  }

  /// Check when the user last exported data (for rate limiting).
  Future<DateTime?> getLastExportTime(String userId) async {
    final row = await _db.queryOne(
      '''
      SELECT MAX(created_at) as last_export
      FROM audit_logs
      WHERE user_id = @userId AND action = 'data_export'
      ''',
      parameters: {'userId': userId},
    );
    final value = row?[0];
    if (value == null) return null;
    return value is DateTime ? value : DateTime.tryParse(value.toString());
  }

  /// Log a data export event.
  Future<void> logExport(String userId) async {
    await _db.execute(
      '''
      INSERT INTO audit_logs (id, user_id, action, created_at)
      VALUES (gen_random_uuid(), @userId, 'data_export', NOW())
      ''',
      parameters: {'userId': userId},
    );
  }
}
