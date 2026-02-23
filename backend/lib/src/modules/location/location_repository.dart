import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for location sharing database operations (ephemeral data).
class LocationRepository {
  final Database _db;
  // ignore: unused_field
  final Logger _log = Logger('LocationRepository');

  LocationRepository(this._db);

  // ---------------------------------------------------------------------------
  // Location Shares
  // ---------------------------------------------------------------------------

  /// Creates a new location share and returns the created share row.
  Future<Map<String, dynamic>> createShare({
    required String id,
    required String userId,
    required String spaceId,
    required double latitude,
    required double longitude,
    required String type,
    DateTime? expiresAt,
    String? etaDestination,
    double? etaDestinationLat,
    double? etaDestinationLng,
    int? etaMinutes,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO location_shares (
        id, user_id, space_id, latitude, longitude, type,
        expires_at, eta_destination, eta_destination_lat, eta_destination_lng,
        eta_minutes, created_at, updated_at
      )
      VALUES (
        @id, @userId, @spaceId, @latitude, @longitude, @type,
        @expiresAt, @etaDestination, @etaDestinationLat, @etaDestinationLng,
        @etaMinutes, NOW(), NOW()
      )
      RETURNING id, user_id, space_id, latitude, longitude, type,
                expires_at, eta_destination, eta_destination_lat,
                eta_destination_lng, eta_minutes, created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'userId': userId,
        'spaceId': spaceId,
        'latitude': latitude,
        'longitude': longitude,
        'type': type,
        'expiresAt': expiresAt,
        'etaDestination': etaDestination,
        'etaDestinationLat': etaDestinationLat,
        'etaDestinationLng': etaDestinationLng,
        'etaMinutes': etaMinutes,
      },
    );

    return _shareRowToMap(row!);
  }

  /// Gets all active location shares for a space.
  /// Active means: not expired, or type is 'safe_ping'.
  Future<List<Map<String, dynamic>>> getActiveShares(String spaceId) async {
    final result = await _db.query(
      '''
      SELECT id, user_id, space_id, latitude, longitude, type,
             expires_at, eta_destination, eta_destination_lat,
             eta_destination_lng, eta_minutes, created_at, updated_at
      FROM location_shares
      WHERE space_id = @spaceId
        AND (expires_at > NOW() OR type = 'safe_ping')
      ORDER BY created_at DESC
      ''',
      parameters: {'spaceId': spaceId},
    );

    return result.map(_shareRowToMap).toList();
  }

  /// Gets a location share by ID.
  Future<Map<String, dynamic>?> getShareById(String shareId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, user_id, space_id, latitude, longitude, type,
             expires_at, eta_destination, eta_destination_lat,
             eta_destination_lng, eta_minutes, created_at, updated_at
      FROM location_shares
      WHERE id = @shareId
      ''',
      parameters: {'shareId': shareId},
    );

    if (row == null) return null;
    return _shareRowToMap(row);
  }

  /// Updates the location coordinates for an active share.
  Future<Map<String, dynamic>?> updateLocation(
    String shareId,
    double latitude,
    double longitude,
  ) async {
    final row = await _db.queryOne(
      '''
      UPDATE location_shares
      SET latitude = @latitude, longitude = @longitude, updated_at = NOW()
      WHERE id = @shareId
      RETURNING id, user_id, space_id, latitude, longitude, type,
                expires_at, eta_destination, eta_destination_lat,
                eta_destination_lng, eta_minutes, created_at, updated_at
      ''',
      parameters: {
        'shareId': shareId,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    if (row == null) return null;
    return _shareRowToMap(row);
  }

  /// Hard-deletes a location share (stops sharing).
  Future<void> stopSharing(String shareId) async {
    await _db.execute(
      'DELETE FROM location_shares WHERE id = @shareId',
      parameters: {'shareId': shareId},
    );
  }

  /// Hard-deletes all expired location shares (for background cleanup job).
  Future<int> cleanupExpired() async {
    return _db.execute('''
      DELETE FROM location_shares
      WHERE expires_at IS NOT NULL AND expires_at < NOW()
        AND type != 'safe_ping'
      ''');
  }

  /// Creates a safe ping share (point-in-time location broadcast).
  Future<Map<String, dynamic>> createSafePing({
    required String id,
    required String userId,
    required String spaceId,
    required double latitude,
    required double longitude,
  }) async {
    return createShare(
      id: id,
      userId: userId,
      spaceId: spaceId,
      latitude: latitude,
      longitude: longitude,
      type: 'safe_ping',
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _shareRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'user_id': row[1] as String,
      'space_id': row[2] as String,
      'latitude': row[3] as double,
      'longitude': row[4] as double,
      'type': row[5] as String,
      'expires_at': row[6] != null
          ? (row[6] as DateTime).toIso8601String()
          : null,
      'eta_destination': row[7] as String?,
      'eta_destination_lat': row[8] as double?,
      'eta_destination_lng': row[9] as double?,
      'eta_minutes': row[10] as int?,
      'created_at': (row[11] as DateTime).toIso8601String(),
      'updated_at': (row[12] as DateTime).toIso8601String(),
    };
  }
}
