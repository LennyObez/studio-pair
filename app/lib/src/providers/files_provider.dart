import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/files_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/files_dao.dart';

/// File item model.
class FileItem {
  const FileItem({
    required this.id,
    required this.filename,
    required this.mimeType,
    required this.size,
    this.folderId,
    this.previewUrl,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      id: json['id'],
      filename: json['filename'],
      mimeType: json['mime_type'] ?? '',
      size: json['size'] ?? 0,
      folderId: json['folder_id'],
      previewUrl: json['preview_url'],
      uploadedBy: json['uploaded_by'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  final String id;
  final String filename;
  final String mimeType;

  /// File size in bytes.
  final int size;
  final String? folderId;
  final String? previewUrl;
  final String uploadedBy;
  final String createdAt;
}

/// Folder item model.
class FolderItem {
  const FolderItem({
    required this.id,
    required this.name,
    this.parentFolderId,
    this.fileCount = 0,
  });

  factory FolderItem.fromJson(Map<String, dynamic> json) {
    return FolderItem(
      id: json['id'],
      name: json['name'],
      parentFolderId: json['parent_folder_id'],
      fileCount: json['file_count'] ?? 0,
    );
  }

  final String id;
  final String name;
  final String? parentFolderId;
  final int fileCount;
}

/// Files state.
class FilesState {
  const FilesState({
    this.files = const [],
    this.folders = const [],
    this.currentFolderId,
    this.breadcrumbs = const [],
    this.storageUsed = 0,
    this.storageLimit = 0,
    this.isLoading = false,
    this.isCached = false,
    this.error,
  });

  final List<FileItem> files;
  final List<FolderItem> folders;
  final String? currentFolderId;
  final List<FolderItem> breadcrumbs;

  /// Storage used in bytes.
  final int storageUsed;

  /// Storage limit in bytes.
  final int storageLimit;
  final bool isLoading;
  final bool isCached;
  final String? error;

  FilesState copyWith({
    List<FileItem>? files,
    List<FolderItem>? folders,
    String? currentFolderId,
    List<FolderItem>? breadcrumbs,
    int? storageUsed,
    int? storageLimit,
    bool? isLoading,
    bool? isCached,
    String? error,
    bool clearError = false,
    bool clearCurrentFolderId = false,
  }) {
    return FilesState(
      files: files ?? this.files,
      folders: folders ?? this.folders,
      currentFolderId: clearCurrentFolderId
          ? null
          : (currentFolderId ?? this.currentFolderId),
      breadcrumbs: breadcrumbs ?? this.breadcrumbs,
      storageUsed: storageUsed ?? this.storageUsed,
      storageLimit: storageLimit ?? this.storageLimit,
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Files state notifier managing file and folder operations.
class FilesNotifier extends StateNotifier<FilesState> {
  FilesNotifier(this._api, this._dao) : super(const FilesState());

  final FilesApi _api;
  final FilesDao _dao;

  /// Upload a file to a space.
  Future<bool> uploadFile(
    String spaceId,
    String filePath,
    String filename, {
    String? folderId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: filename),
        if (folderId != null) 'folder_id': folderId,
      });

      final response = await _api.uploadFile(
        spaceId,
        formData,
        folderId: folderId,
        filename: filename,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final newFile = FileItem.fromJson(data);
        state = state.copyWith(
          files: [...state.files, newFile],
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Load files and folders for a space, optionally within a folder.
  Future<void> loadFiles(String spaceId, {String? folderId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // 1. Load from cache first
    try {
      final cached = await _dao.getFiles(spaceId, folderId: folderId).first;
      if (cached.isNotEmpty) {
        final files = cached
            .map(
              (c) => FileItem(
                id: c.id,
                filename: c.filename,
                mimeType: c.mimeType,
                size: c.sizeBytes,
                folderId: c.folderId,
                previewUrl: c.thumbnailUrl,
                uploadedBy: c.uploadedBy,
                createdAt: c.createdAt.toIso8601String(),
              ),
            )
            .toList();
        state = state.copyWith(files: files, isLoading: false, isCached: true);
      }
    } catch (_) {
      // Cache read failed, continue to API
    }

    // 2. Try API in background
    try {
      final filesResponse = await _api.listFiles(spaceId, folderId: folderId);
      final fileItems = parseList(filesResponse.data);
      final files = fileItems.map(FileItem.fromJson).toList();

      final foldersResponse = await _api.listFolders(
        spaceId,
        parentFolderId: folderId,
      );
      final folderItems = parseList(foldersResponse.data);
      final folders = folderItems.map(FolderItem.fromJson).toList();

      // Upsert files into cache
      for (final item in files) {
        await _dao.upsertFile(
          CachedFilesCompanion(
            id: Value(item.id),
            spaceId: Value(spaceId),
            uploadedBy: Value(item.uploadedBy),
            filename: Value(item.filename),
            sizeBytes: Value(item.size),
            mimeType: Value(item.mimeType),
            folderId: Value(item.folderId),
            url: Value(item.previewUrl ?? ''),
            thumbnailUrl: Value(item.previewUrl),
            createdAt: Value(
              DateTime.tryParse(item.createdAt) ?? DateTime.now(),
            ),
            updatedAt: Value(DateTime.now()),
            syncedAt: Value(DateTime.now()),
          ),
        );
      }

      state = state.copyWith(
        folders: folders,
        files: files,
        isLoading: false,
        isCached: false,
      );
    } catch (e) {
      if (state.files.isEmpty) {
        state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Navigate into a folder or back to root.
  void navigateToFolder(String? folderId) {
    if (folderId == null) {
      state = state.copyWith(clearCurrentFolderId: true, breadcrumbs: []);
    } else {
      final folder = state.folders.firstWhere(
        (f) => f.id == folderId,
        orElse: () => FolderItem(id: folderId, name: folderId),
      );
      state = state.copyWith(
        currentFolderId: folderId,
        breadcrumbs: [...state.breadcrumbs, folder],
      );
    }
  }

  /// Create a new folder.
  Future<bool> createFolder(String spaceId, String name) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.createFolder(
        spaceId,
        name,
        parentFolderId: state.currentFolderId,
      );

      final newFolder = FolderItem.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        folders: [...state.folders, newFolder],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Delete a file.
  Future<bool> deleteFile(String spaceId, String fileId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.deleteFile(spaceId, fileId);

      state = state.copyWith(
        files: state.files.where((f) => f.id != fileId).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Delete a folder.
  Future<bool> deleteFolder(String spaceId, String folderId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.deleteFolder(spaceId, folderId);

      state = state.copyWith(
        folders: state.folders.where((f) => f.id != folderId).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Move a file to a different folder.
  Future<bool> moveFile(
    String spaceId,
    String fileId,
    String targetFolderId,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.moveFile(spaceId, fileId, targetFolderId);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Load storage usage for the space.
  Future<void> loadStorageUsage(String spaceId) async {
    try {
      final response = await _api.getStorageUsage(spaceId);
      final data = response.data as Map<String, dynamic>;

      state = state.copyWith(
        storageUsed: data['storage_used'] ?? 0,
        storageLimit: data['storage_limit'] ?? 0,
      );
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
    }
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Files state provider.
final filesProvider = StateNotifierProvider<FilesNotifier, FilesState>((ref) {
  return FilesNotifier(
    ref.watch(filesApiProvider),
    ref.watch(filesDaoProvider),
  );
});

/// Convenience provider for the current file list.
final fileListProvider = Provider<List<FileItem>>((ref) {
  return ref.watch(filesProvider).files;
});

/// Convenience provider for the current folder list.
final folderListProvider = Provider<List<FolderItem>>((ref) {
  return ref.watch(filesProvider).folders;
});

/// Convenience provider for storage usage as a percentage (0.0 - 1.0).
final storageUsageProvider = Provider<double>((ref) {
  final filesState = ref.watch(filesProvider);
  if (filesState.storageLimit == 0) return 0.0;
  return filesState.storageUsed / filesState.storageLimit;
});
