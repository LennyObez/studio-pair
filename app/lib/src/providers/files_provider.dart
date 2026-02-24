import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';

// ── Navigation state providers ──────────────────────────────────────────

/// Currently browsed folder ID (null = root).
final currentFolderIdProvider = StateProvider<String?>((ref) => null);

/// Storage usage (used bytes, limit bytes) loaded separately.
final storageUsageProvider = StateProvider<({int used, int limit})>(
  (ref) => (used: 0, limit: 0),
);

// ── Files notifier ──────────────────────────────────────────────────────

/// Files notifier backed by the [FilesRepository].
///
/// The [build] method fetches files from the repository (API + cache)
/// whenever the current space or folder changes.
class FilesNotifier extends AutoDisposeAsyncNotifier<List<CachedFile>> {
  @override
  Future<List<CachedFile>> build() async {
    final repo = ref.watch(filesRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    final folderId = ref.watch(currentFolderIdProvider);
    if (spaceId == null) return [];
    return repo.getFiles(spaceId, folderId: folderId);
  }

  /// Upload a file and refresh the list.
  Future<bool> uploadFile(
    String spaceId,
    dynamic fileData, {
    String? folderId,
    String? filename,
  }) async {
    final repo = ref.read(filesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.uploadFile(
        spaceId,
        fileData,
        folderId: folderId,
        filename: filename,
      );
      return repo.getFiles(
        spaceId,
        folderId: ref.read(currentFolderIdProvider),
      );
    });
    return !state.hasError;
  }

  /// Delete a file and refresh the list.
  Future<bool> deleteFile(String spaceId, String fileId) async {
    final repo = ref.read(filesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteFile(spaceId, fileId);
      return repo.getFiles(
        spaceId,
        folderId: ref.read(currentFolderIdProvider),
      );
    });
    return !state.hasError;
  }

  /// Move a file to a different folder and refresh.
  Future<bool> moveFile(
    String spaceId,
    String fileId,
    String targetFolderId,
  ) async {
    final repo = ref.read(filesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.moveFile(spaceId, fileId, targetFolderId);
      return repo.getFiles(
        spaceId,
        folderId: ref.read(currentFolderIdProvider),
      );
    });
    return !state.hasError;
  }

  /// Rename a file and refresh.
  Future<bool> renameFile(String spaceId, String fileId, String newName) async {
    final repo = ref.read(filesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.renameFile(spaceId, fileId, newName);
      return repo.getFiles(
        spaceId,
        folderId: ref.read(currentFolderIdProvider),
      );
    });
    return !state.hasError;
  }

  /// Load storage usage for the space (non-fatal on failure).
  Future<void> loadStorageUsage(String spaceId) async {
    final repo = ref.read(filesRepositoryProvider);
    try {
      final data = await repo.getStorageUsage(spaceId);
      ref.read(storageUsageProvider.notifier).state = (
        used: data['storage_used'] as int? ?? 0,
        limit: data['storage_limit'] as int? ?? 0,
      );
    } catch (_) {
      // Non-fatal.
    }
  }
}

/// Files async provider.
final filesProvider =
    AsyncNotifierProvider.autoDispose<FilesNotifier, List<CachedFile>>(
      FilesNotifier.new,
    );

// ── Folders notifier ────────────────────────────────────────────────────

/// Folders notifier for folder listing (separate from files).
class FoldersNotifier
    extends AutoDisposeAsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.watch(filesRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    final parentFolderId = ref.watch(currentFolderIdProvider);
    if (spaceId == null) return [];
    return repo.listFolders(spaceId, parentFolderId: parentFolderId);
  }

  /// Create a new folder and refresh.
  Future<bool> createFolder(
    String spaceId,
    String name, {
    String? parentFolderId,
  }) async {
    final repo = ref.read(filesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.createFolder(spaceId, name, parentFolderId: parentFolderId);
      return repo.listFolders(
        spaceId,
        parentFolderId: ref.read(currentFolderIdProvider),
      );
    });
    return !state.hasError;
  }

  /// Delete a folder and refresh.
  Future<bool> deleteFolder(String spaceId, String folderId) async {
    final repo = ref.read(filesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteFolder(spaceId, folderId);
      return repo.listFolders(
        spaceId,
        parentFolderId: ref.read(currentFolderIdProvider),
      );
    });
    return !state.hasError;
  }
}

/// Folders async provider.
final foldersProvider =
    AsyncNotifierProvider.autoDispose<
      FoldersNotifier,
      List<Map<String, dynamic>>
    >(FoldersNotifier.new);

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for the current file list.
final fileListProvider = Provider<List<CachedFile>>((ref) {
  return ref.watch(filesProvider).valueOrNull ?? [];
});

/// Convenience provider for the current folder list.
final folderListProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(foldersProvider).valueOrNull ?? [];
});

/// Convenience provider for storage usage as a percentage (0.0 - 1.0).
final storageUsagePercentProvider = Provider<double>((ref) {
  final usage = ref.watch(storageUsageProvider);
  if (usage.limit == 0) return 0.0;
  return usage.used / usage.limit;
});
