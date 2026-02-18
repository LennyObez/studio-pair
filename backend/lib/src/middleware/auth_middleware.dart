import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

import '../utils/jwt_utils.dart';
import '../utils/request_utils.dart';
import '../utils/response_utils.dart';

/// Paths that do not require authentication.
const List<String> _publicPaths = [
  '/api/v1/auth/register',
  '/api/v1/auth/login',
  '/api/v1/auth/refresh',
  '/api/v1/auth/forgot-password',
  '/api/v1/auth/reset-password',
  '/api/v1/health',
  '/api/v1/health/ready',
];

/// Path prefixes that do not require authentication.
const List<String> _publicPrefixes = ['/api/v1/auth/oauth/'];

/// Creates authentication middleware that validates JWT tokens.
///
/// Public paths (login, register, etc.) are allowed through without a token.
/// All other paths require a valid Bearer token in the Authorization header.
Middleware createAuthMiddleware(JwtUtils jwtUtils) {
  final log = Logger('AuthMiddleware');

  return (Handler innerHandler) {
    return (Request request) async {
      final path = '/${request.url.path}';

      // Allow preflight CORS requests through
      if (request.method == 'OPTIONS') {
        return innerHandler(request);
      }

      // Check if path is public
      if (_isPublicPath(path)) {
        return innerHandler(request);
      }

      // Extract Bearer token
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        log.fine('Missing or invalid Authorization header for $path');
        return unauthorizedResponse('Missing or invalid authorization token');
      }

      final token = authHeader.substring(7); // Remove 'Bearer ' prefix

      // Verify token
      final claims = jwtUtils.verifyToken(token);
      if (claims == null) {
        log.fine('Invalid token for $path');
        return unauthorizedResponse('Invalid or expired token');
      }

      // Check token type - only access and sensitive tokens allowed for API calls
      final tokenType = claims['type'] as String?;
      if (tokenType != 'access' && tokenType != 'sensitive') {
        log.fine('Wrong token type ($tokenType) used for $path');
        return unauthorizedResponse('Invalid token type');
      }

      final userId = claims.subject;
      if (userId == null) {
        log.fine('Token missing subject for $path');
        return unauthorizedResponse('Invalid token: missing user identity');
      }

      final email = claims['email'] as String?;

      // Attach user context to request
      final updatedRequest = addContext(request, {
        authUserIdKey: userId,
        if (email != null) authUserEmailKey: email,
      });

      return innerHandler(updatedRequest);
    };
  };
}

/// Checks whether a given path is a public path that doesn't need auth.
bool _isPublicPath(String path) {
  // Exact match
  if (_publicPaths.contains(path)) return true;

  // Prefix match
  for (final prefix in _publicPrefixes) {
    if (path.startsWith(prefix)) return true;
  }

  return false;
}
