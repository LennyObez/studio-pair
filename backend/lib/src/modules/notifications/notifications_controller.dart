import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../config/app_config.dart';
import '../../services/notification_service.dart';
import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'notifications_service.dart';

/// Controller for notification endpoints.
class NotificationsController {
  final NotificationsModuleService _service;
  final NotificationService _notificationService;
  final AppConfig _config;

  NotificationsController(
    this._service,
    this._notificationService,
    this._config,
  );

  /// Returns the router with all notification routes.
  Router get router {
    final router = Router();

    router.get('/', _listNotifications);
    router.patch('/<notificationId>/read', _markRead);
    router.post('/mark-all-read', _markAllRead);
    router.get('/preferences', _getPreferences);
    router.put('/preferences', _updatePreferences);
    router.post('/devices/register', _registerDevice);
    router.post('/devices/unregister', _unregisterDevice);
    router.post('/webhook', _handleWebhook);

    return router;
  }

  /// GET /api/v1/notifications
  ///
  /// Lists notifications for the current user.
  /// Query params: cursor, limit, unread_only
  Future<Response> _listNotifications(Request request) async {
    try {
      final userId = getUserId(request);
      final pagination = getPaginationParams(request);
      final unreadOnly = request.url.queryParameters['unread_only'] == 'true';

      final result = await _service.listNotifications(
        userId: userId,
        cursor: pagination.cursor,
        limit: pagination.limit,
        unreadOnly: unreadOnly,
      );

      return jsonResponse(result);
    } catch (e) {
      return internalErrorResponse('An unexpected error occurred');
    }
  }

  /// PATCH /api/v1/notifications/<notificationId>/read
  ///
  /// Marks a specific notification as read.
  Future<Response> _markRead(Request request, String notificationId) async {
    try {
      final userId = getUserId(request);
      final marked = await _service.markRead(notificationId, userId);

      if (!marked) {
        return notFoundResponse('Notification not found or already read');
      }

      return jsonResponse({'message': 'Notification marked as read'});
    } catch (e) {
      return internalErrorResponse('An unexpected error occurred');
    }
  }

  /// POST /api/v1/notifications/mark-all-read
  ///
  /// Marks all notifications as read.
  Future<Response> _markAllRead(Request request) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);
      final spaceId = body['space_id'] as String?;

      final count = await _service.markAllRead(userId, spaceId: spaceId);

      return jsonResponse({
        'message': 'Notifications marked as read',
        'count': count,
      });
    } catch (e) {
      return internalErrorResponse('An unexpected error occurred');
    }
  }

  /// GET /api/v1/notifications/preferences
  ///
  /// Gets notification preferences for the current user.
  Future<Response> _getPreferences(Request request) async {
    try {
      final userId = getUserId(request);
      final prefs = await _service.getPreferences(userId);
      return jsonResponse(prefs);
    } catch (e) {
      return internalErrorResponse('An unexpected error occurred');
    }
  }

  /// PUT /api/v1/notifications/preferences
  ///
  /// Updates notification preferences.
  Future<Response> _updatePreferences(Request request) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);

      final prefs = await _service.updatePreferences(userId, body);
      return jsonResponse(prefs);
    } catch (e) {
      return internalErrorResponse('An unexpected error occurred');
    }
  }

  /// POST /api/v1/notifications/devices/register
  ///
  /// Registers a device token for push notifications.
  Future<Response> _registerDevice(Request request) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);

      final token = body['token'] as String?;
      final platform = body['platform'] as String?;

      if (token == null || token.isEmpty) {
        return validationErrorResponse('Device token is required');
      }
      if (platform == null || !['ios', 'android', 'web'].contains(platform)) {
        return validationErrorResponse('Platform must be ios, android, or web');
      }

      await _notificationService.registerDeviceToken(
        userId: userId,
        token: token,
        platform: platform,
        deviceName: body['device_name'] as String?,
      );

      return jsonResponse({'message': 'Device registered'});
    } catch (e) {
      return internalErrorResponse('An unexpected error occurred');
    }
  }

  /// POST /api/v1/notifications/devices/unregister
  ///
  /// Unregisters a device token.
  Future<Response> _unregisterDevice(Request request) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);

      final token = body['token'] as String?;
      if (token == null || token.isEmpty) {
        return validationErrorResponse('Device token is required');
      }

      await _notificationService.unregisterDeviceToken(
        userId: userId,
        token: token,
      );

      return jsonResponse({'message': 'Device unregistered'});
    } catch (e) {
      return internalErrorResponse('An unexpected error occurred');
    }
  }

  /// POST /api/v1/notifications/webhook
  ///
  /// Handles push notification delivery callbacks (e.g. from FCM).
  /// Verifies the webhook signature before processing.
  Future<Response> _handleWebhook(Request request) async {
    try {
      final rawBody = await request.readAsString();
      final signature = request.headers['x-webhook-signature'];

      if (!_verifyWebhookSignature(rawBody, signature)) {
        return unauthorizedResponse('Invalid webhook signature');
      }

      final body = jsonDecode(rawBody) as Map<String, dynamic>;
      final event = body['event'] as String?;

      if (event == null) {
        return validationErrorResponse('Missing event field');
      }

      // Process webhook event (delivery receipt, bounce, etc.)
      switch (event) {
        case 'delivery':
        case 'bounce':
        case 'error':
          // Log the event; full processing can be added later
          break;
        default:
          return validationErrorResponse('Unknown webhook event: $event');
      }

      return jsonResponse({'message': 'Webhook processed'});
    } catch (e) {
      return internalErrorResponse('An unexpected error occurred');
    }
  }

  /// Verifies the HMAC-SHA256 webhook signature against the request body.
  /// Uses constant-time comparison to prevent timing attacks.
  bool _verifyWebhookSignature(String body, String? signature) {
    if (signature == null || signature.isEmpty) return false;

    final fcmKey = _config.fcmServerKey;
    if (fcmKey.isEmpty) return false;

    final key = utf8.encode(fcmKey);
    final bytes = utf8.encode(body);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    final expected = 'sha256=$digest';

    // Constant-time comparison to prevent timing attacks
    if (expected.length != signature.length) return false;
    var result = 0;
    for (var i = 0; i < expected.length; i++) {
      result |= expected.codeUnitAt(i) ^ signature.codeUnitAt(i);
    }
    return result == 0;
  }
}
