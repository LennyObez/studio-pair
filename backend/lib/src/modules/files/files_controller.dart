import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'files_service.dart';

/// Controller for file storage and management endpoints.
class FilesController {
  final FilesService _service;
  final Logger _log = Logger('FilesController');

  FilesController(this._service);

  /// Returns the router with all file routes.
  Router get router {
    final router = Router();

    // Search (must be before /<fileId> to avoid "search" being captured)
    router.get('/search', _searchFiles);

    // Storage quota
    router.get('/storage/quota', _getStorageQuota);

    // Folders
    router.post('/folders', _createFolder);
    router.get('/folders', _getFolders);
    router.patch('/folders/<folderId>', _updateFolder);
    router.delete('/folders/<folderId>', _deleteFolder);

    // Files CRUD
    router.post('/files', _createFile);
    router.get('/files', _getFiles);
    router.get('/files/<fileId>', _getFile);
    router.patch('/files/<fileId>', _updateFile);
    router.delete('/files/<fileId>', _deleteFile);

    // Sharing
    router.post('/files/<fileId>/share', _shareFile);

    return router;
  }

  /// POST /folders
  ///
  /// Creates a new folder.
  /// Body: { "name": "...", "parent_folder_id": "..." }
  Future<Response> _createFolder(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final name = body['name'] as String?;
      if (name == null || name.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'name', 'message': 'Folder name is required'},
          ],
        );
      }

      final result = await _service.createFolder(
        spaceId: spaceId,
        userId: userId,
        name: name,
        parentFolderId: body['parent_folder_id'] as String?,
      );

      return createdResponse(result);
    } on FilesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create folder error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /folders?parentId=
  ///
  /// Gets child folders for a given parent.
  Future<Response> _getFolders(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final parentId = request.url.queryParameters['parentId'];

      final folders = await _service.getFolders(
        spaceId: spaceId,
        userId: userId,
        parentFolderId: parentId,
      );

      return jsonResponse({'data': folders});
    } on FilesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get folders error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /folders/:folderId
  ///
  /// Updates a folder name.
  /// Body: { "name": "..." }
  Future<Response> _updateFolder(Request request, String folderId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final name = body['name'] as String?;
      if (name == null || name.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'name', 'message': 'Folder name is required'},
          ],
        );
      }

      final result = await _service.updateFolder(
        folderId: folderId,
        spaceId: spaceId,
        userId: userId,
        name: name,
      );

      return jsonResponse(result);
    } on FilesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update folder error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /folders/:folderId
  ///
  /// Soft-deletes a folder.
  Future<Response> _deleteFolder(Request request, String folderId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final membership = getMembership(request);
      final userRole = membership?.role ?? 'member';

      await _service.deleteFolder(
        folderId: folderId,
        spaceId: spaceId,
        userId: userId,
        userRole: userRole,
      );

      return noContentResponse();
    } on FilesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete folder error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /files
  ///
  /// Creates a new file record (multipart upload metadata).
  /// Body: {
  ///   "filename": "...",
  ///   "mime_type": "...",
  ///   "size_bytes": 12345,
  ///   "storage_key": "...",
  ///   "folder_id": "..."
  /// }
  Future<Response> _createFile(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final filename = body['filename'] as String?;
      final mimeType = body['mime_type'] as String?;
      final sizeBytes = body['size_bytes'] as num?;
      final storageKey = body['storage_key'] as String?;

      if (filename == null ||
          mimeType == null ||
          sizeBytes == null ||
          storageKey == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (filename == null)
              {'field': 'filename', 'message': 'Filename is required'},
            if (mimeType == null)
              {'field': 'mime_type', 'message': 'MIME type is required'},
            if (sizeBytes == null)
              {'field': 'size_bytes', 'message': 'File size is required'},
            if (storageKey == null)
              {'field': 'storage_key', 'message': 'Storage key is required'},
          ],
        );
      }

      final result = await _service.createFile(
        spaceId: spaceId,
        userId: userId,
        filename: filename,
        mimeType: mimeType,
        sizeBytes: sizeBytes.toInt(),
        storageKey: storageKey,
        folderId: body['folder_id'] as String?,
      );

      return createdResponse(result);
    } on FilesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create file error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /files?folderId=&cursor=&limit=
  ///
  /// Gets files in a space with optional folder filter and pagination.
  Future<Response> _getFiles(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final folderId = request.url.queryParameters['folderId'];
      final pagination = getPaginationParams(request);

      final files = await _service.getFiles(
        spaceId: spaceId,
        userId: userId,
        folderId: folderId,
        cursor: pagination.cursor,
        limit: pagination.limit,
      );

      final hasMore = files.length >= pagination.limit;
      final nextCursor = hasMore && files.isNotEmpty
          ? files.last['created_at'] as String
          : null;

      return paginatedResponse(files, cursor: nextCursor, hasMore: hasMore);
    } on FilesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get files error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /files/:fileId
  ///
  /// Gets a single file by ID.
  Future<Response> _getFile(Request request, String fileId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final file = await _service.getFile(
        fileId: fileId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(file);
    } on FilesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get file error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /files/:fileId
  ///
  /// Updates a file's metadata.
  /// Body: { "filename": "...", "folder_id": "..." }
  Future<Response> _updateFile(Request request, String fileId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final updates = <String, dynamic>{};
      if (body.containsKey('filename')) {
        updates['filename'] = body['filename'];
      }
      if (body.containsKey('folder_id')) {
        updates['folder_id'] = body['folder_id'];
      }

      final result = await _service.updateFile(
        fileId: fileId,
        spaceId: spaceId,
        userId: userId,
        updates: updates,
      );

      return jsonResponse(result);
    } on FilesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update file error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /files/:fileId
  ///
  /// Soft-deletes a file.
  Future<Response> _deleteFile(Request request, String fileId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final membership = getMembership(request);
      final userRole = membership?.role ?? 'member';

      await _service.deleteFile(
        fileId: fileId,
        spaceId: spaceId,
        userId: userId,
        userRole: userRole,
      );

      return noContentResponse();
    } on FilesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete file error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /files/:fileId/share
  ///
  /// Shares a file with another user.
  /// Body: { "shared_with_user_id": "...", "access_level": "read|read_write" }
  Future<Response> _shareFile(Request request, String fileId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final sharedWithUserId = body['shared_with_user_id'] as String?;
      final accessLevel = body['access_level'] as String? ?? 'read';

      if (sharedWithUserId == null || sharedWithUserId.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {
              'field': 'shared_with_user_id',
              'message': 'Target user ID is required',
            },
          ],
        );
      }

      final result = await _service.shareFile(
        fileId: fileId,
        spaceId: spaceId,
        userId: userId,
        sharedWithUserId: sharedWithUserId,
        accessLevel: accessLevel,
      );

      return createdResponse(result);
    } on FilesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Share file error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /storage/quota
  ///
  /// Gets storage usage and quota for the space.
  Future<Response> _getStorageQuota(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final quota = await _service.getStorageQuota(
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(quota);
    } on FilesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get storage quota error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /files/search?q=
  ///
  /// Full-text searches files by filename.
  Future<Response> _searchFiles(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final query = request.url.queryParameters['q'];
      if (query == null || query.isEmpty) {
        return validationErrorResponse(
          'Search query is required',
          errors: [
            {'field': 'q', 'message': 'Query parameter "q" is required'},
          ],
        );
      }

      final files = await _service.searchFiles(
        spaceId: spaceId,
        userId: userId,
        query: query,
      );

      return jsonResponse({'data': files});
    } on FilesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Search files error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
