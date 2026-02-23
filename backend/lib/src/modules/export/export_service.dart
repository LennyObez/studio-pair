import 'package:logging/logging.dart';

import 'export_repository.dart';

/// Service for GDPR data export.
///
/// Gathers all user data across modules and serializes it into a
/// structured JSON document. Rate-limited to one export per 24 hours.
class ExportService {
  final ExportRepository _repo;
  final Logger _log = Logger('ExportService');

  /// Minimum time between exports.
  static const _exportCooldown = Duration(hours: 24);

  ExportService(this._repo);

  /// Exports all data belonging to the given user.
  ///
  /// Returns a structured map containing every category of user data.
  /// Throws [ExportException] if the user is rate-limited.
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    // Rate-limit check
    final lastExport = await _repo.getLastExportTime(userId);
    if (lastExport != null) {
      final since = DateTime.now().toUtc().difference(lastExport);
      if (since < _exportCooldown) {
        final remaining = _exportCooldown - since;
        throw ExportException(
          'You can only export your data once every 24 hours. '
          'Please try again in ${remaining.inMinutes} minutes.',
          code: 'EXPORT_RATE_LIMITED',
          statusCode: 429,
        );
      }
    }

    _log.info('Starting data export for user $userId');

    // Gather data from all modules concurrently
    final results = await Future.wait([
      _repo.getUserProfile(userId), // 0
      _repo.getUserSpaces(userId), // 1
      _repo.getUserActivities(userId), // 2
      _repo.getUserCalendarEvents(userId), // 3
      _repo.getUserTasks(userId), // 4
      _repo.getUserMessages(userId), // 5
      _repo.getUserFinances(userId), // 6
      _repo.getUserHealthData(userId), // 7
      _repo.getUserFiles(userId), // 8
      _repo.getUserNotificationPreferences(userId), // 9
    ]);

    // Log the export
    await _repo.logExport(userId);

    _log.info('Data export completed for user $userId');

    return {
      'export_version': '1.0',
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'user_id': userId,
      'profile': results[0],
      'spaces': results[1],
      'activities': results[2],
      'calendar_events': results[3],
      'tasks': results[4],
      'messages': results[5],
      'finances': results[6],
      'health_data': results[7],
      'files': results[8],
      'notification_preferences': results[9],
    };
  }
}

/// Exception thrown for export-related errors.
class ExportException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const ExportException(
    this.message, {
    this.code = 'EXPORT_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'ExportException($code): $message';
}
