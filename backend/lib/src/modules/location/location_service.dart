import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../services/notification_service.dart';
import '../spaces/spaces_repository.dart';
import 'location_repository.dart';

/// Custom exception for location-related errors.
class LocationException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const LocationException(
    this.message, {
    this.code = 'LOCATION_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'LocationException($code): $message';
}

/// Service containing all location sharing business logic.
class LocationService {
  final LocationRepository _repo;
  final SpacesRepository _spacesRepo;
  final NotificationService _notificationService;
  final Logger _log = Logger('LocationService');
  final Uuid _uuid = const Uuid();

  /// Allowed duration presets in minutes.
  // ignore: unused_field
  static const _allowedDurations = [15, 30, 60, 120];

  /// Maximum custom duration in minutes (8 hours).
  static const _maxDurationMinutes = 480;

  LocationService(this._repo, this._spacesRepo, this._notificationService);

  // ---------------------------------------------------------------------------
  // Sharing
  // ---------------------------------------------------------------------------

  /// Starts sharing location with space members.
  ///
  /// Duration is in minutes. Accepted presets: 15, 30, 60, 120 minutes,
  /// or any custom value up to 480 minutes (8 hours).
  Future<Map<String, dynamic>> startSharing({
    required String userId,
    required String spaceId,
    required double latitude,
    required double longitude,
    required int durationMinutes,
    String type = 'live',
  }) async {
    // Validate coordinates
    _validateCoordinates(latitude, longitude);

    // Validate duration
    if (durationMinutes <= 0) {
      throw const LocationException(
        'Duration must be a positive number of minutes',
        code: 'INVALID_DURATION',
        statusCode: 422,
      );
    }

    if (durationMinutes > _maxDurationMinutes) {
      throw const LocationException(
        'Duration cannot exceed $_maxDurationMinutes minutes (${_maxDurationMinutes ~/ 60} hours)',
        code: 'INVALID_DURATION',
        statusCode: 422,
      );
    }

    // Validate type
    if (type != 'live' && type != 'eta') {
      throw const LocationException(
        'Share type must be "live" or "eta"',
        code: 'INVALID_TYPE',
        statusCode: 422,
      );
    }

    final expiresAt = DateTime.now().toUtc().add(
      Duration(minutes: durationMinutes),
    );

    final shareId = _uuid.v4();
    final share = await _repo.createShare(
      id: shareId,
      userId: userId,
      spaceId: spaceId,
      latitude: latitude,
      longitude: longitude,
      type: type,
      expiresAt: expiresAt,
    );

    // Notify space members
    await _notifySpaceMembers(
      spaceId: spaceId,
      excludeUserId: userId,
      type: 'location.sharing_started',
      title: 'Location sharing started',
      body: 'A space member started sharing their location',
      data: {'share_id': shareId},
    );

    _log.info(
      'Location sharing started: $shareId by $userId '
      'for $durationMinutes minutes',
    );
    return share;
  }

  /// Updates the coordinates for an active share.
  Future<Map<String, dynamic>> updateLocation({
    required String shareId,
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    _validateCoordinates(latitude, longitude);

    final existing = await _repo.getShareById(shareId);
    if (existing == null) {
      throw const LocationException(
        'Location share not found',
        code: 'SHARE_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify ownership
    if (existing['user_id'] != userId) {
      throw const LocationException(
        'You can only update your own location share',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Check if share has expired
    final expiresAt = existing['expires_at'] as String?;
    if (expiresAt != null) {
      final expiry = DateTime.parse(expiresAt);
      if (expiry.isBefore(DateTime.now().toUtc())) {
        throw const LocationException(
          'This location share has expired',
          code: 'SHARE_EXPIRED',
          statusCode: 410,
        );
      }
    }

    final updated = await _repo.updateLocation(shareId, latitude, longitude);
    if (updated == null) {
      throw const LocationException(
        'Failed to update location',
        code: 'UPDATE_FAILED',
        statusCode: 500,
      );
    }

    _log.fine('Location updated for share: $shareId');
    return updated;
  }

  /// Stops sharing location (deletes the share).
  Future<void> stopSharing({
    required String shareId,
    required String userId,
  }) async {
    final existing = await _repo.getShareById(shareId);
    if (existing == null) {
      throw const LocationException(
        'Location share not found',
        code: 'SHARE_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify ownership
    if (existing['user_id'] != userId) {
      throw const LocationException(
        'You can only stop your own location share',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.stopSharing(shareId);
    _log.info('Location sharing stopped: $shareId by $userId');
  }

  /// Gets all active location shares for a space.
  Future<List<Map<String, dynamic>>> getActiveShares(String spaceId) async {
    return _repo.getActiveShares(spaceId);
  }

  // ---------------------------------------------------------------------------
  // Safe Ping
  // ---------------------------------------------------------------------------

  /// Sends a safe ping: a point-in-time location broadcast to all space members.
  Future<Map<String, dynamic>> sendSafePing({
    required String userId,
    required String spaceId,
    required double latitude,
    required double longitude,
  }) async {
    _validateCoordinates(latitude, longitude);

    final shareId = _uuid.v4();
    final share = await _repo.createSafePing(
      id: shareId,
      userId: userId,
      spaceId: spaceId,
      latitude: latitude,
      longitude: longitude,
    );

    // Notify all space members immediately with push notification
    await _notifySpaceMembers(
      spaceId: spaceId,
      excludeUserId: userId,
      type: 'location.safe_ping',
      title: 'Safe Ping',
      body: 'A space member sent a safe ping with their location',
      data: {'share_id': shareId},
      channels: {NotificationChannel.inApp, NotificationChannel.push},
    );

    _log.info('Safe ping sent: $shareId by $userId in space $spaceId');
    return share;
  }

  // ---------------------------------------------------------------------------
  // ETA Sharing
  // ---------------------------------------------------------------------------

  /// Shares an ETA with destination and estimated minutes.
  Future<Map<String, dynamic>> shareETA({
    required String userId,
    required String spaceId,
    required double latitude,
    required double longitude,
    required String destination,
    required double destinationLat,
    required double destinationLng,
    required int estimatedMinutes,
  }) async {
    _validateCoordinates(latitude, longitude);
    _validateCoordinates(destinationLat, destinationLng);

    if (destination.trim().isEmpty) {
      throw const LocationException(
        'Destination name is required',
        code: 'INVALID_DESTINATION',
        statusCode: 422,
      );
    }

    if (estimatedMinutes <= 0) {
      throw const LocationException(
        'Estimated minutes must be a positive number',
        code: 'INVALID_ETA',
        statusCode: 422,
      );
    }

    // ETA share expires when estimated arrival time passes (with some buffer)
    final expiresAt = DateTime.now().toUtc().add(
      Duration(minutes: (estimatedMinutes * 1.5).ceil()),
    );

    final shareId = _uuid.v4();
    final share = await _repo.createShare(
      id: shareId,
      userId: userId,
      spaceId: spaceId,
      latitude: latitude,
      longitude: longitude,
      type: 'eta',
      expiresAt: expiresAt,
      etaDestination: destination.trim(),
      etaDestinationLat: destinationLat,
      etaDestinationLng: destinationLng,
      etaMinutes: estimatedMinutes,
    );

    // Notify space members
    await _notifySpaceMembers(
      spaceId: spaceId,
      excludeUserId: userId,
      type: 'location.eta_shared',
      title: 'ETA Shared',
      body:
          'A space member shared their ETA: '
          '$estimatedMinutes min to ${destination.trim()}',
      data: {
        'share_id': shareId,
        'destination': destination.trim(),
        'eta_minutes': estimatedMinutes,
      },
    );

    _log.info(
      'ETA shared: $shareId by $userId - '
      '$estimatedMinutes min to ${destination.trim()}',
    );
    return share;
  }

  // ---------------------------------------------------------------------------
  // Background Job
  // ---------------------------------------------------------------------------

  /// Cleans up all expired location shares.
  Future<int> cleanupExpired() async {
    final count = await _repo.cleanupExpired();
    if (count > 0) {
      _log.info('Cleaned up $count expired location shares');
    }
    return count;
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Validates latitude and longitude values.
  void _validateCoordinates(double latitude, double longitude) {
    if (latitude < -90 || latitude > 90) {
      throw const LocationException(
        'Latitude must be between -90 and 90',
        code: 'INVALID_COORDINATES',
        statusCode: 422,
      );
    }

    if (longitude < -180 || longitude > 180) {
      throw const LocationException(
        'Longitude must be between -180 and 180',
        code: 'INVALID_COORDINATES',
        statusCode: 422,
      );
    }
  }

  /// Notifies all active space members except the specified user.
  Future<void> _notifySpaceMembers({
    required String spaceId,
    required String excludeUserId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    Set<NotificationChannel>? channels,
  }) async {
    try {
      final members = await _spacesRepo.listMembers(spaceId);
      for (final member in members) {
        final memberId = member['user_id'] as String;
        if (memberId != excludeUserId) {
          await _notificationService.notify(
            userId: memberId,
            type: type,
            title: title,
            body: body,
            spaceId: spaceId,
            data: data,
            channels:
                channels ??
                {NotificationChannel.inApp, NotificationChannel.push},
          );
        }
      }
    } catch (e, stackTrace) {
      _log.warning('Failed to notify space members', e, stackTrace);
    }
  }
}
