import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Notifications API service for managing user notifications.
class NotificationsApi {
  NotificationsApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// List notifications with optional pagination.
  Future<Response> listNotifications({String? cursor, int? limit}) {
    return _client.get(
      '/notifications/',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
  }

  /// Mark a specific notification as read.
  Future<Response> markAsRead(String notificationId) {
    return _client.post('/notifications/$notificationId/read');
  }

  /// Mark all notifications as read.
  Future<Response> markAllAsRead() {
    return _client.post('/notifications/read-all');
  }

  /// Get the count of unread notifications.
  Future<Response> getUnreadCount() {
    return _client.get('/notifications/unread-count');
  }
}
