import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Key used to store the authenticated user ID in the request context.
const String authUserIdKey = 'auth.userId';

/// Key used to store the authenticated user email in the request context.
const String authUserEmailKey = 'auth.userEmail';

/// Key used to store the space ID in the request context.
const String spaceIdKey = 'space.id';

/// Key used to store the space membership in the request context.
const String spaceMembershipKey = 'space.membership';

/// Reads and parses the JSON body from a request.
Future<Map<String, dynamic>> readJsonBody(Request request) async {
  final body = await request.readAsString();
  if (body.isEmpty) {
    return {};
  }
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('Request body must be a JSON object');
  } on FormatException {
    rethrow;
  }
}

/// Gets the authenticated user ID from the request context.
///
/// Throws [StateError] if no user ID is present (auth middleware should
/// have caught this).
String getUserId(Request request) {
  final userId = request.context[authUserIdKey];
  if (userId == null || userId is! String) {
    throw StateError('No authenticated user ID in request context');
  }
  return userId;
}

/// Gets the authenticated user email from the request context.
String? getUserEmail(Request request) {
  return request.context[authUserEmailKey] as String?;
}

/// Gets the space ID from the route parameters.
String getSpaceId(Request request) {
  final spaceId = request.params['spaceId'];
  if (spaceId == null || spaceId.isEmpty) {
    throw StateError('No space ID in route parameters');
  }
  return spaceId;
}

/// Gets the space membership from the request context.
///
/// This is populated by the space middleware.
SpaceMembershipContext? getMembership(Request request) {
  return request.context[spaceMembershipKey] as SpaceMembershipContext?;
}

/// Extracts cursor-based pagination parameters from query string.
///
/// Returns a record of (cursor, limit).
/// - `cursor`: opaque pagination cursor, null for first page
/// - `limit`: number of items per page, clamped to 1–100, default 25
({String? cursor, int limit}) getPaginationParams(Request request) {
  final cursor = request.url.queryParameters['cursor'];
  final limitStr = request.url.queryParameters['limit'];

  var limit = 25;
  if (limitStr != null) {
    limit = int.tryParse(limitStr) ?? 25;
    limit = limit.clamp(1, 100);
  }

  return (cursor: cursor?.isNotEmpty == true ? cursor : null, limit: limit);
}

/// Helper to add context values to a request (creates a new request with
/// merged context).
Request addContext(Request request, Map<String, Object> values) {
  return request.change(context: {...request.context, ...values});
}

/// Data class for space membership context attached to requests.
class SpaceMembershipContext {
  final String spaceId;
  final String userId;
  final String role;
  final String accessLevel;

  const SpaceMembershipContext({
    required this.spaceId,
    required this.userId,
    required this.role,
    required this.accessLevel,
  });

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin' || role == 'owner';
  bool get canWrite => accessLevel == 'read_write';
}
