import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Vault API service for managing encrypted credential entries within a space.
class VaultApi {
  VaultApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Create a new vault entry.
  Future<Response> createEntry(
    String spaceId, {
    required String domain,
    required String label,
    required String encryptedBlob,
  }) {
    return _client.post(
      '/spaces/$spaceId/vault/entries',
      data: {'domain': domain, 'label': label, 'encrypted_blob': encryptedBlob},
    );
  }

  /// List vault entries with optional search filter.
  Future<Response> listEntries(String spaceId, {String? search}) {
    return _client.get(
      '/spaces/$spaceId/vault/entries',
      queryParameters: {if (search != null) 'search': search},
    );
  }

  /// Get a specific vault entry by ID.
  Future<Response> getEntry(String spaceId, String entryId) {
    return _client.get('/spaces/$spaceId/vault/entries/$entryId');
  }

  /// Update a vault entry.
  Future<Response> updateEntry(
    String spaceId,
    String entryId,
    Map<String, dynamic> data,
  ) {
    return _client.patch('/spaces/$spaceId/vault/entries/$entryId', data: data);
  }

  /// Delete a vault entry.
  Future<Response> deleteEntry(String spaceId, String entryId) {
    return _client.delete('/spaces/$spaceId/vault/entries/$entryId');
  }

  /// Share a vault entry with specific users.
  Future<Response> shareEntry(
    String spaceId,
    String entryId,
    List<String> userIds,
  ) {
    return _client.post(
      '/spaces/$spaceId/vault/entries/$entryId/share',
      data: {'user_ids': userIds},
    );
  }

  /// Remove a user's access to a shared vault entry.
  Future<Response> unshareEntry(String spaceId, String entryId, String userId) {
    return _client.delete(
      '/spaces/$spaceId/vault/entries/$entryId/share/$userId',
    );
  }
}
