import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/notifications_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/notifications_dao.dart';

/// App notification model.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.spaceId,
    this.sourceModule,
    this.sourceEntityId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      body: json['body'],
      spaceId: json['space_id'],
      sourceModule: json['source_module'],
      sourceEntityId: json['source_entity_id'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  final String id;
  final String type;
  final String title;
  final String body;
  final String? spaceId;
  final String? sourceModule;
  final String? sourceEntityId;
  final bool isRead;
  final DateTime createdAt;
}

/// Notifications state.
class NotificationsState {
  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isCached = false,
    this.error,
  });

  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final bool isCached;
  final String? error;

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? isCached,
    String? error,
    bool clearError = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifications state notifier managing notification loading and read status.
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier(this._api, this._dao)
    : super(const NotificationsState());

  final NotificationsApi _api;
  final NotificationsDao _dao;

  /// Load notifications for the current user.
  Future<void> loadNotifications({String? userId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // 1. Load from cache first
    if (userId != null) {
      try {
        final cached = await _dao.getNotifications(userId).first;
        if (cached.isNotEmpty) {
          final notifications = cached
              .map(
                (c) => AppNotification(
                  id: c.id,
                  type: c.type,
                  title: c.title,
                  body: c.body,
                  spaceId: c.spaceId,
                  sourceModule: c.sourceModule,
                  sourceEntityId: c.sourceEntityId,
                  isRead: c.isRead,
                  createdAt: c.createdAt,
                ),
              )
              .toList();
          final unread = notifications.where((n) => !n.isRead).length;
          state = state.copyWith(
            notifications: notifications,
            unreadCount: unread,
            isLoading: false,
            isCached: true,
          );
        }
      } catch (_) {
        // Cache read failed, continue to API
      }
    }

    // 2. Try API in background
    try {
      final response = await _api.listNotifications();
      final items = parseList(response.data);
      final notifications = items.map(AppNotification.fromJson).toList();

      final unread = notifications.where((n) => !n.isRead).length;

      // Upsert into cache
      if (userId != null) {
        for (final item in notifications) {
          await _dao.upsertNotification(
            CachedNotificationsCompanion(
              id: Value(item.id),
              userId: Value(userId),
              spaceId: Value(item.spaceId),
              type: Value(item.type),
              title: Value(item.title),
              body: Value(item.body),
              sourceModule: Value(item.sourceModule),
              sourceEntityId: Value(item.sourceEntityId),
              isRead: Value(item.isRead),
              createdAt: Value(item.createdAt),
              syncedAt: Value(DateTime.now()),
            ),
          );
        }
      }

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unread,
        isLoading: false,
        isCached: false,
      );
    } catch (e) {
      if (state.notifications.isEmpty) {
        state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Mark a single notification as read.
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _api.markAsRead(notificationId);

      final updatedNotifications = state.notifications.map((notif) {
        if (notif.id == notificationId) {
          return AppNotification(
            id: notif.id,
            type: notif.type,
            title: notif.title,
            body: notif.body,
            spaceId: notif.spaceId,
            sourceModule: notif.sourceModule,
            sourceEntityId: notif.sourceEntityId,
            isRead: true,
            createdAt: notif.createdAt,
          );
        }
        return notif;
      }).toList();

      final unread = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unread,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return false;
    }
  }

  /// Mark all notifications as read.
  Future<bool> markAllAsRead() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.markAllAsRead();

      final updatedNotifications = state.notifications.map((notif) {
        return AppNotification(
          id: notif.id,
          type: notif.type,
          title: notif.title,
          body: notif.body,
          spaceId: notif.spaceId,
          sourceModule: notif.sourceModule,
          sourceEntityId: notif.sourceEntityId,
          isRead: true,
          createdAt: notif.createdAt,
        );
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Refresh the unread notification count.
  Future<void> refreshUnreadCount() async {
    try {
      final response = await _api.getUnreadCount();
      final data = response.data;
      final count = data is Map ? (data['count'] as int? ?? 0) : 0;
      state = state.copyWith(unreadCount: count);
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
    }
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Notifications state provider.
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
      return NotificationsNotifier(
        ref.watch(notificationsApiProvider),
        ref.watch(notificationsDaoProvider),
      );
    });

/// Convenience provider for the unread notification count.
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});

/// Convenience provider for the notification list.
final notificationListProvider = Provider<List<AppNotification>>((ref) {
  return ref.watch(notificationsProvider).notifications;
});
