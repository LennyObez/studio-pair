import 'package:drift/drift.dart';
import 'package:studio_pair/src/services/api/files_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/files_dao.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Repository that wraps the Files API and DAO to provide an
/// offline-first data layer with batch cache upserts.
class FilesRepository {
  FilesRepository(this._api, this._dao);

  final FilesApi _api;
  final FilesDao _dao;

  /// Returns cached files, then fetches fresh from API and updates cache.
  Future<List<CachedFile>> getFiles(String spaceId, {String? folderId}) async {
    try {
      final response = await _api.listFiles(spaceId, folderId: folderId);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedFiles,
          jsonList
              .map(
                (json) => CachedFilesCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  uploadedBy: json['uploaded_by'] as String? ?? '',
                  filename: json['filename'] as String? ?? '',
                  sizeBytes: json['size_bytes'] as int? ?? 0,
                  mimeType:
                      json['mime_type'] as String? ??
                      'application/octet-stream',
                  folderId: Value(json['folder_id'] as String?),
                  url: json['url'] as String? ?? '',
                  thumbnailUrl: Value(json['thumbnail_url'] as String?),
                  createdAt:
                      DateTime.tryParse(json['created_at'] as String? ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(json['updated_at'] as String? ?? '') ??
                      DateTime.now(),
                  syncedAt: DateTime.now(),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
      return _dao.getFiles(spaceId, folderId: folderId).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getFiles(spaceId, folderId: folderId).first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load files: $e');
    }
  }

  /// Uploads a file to a space.
  Future<Map<String, dynamic>> uploadFile(
    String spaceId,
    dynamic fileData, {
    String? folderId,
    String? filename,
  }) async {
    try {
      final response = await _api.uploadFile(
        spaceId,
        fileData,
        folderId: folderId,
        filename: filename,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to upload file: $e');
    }
  }

  /// Gets a specific file by ID, with cache fallback.
  Future<Map<String, dynamic>> getFile(String spaceId, String fileId) async {
    try {
      final response = await _api.getFile(spaceId, fileId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getFileById(fileId);
      if (cached != null) return {'id': cached.id, 'filename': cached.filename};
      throw UnknownFailure('Failed to get file: $e');
    }
  }

  /// Deletes a file via the API and removes from cache.
  Future<void> deleteFile(String spaceId, String fileId) async {
    try {
      await _api.deleteFile(spaceId, fileId);
      await _dao.deleteFile(fileId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete file: $e');
    }
  }

  /// Moves a file to a different folder.
  Future<Map<String, dynamic>> moveFile(
    String spaceId,
    String fileId,
    String targetFolderId,
  ) async {
    try {
      final response = await _api.moveFile(spaceId, fileId, targetFolderId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to move file: $e');
    }
  }

  /// Renames a file.
  Future<Map<String, dynamic>> renameFile(
    String spaceId,
    String fileId,
    String newName,
  ) async {
    try {
      final response = await _api.renameFile(spaceId, fileId, newName);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to rename file: $e');
    }
  }

  /// Creates a new folder.
  Future<Map<String, dynamic>> createFolder(
    String spaceId,
    String name, {
    String? parentFolderId,
  }) async {
    try {
      final response = await _api.createFolder(
        spaceId,
        name,
        parentFolderId: parentFolderId,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to create folder: $e');
    }
  }

  /// Lists folders with optional parent folder filter.
  Future<List<Map<String, dynamic>>> listFolders(
    String spaceId, {
    String? parentFolderId,
  }) async {
    try {
      final response = await _api.listFolders(
        spaceId,
        parentFolderId: parentFolderId,
      );
      return _parseList(response.data);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to list folders: $e');
    }
  }

  /// Deletes a folder.
  Future<void> deleteFolder(String spaceId, String folderId) async {
    try {
      await _api.deleteFolder(spaceId, folderId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete folder: $e');
    }
  }

  /// Gets storage usage for a space.
  Future<Map<String, dynamic>> getStorageUsage(String spaceId) async {
    try {
      final response = await _api.getStorageUsage(spaceId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get storage usage: $e');
    }
  }

  /// Watches cached files for a space (reactive stream).
  Stream<List<CachedFile>> watchFiles(String spaceId, {String? folderId}) {
    return _dao.getFiles(spaceId, folderId: folderId);
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
