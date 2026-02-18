import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'location_service.dart';

/// Controller for location sharing and safety endpoints.
class LocationController {
  final LocationService _service;
  final Logger _log = Logger('LocationController');

  LocationController(this._service);

  /// Returns the router with all location routes.
  Router get router {
    final router = Router();

    // Location sharing
    router.post('/share', _startSharing);
    router.put('/share/<shareId>', _updateLocation);
    router.delete('/share/<shareId>', _stopSharing);
    router.get('/shares', _getActiveShares);

    // Safety features
    router.post('/safe-ping', _sendSafePing);
    router.post('/eta', _shareETA);

    return router;
  }

  /// POST /api/v1/spaces/<spaceId>/location/share
  ///
  /// Starts sharing location with space members.
  /// Body: { "latitude": 0.0, "longitude": 0.0, "duration": 60, "type": "live" }
  Future<Response> _startSharing(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final latitude = body['latitude'] as num?;
      final longitude = body['longitude'] as num?;
      final duration = body['duration'] as int?;

      if (latitude == null || longitude == null || duration == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (latitude == null)
              {'field': 'latitude', 'message': 'Latitude is required'},
            if (longitude == null)
              {'field': 'longitude', 'message': 'Longitude is required'},
            if (duration == null)
              {
                'field': 'duration',
                'message': 'Duration (minutes) is required',
              },
          ],
        );
      }

      final type = body['type'] as String? ?? 'live';

      final result = await _service.startSharing(
        userId: userId,
        spaceId: spaceId,
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
        durationMinutes: duration,
        type: type,
      );

      return createdResponse(result);
    } on LocationException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Start sharing error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PUT /api/v1/spaces/<spaceId>/location/share/<shareId>
  ///
  /// Updates the user's current location.
  /// Body: { "latitude": 0.0, "longitude": 0.0 }
  Future<Response> _updateLocation(Request request, String shareId) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);

      final latitude = body['latitude'] as num?;
      final longitude = body['longitude'] as num?;

      if (latitude == null || longitude == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (latitude == null)
              {'field': 'latitude', 'message': 'Latitude is required'},
            if (longitude == null)
              {'field': 'longitude', 'message': 'Longitude is required'},
          ],
        );
      }

      final result = await _service.updateLocation(
        shareId: shareId,
        userId: userId,
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
      );

      return jsonResponse(result);
    } on LocationException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update location error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /api/v1/spaces/<spaceId>/location/share/<shareId>
  ///
  /// Stops sharing location.
  Future<Response> _stopSharing(Request request, String shareId) async {
    try {
      final userId = getUserId(request);

      await _service.stopSharing(shareId: shareId, userId: userId);

      return noContentResponse();
    } on LocationException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Stop sharing error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/location/shares
  ///
  /// Gets all active location shares visible to the current user.
  Future<Response> _getActiveShares(Request request) async {
    try {
      final spaceId = getSpaceId(request);
      final shares = await _service.getActiveShares(spaceId);

      return jsonResponse({'data': shares});
    } catch (e, stackTrace) {
      _log.severe('Get active shares error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/location/safe-ping
  ///
  /// Sends a "safe ping" notification to space members.
  /// Body: { "latitude": 0.0, "longitude": 0.0 }
  Future<Response> _sendSafePing(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final latitude = body['latitude'] as num?;
      final longitude = body['longitude'] as num?;

      if (latitude == null || longitude == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (latitude == null)
              {'field': 'latitude', 'message': 'Latitude is required'},
            if (longitude == null)
              {'field': 'longitude', 'message': 'Longitude is required'},
          ],
        );
      }

      final result = await _service.sendSafePing(
        userId: userId,
        spaceId: spaceId,
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
      );

      return createdResponse(result);
    } on LocationException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Safe ping error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/location/eta
  ///
  /// Shares an ETA with space members.
  /// Body: { "latitude": 0.0, "longitude": 0.0, "destination": "Home",
  ///         "destination_lat": 0.0, "destination_lng": 0.0, "estimated_minutes": 15 }
  Future<Response> _shareETA(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final latitude = body['latitude'] as num?;
      final longitude = body['longitude'] as num?;
      final destination = body['destination'] as String?;
      final destinationLat = body['destination_lat'] as num?;
      final destinationLng = body['destination_lng'] as num?;
      final estimatedMinutes = body['estimated_minutes'] as int?;

      if (latitude == null ||
          longitude == null ||
          destination == null ||
          destinationLat == null ||
          destinationLng == null ||
          estimatedMinutes == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (latitude == null)
              {'field': 'latitude', 'message': 'Latitude is required'},
            if (longitude == null)
              {'field': 'longitude', 'message': 'Longitude is required'},
            if (destination == null)
              {
                'field': 'destination',
                'message': 'Destination name is required',
              },
            if (destinationLat == null)
              {
                'field': 'destination_lat',
                'message': 'Destination latitude is required',
              },
            if (destinationLng == null)
              {
                'field': 'destination_lng',
                'message': 'Destination longitude is required',
              },
            if (estimatedMinutes == null)
              {
                'field': 'estimated_minutes',
                'message': 'Estimated minutes is required',
              },
          ],
        );
      }

      final result = await _service.shareETA(
        userId: userId,
        spaceId: spaceId,
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
        destination: destination,
        destinationLat: destinationLat.toDouble(),
        destinationLng: destinationLng.toDouble(),
        estimatedMinutes: estimatedMinutes,
      );

      return createdResponse(result);
    } on LocationException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Share ETA error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
