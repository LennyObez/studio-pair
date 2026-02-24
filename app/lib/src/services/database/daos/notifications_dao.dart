import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'notifications_dao.g.dart';

@DriftAccessor(tables: [CachedNotifications])
class NotificationsDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationsDaoMixin {
  NotificationsDao(super.db);

  /// Inserts or updates a cached notification.
  Future<void> upsertNotification(CachedNotificationsCompanion notification) {
    try {
      return into(cachedNotifications).insertOnConflictUpdate(notification);
    } catch (e) {
      throw StorageFailure('Failed to upsert notification: $e');
    }
  }

  /// Watches all notifications for a given user, ordered by most recent first.
  Stream<List<CachedNotification>> getNotifications(String userId) {
    try {
      return (select(cachedNotifications)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get notifications: $e');
    }
  }

  /// Returns the count of unread notifications for a user.
  Future<int> getUnreadCount(String userId) async {
    try {
      final count = cachedNotifications.id.count();
      final query = selectOnly(cachedNotifications)
        ..addColumns([count])
        ..where(
          cachedNotifications.userId.equals(userId) &
              cachedNotifications.isRead.equals(false),
        );
      final result = await query.getSingle();
      return result.read(count) ?? 0;
    } catch (e) {
      throw StorageFailure('Failed to get unread count: $e');
    }
  }

  /// Marks a notification as read.
  Future<void> markAsRead(String id) {
    try {
      return (update(cachedNotifications)..where((t) => t.id.equals(id))).write(
        const CachedNotificationsCompanion(isRead: Value(true)),
      );
    } catch (e) {
      throw StorageFailure('Failed to mark notification as read: $e');
    }
  }

  /// Deletes a notification from the local cache.
  Future<int> deleteNotification(String id) {
    try {
      return (delete(cachedNotifications)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete notification: $e');
    }
  }

  /// Batch upserts notifications into cache.
  Future<void> upsertNotifications(
    List<CachedNotificationsCompanion> notifications,
  ) {
    try {
      return batch((b) {
        b.insertAll(
          cachedNotifications,
          notifications,
          mode: InsertMode.insertOrReplace,
        );
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert notifications: $e');
    }
  }
}
