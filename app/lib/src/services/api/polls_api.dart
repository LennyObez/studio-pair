import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Polls API service for creating and managing polls within a space.
class PollsApi {
  PollsApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Create a new poll.
  Future<Response> createPoll(
    String spaceId, {
    required String question,
    required String type,
    required List<Map<String, dynamic>> options,
    bool? isAnonymous,
    String? deadline,
  }) {
    return _client.post(
      '/spaces/$spaceId/polls/',
      data: {
        'question': question,
        'type': type,
        'options': options,
        if (isAnonymous != null) 'is_anonymous': isAnonymous,
        if (deadline != null) 'deadline': deadline,
      },
    );
  }

  /// List polls with optional filters and pagination.
  Future<Response> listPolls(
    String spaceId, {
    bool? active,
    String? cursor,
    int? limit,
  }) {
    return _client.get(
      '/spaces/$spaceId/polls/',
      queryParameters: {
        if (active != null) 'active': active,
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
  }

  /// Get a specific poll by ID.
  Future<Response> getPoll(String spaceId, String pollId) {
    return _client.get('/spaces/$spaceId/polls/$pollId');
  }

  /// Close a poll so no more votes can be cast.
  Future<Response> closePoll(String spaceId, String pollId) {
    return _client.post('/spaces/$spaceId/polls/$pollId/close');
  }

  /// Delete a poll.
  Future<Response> deletePoll(String spaceId, String pollId) {
    return _client.delete('/spaces/$spaceId/polls/$pollId');
  }

  /// Cast a vote on a poll.
  Future<Response> vote(
    String spaceId,
    String pollId,
    List<String> optionIds, {
    Map<String, int>? ranks,
  }) {
    return _client.post(
      '/spaces/$spaceId/polls/$pollId/vote',
      data: {'option_ids': optionIds, if (ranks != null) 'ranks': ranks},
    );
  }

  /// Remove your vote from a poll.
  Future<Response> removeVote(String spaceId, String pollId) {
    return _client.delete('/spaces/$spaceId/polls/$pollId/vote');
  }

  /// Get the results of a poll.
  Future<Response> getResults(String spaceId, String pollId) {
    return _client.get('/spaces/$spaceId/polls/$pollId/results');
  }

  /// Pick a random option from a poll.
  Future<Response> randomPick(String spaceId, String pollId) {
    return _client.post('/spaces/$spaceId/polls/$pollId/random');
  }
}
