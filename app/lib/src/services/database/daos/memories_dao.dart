import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'memories_dao.g.dart';

@DriftAccessor(tables: [CachedMemories])
class MemoriesDao extends DatabaseAccessor<AppDatabase>
    with _$MemoriesDaoMixin {
  MemoriesDao(super.db);

  /// Inserts or updates a cached memory.
  Future<void> upsertMemory(CachedMemoriesCompanion memory) {
    try {
      return into(cachedMemories).insertOnConflictUpdate(memory);
    } catch (e) {
      throw StorageFailure('Failed to upsert memory: $e');
    }
  }

  /// Watches all memories for a given space, ordered by memory date descending.
  Stream<List<CachedMemory>> getMemories(String spaceId) {
    try {
      return (select(cachedMemories)
            ..where((t) => t.spaceId.equals(spaceId))
            ..orderBy([(t) => OrderingTerm.desc(t.memoryDate)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get memories: $e');
    }
  }

  /// Retrieves a single memory by its ID, or null if not found.
  Future<CachedMemory?> getMemoryById(String id) {
    try {
      return (select(
        cachedMemories,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      throw StorageFailure('Failed to get memory by id: $e');
    }
  }

  /// Retrieves all milestone memories for a space.
  Future<List<CachedMemory>> getMilestones(String spaceId) {
    try {
      return (select(cachedMemories)
            ..where(
              (t) => t.spaceId.equals(spaceId) & t.isMilestone.equals(true),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.memoryDate)]))
          .get();
    } catch (e) {
      throw StorageFailure('Failed to get milestones: $e');
    }
  }

  /// Deletes a memory from the local cache.
  Future<int> deleteMemory(String id) {
    try {
      return (delete(cachedMemories)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete memory: $e');
    }
  }

  /// Batch upserts memories into cache.
  Future<void> upsertMemories(List<CachedMemoriesCompanion> memories) {
    try {
      return batch((b) {
        b.insertAll(cachedMemories, memories, mode: InsertMode.insertOrReplace);
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert memories: $e');
    }
  }
}
