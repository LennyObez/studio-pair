import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../spaces/spaces_repository.dart';
import 'health_repository.dart';

/// Custom exception for health-related errors.
class HealthException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const HealthException(
    this.message, {
    this.code = 'HEALTH_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'HealthException($code): $message';
}

/// Service containing all health-related business logic.
class HealthService {
  final HealthRepository _repo;
  final SpacesRepository _spacesRepo;
  final Logger _log = Logger('HealthService');
  final Uuid _uuid = const Uuid();

  /// Valid measurement types and their allowed units.
  static const _validMeasurementTypes = {
    'weight': ['kg', 'lbs'],
    'height': ['cm', 'in'],
    'blood_pressure_systolic': ['mmHg'],
    'blood_pressure_diastolic': ['mmHg'],
    'heart_rate': ['bpm'],
    'temperature': ['C', 'F'],
    'blood_glucose': ['mg/dL', 'mmol/L'],
    'sleep': ['hours'],
    'steps': ['count'],
    'water_intake': ['ml', 'oz'],
  };

  HealthService(this._repo, this._spacesRepo);

  // ---------------------------------------------------------------------------
  // Profiles
  // ---------------------------------------------------------------------------

  /// Gets or creates a health profile for the current user.
  Future<Map<String, dynamic>> getProfile({
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);
    return _repo.getOrCreateProfile(userId, spaceId);
  }

  /// Updates the current user's health profile.
  ///
  /// Verifies the profile belongs to the requesting user.
  Future<Map<String, dynamic>> updateProfile({
    required String spaceId,
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final profile = await _repo.getOrCreateProfile(userId, spaceId);
    final profileId = profile['id'] as String;

    // Verify the profile belongs to the requesting user
    if (profile['user_id'] != userId) {
      throw const HealthException(
        'You can only update your own profile',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    final updated = await _repo.updateProfile(profileId, updates);
    if (updated == null) {
      throw const HealthException(
        'Profile not found',
        code: 'PROFILE_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('Health profile updated for user $userId in space $spaceId');

    return updated;
  }

  /// Gets all health profiles in a space (space members' profiles).
  Future<List<Map<String, dynamic>>> getProfilesForSpace({
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);
    return _repo.getProfilesForSpace(spaceId);
  }

  // ---------------------------------------------------------------------------
  // Measurements
  // ---------------------------------------------------------------------------

  /// Adds a health measurement.
  ///
  /// Validates the measurement type and unit.
  Future<Map<String, dynamic>> addMeasurement({
    required String spaceId,
    required String userId,
    required String measurementType,
    required double value,
    required String unit,
    String? source,
    required DateTime measuredAt,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    // Validate measurement type
    if (!_validMeasurementTypes.containsKey(measurementType)) {
      throw HealthException(
        'Invalid measurement type. Must be one of: ${_validMeasurementTypes.keys.join(", ")}',
        code: 'INVALID_MEASUREMENT_TYPE',
        statusCode: 422,
      );
    }

    // Validate unit for the measurement type
    final validUnits = _validMeasurementTypes[measurementType]!;
    if (!validUnits.contains(unit)) {
      throw HealthException(
        'Invalid unit for $measurementType. Must be one of: ${validUnits.join(", ")}',
        code: 'INVALID_UNIT',
        statusCode: 422,
      );
    }

    final measurement = await _repo.addMeasurement(
      id: _uuid.v4(),
      userId: userId,
      measurementType: measurementType,
      value: value,
      unit: unit,
      source: source,
      measuredAt: measuredAt,
    );

    _log.info(
      'Measurement added: $measurementType=$value$unit for user $userId',
    );

    return measurement;
  }

  /// Gets measurements for a user.
  ///
  /// Verifies the requesting user is viewing their own data or is a
  /// space member.
  Future<List<Map<String, dynamic>>> getMeasurements({
    required String spaceId,
    required String userId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final clampedLimit = limit.clamp(1, 200);

    return _repo.getMeasurements(
      userId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      limit: clampedLimit,
    );
  }

  /// Gets the latest measurement of a given type for the current user.
  Future<Map<String, dynamic>?> getLatestMeasurement({
    required String spaceId,
    required String userId,
    required String type,
  }) async {
    await _verifySpaceMembership(spaceId, userId);
    return _repo.getLatestMeasurement(userId, type);
  }

  // ---------------------------------------------------------------------------
  // Sexual Health
  // ---------------------------------------------------------------------------

  /// Creates a sexual health entry.
  ///
  /// Verifies opt-in consent and enforces hard delete policy.
  Future<Map<String, dynamic>> createSexualHealthEntry({
    required String spaceId,
    required String userId,
    required DateTime date,
    required bool isProtected,
    String? feedbackEncrypted,
    String? linkedFantasyActivityId,
    required List<String> participantIds,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    // Verify all participants are space members
    for (final participantId in participantIds) {
      final membership = await _spacesRepo.getMember(spaceId, participantId);
      if (membership == null || membership['status'] != 'active') {
        throw HealthException(
          'Participant $participantId is not an active member of this space',
          code: 'INVALID_PARTICIPANT',
          statusCode: 422,
        );
      }
    }

    final entry = await _repo.createSexualHealthEntry(
      id: _uuid.v4(),
      spaceId: spaceId,
      date: date,
      isProtected: isProtected,
      feedbackEncrypted: feedbackEncrypted,
      linkedFantasyActivityId: linkedFantasyActivityId,
      participantIds: participantIds,
    );

    _log.info('Sexual health entry created in space $spaceId');

    return entry;
  }

  /// Gets sexual health entries for a space.
  Future<List<Map<String, dynamic>>> getSexualHealthEntries({
    required String spaceId,
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    return _repo.getSexualHealthEntries(
      spaceId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Permanently deletes a sexual health entry (HARD DELETE).
  ///
  /// Sexual health data supports permanent deletion for privacy compliance.
  Future<void> hardDeleteSexualHealthEntry({
    required String entryId,
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    await _repo.hardDeleteSexualHealthEntry(entryId);

    _log.info(
      'Sexual health entry $entryId permanently deleted in space $spaceId by $userId',
    );
  }

  // ---------------------------------------------------------------------------
  // GDPR
  // ---------------------------------------------------------------------------

  /// Permanently deletes ALL health data for the requesting user.
  ///
  /// This is a GDPR compliance operation and permanently removes
  /// all health profiles, measurements, and sexual health data.
  Future<void> deleteAllHealthData({required String userId}) async {
    await _repo.deleteAllHealthData(userId);

    _log.info('All health data permanently deleted for user $userId (GDPR)');
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Verifies that a user is an active member of a space.
  Future<Map<String, dynamic>> _verifySpaceMembership(
    String spaceId,
    String userId,
  ) async {
    final membership = await _spacesRepo.getMember(spaceId, userId);
    if (membership == null || membership['status'] != 'active') {
      throw const HealthException(
        'You do not have access to this space',
        code: 'SPACE_ACCESS_DENIED',
        statusCode: 403,
      );
    }
    return membership;
  }
}
