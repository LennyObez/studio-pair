import 'package:drift/drift.dart';
import '../app_database.dart';

part 'memories_dao.g.dart';

@DriftAccessor(tables: [CachedMemories])
class MemoriesDao extends DatabaseAccessor<AppDatabase>
    with _$MemoriesDaoMixin {
  MemoriesDao(super.db);

  /// Inserts or updates a cached memory.
  Future<void> upsertMemory(CachedMemoriesCompanion memory) {
    return into(cachedMemories).insertOnConflictUpdate(memory);
  }

  /// Watches all memories for a given space, ordered by memory date descending.
  Stream<List<CachedMemory>> getMemories(String spaceId) {
    return (select(cachedMemories)
          ..where((t) => t.spaceId.equals(spaceId))
          ..orderBy([(t) => OrderingTerm.desc(t.memoryDate)]))
        .watch();
  }

  /// Retrieves a single memory by its ID, or null if not found.
  Future<CachedMemory?> getMemoryById(String id) {
    return (select(
      cachedMemories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Retrieves all milestone memories for a space.
  Future<List<CachedMemory>> getMilestones(String spaceId) {
    return (select(cachedMemories)
          ..where((t) => t.spaceId.equals(spaceId) & t.isMilestone.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.memoryDate)]))
        .get();
  }

  /// Deletes a memory from the local cache.
  Future<int> deleteMemory(String id) {
    return (delete(cachedMemories)..where((t) => t.id.equals(id))).go();
  }
}
