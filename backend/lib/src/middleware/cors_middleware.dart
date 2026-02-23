import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

/// Creates CORS middleware with proper configuration for the Studio Pair API.
///
/// When [allowedOrigins] is provided, only those origins are accepted.
/// Otherwise, the request's Origin header is echoed back (standard CORS
/// practice for development when credentials are allowed).
Middleware corsMiddleware({List<String>? allowedOrigins}) {
  return (Handler innerHandler) {
    return (Request request) async {
      final requestOrigin = request.headers['origin'];

      String origin;
      if (allowedOrigins != null && allowedOrigins.isNotEmpty) {
        // Only allow configured origins
        if (requestOrigin != null && allowedOrigins.contains(requestOrigin)) {
          origin = requestOrigin;
        } else {
          origin = allowedOrigins.first;
        }
      } else {
        // Development mode: echo the request Origin header back
        origin = requestOrigin ?? '';
      }

      final overrideHeaders = {
        ACCESS_CONTROL_ALLOW_ORIGIN: origin,
        ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
        ACCESS_CONTROL_ALLOW_HEADERS:
            'Origin, Content-Type, Accept, Authorization, X-Requested-With, '
            'X-Space-Id',
        ACCESS_CONTROL_MAX_AGE: '86400', // 24 hours
        ACCESS_CONTROL_ALLOW_CREDENTIALS: 'true',
        ACCESS_CONTROL_EXPOSE_HEADERS:
            'X-Total-Count, X-Page-Count, X-Request-Id',
      };

      final corsHandler = corsHeaders(headers: overrideHeaders);
      final handler = corsHandler(innerHandler);
      return handler(request);
    };
  };
}
