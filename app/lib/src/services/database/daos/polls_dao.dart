import 'package:drift/drift.dart';
import '../app_database.dart';

part 'polls_dao.g.dart';

@DriftAccessor(tables: [CachedPolls])
class PollsDao extends DatabaseAccessor<AppDatabase> with _$PollsDaoMixin {
  PollsDao(super.db);

  /// Inserts or updates a cached poll.
  Future<void> upsertPoll(CachedPollsCompanion poll) {
    return into(cachedPolls).insertOnConflictUpdate(poll);
  }

  /// Watches polls for a given space with an optional active filter,
  /// ordered by most recently created.
  Stream<List<CachedPoll>> getPolls(String spaceId, {bool? isActive}) {
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
  }

  /// Retrieves a single poll by its ID, or null if not found.
  Future<CachedPoll?> getPollById(String id) {
    return (select(
      cachedPolls,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Deletes a poll from the local cache.
  Future<int> deletePoll(String id) {
    return (delete(cachedPolls)..where((t) => t.id.equals(id))).go();
  }
}
