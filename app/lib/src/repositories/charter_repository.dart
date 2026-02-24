import 'package:drift/drift.dart';
import 'package:studio_pair/src/services/api/charter_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/charter_dao.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Repository that wraps the Charter API and DAO to provide an
/// offline-first data layer with batch cache upserts.
class CharterRepository {
  CharterRepository(this._api, this._dao);

  final CharterApi _api;
  final CharterDao _dao;

  /// Returns the cached charter, then fetches fresh from API and updates cache.
  Future<CachedCharter?> getCharter(String spaceId) async {
    try {
      final response = await _api.getCharter(spaceId);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        await _dao.db.batch((b) {
          b.insert(
            _dao.cachedCharters,
            CachedChartersCompanion.insert(
              id: data['id'] as String,
              spaceId: data['space_id'] as String? ?? spaceId,
              content: data['content'] as String? ?? '',
              editedBy: data['edited_by'] as String? ?? '',
              createdAt:
                  DateTime.tryParse(data['created_at'] as String? ?? '') ??
                  DateTime.now(),
              updatedAt:
                  DateTime.tryParse(data['updated_at'] as String? ?? '') ??
                  DateTime.now(),
              syncedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrReplace,
          );
        });
      }
      return _dao.getCharter(spaceId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getCharter(spaceId);
      if (cached != null) return cached;
      throw UnknownFailure('Failed to load charter: $e');
    }
  }

  /// Updates the charter content via the API.
  Future<Map<String, dynamic>> updateCharter(
    String spaceId,
    String content,
  ) async {
    try {
      final response = await _api.updateCharter(spaceId, content);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update charter: $e');
    }
  }

  /// Gets all charter versions, with cache fallback.
  Future<List<CachedCharter>> getVersions(String spaceId) async {
    try {
      final response = await _api.getVersions(spaceId);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedCharters,
          jsonList
              .map(
                (json) => CachedChartersCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  content: json['content'] as String? ?? '',
                  editedBy: json['edited_by'] as String? ?? '',
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
      return _dao.getVersions(spaceId).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getVersions(spaceId).first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load charter versions: $e');
    }
  }

  /// Gets a specific charter version by ID.
  Future<Map<String, dynamic>> getVersion(
    String spaceId,
    String versionId,
  ) async {
    try {
      final response = await _api.getVersion(spaceId, versionId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get charter version: $e');
    }
  }

  /// Acknowledges the current charter.
  Future<Map<String, dynamic>> acknowledgeCharter(String spaceId) async {
    try {
      final response = await _api.acknowledgeCharter(spaceId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to acknowledge charter: $e');
    }
  }

  /// Watches cached charter versions for a space (reactive stream).
  Stream<List<CachedCharter>> watchVersions(String spaceId) {
    return _dao.getVersions(spaceId);
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
