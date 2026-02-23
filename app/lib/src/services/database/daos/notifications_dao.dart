import 'package:drift/drift.dart';
import '../app_database.dart';

part 'notifications_dao.g.dart';

@DriftAccessor(tables: [CachedNotifications])
class NotificationsDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationsDaoMixin {
  NotificationsDao(super.db);

  /// Inserts or updates a cached notification.
  Future<void> upsertNotification(CachedNotificationsCompanion notification) {
    return into(cachedNotifications).insertOnConflictUpdate(notification);
  }

  /// Watches all notifications for a given user, ordered by most recent first.
  Stream<List<CachedNotification>> getNotifications(String userId) {
    return (select(cachedNotifications)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Returns the count of unread notifications for a user.
  Future<int> getUnreadCount(String userId) async {
    final count = cachedNotifications.id.count();
    final query = selectOnly(cachedNotifications)
      ..addColumns([count])
      ..where(
        cachedNotifications.userId.equals(userId) &
            cachedNotifications.isRead.equals(false),
      );
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Marks a notification as read.
  Future<void> markAsRead(String id) {
    return (update(cachedNotifications)..where((t) => t.id.equals(id))).write(
      const CachedNotificationsCompanion(isRead: Value(true)),
    );
  }

  /// Deletes a notification from the local cache.
  Future<int> deleteNotification(String id) {
    return (delete(cachedNotifications)..where((t) => t.id.equals(id))).go();
  }
}
