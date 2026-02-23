import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Background message handler -- must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background isolate.
  await Firebase.initializeApp();
  debugPrint('[Push] Background message: ${message.messageId}');
}

/// Service managing push notification lifecycle:
/// - Firebase Messaging initialisation
/// - Permission requests (iOS / Android 13+)
/// - Token registration with the backend
/// - Foreground, background, and tap handling
class PushNotificationService {
  final Logger _log = Logger('PushNotificationService');

  late final FirebaseMessaging _messaging;
  final Dio _dio;
  final String _baseUrl;
  final Future<String?> Function() _getAuthToken;

  /// Callback invoked when a notification is tapped and the app opens.
  void Function(Map<String, dynamic> data)? onNotificationTap;

  /// Callback invoked when a foreground notification arrives.
  void Function(RemoteMessage message)? onForegroundMessage;

  PushNotificationService({
    required Dio dio,
    required String baseUrl,
    required Future<String?> Function() getAuthToken,
  }) : _dio = dio,
       _baseUrl = baseUrl,
       _getAuthToken = getAuthToken;

  /// Initializes Firebase Messaging and registers handlers.
  Future<void> initialize() async {
    _messaging = FirebaseMessaging.instance;

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Request permissions (iOS shows dialog, Android 13+ shows dialog)
    final settings = await _messaging.requestPermission();

    _log.info('Push permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      _log.warning('Push notifications denied by user');
      return;
    }

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen for notification taps when the app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if the app was opened from a terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Register the device token
    await _registerToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((_) => _registerToken());
  }

  /// Handles a foreground push notification.
  void _handleForegroundMessage(RemoteMessage message) {
    _log.info('Foreground message: ${message.notification?.title}');
    onForegroundMessage?.call(message);
  }

  /// Handles a notification tap (app opened from background/terminated).
  void _handleNotificationTap(RemoteMessage message) {
    _log.info('Notification tap: ${message.data}');
    onNotificationTap?.call(message.data);
  }

  /// Registers the current FCM token with the backend.
  Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) {
        _log.warning('FCM token is null');
        return;
      }

      final authToken = await _getAuthToken();
      if (authToken == null) {
        _log.warning('No auth token available, skipping device registration');
        return;
      }

      final platform = defaultTargetPlatform == TargetPlatform.iOS
          ? 'ios'
          : 'android';

      await _dio.post(
        '$_baseUrl/api/v1/notifications/devices/register',
        data: jsonEncode({'token': token, 'platform': platform}),
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      _log.info('Device token registered ($platform)');
    } catch (e) {
      _log.warning('Failed to register device token', e);
    }
  }

  /// Unregisters the current FCM token from the backend (e.g. on logout).
  Future<void> unregister() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      final authToken = await _getAuthToken();
      if (authToken == null) return;

      await _dio.post(
        '$_baseUrl/api/v1/notifications/devices/unregister',
        data: jsonEncode({'token': token}),
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      _log.info('Device token unregistered');
    } catch (e) {
      _log.warning('Failed to unregister device token', e);
    }
  }
}
