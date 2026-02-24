import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'finances_dao.g.dart';

@DriftAccessor(tables: [CachedFinanceEntries])
class FinancesDao extends DatabaseAccessor<AppDatabase>
    with _$FinancesDaoMixin {
  FinancesDao(super.db);

  /// Inserts or updates a cached finance entry.
  Future<void> upsertEntry(CachedFinanceEntriesCompanion entry) {
    try {
      return into(cachedFinanceEntries).insertOnConflictUpdate(entry);
    } catch (e) {
      throw StorageFailure('Failed to upsert finance entry: $e');
    }
  }

  /// Watches finance entries for a given space with an optional type filter,
  /// ordered by date descending.
  Stream<List<CachedFinanceEntry>> getEntries(String spaceId, {String? type}) {
    try {
      return (select(cachedFinanceEntries)
            ..where((t) {
              var condition = t.spaceId.equals(spaceId);
              if (type != null) {
                condition = condition & t.type.equals(type);
              }
              return condition;
            })
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get finance entries: $e');
    }
  }

  /// Retrieves a single finance entry by its ID, or null if not found.
  Future<CachedFinanceEntry?> getEntryById(String id) {
    try {
      return (select(
        cachedFinanceEntries,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      throw StorageFailure('Failed to get finance entry by id: $e');
    }
  }

  /// Deletes a finance entry from the local cache.
  Future<int> deleteEntry(String id) {
    try {
      return (delete(cachedFinanceEntries)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete finance entry: $e');
    }
  }

  /// Batch upserts finance entries into cache.
  Future<void> upsertEntries(List<CachedFinanceEntriesCompanion> entries) {
    try {
      return batch((b) {
        b.insertAll(
          cachedFinanceEntries,
          entries,
          mode: InsertMode.insertOrReplace,
        );
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert finance entries: $e');
    }
  }
}
