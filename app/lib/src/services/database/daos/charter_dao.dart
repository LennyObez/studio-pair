import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'charter_dao.g.dart';

@DriftAccessor(tables: [CachedCharters])
class CharterDao extends DatabaseAccessor<AppDatabase> with _$CharterDaoMixin {
  CharterDao(super.db);

  /// Inserts or updates a cached charter.
  Future<void> upsertCharter(CachedChartersCompanion charter) {
    try {
      return into(cachedCharters).insertOnConflictUpdate(charter);
    } catch (e) {
      throw StorageFailure('Failed to upsert charter: $e');
    }
  }

  /// Retrieves the latest charter version for a space, or null if none exists.
  Future<CachedCharter?> getCharter(String spaceId) {
    try {
      return (select(cachedCharters)
            ..where((t) => t.spaceId.equals(spaceId))
            ..orderBy([(t) => OrderingTerm.desc(t.versionNumber)])
            ..limit(1))
          .getSingleOrNull();
    } catch (e) {
      throw StorageFailure('Failed to get charter: $e');
    }
  }

  /// Watches all charter versions for a space, ordered by version number descending.
  Stream<List<CachedCharter>> getVersions(String spaceId) {
    try {
      return (select(cachedCharters)
            ..where((t) => t.spaceId.equals(spaceId))
            ..orderBy([(t) => OrderingTerm.desc(t.versionNumber)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get charter versions: $e');
    }
  }

  /// Deletes a charter from the local cache.
  Future<int> deleteCharter(String id) {
    try {
      return (delete(cachedCharters)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete charter: $e');
    }
  }

  /// Batch upserts charters into cache.
  Future<void> upsertCharters(List<CachedChartersCompanion> charters) {
    try {
      return batch((b) {
        b.insertAll(cachedCharters, charters, mode: InsertMode.insertOrReplace);
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert charters: $e');
    }
  }
}
