import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'polls_dao.g.dart';

@DriftAccessor(tables: [CachedPolls])
class PollsDao extends DatabaseAccessor<AppDatabase> with _$PollsDaoMixin {
  PollsDao(super.db);

  /// Inserts or updates a cached poll.
  Future<void> upsertPoll(CachedPollsCompanion poll) {
    try {
      return into(cachedPolls).insertOnConflictUpdate(poll);
    } catch (e) {
      throw StorageFailure('Failed to upsert poll: $e');
    }
  }

  /// Watches polls for a given space with an optional active filter,
  /// ordered by most recently created.
  Stream<List<CachedPoll>> getPolls(String spaceId, {bool? isActive}) {
    try {
      return (select(cachedPolls)
            ..where((t) {
              var condition = t.spaceId.equals(spaceId);
              if (isActive != null) {
                condition = condition & t.isActive.equals(isActive);
              }
              return condition;
            })
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get polls: $e');
    }
  }

  /// Retrieves a single poll by its ID, or null if not found.
  Future<CachedPoll?> getPollById(String id) {
    try {
      return (select(
        cachedPolls,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      throw StorageFailure('Failed to get poll by id: $e');
    }
  }

  /// Deletes a poll from the local cache.
  Future<int> deletePoll(String id) {
    try {
      return (delete(cachedPolls)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete poll: $e');
    }
  }

  /// Batch upserts polls into cache.
  Future<void> upsertPolls(List<CachedPollsCompanion> polls) {
    try {
      return batch((b) {
        b.insertAll(cachedPolls, polls, mode: InsertMode.insertOrReplace);
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert polls: $e');
    }
  }
}
