import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../spaces/spaces_repository.dart';
import 'files_repository.dart';

/// Custom exception for files-related errors.
class FilesException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const FilesException(
    this.message, {
    this.code = 'FILES_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'FilesException($code): $message';
}

/// Service containing all file and folder business logic.
class FilesService {
  final FilesRepository _repo;
  final SpacesRepository _spacesRepo;
  final Logger _log = Logger('FilesService');
  final Uuid _uuid = const Uuid();

  /// Maximum folder nesting depth.
  static const int _maxFolderDepth = 5;

  /// Default storage quota in bytes (500 MB).
  static const int _defaultStorageQuota = 524288000;

  /// Blocked executable MIME types.
  static const _blockedMimeTypes = [
    'application/x-msdownload',
    'application/x-executable',
    'application/x-msdos-program',
    'application/x-sh',
    'application/x-bat',
    'application/x-cmd',
    'application/vnd.microsoft.portable-executable',
  ];

  FilesService(this._repo, this._spacesRepo);

  // ---------------------------------------------------------------------------
  // Folders
  // ---------------------------------------------------------------------------

  /// Creates a new folder.
  ///
  /// Validates the name and checks that folder depth does not exceed the limit.
  Future<Map<String, dynamic>> createFolder({
    required String spaceId,
    required String userId,
    required String name,
    String? parentFolderId,
  }) async {
    // Validate name
    if (name.trim().isEmpty) {
      throw const FilesException(
        'Folder name is required',
        code: 'INVALID_NAME',
        statusCode: 422,
      );
    }

    if (name.trim().length > 255) {
      throw const FilesException(
        'Folder name must be at most 255 characters',
        code: 'INVALID_NAME',
        statusCode: 422,
      );
    }

    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Determine depth
    var depth = 0;
    if (parentFolderId != null) {
      final parent = await _repo.getFolderById(parentFolderId);
      if (parent == null) {
        throw const FilesException(
          'Parent folder not found',
          code: 'PARENT_NOT_FOUND',
          statusCode: 404,
        );
      }
      if (parent['space_id'] != spaceId) {
        throw const FilesException(
          'Parent folder not found',
          code: 'PARENT_NOT_FOUND',
          statusCode: 404,
        );
      }
      depth = (parent['depth'] as int) + 1;
    }

    // Check depth limit
    if (depth > _maxFolderDepth) {
      throw const FilesException(
        'Maximum folder depth of $_maxFolderDepth exceeded',
        code: 'MAX_DEPTH_EXCEEDED',
        statusCode: 422,
      );
    }

    final folder = await _repo.createFolder(
      id: _uuid.v4(),
      spaceId: spaceId,
      parentFolderId: parentFolderId,
      name: name.trim(),
      createdBy: userId,
      depth: depth,
    );

    _log.info(
      'Folder created: ${folder['name']} (${folder['id']}) in space $spaceId',
    );

    return folder;
  }

  /// Gets child folders for a parent in a space.
  Future<List<Map<String, dynamic>>> getFolders({
    required String spaceId,
    required String userId,
    String? parentFolderId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);
    return _repo.getFolders(spaceId, parentFolderId);
  }

  /// Updates a folder name.
  Future<Map<String, dynamic>> updateFolder({
    required String folderId,
    required String spaceId,
    required String userId,
    required String name,
  }) async {
    if (name.trim().isEmpty) {
      throw const FilesException(
        'Folder name is required',
        code: 'INVALID_NAME',
        statusCode: 422,
      );
    }

    final folder = await _repo.getFolderById(folderId);
    if (folder == null || folder['space_id'] != spaceId) {
      throw const FilesException(
        'Folder not found',
        code: 'FOLDER_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (folder['is_system'] == true) {
      throw const FilesException(
        'System folders cannot be renamed',
        code: 'SYSTEM_FOLDER',
        statusCode: 403,
      );
    }

    final updated = await _repo.updateFolder(folderId, name.trim());
    if (updated == null) {
      throw const FilesException(
        'Folder not found',
        code: 'FOLDER_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('Folder updated: $folderId in space $spaceId');

    return updated;
  }

  /// Soft-deletes a folder.
  Future<void> deleteFolder({
    required String folderId,
    required String spaceId,
    required String userId,
    required String userRole,
  }) async {
    final folder = await _repo.getFolderById(folderId);
    if (folder == null || folder['space_id'] != spaceId) {
      throw const FilesException(
        'Folder not found',
        code: 'FOLDER_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (folder['is_system'] == true) {
      throw const FilesException(
        'System folders cannot be deleted',
        code: 'SYSTEM_FOLDER',
        statusCode: 403,
      );
    }

    final isCreator = folder['created_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdmin) {
      throw const FilesException(
        'Only the folder creator or a space admin can delete this folder',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.softDeleteFolder(folderId);

    _log.info('Folder deleted: $folderId in space $spaceId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Files
  // ---------------------------------------------------------------------------

  /// Creates a new file record.
  ///
  /// Checks storage quota and validates MIME type (blocks executables).
  Future<Map<String, dynamic>> createFile({
    required String spaceId,
    required String userId,
    required String filename,
    required String mimeType,
    required int sizeBytes,
    required String storageKey,
    String? folderId,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Validate MIME type - block executables
    if (_blockedMimeTypes.contains(mimeType)) {
      throw const FilesException(
        'Executable files are not allowed',
        code: 'BLOCKED_MIME_TYPE',
        statusCode: 422,
      );
    }

    // Check storage quota
    final usedBytes = await _repo.getStorageUsed(spaceId);
    if (usedBytes + sizeBytes > _defaultStorageQuota) {
      throw const FilesException(
        'Storage quota exceeded',
        code: 'STORAGE_QUOTA_EXCEEDED',
        statusCode: 422,
      );
    }

    // Validate folder if specified
    if (folderId != null) {
      final folder = await _repo.getFolderById(folderId);
      if (folder == null || folder['space_id'] != spaceId) {
        throw const FilesException(
          'Folder not found',
          code: 'FOLDER_NOT_FOUND',
          statusCode: 404,
        );
      }
    }

    final file = await _repo.createFile(
      id: _uuid.v4(),
      spaceId: spaceId,
      folderId: folderId,
      uploadedBy: userId,
      filename: filename,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      storageKey: storageKey,
    );

    _log.info('File created: $filename (${file['id']}) in space $spaceId');

    return file;
  }

  /// Gets a file by ID, verifying space access.
  Future<Map<String, dynamic>> getFile({
    required String fileId,
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final file = await _repo.getFileById(fileId);
    if (file == null) {
      throw const FilesException(
        'File not found',
        code: 'FILE_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (file['space_id'] != spaceId) {
      throw const FilesException(
        'File not found',
        code: 'FILE_NOT_FOUND',
        statusCode: 404,
      );
    }

    return file;
  }

  /// Gets files in a space with optional folder filter and pagination.
  Future<List<Map<String, dynamic>>> getFiles({
    required String spaceId,
    required String userId,
    String? folderId,
    String? cursor,
    int limit = 25,
  }) async {
    await _verifySpaceMembership(spaceId, userId);
    return _repo.getFiles(
      spaceId,
      folderId: folderId,
      cursor: cursor,
      limit: limit,
    );
  }

  /// Updates a file.
  Future<Map<String, dynamic>> updateFile({
    required String fileId,
    required String spaceId,
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    final file = await _repo.getFileById(fileId);
    if (file == null || file['space_id'] != spaceId) {
      throw const FilesException(
        'File not found',
        code: 'FILE_NOT_FOUND',
        statusCode: 404,
      );
    }

    final updated = await _repo.updateFile(fileId, updates);
    if (updated == null) {
      throw const FilesException(
        'File not found',
        code: 'FILE_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('File updated: $fileId in space $spaceId');

    return updated;
  }

  /// Soft-deletes a file.
  ///
  /// Verifies the user is the uploader or a space admin.
  Future<void> deleteFile({
    required String fileId,
    required String spaceId,
    required String userId,
    required String userRole,
  }) async {
    final file = await _repo.getFileById(fileId);
    if (file == null || file['space_id'] != spaceId) {
      throw const FilesException(
        'File not found',
        code: 'FILE_NOT_FOUND',
        statusCode: 404,
      );
    }

    final isUploader = file['uploaded_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isUploader && !isAdmin) {
      throw const FilesException(
        'Only the uploader or a space admin can delete this file',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.softDeleteFile(fileId);

    _log.info('File deleted: $fileId in space $spaceId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Sharing
  // ---------------------------------------------------------------------------

  /// Shares a file with another user.
  ///
  /// Verifies the requesting user has access to the file.
  Future<Map<String, dynamic>> shareFile({
    required String fileId,
    required String spaceId,
    required String userId,
    required String sharedWithUserId,
    required String accessLevel,
  }) async {
    // Verify the file exists and belongs to the space
    final file = await _repo.getFileById(fileId);
    if (file == null || file['space_id'] != spaceId) {
      throw const FilesException(
        'File not found',
        code: 'FILE_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the target user is a space member
    final targetMembership = await _spacesRepo.getMember(
      spaceId,
      sharedWithUserId,
    );
    if (targetMembership == null || targetMembership['status'] != 'active') {
      throw const FilesException(
        'Target user is not a member of this space',
        code: 'INVALID_TARGET_USER',
        statusCode: 422,
      );
    }

    // Validate access level
    if (accessLevel != 'read' && accessLevel != 'read_write') {
      throw const FilesException(
        'Access level must be "read" or "read_write"',
        code: 'INVALID_ACCESS_LEVEL',
        statusCode: 422,
      );
    }

    final share = await _repo.shareFile(
      id: _uuid.v4(),
      fileId: fileId,
      sharedWithUserId: sharedWithUserId,
      accessLevel: accessLevel,
      sharedBy: userId,
    );

    _log.info('File $fileId shared with $sharedWithUserId by $userId');

    return share;
  }

  // ---------------------------------------------------------------------------
  // Storage
  // ---------------------------------------------------------------------------

  /// Gets the storage usage and quota for a space.
  Future<Map<String, dynamic>> getStorageQuota({
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final usedBytes = await _repo.getStorageUsed(spaceId);
    const totalBytes = _defaultStorageQuota;
    final percentage = totalBytes > 0
        ? ((usedBytes / totalBytes) * 100).round()
        : 0;

    return {
      'used_bytes': usedBytes,
      'total_bytes': totalBytes,
      'percentage': percentage,
    };
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  /// Searches files by filename in a space.
  Future<List<Map<String, dynamic>>> searchFiles({
    required String spaceId,
    required String userId,
    required String query,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    if (query.trim().isEmpty) {
      throw const FilesException(
        'Search query is required',
        code: 'INVALID_QUERY',
        statusCode: 422,
      );
    }

    return _repo.searchFiles(spaceId, query.trim());
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Verifies that a user is an active member of a space.
  Future<Map<String, dynamic>> _verifySpaceMembership(
    String spaceId,
    String userId,
  ) async {
    final membership = await _spacesRepo.getMember(spaceId, userId);
    if (membership == null || membership['status'] != 'active') {
      throw const FilesException(
        'You do not have access to this space',
        code: 'SPACE_ACCESS_DENIED',
        statusCode: 403,
      );
    }
    return membership;
  }
}
