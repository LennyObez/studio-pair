import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:uuid/uuid.dart';

import '../config/app_config.dart';
import '../config/database.dart';

/// Notification delivery channel.
enum NotificationChannel { inApp, push, email }

/// Service for creating and delivering notifications.
class NotificationService {
  final Database _db;
  final AppConfig _config;
  final Logger _log = Logger('NotificationService');
  final Uuid _uuid = const Uuid();

  late final SmtpServer _smtpServer;

  NotificationService(this._db, this._config) {
    _smtpServer = SmtpServer(
      _config.smtpHost,
      port: _config.smtpPort,
      username: _config.smtpUsername.isNotEmpty ? _config.smtpUsername : null,
      password: _config.smtpPassword.isNotEmpty ? _config.smtpPassword : null,
      ssl: _config.smtpPort == 465,
      allowInsecure: _config.isDevelopment,
    );
  }

  /// Creates an in-app notification stored in the database.
  Future<Map<String, dynamic>> createInAppNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    String? spaceId,
    Map<String, dynamic>? data,
  }) async {
    final id = _uuid.v4();
    try {
      final result = await _db.query(
        '''
        INSERT INTO notifications (id, user_id, type, title, body, space_id, data, created_at)
        VALUES (@id, @userId, @type, @title, @body, @spaceId, @data, NOW())
        RETURNING id, user_id, type, title, body, space_id, data, read_at, created_at
        ''',
        parameters: {
          'id': id,
          'userId': userId,
          'type': type,
          'title': title,
          'body': body,
          'spaceId': spaceId,
          'data': data != null ? jsonEncode(data) : null,
        },
      );

      _log.info('Created in-app notification for user $userId: $title');
      return result.first.toColumnMap();
    } catch (e) {
      _log.severe('Failed to create notification for $userId', e);
      return {
        'id': id,
        'user_id': userId,
        'type': type,
        'title': title,
        'body': body,
        'space_id': spaceId,
        'data': data,
        'read_at': null,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };
    }
  }

  /// Sends a push notification via FCM HTTP v1 API.
  ///
  /// Requires device tokens to be registered. Falls back to logging
  /// if FCM is not configured.
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (_config.fcmServerKey.isEmpty) {
      _log.fine('Push notification skipped (FCM not configured): $title');
      return;
    }

    try {
      // Fetch device tokens for the user
      final tokens = await _db.query(
        '''
        SELECT token, platform
        FROM device_tokens
        WHERE user_id = @userId
        ''',
        parameters: {'userId': userId},
      );

      for (final row in tokens) {
        final tokenData = row.toColumnMap();
        final deviceToken = tokenData['token'] as String;
        await _sendFcmMessage(
          token: deviceToken,
          title: title,
          body: body,
          data: data,
        );
      }
    } catch (e) {
      _log.warning('Push notification failed for user $userId', e);
    }
  }

  /// Sends an email notification.
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String htmlBody,
    String? textBody,
  }) async {
    try {
      final message = Message()
        ..from = Address(_config.smtpFromEmail, _config.smtpFromName)
        ..recipients.add(to)
        ..subject = subject
        ..html = htmlBody
        ..text = textBody;

      await send(message, _smtpServer);
      _log.info('Email sent to $to: $subject');
      return true;
    } catch (e) {
      _log.severe('Failed to send email to $to', e);
      return false;
    }
  }

  /// Sends a notification through all configured channels for the user.
  Future<void> notify({
    required String userId,
    required String type,
    required String title,
    required String body,
    String? spaceId,
    Map<String, dynamic>? data,
    Set<NotificationChannel> channels = const {
      NotificationChannel.inApp,
      NotificationChannel.push,
    },
  }) async {
    if (channels.contains(NotificationChannel.inApp)) {
      await createInAppNotification(
        userId: userId,
        type: type,
        title: title,
        body: body,
        spaceId: spaceId,
        data: data,
      );
    }

    if (channels.contains(NotificationChannel.push)) {
      await sendPushNotification(
        userId: userId,
        title: title,
        body: body,
        data: data,
      );
    }
  }

  /// Marks a notification as read.
  Future<void> markRead(String notificationId, String userId) async {
    await _db.execute(
      '''
      UPDATE notifications
      SET read_at = NOW()
      WHERE id = @id AND user_id = @userId AND read_at IS NULL
      ''',
      parameters: {'id': notificationId, 'userId': userId},
    );
    _log.fine('Marked notification $notificationId as read for $userId');
  }

  /// Marks all notifications as read for a user.
  Future<void> markAllRead(String userId, {String? spaceId}) async {
    final params = <String, dynamic>{'userId': userId};
    var sql = '''
      UPDATE notifications
      SET read_at = NOW()
      WHERE user_id = @userId AND read_at IS NULL
    ''';
    if (spaceId != null) {
      sql += ' AND space_id = @spaceId';
      params['spaceId'] = spaceId;
    }
    await _db.execute(sql, parameters: params);
    _log.fine('Marked all notifications as read for user $userId');
  }

  /// Gets notification preferences for a user.
  Future<Map<String, dynamic>> getPreferences(String userId) async {
    final row = await _db.queryOne(
      '''
      SELECT user_id, push_enabled, email_enabled,
             quiet_hours_enabled, quiet_hours_start, quiet_hours_end,
             channel_preferences, updated_at
      FROM notification_preferences
      WHERE user_id = @userId
      ''',
      parameters: {'userId': userId},
    );

    if (row != null) {
      return row.toColumnMap();
    }

    // Return defaults
    return {
      'push_enabled': true,
      'email_enabled': true,
      'quiet_hours_enabled': false,
      'quiet_hours_start': '22:00',
      'quiet_hours_end': '08:00',
      'channel_preferences': null,
    };
  }

  /// Sends a push notification via FCM legacy HTTP API.
  ///
  /// Uses the legacy endpoint with server key authentication.
  /// For production, consider migrating to FCM HTTP v1 API with OAuth2.
  Future<void> _sendFcmMessage({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final payload = {
        'to': token,
        'notification': {'title': title, 'body': body},
        if (data != null) 'data': data.map((k, v) => MapEntry(k, v.toString())),
      };

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Authorization': 'key=${_config.fcmServerKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        _log.fine('FCM message sent to $token');
      } else {
        _log.warning(
          'FCM send failed (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      _log.warning('FCM send error for token $token', e);
    }
  }

  /// Registers a device token for push notifications.
  Future<void> registerDeviceToken({
    required String userId,
    required String token,
    required String platform,
    String? deviceName,
  }) async {
    await _db.execute(
      '''
      INSERT INTO device_tokens (user_id, token, platform, device_name, created_at, updated_at)
      VALUES (@userId, @token, @platform, @deviceName, NOW(), NOW())
      ON CONFLICT (user_id, token) DO UPDATE SET
        platform = @platform,
        device_name = @deviceName,
        updated_at = NOW()
      ''',
      parameters: {
        'userId': userId,
        'token': token,
        'platform': platform,
        'deviceName': deviceName,
      },
    );
    _log.info('Device token registered for user $userId ($platform)');
  }

  /// Unregisters a device token.
  Future<void> unregisterDeviceToken({
    required String userId,
    required String token,
  }) async {
    await _db.execute(
      '''
      DELETE FROM device_tokens
      WHERE user_id = @userId AND token = @token
      ''',
      parameters: {'userId': userId, 'token': token},
    );
    _log.info('Device token unregistered for user $userId');
  }

  /// Updates notification preferences for a user.
  Future<Map<String, dynamic>> updatePreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    final result = await _db.query(
      '''
      INSERT INTO notification_preferences
        (user_id, push_enabled, email_enabled, quiet_hours_enabled,
         quiet_hours_start, quiet_hours_end, channel_preferences, updated_at)
      VALUES
        (@userId, @pushEnabled, @emailEnabled, @quietHoursEnabled,
         @quietHoursStart, @quietHoursEnd, @channelPreferences, NOW())
      ON CONFLICT (user_id) DO UPDATE SET
        push_enabled = @pushEnabled,
        email_enabled = @emailEnabled,
        quiet_hours_enabled = @quietHoursEnabled,
        quiet_hours_start = @quietHoursStart,
        quiet_hours_end = @quietHoursEnd,
        channel_preferences = @channelPreferences,
        updated_at = NOW()
      RETURNING user_id, push_enabled, email_enabled,
                quiet_hours_enabled, quiet_hours_start, quiet_hours_end,
                channel_preferences, updated_at
      ''',
      parameters: {
        'userId': userId,
        'pushEnabled': preferences['push_enabled'] ?? true,
        'emailEnabled': preferences['email_enabled'] ?? true,
        'quietHoursEnabled': preferences['quiet_hours_enabled'] ?? false,
        'quietHoursStart': preferences['quiet_hours_start'] ?? '22:00',
        'quietHoursEnd': preferences['quiet_hours_end'] ?? '08:00',
        'channelPreferences': preferences['channel_preferences'],
      },
    );

    _log.info('Updated notification preferences for user $userId');
    return result.first.toColumnMap();
  }
}
