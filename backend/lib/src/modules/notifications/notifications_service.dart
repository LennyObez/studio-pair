import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import 'notifications_repository.dart';

/// Service for notification module business logic.
class NotificationsModuleService {
  final NotificationsRepository _repo;
  final Logger _log = Logger('NotificationsModuleService');
  // ignore: unused_field
  final Uuid _uuid = const Uuid();

  NotificationsModuleService(this._repo);

  /// Lists notifications for a user with pagination.
  Future<Map<String, dynamic>> listNotifications({
    required String userId,
    String? cursor,
    int limit = 25,
    bool unreadOnly = false,
  }) async {
    // Fetch one extra to determine if there are more
    final notifications = await _repo.listNotifications(
      userId: userId,
      cursor: cursor,
      limit: limit + 1,
      unreadOnly: unreadOnly,
    );

    final hasMore = notifications.length > limit;
    if (hasMore) {
      notifications.removeLast();
    }

    final nextCursor = hasMore && notifications.isNotEmpty
        ? notifications.last['created_at']?.toString()
        : null;

    return {
      'data': notifications,
      'pagination': {'cursor': nextCursor, 'has_more': hasMore},
    };
  }

  /// Marks a single notification as read.
  Future<bool> markRead(String notificationId, String userId) async {
    final marked = await _repo.markRead(notificationId, userId);
    if (!marked) {
      _log.fine('Notification $notificationId not found or already read');
    }
    return marked;
  }

  /// Marks all notifications as read for a user.
  Future<int> markAllRead(String userId, {String? spaceId}) async {
    return _repo.markAllRead(userId, spaceId: spaceId);
  }

  /// Gets notification preferences for a user, with defaults.
  Future<Map<String, dynamic>> getPreferences(String userId) async {
    final prefs = await _repo.getPreferences(userId);
    if (prefs != null) {
      return prefs;
    }

    // Return default preferences
    return {
      'user_id': userId,
      'push_enabled': true,
      'email_enabled': true,
      'quiet_hours_enabled': false,
      'quiet_hours_start': '22:00',
      'quiet_hours_end': '08:00',
      'channel_preferences': null,
    };
  }

  /// Updates notification preferences for a user.
  Future<Map<String, dynamic>> updatePreferences(
    String userId,
    Map<String, dynamic> input,
  ) async {
    return _repo.upsertPreferences(
      userId: userId,
      pushEnabled: input['push_enabled'] as bool? ?? true,
      emailEnabled: input['email_enabled'] as bool? ?? true,
      quietHoursEnabled: input['quiet_hours_enabled'] as bool? ?? false,
      quietHoursStart: input['quiet_hours_start'] as String? ?? '22:00',
      quietHoursEnd: input['quiet_hours_end'] as String? ?? '08:00',
      channelPreferences: input['channel_preferences'] as String?,
    );
  }
}
