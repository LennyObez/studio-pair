import 'package:drift/drift.dart';
import 'package:studio_pair/src/services/api/polls_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/polls_dao.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Repository that wraps the Polls API and DAO to provide an
/// offline-first data layer with batch cache upserts.
class PollsRepository {
  PollsRepository(this._api, this._dao);

  final PollsApi _api;
  final PollsDao _dao;

  /// Returns cached polls, then fetches fresh from API and updates cache.
  Future<List<CachedPoll>> getPolls(String spaceId, {bool? isActive}) async {
    try {
      final response = await _api.listPolls(spaceId, active: isActive);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedPolls,
          jsonList
              .map(
                (json) => CachedPollsCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  createdBy: json['created_by'] as String? ?? '',
                  question: json['question'] as String,
                  options: json['options'] is String
                      ? json['options'] as String
                      : json['options'].toString(),
                  votes: Value(
                    json['votes'] is String
                        ? json['votes'] as String?
                        : json['votes']?.toString(),
                  ),
                  expiresAt: Value(
                    DateTime.tryParse(json['expires_at'] as String? ?? ''),
                  ),
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
      return _dao.getPolls(spaceId, isActive: isActive).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getPolls(spaceId, isActive: isActive).first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load polls: $e');
    }
  }

  /// Creates a new poll via the API.
  Future<Map<String, dynamic>> createPoll(
    String spaceId, {
    required String question,
    required String type,
    required List<Map<String, dynamic>> options,
    bool? isAnonymous,
    String? deadline,
  }) async {
    try {
      final response = await _api.createPoll(
        spaceId,
        question: question,
        type: type,
        options: options,
        isAnonymous: isAnonymous,
        deadline: deadline,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to create poll: $e');
    }
  }

  /// Gets a specific poll by ID, with cache fallback.
  Future<Map<String, dynamic>> getPoll(String spaceId, String pollId) async {
    try {
      final response = await _api.getPoll(spaceId, pollId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getPollById(pollId);
      if (cached != null) return {'id': cached.id, 'question': cached.question};
      throw UnknownFailure('Failed to get poll: $e');
    }
  }

  /// Closes a poll so no more votes can be cast.
  Future<Map<String, dynamic>> closePoll(String spaceId, String pollId) async {
    try {
      final response = await _api.closePoll(spaceId, pollId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to close poll: $e');
    }
  }

  /// Deletes a poll via the API and removes from cache.
  Future<void> deletePoll(String spaceId, String pollId) async {
    try {
      await _api.deletePoll(spaceId, pollId);
      await _dao.deletePoll(pollId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete poll: $e');
    }
  }

  /// Casts a vote on a poll.
  Future<Map<String, dynamic>> vote(
    String spaceId,
    String pollId,
    List<String> optionIds, {
    Map<String, int>? ranks,
  }) async {
    try {
      final response = await _api.vote(
        spaceId,
        pollId,
        optionIds,
        ranks: ranks,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to vote on poll: $e');
    }
  }

  /// Removes a vote from a poll.
  Future<void> removeVote(String spaceId, String pollId) async {
    try {
      await _api.removeVote(spaceId, pollId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to remove vote: $e');
    }
  }

  /// Gets the results of a poll.
  Future<Map<String, dynamic>> getResults(String spaceId, String pollId) async {
    try {
      final response = await _api.getResults(spaceId, pollId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get poll results: $e');
    }
  }

  /// Picks a random option from a poll.
  Future<Map<String, dynamic>> randomPick(String spaceId, String pollId) async {
    try {
      final response = await _api.randomPick(spaceId, pollId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to pick random option: $e');
    }
  }

  /// Watches cached polls for a space (reactive stream).
  Stream<List<CachedPoll>> watchPolls(String spaceId, {bool? isActive}) {
    return _dao.getPolls(spaceId, isActive: isActive);
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
