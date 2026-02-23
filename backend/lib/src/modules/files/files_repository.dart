import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for file and folder database operations.
class FilesRepository {
  final Database _db;
  // ignore: unused_field
  final Logger _log = Logger('FilesRepository');

  FilesRepository(this._db);

  // ---------------------------------------------------------------------------
  // Folders
  // ---------------------------------------------------------------------------

  /// Creates a new folder and returns the created row.
  Future<Map<String, dynamic>> createFolder({
    required String id,
    required String spaceId,
    required String? parentFolderId,
    required String name,
    required String createdBy,
    bool isSystem = false,
    int depth = 0,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO folders (
        id, space_id, parent_folder_id, name, created_by,
        is_system, depth, created_at, updated_at
      )
      VALUES (
        @id, @spaceId, @parentFolderId, @name, @createdBy,
        @isSystem, @depth, NOW(), NOW()
      )
      RETURNING id, space_id, parent_folder_id, name, created_by,
                is_system, depth, created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'spaceId': spaceId,
        'parentFolderId': parentFolderId,
        'name': name,
        'createdBy': createdBy,
        'isSystem': isSystem,
        'depth': depth,
      },
    );

    return _folderRowToMap(row!);
  }

  /// Gets a folder by ID.
  Future<Map<String, dynamic>?> getFolderById(String folderId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, parent_folder_id, name, created_by,
             is_system, depth, created_at, updated_at
      FROM folders
      WHERE id = @folderId AND deleted_at IS NULL
      ''',
      parameters: {'folderId': folderId},
    );

    if (row == null) return null;
    return _folderRowToMap(row);
  }

  /// Gets child folders for a given parent folder in a space.
  Future<List<Map<String, dynamic>>> getFolders(
    String spaceId,
    String? parentFolderId,
  ) async {
    final result = await _db.query(
      '''
      SELECT id, space_id, parent_folder_id, name, created_by,
             is_system, depth, created_at, updated_at
      FROM folders
      WHERE space_id = @spaceId
        AND deleted_at IS NULL
        AND ${parentFolderId == null ? 'parent_folder_id IS NULL' : 'parent_folder_id = @parentFolderId'}
      ORDER BY name ASC
      ''',
      parameters: {
        'spaceId': spaceId,
        if (parentFolderId != null) 'parentFolderId': parentFolderId,
      },
    );

    return result.map(_folderRowToMap).toList();
  }

  /// Updates a folder name.
  Future<Map<String, dynamic>?> updateFolder(
    String folderId,
    String name,
  ) async {
    final row = await _db.queryOne(
      '''
      UPDATE folders
      SET name = @name, updated_at = NOW()
      WHERE id = @folderId AND deleted_at IS NULL
      RETURNING id, space_id, parent_folder_id, name, created_by,
                is_system, depth, created_at, updated_at
      ''',
      parameters: {'folderId': folderId, 'name': name},
    );

    if (row == null) return null;
    return _folderRowToMap(row);
  }

  /// Soft-deletes a folder.
  Future<void> softDeleteFolder(String folderId) async {
    await _db.execute(
      '''
      UPDATE folders
      SET deleted_at = NOW(), updated_at = NOW()
      WHERE id = @folderId AND deleted_at IS NULL
      ''',
      parameters: {'folderId': folderId},
    );
  }

  // ---------------------------------------------------------------------------
  // Files
  // ---------------------------------------------------------------------------

  /// Creates a new file record and returns the created row.
  Future<Map<String, dynamic>> createFile({
    required String id,
    required String spaceId,
    required String? folderId,
    required String uploadedBy,
    required String filename,
    required String mimeType,
    required int sizeBytes,
    required String storageKey,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO files (
        id, space_id, folder_id, uploaded_by, filename,
        mime_type, size_bytes, storage_key, created_at, updated_at
      )
      VALUES (
        @id, @spaceId, @folderId, @uploadedBy, @filename,
        @mimeType, @sizeBytes, @storageKey, NOW(), NOW()
      )
      RETURNING id, space_id, folder_id, uploaded_by, filename,
                mime_type, size_bytes, storage_key, created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'spaceId': spaceId,
        'folderId': folderId,
        'uploadedBy': uploadedBy,
        'filename': filename,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'storageKey': storageKey,
      },
    );

    return _fileRowToMap(row!);
  }

  /// Gets a file by ID.
  Future<Map<String, dynamic>?> getFileById(String fileId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, folder_id, uploaded_by, filename,
             mime_type, size_bytes, storage_key, created_at, updated_at
      FROM files
      WHERE id = @fileId AND deleted_at IS NULL
      ''',
      parameters: {'fileId': fileId},
    );

    if (row == null) return null;
    return _fileRowToMap(row);
  }

  /// Gets files in a space, optionally filtered by folder, with cursor pagination.
  Future<List<Map<String, dynamic>>> getFiles(
    String spaceId, {
    String? folderId,
    String? cursor,
    int limit = 25,
  }) async {
    final conditions = <String>['space_id = @spaceId', 'deleted_at IS NULL'];
    final params = <String, dynamic>{'spaceId': spaceId, 'limit': limit};

    if (folderId != null) {
      conditions.add('folder_id = @folderId');
      params['folderId'] = folderId;
    }

    if (cursor != null) {
      conditions.add('created_at < @cursor');
      params['cursor'] = DateTime.parse(cursor);
    }

    final result = await _db.query('''
      SELECT id, space_id, folder_id, uploaded_by, filename,
             mime_type, size_bytes, storage_key, created_at, updated_at
      FROM files
      WHERE ${conditions.join(' AND ')}
      ORDER BY created_at DESC
      LIMIT @limit
      ''', parameters: params);

    return result.map(_fileRowToMap).toList();
  }

  /// Updates a file with the given fields.
  Future<Map<String, dynamic>?> updateFile(
    String fileId,
    Map<String, dynamic> updates,
  ) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'fileId': fileId};

    if (updates.containsKey('filename')) {
      setClauses.add('filename = @filename');
      params['filename'] = updates['filename'];
    }
    if (updates.containsKey('folder_id')) {
      setClauses.add('folder_id = @folderId');
      params['folderId'] = updates['folder_id'];
    }

    if (setClauses.isEmpty) return getFileById(fileId);

    setClauses.add('updated_at = NOW()');

    final row = await _db.queryOne('''
      UPDATE files
      SET ${setClauses.join(', ')}
      WHERE id = @fileId AND deleted_at IS NULL
      RETURNING id, space_id, folder_id, uploaded_by, filename,
                mime_type, size_bytes, storage_key, created_at, updated_at
      ''', parameters: params);

    if (row == null) return null;
    return _fileRowToMap(row);
  }

  /// Soft-deletes a file.
  Future<void> softDeleteFile(String fileId) async {
    await _db.execute(
      '''
      UPDATE files
      SET deleted_at = NOW(), updated_at = NOW()
      WHERE id = @fileId AND deleted_at IS NULL
      ''',
      parameters: {'fileId': fileId},
    );
  }

  // ---------------------------------------------------------------------------
  // Sharing
  // ---------------------------------------------------------------------------

  /// Shares a file with a user and returns the share record.
  Future<Map<String, dynamic>> shareFile({
    required String id,
    required String fileId,
    required String sharedWithUserId,
    required String accessLevel,
    required String sharedBy,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO file_shares (
        id, file_id, shared_with_user_id, access_level, shared_by, created_at
      )
      VALUES (@id, @fileId, @sharedWithUserId, @accessLevel, @sharedBy, NOW())
      ON CONFLICT (file_id, shared_with_user_id)
      DO UPDATE SET access_level = @accessLevel
      RETURNING id, file_id, shared_with_user_id, access_level, shared_by, created_at
      ''',
      parameters: {
        'id': id,
        'fileId': fileId,
        'sharedWithUserId': sharedWithUserId,
        'accessLevel': accessLevel,
        'sharedBy': sharedBy,
      },
    );

    return _shareRowToMap(row!);
  }

  // ---------------------------------------------------------------------------
  // Storage
  // ---------------------------------------------------------------------------

  /// Gets the total storage used by a space in bytes.
  Future<int> getStorageUsed(String spaceId) async {
    final row = await _db.queryOne(
      '''
      SELECT COALESCE(SUM(size_bytes), 0)
      FROM files
      WHERE space_id = @spaceId AND deleted_at IS NULL
      ''',
      parameters: {'spaceId': spaceId},
    );
    return (row?[0] as int?) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  /// Full-text searches files by filename in a space.
  Future<List<Map<String, dynamic>>> searchFiles(
    String spaceId,
    String query,
  ) async {
    final result = await _db.query(
      '''
      SELECT id, space_id, folder_id, uploaded_by, filename,
             mime_type, size_bytes, storage_key, created_at, updated_at
      FROM files
      WHERE space_id = @spaceId
        AND deleted_at IS NULL
        AND filename ILIKE @query
      ORDER BY created_at DESC
      LIMIT 50
      ''',
      parameters: {'spaceId': spaceId, 'query': '%$query%'},
    );

    return result.map(_fileRowToMap).toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _folderRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'parent_folder_id': row[2] as String?,
      'name': row[3] as String,
      'created_by': row[4] as String,
      'is_system': row[5] as bool,
      'depth': row[6] as int,
      'created_at': (row[7] as DateTime).toIso8601String(),
      'updated_at': (row[8] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _fileRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'folder_id': row[2] as String?,
      'uploaded_by': row[3] as String,
      'filename': row[4] as String,
      'mime_type': row[5] as String,
      'size_bytes': row[6] as int,
      'storage_key': row[7] as String,
      'created_at': (row[8] as DateTime).toIso8601String(),
      'updated_at': (row[9] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _shareRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'file_id': row[1] as String,
      'shared_with_user_id': row[2] as String,
      'access_level': row[3] as String,
      'shared_by': row[4] as String,
      'created_at': (row[5] as DateTime).toIso8601String(),
    };
  }
}
