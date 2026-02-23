import 'package:drift/drift.dart';
import '../app_database.dart';

part 'files_dao.g.dart';

@DriftAccessor(tables: [CachedFiles])
class FilesDao extends DatabaseAccessor<AppDatabase> with _$FilesDaoMixin {
  FilesDao(super.db);

  /// Inserts or updates a cached file.
  Future<void> upsertFile(CachedFilesCompanion file) {
    return into(cachedFiles).insertOnConflictUpdate(file);
  }

  /// Watches files for a given space with an optional folder filter,
  /// ordered by most recently created.
  Stream<List<CachedFile>> getFiles(String spaceId, {String? folderId}) {
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
  }

  /// Retrieves a single file by its ID, or null if not found.
  Future<CachedFile?> getFileById(String id) {
    return (select(
      cachedFiles,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Deletes a file from the local cache.
  Future<int> deleteFile(String id) {
    return (delete(cachedFiles)..where((t) => t.id.equals(id))).go();
  }
}
