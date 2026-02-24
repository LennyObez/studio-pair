import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Files API service for file uploads, folders, and storage management within a space.
class FilesApi {
  FilesApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Upload a file to a space (multipart).
  Future<Response> uploadFile(
    String spaceId,
    dynamic fileData, {
    String? folderId,
    String? filename,
  }) {
    return _client.post(
      '/spaces/$spaceId/files/upload',
      data: fileData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  /// List files in a space with optional folder filter and pagination.
  Future<Response> listFiles(
    String spaceId, {
    String? folderId,
    String? cursor,
    int? limit,
  }) {
    return _client.get(
      '/spaces/$spaceId/files/files',
      queryParameters: {
        if (folderId != null) 'folder_id': folderId,
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
  }

  /// Get a specific file by ID.
  Future<Response> getFile(String spaceId, String fileId) {
    return _client.get('/spaces/$spaceId/files/files/$fileId');
  }

  /// Delete a file.
  Future<Response> deleteFile(String spaceId, String fileId) {
    return _client.delete('/spaces/$spaceId/files/files/$fileId');
  }

  /// Move a file to a different folder.
  Future<Response> moveFile(
    String spaceId,
    String fileId,
    String targetFolderId,
  ) {
    return _client.post(
      '/spaces/$spaceId/files/files/$fileId/move',
      data: {'folder_id': targetFolderId},
    );
  }

  /// Rename a file.
  Future<Response> renameFile(String spaceId, String fileId, String newName) {
    return _client.patch(
      '/spaces/$spaceId/files/files/$fileId',
      data: {'filename': newName},
    );
  }

  /// Create a new folder.
  Future<Response> createFolder(
    String spaceId,
    String name, {
    String? parentFolderId,
  }) {
    return _client.post(
      '/spaces/$spaceId/files/folders',
      data: {
        'name': name,
        if (parentFolderId != null) 'parent_folder_id': parentFolderId,
      },
    );
  }

  /// List folders with optional parent folder filter.
  Future<Response> listFolders(String spaceId, {String? parentFolderId}) {
    return _client.get(
      '/spaces/$spaceId/files/folders',
      queryParameters: {
        if (parentFolderId != null) 'parent_folder_id': parentFolderId,
      },
    );
  }

  /// Delete a folder.
  Future<Response> deleteFolder(String spaceId, String folderId) {
    return _client.delete('/spaces/$spaceId/files/folders/$folderId');
  }

  /// Get storage usage for a space.
  Future<Response> getStorageUsage(String spaceId) {
    return _client.get('/spaces/$spaceId/files/storage');
  }
}
