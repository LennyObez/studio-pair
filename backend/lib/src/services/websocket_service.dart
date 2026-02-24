import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A connected WebSocket client.
class WsClient {
  final String userId;
  final WebSocketChannel channel;
  final DateTime connectedAt;

  WsClient({required this.userId, required this.channel})
    : connectedAt = DateTime.now();
}

/// WebSocket event types for the real-time protocol.
abstract class WsEventType {
  static const messageNew = 'message.new';
  static const messageUpdated = 'message.updated';
  static const messageDeleted = 'message.deleted';
  static const typingStart = 'typing.start';
  static const typingStop = 'typing.stop';
  static const readReceipt = 'read.receipt';
  static const presenceUpdate = 'presence.update';
  static const error = 'error';
  static const pong = 'pong';
}

/// Service for managing WebSocket connections and broadcasting events.
class WebSocketService {
  final Logger _log = Logger('WebSocketService');

  /// Connected clients indexed by userId.
  /// A user can have multiple connections (multiple devices).
  final Map<String, List<WsClient>> _clients = {};

  /// Space memberships cache: spaceId -> set of userIds.
  final Map<String, Set<String>> _spaceMembers = {};

  /// Register a new WebSocket client connection.
  void addClient(String userId, WebSocketChannel channel) {
    final client = WsClient(userId: userId, channel: channel);
    _clients.putIfAbsent(userId, () => []).add(client);

    _log.info(
      'WebSocket client connected: $userId '
      '(${_clients[userId]!.length} connections)',
    );

    // Listen for incoming messages
    channel.stream.listen(
      (data) => _handleMessage(userId, data),
      onDone: () => _removeClient(userId, channel),
      onError: (e) {
        _log.warning('WebSocket error for $userId: $e');
        _removeClient(userId, channel);
      },
    );

    // Send initial presence
    _broadcastPresence(userId, 'online');
  }

  /// Remove a client connection.
  void _removeClient(String userId, WebSocketChannel channel) {
    final clients = _clients[userId];
    if (clients != null) {
      clients.removeWhere((c) => c.channel == channel);
      if (clients.isEmpty) {
        _clients.remove(userId);
        _broadcastPresence(userId, 'offline');
      }
    }
    _log.info('WebSocket client disconnected: $userId');
  }

  /// Handle an incoming WebSocket message from a client.
  void _handleMessage(String userId, dynamic data) {
    try {
      final message = jsonDecode(data as String) as Map<String, dynamic>;
      final type = message['type'] as String?;

      switch (type) {
        case 'ping':
          sendToUser(userId, {'type': WsEventType.pong});
          break;
        case 'typing.start':
        case 'typing.stop':
          final conversationId = message['conversation_id'] as String?;
          final spaceId = message['space_id'] as String?;
          if (conversationId != null && spaceId != null) {
            broadcastToSpace(spaceId, {
              'type': type,
              'user_id': userId,
              'conversation_id': conversationId,
            }, excludeUserId: userId);
          }
          break;
        case 'read.receipt':
          final conversationId = message['conversation_id'] as String?;
          final messageId = message['message_id'] as String?;
          final spaceId = message['space_id'] as String?;
          if (conversationId != null && messageId != null && spaceId != null) {
            broadcastToSpace(spaceId, {
              'type': WsEventType.readReceipt,
              'user_id': userId,
              'conversation_id': conversationId,
              'message_id': messageId,
            }, excludeUserId: userId);
          }
          break;
        default:
          _log.fine('Unknown WebSocket message type: $type from $userId');
      }
    } catch (e) {
      _log.warning('Failed to parse WebSocket message from $userId: $e');
      sendToUser(userId, {
        'type': WsEventType.error,
        'message': 'Invalid message format',
      });
    }
  }

  /// Update the space membership cache.
  void updateSpaceMembers(String spaceId, Set<String> memberIds) {
    _spaceMembers[spaceId] = memberIds;
  }

  /// Send a message to all connections of a specific user.
  void sendToUser(String userId, Map<String, dynamic> event) {
    final clients = _clients[userId];
    if (clients == null || clients.isEmpty) return;

    final encoded = jsonEncode(event);
    for (final client in clients) {
      try {
        client.channel.sink.add(encoded);
      } catch (e) {
        _log.warning('Failed to send to $userId: $e');
      }
    }
  }

  /// Broadcast an event to all connected members of a space.
  void broadcastToSpace(
    String spaceId,
    Map<String, dynamic> event, {
    String? excludeUserId,
  }) {
    final members = _spaceMembers[spaceId];
    if (members == null) return;

    for (final memberId in members) {
      if (memberId == excludeUserId) continue;
      sendToUser(memberId, event);
    }
  }

  /// Broadcast a presence update for a user to all their spaces.
  void _broadcastPresence(String userId, String status) {
    for (final entry in _spaceMembers.entries) {
      if (entry.value.contains(userId)) {
        broadcastToSpace(entry.key, {
          'type': WsEventType.presenceUpdate,
          'user_id': userId,
          'status': status,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        }, excludeUserId: userId);
      }
    }
  }

  /// Check if a user is currently connected.
  bool isOnline(String userId) => _clients.containsKey(userId);

  /// Get the number of connected users.
  int get connectedUserCount => _clients.length;

  /// Dispose all connections.
  void dispose() {
    for (final clients in _clients.values) {
      for (final client in clients) {
        try {
          client.channel.sink.close();
        } catch (_) {}
      }
    }
    _clients.clear();
    _spaceMembers.clear();
  }
}
