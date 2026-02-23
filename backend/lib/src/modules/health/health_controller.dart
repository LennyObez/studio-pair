import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'health_service.dart';

/// Controller for health & wellness tracking endpoints.
///
/// Note: Sexual health data supports hard-delete for privacy compliance.
class HealthController {
  final HealthService _service;
  final Logger _log = Logger('HealthController');

  HealthController(this._service);

  /// Returns the router with all health routes.
  Router get router {
    final router = Router();

    // Profile
    router.get('/health/profile', _getProfile);
    router.patch('/health/profile', _updateProfile);
    router.get('/health/profiles', _getProfilesForSpace);

    // Measurements (latest must be before generic measurements route)
    router.get('/health/measurements/latest', _getLatestMeasurement);
    router.post('/health/measurements', _addMeasurement);
    router.get('/health/measurements', _getMeasurements);

    // Sexual health (with hard-delete support)
    router.post('/health/sexual', _createSexualHealthEntry);
    router.get('/health/sexual', _getSexualHealthEntries);
    router.delete('/health/sexual/<entryId>', _hardDeleteSexualHealthEntry);

    // GDPR
    router.delete('/health/data', _deleteAllHealthData);

    return router;
  }

  /// GET /health/profile
  ///
  /// Gets or creates the current user's health profile.
  Future<Response> _getProfile(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final profile = await _service.getProfile(
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(profile);
    } on HealthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get profile error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /health/profile
  ///
  /// Updates the current user's health profile.
  /// Body: any subset of { date_of_birth, blood_type, allergies,
  ///   medications, emergency_contact, sexual_health_opt_in }
  Future<Response> _updateProfile(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final updates = <String, dynamic>{};

      if (body.containsKey('date_of_birth')) {
        updates['date_of_birth'] = body['date_of_birth'];
      }
      if (body.containsKey('blood_type')) {
        updates['blood_type'] = body['blood_type'];
      }
      if (body.containsKey('allergies')) {
        updates['allergies'] = body['allergies'];
      }
      if (body.containsKey('medications')) {
        updates['medications'] = body['medications'];
      }
      if (body.containsKey('emergency_contact')) {
        updates['emergency_contact'] = body['emergency_contact'];
      }
      if (body.containsKey('sexual_health_opt_in')) {
        updates['sexual_health_opt_in'] = body['sexual_health_opt_in'];
      }

      final result = await _service.updateProfile(
        spaceId: spaceId,
        userId: userId,
        updates: updates,
      );

      return jsonResponse(result);
    } on HealthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update profile error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /health/profiles
  ///
  /// Gets all health profiles for space members.
  Future<Response> _getProfilesForSpace(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final profiles = await _service.getProfilesForSpace(
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse({'data': profiles});
    } on HealthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get profiles error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /health/measurements
  ///
  /// Adds a health measurement.
  /// Body: {
  ///   "measurement_type": "weight|height|blood_pressure_systolic|...",
  ///   "value": 75.5,
  ///   "unit": "kg",
  ///   "source": "manual",
  ///   "measured_at": "ISO 8601"
  /// }
  Future<Response> _addMeasurement(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final measurementType = body['measurement_type'] as String?;
      final value = body['value'] as num?;
      final unit = body['unit'] as String?;
      final measuredAtStr = body['measured_at'] as String?;

      if (measurementType == null ||
          value == null ||
          unit == null ||
          measuredAtStr == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (measurementType == null)
              {
                'field': 'measurement_type',
                'message': 'Measurement type is required',
              },
            if (value == null)
              {'field': 'value', 'message': 'Value is required'},
            if (unit == null) {'field': 'unit', 'message': 'Unit is required'},
            if (measuredAtStr == null)
              {
                'field': 'measured_at',
                'message': 'Measurement date is required',
              },
          ],
        );
      }

      final measuredAt = DateTime.tryParse(measuredAtStr);
      if (measuredAt == null) {
        return validationErrorResponse(
          'Invalid date format. Use ISO 8601 format.',
          errors: [
            {'field': 'measured_at', 'message': 'Invalid date format'},
          ],
        );
      }

      final result = await _service.addMeasurement(
        spaceId: spaceId,
        userId: userId,
        measurementType: measurementType,
        value: value.toDouble(),
        unit: unit,
        source: body['source'] as String?,
        measuredAt: measuredAt,
      );

      return createdResponse(result);
    } on HealthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Add measurement error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /health/measurements?type=&startDate=&endDate=
  ///
  /// Gets measurements for the current user with optional filters.
  Future<Response> _getMeasurements(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final type = request.url.queryParameters['type'];
      final startDateStr = request.url.queryParameters['startDate'];
      final endDateStr = request.url.queryParameters['endDate'];

      DateTime? startDate;
      DateTime? endDate;

      if (startDateStr != null) {
        startDate = DateTime.tryParse(startDateStr);
      }
      if (endDateStr != null) {
        endDate = DateTime.tryParse(endDateStr);
      }

      final measurements = await _service.getMeasurements(
        spaceId: spaceId,
        userId: userId,
        type: type,
        startDate: startDate,
        endDate: endDate,
      );

      return jsonResponse({'data': measurements});
    } on HealthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get measurements error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /health/measurements/latest?type=
  ///
  /// Gets the most recent measurement of a given type.
  Future<Response> _getLatestMeasurement(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final type = request.url.queryParameters['type'];
      if (type == null || type.isEmpty) {
        return validationErrorResponse(
          'Measurement type is required',
          errors: [
            {'field': 'type', 'message': 'Query parameter "type" is required'},
          ],
        );
      }

      final measurement = await _service.getLatestMeasurement(
        spaceId: spaceId,
        userId: userId,
        type: type,
      );

      if (measurement == null) {
        return notFoundResponse('No measurement found for type "$type"');
      }

      return jsonResponse(measurement);
    } on HealthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get latest measurement error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /health/sexual
  ///
  /// Creates a sexual health entry.
  /// Body: {
  ///   "date": "ISO 8601",
  ///   "is_protected": true,
  ///   "feedback_encrypted": "...",
  ///   "linked_fantasy_activity_id": "...",
  ///   "participant_ids": ["userId1", "userId2"]
  /// }
  Future<Response> _createSexualHealthEntry(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final dateStr = body['date'] as String?;
      final isProtected = body['is_protected'] as bool?;
      final rawParticipantIds = body['participant_ids'] as List<dynamic>?;

      if (dateStr == null || isProtected == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (dateStr == null)
              {'field': 'date', 'message': 'Date is required'},
            if (isProtected == null)
              {
                'field': 'is_protected',
                'message': 'Protection status is required',
              },
          ],
        );
      }

      final date = DateTime.tryParse(dateStr);
      if (date == null) {
        return validationErrorResponse(
          'Invalid date format. Use ISO 8601 format.',
          errors: [
            {'field': 'date', 'message': 'Invalid date format'},
          ],
        );
      }

      final participantIds =
          rawParticipantIds?.map((e) => e as String).toList() ?? [];

      final result = await _service.createSexualHealthEntry(
        spaceId: spaceId,
        userId: userId,
        date: date,
        isProtected: isProtected,
        feedbackEncrypted: body['feedback_encrypted'] as String?,
        linkedFantasyActivityId: body['linked_fantasy_activity_id'] as String?,
        participantIds: participantIds,
      );

      return createdResponse(result);
    } on HealthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create sexual health entry error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /health/sexual?startDate=&endDate=
  ///
  /// Gets sexual health entries for the space.
  Future<Response> _getSexualHealthEntries(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final startDateStr = request.url.queryParameters['startDate'];
      final endDateStr = request.url.queryParameters['endDate'];

      DateTime? startDate;
      DateTime? endDate;

      if (startDateStr != null) {
        startDate = DateTime.tryParse(startDateStr);
      }
      if (endDateStr != null) {
        endDate = DateTime.tryParse(endDateStr);
      }

      final entries = await _service.getSexualHealthEntries(
        spaceId: spaceId,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return jsonResponse({'data': entries});
    } on HealthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get sexual health entries error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /health/sexual/:entryId
  ///
  /// Permanently deletes a sexual health entry (HARD DELETE).
  /// This is a privacy-critical operation - data is irrecoverable.
  Future<Response> _hardDeleteSexualHealthEntry(
    Request request,
    String entryId,
  ) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      await _service.hardDeleteSexualHealthEntry(
        entryId: entryId,
        spaceId: spaceId,
        userId: userId,
      );

      return noContentResponse();
    } on HealthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Hard delete sexual health entry error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /health/data
  ///
  /// Permanently deletes ALL health data for the current user (GDPR compliance).
  /// This is an irreversible operation.
  Future<Response> _deleteAllHealthData(Request request) async {
    try {
      final userId = getUserId(request);

      await _service.deleteAllHealthData(userId: userId);

      return noContentResponse();
    } on HealthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete all health data error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
