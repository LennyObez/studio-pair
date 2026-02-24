import 'package:drift/drift.dart';
import 'package:studio_pair/src/services/api/notifications_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/notifications_dao.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Repository that wraps the Notifications API and DAO to provide an
/// offline-first data layer with batch cache upserts.
class NotificationsRepository {
  NotificationsRepository(this._api, this._dao);

  final NotificationsApi _api;
  final NotificationsDao _dao;

  /// Returns cached notifications, then fetches fresh from API and updates cache.
  Future<List<CachedNotification>> getNotifications(String userId) async {
    try {
      final response = await _api.listNotifications();
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedNotifications,
          jsonList
              .map(
                (json) => CachedNotificationsCompanion.insert(
                  id: json['id'] as String,
                  userId: json['user_id'] as String? ?? userId,
                  spaceId: Value(json['space_id'] as String?),
                  type: json['type'] as String? ?? '',
                  title: json['title'] as String? ?? '',
                  body: json['body'] as String? ?? '',
                  sourceModule: Value(json['source_module'] as String?),
                  sourceEntityId: Value(json['source_entity_id'] as String?),
                  createdAt:
                      DateTime.tryParse(json['created_at'] as String? ?? '') ??
                      DateTime.now(),
                  syncedAt: DateTime.now(),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
      return _dao.getNotifications(userId).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getNotifications(userId).first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load notifications: $e');
    }
  }

  /// Marks a specific notification as read via the API and locally.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _api.markAsRead(notificationId);
      await _dao.markAsRead(notificationId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to mark notification as read: $e');
    }
  }

  /// Marks all notifications as read via the API.
  Future<void> markAllAsRead() async {
    try {
      await _api.markAllAsRead();
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to mark all notifications as read: $e');
    }
  }

  /// Gets the count of unread notifications, with cache fallback.
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _api.getUnreadCount();
      final data = response.data;
      if (data is Map && data.containsKey('count')) {
        return data['count'] as int;
      }
      return _dao.getUnreadCount(userId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      return _dao.getUnreadCount(userId);
    }
  }

  /// Watches cached notifications for a user (reactive stream).
  Stream<List<CachedNotification>> watchNotifications(String userId) {
    return _dao.getNotifications(userId);
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
