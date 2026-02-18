import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for health-related database operations.
class HealthRepository {
  final Database _db;
  final Logger _log = Logger('HealthRepository');

  HealthRepository(this._db);

  // ---------------------------------------------------------------------------
  // Health Profiles
  // ---------------------------------------------------------------------------

  /// Gets or creates a health profile for a user in a space.
  Future<Map<String, dynamic>> getOrCreateProfile(
    String userId,
    String spaceId,
  ) async {
    // Try to find existing profile
    final existing = await _db.queryOne(
      '''
      SELECT id, user_id, space_id, created_at, updated_at
      FROM health_profiles
      WHERE user_id = @userId AND space_id = @spaceId
      ''',
      parameters: {'userId': userId, 'spaceId': spaceId},
    );

    if (existing != null) {
      return _profileRowToMap(existing);
    }

    // Create a new profile
    final row = await _db.queryOne(
      '''
      INSERT INTO health_profiles (id, user_id, space_id, created_at, updated_at)
      VALUES (gen_random_uuid(), @userId, @spaceId, NOW(), NOW())
      RETURNING id, user_id, space_id, created_at, updated_at
      ''',
      parameters: {'userId': userId, 'spaceId': spaceId},
    );

    return _profileRowToMap(row!);
  }

  /// Updates a health profile with the given fields.
  Future<Map<String, dynamic>?> updateProfile(
    String profileId,
    Map<String, dynamic> updates,
  ) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'profileId': profileId};

    if (updates.containsKey('date_of_birth')) {
      setClauses.add('date_of_birth = @dateOfBirth');
      params['dateOfBirth'] = updates['date_of_birth'];
    }
    if (updates.containsKey('blood_type')) {
      setClauses.add('blood_type = @bloodType');
      params['bloodType'] = updates['blood_type'];
    }
    if (updates.containsKey('allergies')) {
      setClauses.add('allergies = @allergies');
      params['allergies'] = updates['allergies'];
    }
    if (updates.containsKey('medications')) {
      setClauses.add('medications = @medications');
      params['medications'] = updates['medications'];
    }
    if (updates.containsKey('emergency_contact')) {
      setClauses.add('emergency_contact = @emergencyContact');
      params['emergencyContact'] = updates['emergency_contact'];
    }
    if (updates.containsKey('sexual_health_opt_in')) {
      setClauses.add('sexual_health_opt_in = @sexualHealthOptIn');
      params['sexualHealthOptIn'] = updates['sexual_health_opt_in'];
    }

    if (setClauses.isEmpty) {
      return _db
          .queryOne(
            '''
        SELECT id, user_id, space_id, created_at, updated_at
        FROM health_profiles
        WHERE id = @profileId
        ''',
            parameters: {'profileId': profileId},
          )
          .then((row) => row != null ? _profileRowToMap(row) : null);
    }

    setClauses.add('updated_at = NOW()');

    final row = await _db.queryOne('''
      UPDATE health_profiles
      SET ${setClauses.join(', ')}
      WHERE id = @profileId
      RETURNING id, user_id, space_id, created_at, updated_at
      ''', parameters: params);

    if (row == null) return null;
    return _profileRowToMap(row);
  }

  /// Gets all health profiles for a space.
  Future<List<Map<String, dynamic>>> getProfilesForSpace(String spaceId) async {
    final result = await _db.query(
      '''
      SELECT hp.id, hp.user_id, hp.space_id, hp.created_at, hp.updated_at,
             u.display_name, u.avatar_url
      FROM health_profiles hp
      JOIN users u ON u.id = hp.user_id
      WHERE hp.space_id = @spaceId
      ORDER BY hp.created_at ASC
      ''',
      parameters: {'spaceId': spaceId},
    );

    return result.map(_profileWithUserRowToMap).toList();
  }

  // ---------------------------------------------------------------------------
  // Measurements
  // ---------------------------------------------------------------------------

  /// Adds a health measurement.
  Future<Map<String, dynamic>> addMeasurement({
    required String id,
    required String userId,
    required String measurementType,
    required double value,
    required String unit,
    String? source,
    required DateTime measuredAt,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO health_measurements (
        id, user_id, measurement_type, value, unit,
        source, measured_at, created_at
      )
      VALUES (
        @id, @userId, @measurementType, @value, @unit,
        @source, @measuredAt, NOW()
      )
      RETURNING id, user_id, measurement_type, value, unit,
                source, measured_at, created_at
      ''',
      parameters: {
        'id': id,
        'userId': userId,
        'measurementType': measurementType,
        'value': value,
        'unit': unit,
        'source': source,
        'measuredAt': measuredAt,
      },
    );

    return _measurementRowToMap(row!);
  }

  /// Gets measurements for a user with optional filters.
  Future<List<Map<String, dynamic>>> getMeasurements(
    String userId, {
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    final conditions = <String>['user_id = @userId'];
    final params = <String, dynamic>{'userId': userId, 'limit': limit};

    if (type != null) {
      conditions.add('measurement_type = @type');
      params['type'] = type;
    }
    if (startDate != null) {
      conditions.add('measured_at >= @startDate');
      params['startDate'] = startDate;
    }
    if (endDate != null) {
      conditions.add('measured_at <= @endDate');
      params['endDate'] = endDate;
    }

    final result = await _db.query('''
      SELECT id, user_id, measurement_type, value, unit,
             source, measured_at, created_at
      FROM health_measurements
      WHERE ${conditions.join(' AND ')}
      ORDER BY measured_at DESC
      LIMIT @limit
      ''', parameters: params);

    return result.map(_measurementRowToMap).toList();
  }

  /// Gets the most recent measurement of a given type for a user.
  Future<Map<String, dynamic>?> getLatestMeasurement(
    String userId,
    String type,
  ) async {
    final row = await _db.queryOne(
      '''
      SELECT id, user_id, measurement_type, value, unit,
             source, measured_at, created_at
      FROM health_measurements
      WHERE user_id = @userId AND measurement_type = @type
      ORDER BY measured_at DESC
      LIMIT 1
      ''',
      parameters: {'userId': userId, 'type': type},
    );

    if (row == null) return null;
    return _measurementRowToMap(row);
  }

  // ---------------------------------------------------------------------------
  // Sexual Health
  // ---------------------------------------------------------------------------

  /// Creates a sexual health entry within a transaction, including participants.
  Future<Map<String, dynamic>> createSexualHealthEntry({
    required String id,
    required String spaceId,
    required DateTime date,
    required bool isProtected,
    String? feedbackEncrypted,
    String? linkedFantasyActivityId,
    required List<String> participantIds,
  }) async {
    return _db.transaction((session) async {
      final row = await session.queryOne(
        '''
        INSERT INTO sexual_health_entries (
          id, space_id, date, is_protected, feedback_encrypted,
          linked_fantasy_activity_id, created_at
        )
        VALUES (
          @id, @spaceId, @date, @isProtected, @feedbackEncrypted,
          @linkedFantasyActivityId, NOW()
        )
        RETURNING id, space_id, date, is_protected, feedback_encrypted,
                  linked_fantasy_activity_id, created_at
        ''',
        parameters: {
          'id': id,
          'spaceId': spaceId,
          'date': date,
          'isProtected': isProtected,
          'feedbackEncrypted': feedbackEncrypted,
          'linkedFantasyActivityId': linkedFantasyActivityId,
        },
      );

      final entry = _sexualHealthRowToMap(row!);

      // Add participants
      for (final participantId in participantIds) {
        await session.execute(
          '''
          INSERT INTO sexual_health_participants (
            id, entry_id, user_id, created_at
          )
          VALUES (gen_random_uuid(), @entryId, @userId, NOW())
          ''',
          parameters: {'entryId': id, 'userId': participantId},
        );
      }

      entry['participant_ids'] = participantIds;

      return entry;
    });
  }

  /// Gets sexual health entries for a space with optional date filters.
  Future<List<Map<String, dynamic>>> getSexualHealthEntries(
    String spaceId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final conditions = <String>['space_id = @spaceId'];
    final params = <String, dynamic>{'spaceId': spaceId};

    if (startDate != null) {
      conditions.add('date >= @startDate');
      params['startDate'] = startDate;
    }
    if (endDate != null) {
      conditions.add('date <= @endDate');
      params['endDate'] = endDate;
    }

    final result = await _db.query('''
      SELECT id, space_id, date, is_protected, feedback_encrypted,
             linked_fantasy_activity_id, created_at
      FROM sexual_health_entries
      WHERE ${conditions.join(' AND ')}
      ORDER BY date DESC
      ''', parameters: params);

    return result.map(_sexualHealthRowToMap).toList();
  }

  /// Permanently deletes a sexual health entry (hard delete, no soft delete).
  Future<void> hardDeleteSexualHealthEntry(String entryId) async {
    // Delete participants first (foreign key constraint)
    await _db.execute(
      '''
      DELETE FROM sexual_health_participants
      WHERE entry_id = @entryId
      ''',
      parameters: {'entryId': entryId},
    );

    // Delete the entry itself
    await _db.execute(
      '''
      DELETE FROM sexual_health_entries
      WHERE id = @entryId
      ''',
      parameters: {'entryId': entryId},
    );
  }

  /// Permanently deletes ALL health data for a user (GDPR compliance).
  Future<void> deleteAllHealthData(String userId) async {
    // Delete measurements
    await _db.execute(
      '''
      DELETE FROM health_measurements
      WHERE user_id = @userId
      ''',
      parameters: {'userId': userId},
    );

    // Delete sexual health participants
    await _db.execute(
      '''
      DELETE FROM sexual_health_participants
      WHERE user_id = @userId
      ''',
      parameters: {'userId': userId},
    );

    // Delete health profiles
    await _db.execute(
      '''
      DELETE FROM health_profiles
      WHERE user_id = @userId
      ''',
      parameters: {'userId': userId},
    );

    _log.info('All health data permanently deleted for user $userId (GDPR)');
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _profileRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'user_id': row[1] as String,
      'space_id': row[2] as String,
      'created_at': (row[3] as DateTime).toIso8601String(),
      'updated_at': (row[4] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _profileWithUserRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'user_id': row[1] as String,
      'space_id': row[2] as String,
      'created_at': (row[3] as DateTime).toIso8601String(),
      'updated_at': (row[4] as DateTime).toIso8601String(),
      'user': {
        'display_name': row[5] as String,
        'avatar_url': row[6] as String?,
      },
    };
  }

  Map<String, dynamic> _measurementRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'user_id': row[1] as String,
      'measurement_type': row[2] as String,
      'value': row[3] as double,
      'unit': row[4] as String,
      'source': row[5] as String?,
      'measured_at': (row[6] as DateTime).toIso8601String(),
      'created_at': (row[7] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _sexualHealthRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'date': (row[2] as DateTime).toIso8601String(),
      'is_protected': row[3] as bool,
      'feedback_encrypted': row[4] as String?,
      'linked_fantasy_activity_id': row[5] as String?,
      'created_at': (row[6] as DateTime).toIso8601String(),
    };
  }
}
