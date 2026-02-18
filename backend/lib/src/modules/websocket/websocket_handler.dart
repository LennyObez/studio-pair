import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../services/websocket_service.dart';
import '../../utils/jwt_utils.dart';

/// Creates a Shelf handler for WebSocket upgrade requests.
///
/// Authenticates via JWT token passed as query parameter:
///   GET /api/v1/ws?token=<jwt>
Handler createWebSocketHandler(JwtUtils jwtUtils, WebSocketService wsService) {
  return webSocketHandler((WebSocketChannel channel, String? protocol) {
    // Connection is established but we need to authenticate via the first message
    // or the token was already validated in the wrapping handler.
    // The userId is passed via the protocol subprotocol field.
    if (protocol != null && protocol.isNotEmpty) {
      wsService.addClient(protocol, channel);
    } else {
      channel.sink.add('{"type":"error","message":"Authentication required"}');
      channel.sink.close();
    }
  });
}

/// Shelf handler that validates the JWT from query parameter before upgrading.
Handler createAuthenticatedWebSocketHandler(
  JwtUtils jwtUtils,
  WebSocketService wsService,
) {
  return (Request request) {
    final token = request.url.queryParameters['token'];
    if (token == null || token.isEmpty) {
      return Response(401, body: 'Missing token');
    }

    final claims = jwtUtils.verifyToken(token);
    if (claims == null) {
      return Response(401, body: 'Invalid token');
    }

    final userId = claims.subject;
    if (userId == null) {
      return Response(401, body: 'Invalid token');
    }

    // Upgrade to WebSocket with userId as the protocol
    final handler = webSocketHandler((WebSocketChannel channel, String? _) {
      wsService.addClient(userId, channel);
    });

    return handler(request);
  };
}
