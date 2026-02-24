import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Memories API service for creating and browsing shared memories within a space.
class MemoriesApi {
  MemoriesApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Create a new memory.
  Future<Response> createMemory(
    String spaceId, {
    required String title,
    required String date,
    String? location,
    String? description,
    List<String>? mediaIds,
    String? linkedActivityId,
    bool? isMilestone,
    String? milestoneType,
  }) {
    return _client.post(
      '/spaces/$spaceId/memories/',
      data: {
        'title': title,
        'date': date,
        if (location != null) 'location': location,
        if (description != null) 'description': description,
        if (mediaIds != null) 'media_ids': mediaIds,
        if (linkedActivityId != null) 'linked_activity_id': linkedActivityId,
        if (isMilestone != null) 'is_milestone': isMilestone,
        if (milestoneType != null) 'milestone_type': milestoneType,
      },
    );
  }

  /// List memories with optional date filters and pagination.
  Future<Response> listMemories(
    String spaceId, {
    String? year,
    String? month,
    String? cursor,
    int? limit,
  }) {
    return _client.get(
      '/spaces/$spaceId/memories/',
      queryParameters: {
        if (year != null) 'year': year,
        if (month != null) 'month': month,
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
  }

  /// Get a specific memory by ID.
  Future<Response> getMemory(String spaceId, String memoryId) {
    return _client.get('/spaces/$spaceId/memories/$memoryId');
  }

  /// Update a memory.
  Future<Response> updateMemory(
    String spaceId,
    String memoryId,
    Map<String, dynamic> data,
  ) {
    return _client.patch('/spaces/$spaceId/memories/$memoryId', data: data);
  }

  /// Delete a memory.
  Future<Response> deleteMemory(String spaceId, String memoryId) {
    return _client.delete('/spaces/$spaceId/memories/$memoryId');
  }

  /// Get memories from this day in previous years.
  Future<Response> getOnThisDay(String spaceId) {
    return _client.get('/spaces/$spaceId/memories/on-this-day');
  }

  /// Get all milestone memories.
  Future<Response> getMilestones(String spaceId) {
    return _client.get('/spaces/$spaceId/memories/milestones');
  }
}
