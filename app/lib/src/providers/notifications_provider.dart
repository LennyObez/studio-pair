import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/auth_provider.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/database/app_database.dart';

// ── Async notifier ──────────────────────────────────────────────────────

/// Notifications notifier backed by the [NotificationsRepository].
///
/// The [build] method fetches notifications from the repository (API + cache)
/// whenever the current user changes.
class NotificationsNotifier
    extends AutoDisposeAsyncNotifier<List<CachedNotification>> {
  @override
  Future<List<CachedNotification>> build() async {
    final repo = ref.watch(notificationsRepositoryProvider);
    final userId = ref.watch(currentUserProvider)?.id;
    if (userId == null) return [];
    return repo.getNotifications(userId);
  }

  /// Mark a single notification as read and refresh.
  Future<bool> markAsRead(String notificationId) async {
    final repo = ref.read(notificationsRepositoryProvider);
    final userId = ref.read(currentUserProvider)?.id;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.markAsRead(notificationId);
      if (userId == null) return <CachedNotification>[];
      return repo.getNotifications(userId);
    });
    return !state.hasError;
  }

  /// Mark all notifications as read and refresh.
  Future<bool> markAllAsRead() async {
    final repo = ref.read(notificationsRepositoryProvider);
    final userId = ref.read(currentUserProvider)?.id;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.markAllAsRead();
      if (userId == null) return <CachedNotification>[];
      return repo.getNotifications(userId);
    });
    return !state.hasError;
  }
}

/// Notifications async provider.
final notificationsProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsNotifier,
      List<CachedNotification>
    >(NotificationsNotifier.new);

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for the unread notification count.
final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});

/// Convenience provider for the notification list.
final notificationListProvider = Provider<List<CachedNotification>>((ref) {
  return ref.watch(notificationsProvider).valueOrNull ?? [];
});
