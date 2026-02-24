import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'spaces_service.dart';

/// Controller for space management endpoints.
class SpacesController {
  final SpacesService _service;
  final Logger _log = Logger('SpacesController');

  SpacesController(this._service);

  /// Returns the router with all spaces routes.
  Router get router {
    final router = Router();

    // Space CRUD
    router.post('/', _createSpace);
    router.get('/', _listMySpaces);
    router.get('/<spaceId>', _getSpace);
    router.patch('/<spaceId>', _updateSpace);
    router.delete('/<spaceId>', _deleteSpace);

    // Invites & Joining
    router.post('/<spaceId>/invite', _createInvite);
    router.post('/join', _joinByCode);

    // Members
    router.get('/<spaceId>/members', _listMembers);
    router.patch('/<spaceId>/members/<userId>', _updateMemberRole);
    router.delete('/<spaceId>/members/<userId>', _removeMember);

    // Leave & Transfer
    router.post('/<spaceId>/leave', _leaveSpace);
    router.post('/<spaceId>/transfer-ownership', _transferOwnership);

    return router;
  }

  /// POST /api/v1/spaces
  ///
  /// Creates a new space.
  /// Body: { "name": "...", "type": "couple", "description": "..." }
  Future<Response> _createSpace(Request request) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);

      final name = body['name'] as String?;
      final type = body['type'] as String?;

      if (name == null || type == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (name == null) {'field': 'name', 'message': 'Name is required'},
            if (type == null) {'field': 'type', 'message': 'Type is required'},
          ],
        );
      }

      final result = await _service.createSpace(
        userId: userId,
        name: name,
        type: type,
        description: body['description'] as String?,
        iconUrl: body['icon_url'] as String?,
      );

      return createdResponse(result);
    } on SpaceException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create space error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces
  ///
  /// Lists all spaces the current user is a member of.
  Future<Response> _listMySpaces(Request request) async {
    try {
      final userId = getUserId(request);
      final spaces = await _service.listMySpaces(userId);

      return jsonResponse({'data': spaces});
    } catch (e, stackTrace) {
      _log.severe('List spaces error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>
  ///
  /// Gets details of a specific space.
  Future<Response> _getSpace(Request request, String spaceId) async {
    try {
      final userId = getUserId(request);
      final space = await _service.getSpace(spaceId, userId);

      return jsonResponse(space);
    } on SpaceException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get space error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /api/v1/spaces/<spaceId>
  ///
  /// Updates a space's details.
  /// Body: { "name": "...", "description": "...", "icon_url": "...", "type": "..." }
  Future<Response> _updateSpace(Request request, String spaceId) async {
    try {
      final userId = getUserId(request);
      final membership = getMembership(request);
      final body = await readJsonBody(request);

      final result = await _service.updateSpace(
        spaceId: spaceId,
        userId: userId,
        userRole: membership?.role ?? 'member',
        name: body['name'] as String?,
        description: body['description'] as String?,
        iconUrl: body['icon_url'] as String?,
        type: body['type'] as String?,
      );

      return jsonResponse(result);
    } on SpaceException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update space error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /api/v1/spaces/<spaceId>
  ///
  /// Deletes a space (owner only, schedules for permanent deletion).
  Future<Response> _deleteSpace(Request request, String spaceId) async {
    try {
      final userId = getUserId(request);
      final membership = getMembership(request);

      await _service.deleteSpace(
        spaceId: spaceId,
        userId: userId,
        userRole: membership?.role ?? 'member',
      );

      return jsonResponse({
        'message': 'Space has been scheduled for deletion.',
      });
    } on SpaceException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete space error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/invite
  ///
  /// Creates an invite code for the space.
  /// Body: { "max_uses": 1, "expires_in_hours": 168 }
  Future<Response> _createInvite(Request request, String spaceId) async {
    try {
      final userId = getUserId(request);
      final membership = getMembership(request);
      final body = await readJsonBody(request);

      final maxUses = body['max_uses'] as int?;
      final expiresInHours = body['expires_in_hours'] as int?;

      final invite = await _service.createInvite(
        spaceId: spaceId,
        userId: userId,
        userRole: membership?.role ?? 'member',
        maxUses: maxUses,
        expiresIn: expiresInHours != null
            ? Duration(hours: expiresInHours)
            : null,
      );

      return createdResponse(invite);
    } on SpaceException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create invite error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/join
  ///
  /// Joins a space using an invite code.
  /// Body: { "code": "ABCD1234" }
  Future<Response> _joinByCode(Request request) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);

      final code = body['code'] as String?;
      if (code == null || code.isEmpty) {
        return validationErrorResponse('Invite code is required');
      }

      final result = await _service.joinByCode(userId: userId, code: code);

      return createdResponse(result);
    } on SpaceException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Join by code error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/members
  ///
  /// Lists all active members of a space.
  Future<Response> _listMembers(Request request, String spaceId) async {
    try {
      final members = await _service.listMembers(spaceId);
      return jsonResponse({'data': members});
    } catch (e, stackTrace) {
      _log.severe('List members error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /api/v1/spaces/<spaceId>/members/<userId>
  ///
  /// Updates a member's role or access level.
  /// Body: { "role": "admin", "access_level": "read_write" }
  Future<Response> _updateMemberRole(
    Request request,
    String spaceId,
    String userId,
  ) async {
    try {
      final actingUserId = getUserId(request);
      final membership = getMembership(request);
      final body = await readJsonBody(request);

      final result = await _service.updateMemberRole(
        spaceId: spaceId,
        targetUserId: userId,
        actingUserId: actingUserId,
        actingRole: membership?.role ?? 'member',
        role: body['role'] as String?,
        accessLevel: body['access_level'] as String?,
      );

      return jsonResponse(result);
    } on SpaceException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update member role error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /api/v1/spaces/<spaceId>/members/<userId>
  ///
  /// Removes a member from the space.
  Future<Response> _removeMember(
    Request request,
    String spaceId,
    String userId,
  ) async {
    try {
      final actingUserId = getUserId(request);
      final membership = getMembership(request);

      await _service.removeMember(
        spaceId: spaceId,
        targetUserId: userId,
        actingUserId: actingUserId,
        actingRole: membership?.role ?? 'member',
      );

      return noContentResponse();
    } on SpaceException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Remove member error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/leave
  ///
  /// Leaves a space voluntarily.
  Future<Response> _leaveSpace(Request request, String spaceId) async {
    try {
      final userId = getUserId(request);
      final membership = getMembership(request);

      await _service.leaveSpace(
        spaceId: spaceId,
        userId: userId,
        userRole: membership?.role ?? 'member',
      );

      return jsonResponse({'message': 'You have left the space.'});
    } on SpaceException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Leave space error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/transfer-ownership
  ///
  /// Transfers ownership to another member.
  /// Body: { "to_user_id": "..." }
  Future<Response> _transferOwnership(Request request, String spaceId) async {
    try {
      final userId = getUserId(request);
      final membership = getMembership(request);
      final body = await readJsonBody(request);

      final toUserId = body['to_user_id'] as String?;
      if (toUserId == null || toUserId.isEmpty) {
        return validationErrorResponse('Target user ID is required');
      }

      await _service.transferOwnership(
        spaceId: spaceId,
        fromUserId: userId,
        fromUserRole: membership?.role ?? 'member',
        toUserId: toUserId,
      );

      return jsonResponse({'message': 'Ownership has been transferred.'});
    } on SpaceException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Transfer ownership error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
