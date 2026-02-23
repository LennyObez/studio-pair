import 'package:drift/drift.dart';
import '../app_database.dart';

part 'finances_dao.g.dart';

@DriftAccessor(tables: [CachedFinanceEntries])
class FinancesDao extends DatabaseAccessor<AppDatabase>
    with _$FinancesDaoMixin {
  FinancesDao(super.db);

  /// Inserts or updates a cached finance entry.
  Future<void> upsertEntry(CachedFinanceEntriesCompanion entry) {
    return into(cachedFinanceEntries).insertOnConflictUpdate(entry);
  }

  /// Watches finance entries for a given space with an optional type filter,
  /// ordered by date descending.
  Stream<List<CachedFinanceEntry>> getEntries(String spaceId, {String? type}) {
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
  }

  /// Retrieves a single finance entry by its ID, or null if not found.
  Future<CachedFinanceEntry?> getEntryById(String id) {
    return (select(
      cachedFinanceEntries,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Deletes a finance entry from the local cache.
  Future<int> deleteEntry(String id) {
    return (delete(cachedFinanceEntries)..where((t) => t.id.equals(id))).go();
  }
}
