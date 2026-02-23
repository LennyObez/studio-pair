import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Location API service for managing location sharing within a space.
class LocationApi {
  LocationApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Start sharing location.
  Future<Response> startSharing(
    String spaceId, {
    required double latitude,
    required double longitude,
    int? duration,
    String? type,
  }) {
    return _client.post(
      '/spaces/$spaceId/location/share',
      data: {
        'latitude': latitude,
        'longitude': longitude,
        if (duration != null) 'duration': duration,
        if (type != null) 'type': type,
      },
    );
  }

  /// Update a live location share.
  Future<Response> updateLocation(
    String spaceId,
    String shareId,
    double lat,
    double lng,
  ) {
    return _client.put(
      '/spaces/$spaceId/location/share/$shareId',
      data: {'latitude': lat, 'longitude': lng},
    );
  }

  /// Stop sharing location.
  Future<Response> stopSharing(String spaceId, String shareId) {
    return _client.delete('/spaces/$spaceId/location/share/$shareId');
  }

  /// Get all active location shares in the space.
  Future<Response> getActiveShares(String spaceId) {
    return _client.get('/spaces/$spaceId/location/shares');
  }

  /// Send a safe ping with current location.
  Future<Response> sendSafePing(String spaceId, double lat, double lng) {
    return _client.post(
      '/spaces/$spaceId/location/safe-ping',
      data: {'latitude': lat, 'longitude': lng},
    );
  }

  /// Share estimated time of arrival.
  Future<Response> shareETA(
    String spaceId, {
    required double latitude,
    required double longitude,
    required String destination,
    required double destinationLat,
    required double destinationLng,
    required int estimatedMinutes,
  }) {
    return _client.post(
      '/spaces/$spaceId/location/eta',
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'destination': destination,
        'destination_lat': destinationLat,
        'destination_lng': destinationLng,
        'estimated_minutes': estimatedMinutes,
      },
    );
  }
}
