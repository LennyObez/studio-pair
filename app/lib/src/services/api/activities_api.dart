import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Activities API service for managing activities within a space.
class ActivitiesApi {
  ActivitiesApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Create a new activity.
  Future<Response> createActivity(
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
  }) {
    return _client.post(
      '/spaces/$spaceId/activities/',
      data: {
        'title': title,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
        if (trailerUrl != null) 'trailer_url': trailerUrl,
        if (externalId != null) 'external_id': externalId,
        if (externalSource != null) 'external_source': externalSource,
        if (privacy != null) 'privacy': privacy,
        if (mode != null) 'mode': mode,
        if (metadata != null) 'metadata': metadata,
      },
    );
  }

  /// List activities with optional filters.
  Future<Response> listActivities(
    String spaceId, {
    String? category,
    String? status,
    String? privacy,
    String? mode,
    String? createdBy,
    String? cursor,
    int? limit,
  }) {
    return _client.get(
      '/spaces/$spaceId/activities/',
      queryParameters: {
        if (category != null) 'category': category,
        if (status != null) 'status': status,
        if (privacy != null) 'privacy': privacy,
        if (mode != null) 'mode': mode,
        if (createdBy != null) 'created_by': createdBy,
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
  }

  /// Get a specific activity by ID.
  Future<Response> getActivity(String spaceId, String activityId) {
    return _client.get('/spaces/$spaceId/activities/$activityId');
  }

  /// Update an existing activity.
  Future<Response> updateActivity(
    String spaceId,
    String activityId,
    Map<String, dynamic> data,
  ) {
    return _client.patch('/spaces/$spaceId/activities/$activityId', data: data);
  }

  /// Delete an activity (soft delete).
  Future<Response> deleteActivity(String spaceId, String activityId) {
    return _client.delete('/spaces/$spaceId/activities/$activityId');
  }

  /// Restore a soft-deleted activity.
  Future<Response> restoreActivity(String spaceId, String activityId) {
    return _client.post('/spaces/$spaceId/activities/$activityId/restore');
  }

  /// Vote on an activity.
  Future<Response> vote(String spaceId, String activityId, int score) {
    return _client.post(
      '/spaces/$spaceId/activities/$activityId/vote',
      data: {'score': score},
    );
  }

  /// Remove a vote from an activity.
  Future<Response> removeVote(String spaceId, String activityId) {
    return _client.delete('/spaces/$spaceId/activities/$activityId/vote');
  }

  /// Get all votes for an activity.
  Future<Response> getVotes(String spaceId, String activityId) {
    return _client.get('/spaces/$spaceId/activities/$activityId/votes');
  }

  /// Mark an activity as complete.
  Future<Response> completeActivity(
    String spaceId,
    String activityId, {
    String? notes,
  }) {
    return _client.post(
      '/spaces/$spaceId/activities/$activityId/complete',
      data: {if (notes != null) 'notes': notes},
    );
  }

  /// Search activities by query string.
  Future<Response> searchActivities(String spaceId, String query) {
    return _client.get(
      '/spaces/$spaceId/activities/search',
      queryParameters: {'q': query},
    );
  }

  /// Get completed activities with optional pagination.
  Future<Response> getCompletedActivities(
    String spaceId, {
    String? cursor,
    int? limit,
  }) {
    return _client.get(
      '/spaces/$spaceId/activities/completed',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
  }

  /// Get activity statistics for the space.
  Future<Response> getStats(String spaceId) {
    return _client.get('/spaces/$spaceId/activities/stats');
  }

  /// Get activities organized by column for a specific user.
  Future<Response> getActivitiesByColumn(String spaceId, String userId) {
    return _client.get('/spaces/$spaceId/activities/columns/$userId');
  }
}
