import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'files_dao.g.dart';

@DriftAccessor(tables: [CachedFiles])
class FilesDao extends DatabaseAccessor<AppDatabase> with _$FilesDaoMixin {
  FilesDao(super.db);

  /// Inserts or updates a cached file.
  Future<void> upsertFile(CachedFilesCompanion file) {
    try {
      return into(cachedFiles).insertOnConflictUpdate(file);
    } catch (e) {
      throw StorageFailure('Failed to upsert file: $e');
    }
  }

  /// Watches files for a given space with an optional folder filter,
  /// ordered by most recently created.
  Stream<List<CachedFile>> getFiles(String spaceId, {String? folderId}) {
    try {
      return (select(cachedFiles)
            ..where((t) {
              var condition = t.spaceId.equals(spaceId);
              if (folderId != null) {
                condition = condition & t.folderId.equals(folderId);
              }
              return condition;
            })
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get files: $e');
    }
  }

  /// Retrieves a single file by its ID, or null if not found.
  Future<CachedFile?> getFileById(String id) {
    try {
      return (select(
        cachedFiles,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      throw StorageFailure('Failed to get file by id: $e');
    }
  }

  /// Deletes a file from the local cache.
  Future<int> deleteFile(String id) {
    try {
      return (delete(cachedFiles)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete file: $e');
    }
  }

  /// Batch upserts files into cache.
  Future<void> upsertFiles(List<CachedFilesCompanion> files) {
    try {
      return batch((b) {
        b.insertAll(cachedFiles, files, mode: InsertMode.insertOrReplace);
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert files: $e');
    }
  }
}
