import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/config/api_config.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/websocket/websocket_service.dart';

/// Provider for the WebSocket service.
final webSocketServiceProvider = Provider<AppWebSocketService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);

  final service = AppWebSocketService(
    baseUrl: ApiConfig.effectiveWsUrl,
    getToken: secureStorage.getAccessToken,
  );

  ref.onDispose(service.dispose);

  return service;
});

/// Provider that exposes a stream of WebSocket events.
final webSocketEventsProvider = StreamProvider<WebSocketEvent>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.events;
});

/// Provider for managing WebSocket connection lifecycle.
final webSocketConnectionProvider = Provider<void>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  wsService.connect();
});
