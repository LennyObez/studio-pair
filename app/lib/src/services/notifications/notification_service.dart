import 'dart:async';

import 'package:flutter/foundation.dart';

/// In-app notification service for managing notification state,
/// badge counts, and foreground notification display.
///
/// This service does NOT interact with Firebase. For Firebase push
/// notification lifecycle (token registration, permissions,
/// background handling), see [PushNotificationService].
class NotificationService {
  NotificationService();

  final _notificationController =
      StreamController<NotificationPayload>.broadcast();
  Stream<NotificationPayload> get notificationStream =>
      _notificationController.stream;

  int _badgeCount = 0;
  int get badgeCount => _badgeCount;

  /// Handle a foreground notification (e.g. from PushNotificationService callback).
  void handleForegroundNotification(NotificationPayload payload) {
    _badgeCount++;
    _notificationController.add(payload);
  }

  /// Handle a notification tap (navigate to relevant screen).
  void handleNotificationTap(NotificationPayload payload) {
    _notificationController.add(payload);
  }

  /// Update badge count.
  void updateBadgeCount(int count) {
    _badgeCount = count;
    debugPrint('[NotificationService] Badge count: $count');
  }

  /// Clear all in-app notifications and reset badge count.
  void clearAll() {
    _badgeCount = 0;
    debugPrint('[NotificationService] Notifications cleared');
  }

  /// Dispose of resources.
  void dispose() {
    _notificationController.close();
  }
}

/// Notification payload model.
class NotificationPayload {
  const NotificationPayload({
    required this.title,
    required this.body,
    required this.type,
    this.data = const {},
  });

  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
}

/// Types of notifications.
enum NotificationType {
  message,
  taskAssigned,
  taskCompleted,
  activityAdded,
  reminderDue,
  pollCreated,
  locationShared,
  financeEntry,
  charterUpdated,
  spaceInvite,
  general,
}
