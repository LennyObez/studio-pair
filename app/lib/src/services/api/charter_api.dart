import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Charter API service for managing the shared relationship charter within a space.
class CharterApi {
  CharterApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Get the current charter for a space.
  Future<Response> getCharter(String spaceId) {
    return _client.get('/spaces/$spaceId/charter/');
  }

  /// Update the charter content.
  Future<Response> updateCharter(String spaceId, String content) {
    return _client.put('/spaces/$spaceId/charter/', data: {'content': content});
  }

  /// Get all charter versions.
  Future<Response> getVersions(String spaceId) {
    return _client.get('/spaces/$spaceId/charter/versions');
  }

  /// Get a specific charter version by ID.
  Future<Response> getVersion(String spaceId, String versionId) {
    return _client.get('/spaces/$spaceId/charter/versions/$versionId');
  }

  /// Acknowledge the current charter.
  Future<Response> acknowledgeCharter(String spaceId) {
    return _client.post('/spaces/$spaceId/charter/acknowledge');
  }
}
