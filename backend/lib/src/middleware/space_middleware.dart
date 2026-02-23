import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../config/database.dart';
import '../utils/request_utils.dart';
import '../utils/response_utils.dart';

/// Middleware that authorizes a user's access to a space.
///
/// This middleware:
/// 1. Extracts `spaceId` from route parameters
/// 2. Verifies the user is an active member of the space
/// 3. Attaches the membership context (role, access level) to the request
/// 4. Returns 403 if the user is not a member
class SpaceMiddleware {
  final Database _db;
  final Logger _log = Logger('SpaceMiddleware');

  SpaceMiddleware(this._db);

  /// Creates a middleware handler that checks space membership.
  Middleware get middleware {
    return (Handler innerHandler) {
      return (Request request) async {
        // Extract spaceId from route params
        final spaceId = request.params['spaceId'];
        if (spaceId == null || spaceId.isEmpty) {
          // No space ID in route, pass through (not a space-scoped route)
          return innerHandler(request);
        }

        // Get user ID from auth context
        final userId = request.context[authUserIdKey] as String?;
        if (userId == null) {
          return unauthorizedResponse('Authentication required');
        }

        try {
          // Check if user is an active member of the space
          final row = await _db.queryOne(
            '''
            SELECT sm.role, sm.access_level, sm.status, s.deleted_at
            FROM space_memberships sm
            JOIN spaces s ON s.id = sm.space_id
            WHERE sm.space_id = @spaceId
              AND sm.user_id = @userId
            ''',
            parameters: {'spaceId': spaceId, 'userId': userId},
          );

          if (row == null) {
            _log.fine('User $userId is not a member of space $spaceId');
            return forbiddenResponse('You are not a member of this space');
          }

          final status = row[2] as String;
          if (status != 'active') {
            _log.fine('User $userId membership in space $spaceId is $status');
            return forbiddenResponse(
              'Your membership in this space is not active',
            );
          }

          // Check if space is deleted
          final deletedAt = row[3];
          if (deletedAt != null) {
            return notFoundResponse('This space has been deleted');
          }

          final role = row[0] as String;
          final accessLevel = row[1] as String;

          // Attach space membership context to request
          final membership = SpaceMembershipContext(
            spaceId: spaceId,
            userId: userId,
            role: role,
            accessLevel: accessLevel,
          );

          final updatedRequest = addContext(request, {
            spaceIdKey: spaceId,
            spaceMembershipKey: membership,
          });

          return innerHandler(updatedRequest);
        } catch (e, stackTrace) {
          _log.severe('Error checking space membership', e, stackTrace);
          return internalErrorResponse();
        }
      };
    };
  }
}
