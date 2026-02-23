import 'package:drift/drift.dart';
import '../app_database.dart';

part 'activities_dao.g.dart';

@DriftAccessor(tables: [CachedActivities, CachedActivityVotes])
class ActivitiesDao extends DatabaseAccessor<AppDatabase>
    with _$ActivitiesDaoMixin {
  ActivitiesDao(super.db);

  /// Inserts or updates a cached activity.
  Future<void> upsertActivity(CachedActivitiesCompanion activity) {
    return into(cachedActivities).insertOnConflictUpdate(activity);
  }

  /// Watches all activities for a given space, ordered by most recently updated.
  Stream<List<CachedActivity>> getActivities(String spaceId) {
    return (select(cachedActivities)
          ..where((t) => t.spaceId.equals(spaceId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// Retrieves a single activity by its ID, or null if not found.
  Future<CachedActivity?> getActivityById(String id) {
    return (select(
      cachedActivities,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Deletes an activity from the local cache.
  Future<int> deleteActivity(String id) {
    return (delete(cachedActivities)..where((t) => t.id.equals(id))).go();
  }

  /// Searches activities by title or description within a space.
  Future<List<CachedActivity>> searchActivities(String query, String spaceId) {
    final pattern = '%$query%';
    return (select(cachedActivities)
          ..where(
            (t) =>
                t.spaceId.equals(spaceId) &
                (t.title.like(pattern) | t.description.like(pattern)),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  /// Retrieves all activities of a specific category within a space.
  Future<List<CachedActivity>> getActivitiesByCategory(
    String category,
    String spaceId,
  ) {
    return (select(cachedActivities)
          ..where(
            (t) => t.spaceId.equals(spaceId) & t.category.equals(category),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  /// Inserts or updates a vote on an activity.
  Future<void> upsertVote(CachedActivityVotesCompanion vote) {
    return into(cachedActivityVotes).insertOnConflictUpdate(vote);
  }

  /// Gets all votes for a specific activity.
  Future<List<CachedActivityVote>> getVotesForActivity(String activityId) {
    return (select(
      cachedActivityVotes,
    )..where((t) => t.activityId.equals(activityId))).get();
  }

  /// Deletes a vote from the local cache.
  Future<int> deleteVote(String id) {
    return (delete(cachedActivityVotes)..where((t) => t.id.equals(id))).go();
  }
}
