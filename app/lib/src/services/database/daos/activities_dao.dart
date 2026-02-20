import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'activities_dao.g.dart';

@DriftAccessor(tables: [CachedActivities, CachedActivityVotes])
class ActivitiesDao extends DatabaseAccessor<AppDatabase>
    with _$ActivitiesDaoMixin {
  ActivitiesDao(super.db);

  /// Inserts or updates a cached activity.
  Future<void> upsertActivity(CachedActivitiesCompanion activity) {
    try {
      return into(cachedActivities).insertOnConflictUpdate(activity);
    } catch (e) {
      throw StorageFailure('Failed to upsert activity: $e');
    }
  }

  /// Watches all activities for a given space, ordered by most recently updated.
  Stream<List<CachedActivity>> getActivities(String spaceId) {
    try {
      return (select(cachedActivities)
            ..where((t) => t.spaceId.equals(spaceId))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get activities: $e');
    }
  }

  /// Retrieves a single activity by its ID, or null if not found.
  Future<CachedActivity?> getActivityById(String id) {
    try {
      return (select(
        cachedActivities,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      throw StorageFailure('Failed to get activity by id: $e');
    }
  }

  /// Deletes an activity from the local cache.
  Future<int> deleteActivity(String id) {
    try {
      return (delete(cachedActivities)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete activity: $e');
    }
  }

  /// Searches activities by title or description within a space.
  Future<List<CachedActivity>> searchActivities(String query, String spaceId) {
    try {
      final pattern = '%$query%';
      return (select(cachedActivities)
            ..where(
              (t) =>
                  t.spaceId.equals(spaceId) &
                  (t.title.like(pattern) | t.description.like(pattern)),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();
    } catch (e) {
      throw StorageFailure('Failed to search activities: $e');
    }
  }

  /// Retrieves all activities of a specific category within a space.
  Future<List<CachedActivity>> getActivitiesByCategory(
    String category,
    String spaceId,
  ) {
    try {
      return (select(cachedActivities)
            ..where(
              (t) => t.spaceId.equals(spaceId) & t.category.equals(category),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();
    } catch (e) {
      throw StorageFailure('Failed to get activities by category: $e');
    }
  }

  /// Inserts or updates a vote on an activity.
  Future<void> upsertVote(CachedActivityVotesCompanion vote) {
    try {
      return into(cachedActivityVotes).insertOnConflictUpdate(vote);
    } catch (e) {
      throw StorageFailure('Failed to upsert vote: $e');
    }
  }

  /// Gets all votes for a specific activity.
  Future<List<CachedActivityVote>> getVotesForActivity(String activityId) {
    try {
      return (select(
        cachedActivityVotes,
      )..where((t) => t.activityId.equals(activityId))).get();
    } catch (e) {
      throw StorageFailure('Failed to get votes for activity: $e');
    }
  }

  /// Deletes a vote from the local cache.
  Future<int> deleteVote(String id) {
    try {
      return (delete(cachedActivityVotes)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete vote: $e');
    }
  }

  /// Batch upserts activities into cache.
  Future<void> upsertActivities(List<CachedActivitiesCompanion> activities) {
    try {
      return batch((b) {
        b.insertAll(
          cachedActivities,
          activities,
          mode: InsertMode.insertOrReplace,
        );
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert activities: $e');
    }
  }

  /// Batch upserts activity votes into cache.
  Future<void> upsertVotes(List<CachedActivityVotesCompanion> votes) {
    try {
      return batch((b) {
        b.insertAll(
          cachedActivityVotes,
          votes,
          mode: InsertMode.insertOrReplace,
        );
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert votes: $e');
    }
  }
}
