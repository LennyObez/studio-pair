import 'package:drift/drift.dart';
import '../app_database.dart';

part 'charter_dao.g.dart';

@DriftAccessor(tables: [CachedCharters])
class CharterDao extends DatabaseAccessor<AppDatabase> with _$CharterDaoMixin {
  CharterDao(super.db);

  /// Inserts or updates a cached charter.
  Future<void> upsertCharter(CachedChartersCompanion charter) {
    return into(cachedCharters).insertOnConflictUpdate(charter);
  }

  /// Retrieves the latest charter version for a space, or null if none exists.
  Future<CachedCharter?> getCharter(String spaceId) {
    return (select(cachedCharters)
          ..where((t) => t.spaceId.equals(spaceId))
          ..orderBy([(t) => OrderingTerm.desc(t.versionNumber)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Watches all charter versions for a space, ordered by version number descending.
  Stream<List<CachedCharter>> getVersions(String spaceId) {
    return (select(cachedCharters)
          ..where((t) => t.spaceId.equals(spaceId))
          ..orderBy([(t) => OrderingTerm.desc(t.versionNumber)]))
        .watch();
  }

  /// Deletes a charter from the local cache.
  Future<int> deleteCharter(String id) {
    return (delete(cachedCharters)..where((t) => t.id.equals(id))).go();
  }
}
