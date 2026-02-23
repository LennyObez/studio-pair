import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'vault_service.dart';

/// Controller for encrypted vault endpoints.
class VaultController {
  final VaultService _service;
  final Logger _log = Logger('VaultController');

  VaultController(this._service);

  /// Returns the router with all vault routes.
  Router get router {
    final router = Router();

    // Domain groups (registered before parameterized routes)
    router.get('/vault/domains', _getDomainGroups);

    // Vault entry CRUD
    router.post('/vault', _createEntry);
    router.get('/vault', _getEntries);
    router.get('/vault/<entryId>', _getEntry);
    router.patch('/vault/<entryId>', _updateEntry);
    router.delete('/vault/<entryId>', _deleteEntry);

    // Sharing
    router.post('/vault/<entryId>/share', _shareEntry);
    router.delete('/vault/<entryId>/share/<userId>', _unshareEntry);

    // Sensitive access
    router.post('/vault/<entryId>/reveal', _revealEntry);

    return router;
  }

  /// POST /vault
  ///
  /// Creates a new vault entry.
  /// Body: {
  ///   "domain": "example.com",
  ///   "favicon_url": "https://...",
  ///   "label": "Work account",
  ///   "encrypted_blob": "base64-encoded-encrypted-data"
  /// }
  Future<Response> _createEntry(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final domain = body['domain'] as String?;
      final encryptedBlob = body['encrypted_blob'] as String?;

      if (domain == null || encryptedBlob == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (domain == null)
              {'field': 'domain', 'message': 'Domain is required'},
            if (encryptedBlob == null)
              {
                'field': 'encrypted_blob',
                'message': 'Encrypted blob is required',
              },
          ],
        );
      }

      final result = await _service.createEntry(
        spaceId: spaceId,
        userId: userId,
        domain: domain,
        faviconUrl: body['favicon_url'] as String?,
        label: body['label'] as String?,
        encryptedBlob: encryptedBlob,
      );

      return createdResponse(result);
    } on VaultException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create vault entry error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /vault?domain=&search=&cursor=&limit=
  ///
  /// Gets vault entries for the user in the current space.
  Future<Response> _getEntries(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final params = request.url.queryParameters;

      final domain = params['domain'];
      final search = params['search'];
      final pagination = getPaginationParams(request);

      final result = await _service.getEntries(
        spaceId: spaceId,
        userId: userId,
        domain: domain,
        search: search,
        cursor: pagination.cursor,
        limit: pagination.limit,
      );

      return paginatedResponse(
        result['data'] as List<dynamic>,
        cursor: result['cursor'] as String?,
        hasMore: result['has_more'] as bool,
      );
    } on VaultException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get vault entries error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /vault/domains
  ///
  /// Gets domain groupings for the user in the current space.
  Future<Response> _getDomainGroups(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final groups = await _service.getDomainGroups(
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse({'data': groups});
    } on VaultException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get domain groups error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /vault/<entryId>
  ///
  /// Gets a single vault entry by ID.
  Future<Response> _getEntry(Request request, String entryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final entry = await _service.getEntry(
        entryId: entryId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(entry);
    } on VaultException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get vault entry error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /vault/<entryId>
  ///
  /// Partially updates a vault entry.
  /// Body: any subset of { domain, favicon_url, label, encrypted_blob }
  Future<Response> _updateEntry(Request request, String entryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      // Build the updates map
      final updates = <String, dynamic>{};

      if (body.containsKey('domain')) {
        updates['domain'] = body['domain'];
      }
      if (body.containsKey('favicon_url')) {
        updates['favicon_url'] = body['favicon_url'];
      }
      if (body.containsKey('label')) {
        updates['label'] = body['label'];
      }
      if (body.containsKey('encrypted_blob')) {
        updates['encrypted_blob'] = body['encrypted_blob'];
      }

      final result = await _service.updateEntry(
        entryId: entryId,
        spaceId: spaceId,
        userId: userId,
        updates: updates,
      );

      return jsonResponse(result);
    } on VaultException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update vault entry error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /vault/<entryId>
  ///
  /// Soft-deletes a vault entry.
  Future<Response> _deleteEntry(Request request, String entryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      await _service.deleteEntry(
        entryId: entryId,
        spaceId: spaceId,
        userId: userId,
      );

      return noContentResponse();
    } on VaultException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete vault entry error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /vault/<entryId>/share
  ///
  /// Shares a vault entry with another user.
  /// Body: { "user_id": "...", "encrypted_symmetric_key": "base64..." }
  Future<Response> _shareEntry(Request request, String entryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final sharedWithUserId = body['user_id'] as String?;
      final encryptedSymmetricKey = body['encrypted_symmetric_key'] as String?;

      if (sharedWithUserId == null || encryptedSymmetricKey == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (sharedWithUserId == null)
              {'field': 'user_id', 'message': 'User ID is required'},
            if (encryptedSymmetricKey == null)
              {
                'field': 'encrypted_symmetric_key',
                'message': 'Encrypted symmetric key is required',
              },
          ],
        );
      }

      final result = await _service.shareEntry(
        entryId: entryId,
        spaceId: spaceId,
        userId: userId,
        sharedWithUserId: sharedWithUserId,
        encryptedSymmetricKey: encryptedSymmetricKey,
      );

      return createdResponse(result);
    } on VaultException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Share vault entry error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /vault/<entryId>/share/<userId>
  ///
  /// Removes a vault entry share for a user.
  Future<Response> _unshareEntry(
    Request request,
    String entryId,
    String unshareUserId,
  ) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      await _service.unshareEntry(
        entryId: entryId,
        spaceId: spaceId,
        userId: userId,
        unshareUserId: unshareUserId,
      );

      return noContentResponse();
    } on VaultException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Unshare vault entry error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /vault/<entryId>/reveal
  ///
  /// Reveals a vault entry's encrypted blob (requires sensitive access token).
  Future<Response> _revealEntry(Request request, String entryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      // Extract sensitive access token from header
      final sensitiveAccessToken =
          request.headers['x-sensitive-access-token'] ?? '';

      final result = await _service.revealEntry(
        entryId: entryId,
        spaceId: spaceId,
        userId: userId,
        sensitiveAccessToken: sensitiveAccessToken,
      );

      return jsonResponse(result);
    } on VaultException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Reveal vault entry error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
