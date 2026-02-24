import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Represents a WebSocket event received from the server.
class WebSocketEvent {
  final String type;
  final Map<String, dynamic> data;

  const WebSocketEvent({required this.type, required this.data});

  factory WebSocketEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketEvent(
      type: json['type'] as String? ?? 'unknown',
      data: json,
    );
  }
}

/// App-side WebSocket client with auto-reconnect and exponential backoff.
class AppWebSocketService {
  final String baseUrl;
  final Future<String?> Function() getToken;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  final _eventController = StreamController<WebSocketEvent>.broadcast();
  Stream<WebSocketEvent> get events => _eventController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _disposed = false;
  int _reconnectAttempts = 0;
  static const _maxReconnectDelay = Duration(seconds: 60);

  AppWebSocketService({required this.baseUrl, required this.getToken});

  /// Connect to the WebSocket server.
  Future<void> connect() async {
    if (_disposed || _isConnected) return;

    final token = await getToken();
    if (token == null) return;

    try {
      final wsUrl = baseUrl
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');
      final uri = Uri.parse('$wsUrl/api/v1/ws');

      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;

      // Authenticate via first message instead of query parameter
      // to avoid token exposure in server logs / proxy logs
      _channel!.sink.add(jsonEncode({'type': 'auth', 'token': token}));

      _isConnected = true;
      _reconnectAttempts = 0;

      _subscription = _channel!.stream.listen(
        _onData,
        onDone: _onDisconnected,
        onError: (e) => _onDisconnected(),
      );

      // Start ping/pong heartbeat every 30s
      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        send({'type': 'ping'});
      });
    } catch (e) {
      _scheduleReconnect();
    }
  }

  /// Handle incoming WebSocket data.
  void _onData(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final event = WebSocketEvent.fromJson(json);
      _eventController.add(event);
    } catch (_) {}
  }

  /// Handle disconnection.
  void _onDisconnected() {
    _isConnected = false;
    _subscription?.cancel();
    _subscription = null;
    _pingTimer?.cancel();
    _channel = null;

    if (!_disposed) {
      _scheduleReconnect();
    }
  }

  /// Schedule a reconnect with exponential backoff.
  void _scheduleReconnect() {
    if (_disposed) return;

    final delay = Duration(
      milliseconds: min(
        (pow(2, _reconnectAttempts) * 1000).toInt(),
        _maxReconnectDelay.inMilliseconds,
      ),
    );
    _reconnectAttempts++;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, connect);
  }

  /// Send a JSON message to the server.
  void send(Map<String, dynamic> data) {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode(data));
      } catch (_) {}
    }
  }

  /// Send a typing start event.
  void sendTypingStart(String spaceId, String conversationId) {
    send({
      'type': 'typing.start',
      'space_id': spaceId,
      'conversation_id': conversationId,
    });
  }

  /// Send a typing stop event.
  void sendTypingStop(String spaceId, String conversationId) {
    send({
      'type': 'typing.stop',
      'space_id': spaceId,
      'conversation_id': conversationId,
    });
  }

  /// Send a read receipt.
  void sendReadReceipt(
    String spaceId,
    String conversationId,
    String messageId,
  ) {
    send({
      'type': 'read.receipt',
      'space_id': spaceId,
      'conversation_id': conversationId,
      'message_id': messageId,
    });
  }

  /// Disconnect and clean up.
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _eventController.close();
  }
}
