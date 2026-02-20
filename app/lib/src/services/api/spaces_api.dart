import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Spaces API service for managing shared spaces.
class SpacesApi {
  SpacesApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Create a new space.
  Future<Response> createSpace({
    required String name,
    required String type,
    String? description,
    List<String>? enabledModules,
  }) {
    return _client.post(
      '/spaces',
      data: {
        'name': name,
        'type': type,
        if (description != null) 'description': description,
        if (enabledModules != null) 'enabledModules': enabledModules,
      },
    );
  }

  /// List all spaces the current user belongs to.
  Future<Response> listMySpaces() {
    return _client.get('/spaces');
  }

  /// Get a specific space by ID.
  Future<Response> getSpace(String spaceId) {
    return _client.get('/spaces/$spaceId');
  }

  /// Update a space.
  Future<Response> updateSpace(
    String spaceId, {
    String? name,
    String? description,
    List<String>? enabledModules,
  }) {
    return _client.patch(
      '/spaces/$spaceId',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (enabledModules != null) 'enabledModules': enabledModules,
      },
    );
  }

  /// Delete a space.
  Future<Response> deleteSpace(String spaceId) {
    return _client.delete('/spaces/$spaceId');
  }

  /// Generate an invite link or send invite to email.
  Future<Response> invite(String spaceId, {String? email, String? role}) {
    return _client.post(
      '/spaces/$spaceId/invite',
      data: {if (email != null) 'email': email, if (role != null) 'role': role},
    );
  }

  /// Join a space using an invite code.
  Future<Response> join({required String inviteCode}) {
    return _client.post('/spaces/join', data: {'inviteCode': inviteCode});
  }

  /// List members of a space.
  Future<Response> listMembers(String spaceId) {
    return _client.get('/spaces/$spaceId/members');
  }

  /// Update a member's role or settings.
  Future<Response> updateMember(
    String spaceId,
    String memberId, {
    required String role,
  }) {
    return _client.patch(
      '/spaces/$spaceId/members/$memberId',
      data: {'role': role},
    );
  }

  /// Remove a member from a space.
  Future<Response> removeMember(String spaceId, String memberId) {
    return _client.delete('/spaces/$spaceId/members/$memberId');
  }

  /// Leave a space.
  Future<Response> leave(String spaceId) {
    return _client.post('/spaces/$spaceId/leave');
  }
}
