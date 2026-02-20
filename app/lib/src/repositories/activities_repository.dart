import 'package:drift/drift.dart';
import 'package:studio_pair/src/services/api/activities_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/activities_dao.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Repository that wraps the Activities API and DAO to provide an
/// offline-first data layer with batch cache upserts.
class ActivitiesRepository {
  ActivitiesRepository(this._api, this._dao);

  final ActivitiesApi _api;
  final ActivitiesDao _dao;

  /// Returns cached activities, then fetches fresh from API and updates cache.
  Future<List<CachedActivity>> getActivities(String spaceId) async {
    try {
      final response = await _api.listActivities(spaceId);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedActivities,
          jsonList
              .map(
                (json) => CachedActivitiesCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  createdBy: json['created_by'] as String? ?? '',
                  title: json['title'] as String,
                  description: Value(json['description'] as String?),
                  category: json['category'] as String? ?? '',
                  thumbnailUrl: Value(json['thumbnail_url'] as String?),
                  trailerUrl: Value(json['trailer_url'] as String?),
                  privacy: json['privacy'] as String? ?? 'shared',
                  status: json['status'] as String? ?? 'active',
                  mode: json['mode'] as String? ?? 'unlinked',
                  createdAt:
                      DateTime.tryParse(json['created_at'] as String? ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(json['updated_at'] as String? ?? '') ??
                      DateTime.now(),
                  syncedAt: DateTime.now(),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
      return _dao.getActivities(spaceId).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getActivities(spaceId).first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load activities: $e');
    }
  }

  /// Creates a new activity via the API.
  Future<Map<String, dynamic>> createActivity(
    String spaceId, {
    required String title,
    String? description,
    String? category,
    String? thumbnailUrl,
    String? trailerUrl,
    String? externalId,
    String? externalSource,
    String? privacy,
    String? mode,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _api.createActivity(
        spaceId,
        title: title,
        description: description,
        category: category,
        thumbnailUrl: thumbnailUrl,
        trailerUrl: trailerUrl,
        externalId: externalId,
        externalSource: externalSource,
        privacy: privacy,
        mode: mode,
        metadata: metadata,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to create activity: $e');
    }
  }

  /// Gets a specific activity by ID, with cache fallback.
  Future<Map<String, dynamic>> getActivity(
    String spaceId,
    String activityId,
  ) async {
    try {
      final response = await _api.getActivity(spaceId, activityId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getActivityById(activityId);
      if (cached != null) return {'id': cached.id, 'title': cached.title};
      throw UnknownFailure('Failed to get activity: $e');
    }
  }

  /// Updates an activity via the API.
  Future<Map<String, dynamic>> updateActivity(
    String spaceId,
    String activityId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _api.updateActivity(spaceId, activityId, data);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update activity: $e');
    }
  }

  /// Deletes an activity via the API and removes from cache.
  Future<void> deleteActivity(String spaceId, String activityId) async {
    try {
      await _api.deleteActivity(spaceId, activityId);
      await _dao.deleteActivity(activityId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete activity: $e');
    }
  }

  /// Restores a soft-deleted activity.
  Future<Map<String, dynamic>> restoreActivity(
    String spaceId,
    String activityId,
  ) async {
    try {
      final response = await _api.restoreActivity(spaceId, activityId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to restore activity: $e');
    }
  }

  /// Votes on an activity.
  Future<Map<String, dynamic>> vote(
    String spaceId,
    String activityId,
    int score,
  ) async {
    try {
      final response = await _api.vote(spaceId, activityId, score);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to vote on activity: $e');
    }
  }

  /// Removes a vote from an activity.
  Future<void> removeVote(String spaceId, String activityId) async {
    try {
      await _api.removeVote(spaceId, activityId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to remove vote: $e');
    }
  }

  /// Gets all votes for an activity.
  Future<List<Map<String, dynamic>>> getVotes(
    String spaceId,
    String activityId,
  ) async {
    try {
      final response = await _api.getVotes(spaceId, activityId);
      return _parseList(response.data);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get votes: $e');
    }
  }

  /// Marks an activity as complete.
  Future<Map<String, dynamic>> completeActivity(
    String spaceId,
    String activityId, {
    String? notes,
  }) async {
    try {
      final response = await _api.completeActivity(
        spaceId,
        activityId,
        notes: notes,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to complete activity: $e');
    }
  }

  /// Searches activities by query string.
  Future<List<CachedActivity>> searchActivities(
    String spaceId,
    String query,
  ) async {
    try {
      final response = await _api.searchActivities(spaceId, query);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedActivities,
          jsonList
              .map(
                (json) => CachedActivitiesCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  createdBy: json['created_by'] as String? ?? '',
                  title: json['title'] as String,
                  description: Value(json['description'] as String?),
                  category: json['category'] as String? ?? '',
                  thumbnailUrl: Value(json['thumbnail_url'] as String?),
                  trailerUrl: Value(json['trailer_url'] as String?),
                  privacy: json['privacy'] as String? ?? 'shared',
                  status: json['status'] as String? ?? 'active',
                  mode: json['mode'] as String? ?? 'unlinked',
                  createdAt:
                      DateTime.tryParse(json['created_at'] as String? ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(json['updated_at'] as String? ?? '') ??
                      DateTime.now(),
                  syncedAt: DateTime.now(),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
      return _dao.searchActivities(query, spaceId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.searchActivities(query, spaceId);
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to search activities: $e');
    }
  }

  /// Gets completed activities with optional pagination.
  Future<List<Map<String, dynamic>>> getCompletedActivities(
    String spaceId, {
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _api.getCompletedActivities(
        spaceId,
        cursor: cursor,
        limit: limit,
      );
      return _parseList(response.data);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get completed activities: $e');
    }
  }

  /// Gets activity statistics for the space.
  Future<Map<String, dynamic>> getStats(String spaceId) async {
    try {
      final response = await _api.getStats(spaceId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get activity stats: $e');
    }
  }

  /// Gets activities organized by column for a specific user.
  Future<Map<String, dynamic>> getActivitiesByColumn(
    String spaceId,
    String userId,
  ) async {
    try {
      final response = await _api.getActivitiesByColumn(spaceId, userId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get activities by column: $e');
    }
  }

  /// Watches cached activities for a space (reactive stream).
  Stream<List<CachedActivity>> watchActivities(String spaceId) {
    return _dao.getActivities(spaceId);
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
