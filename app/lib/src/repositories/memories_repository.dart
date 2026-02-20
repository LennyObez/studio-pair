import 'package:drift/drift.dart';
import 'package:studio_pair/src/services/api/memories_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/memories_dao.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Repository that wraps the Memories API and DAO to provide an
/// offline-first data layer with batch cache upserts.
class MemoriesRepository {
  MemoriesRepository(this._api, this._dao);

  final MemoriesApi _api;
  final MemoriesDao _dao;

  /// Returns cached memories, then fetches fresh from API and updates cache.
  Future<List<CachedMemory>> getMemories(String spaceId) async {
    try {
      final response = await _api.listMemories(spaceId);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedMemories,
          jsonList
              .map(
                (json) => CachedMemoriesCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  createdBy: json['created_by'] as String? ?? '',
                  title: json['title'] as String,
                  description: Value(json['description'] as String?),
                  photoUrls: Value(
                    json['photo_urls'] is String
                        ? json['photo_urls'] as String?
                        : json['photo_urls']?.toString(),
                  ),
                  memoryDate:
                      DateTime.tryParse(
                        json['date'] as String? ??
                            json['memory_date'] as String? ??
                            '',
                      ) ??
                      DateTime.now(),
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
      return _dao.getMemories(spaceId).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getMemories(spaceId).first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load memories: $e');
    }
  }

  /// Creates a new memory via the API.
  Future<Map<String, dynamic>> createMemory(
    String spaceId, {
    required String title,
    required String date,
    String? location,
    String? description,
    List<String>? mediaIds,
    String? linkedActivityId,
    bool? isMilestone,
    String? milestoneType,
  }) async {
    try {
      final response = await _api.createMemory(
        spaceId,
        title: title,
        date: date,
        location: location,
        description: description,
        mediaIds: mediaIds,
        linkedActivityId: linkedActivityId,
        isMilestone: isMilestone,
        milestoneType: milestoneType,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to create memory: $e');
    }
  }

  /// Gets a specific memory by ID, with cache fallback.
  Future<Map<String, dynamic>> getMemory(
    String spaceId,
    String memoryId,
  ) async {
    try {
      final response = await _api.getMemory(spaceId, memoryId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getMemoryById(memoryId);
      if (cached != null) return {'id': cached.id, 'title': cached.title};
      throw UnknownFailure('Failed to get memory: $e');
    }
  }

  /// Updates a memory via the API.
  Future<Map<String, dynamic>> updateMemory(
    String spaceId,
    String memoryId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _api.updateMemory(spaceId, memoryId, data);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update memory: $e');
    }
  }

  /// Deletes a memory via the API and removes from cache.
  Future<void> deleteMemory(String spaceId, String memoryId) async {
    try {
      await _api.deleteMemory(spaceId, memoryId);
      await _dao.deleteMemory(memoryId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete memory: $e');
    }
  }

  /// Gets memories from this day in previous years.
  Future<List<Map<String, dynamic>>> getOnThisDay(String spaceId) async {
    try {
      final response = await _api.getOnThisDay(spaceId);
      return _parseList(response.data);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get on-this-day memories: $e');
    }
  }

  /// Gets all milestone memories, with cache fallback.
  Future<List<CachedMemory>> getMilestones(String spaceId) async {
    try {
      final response = await _api.getMilestones(spaceId);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedMemories,
          jsonList
              .map(
                (json) => CachedMemoriesCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  createdBy: json['created_by'] as String? ?? '',
                  title: json['title'] as String,
                  description: Value(json['description'] as String?),
                  photoUrls: Value(
                    json['photo_urls'] is String
                        ? json['photo_urls'] as String?
                        : json['photo_urls']?.toString(),
                  ),
                  memoryDate:
                      DateTime.tryParse(
                        json['date'] as String? ??
                            json['memory_date'] as String? ??
                            '',
                      ) ??
                      DateTime.now(),
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
      return _dao.getMilestones(spaceId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getMilestones(spaceId);
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to get milestones: $e');
    }
  }

  /// Watches cached memories for a space (reactive stream).
  Stream<List<CachedMemory>> watchMemories(String spaceId) {
    return _dao.getMemories(spaceId);
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
