import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'charter_service.dart';

/// Controller for relationship charter/agreement endpoints.
class CharterController {
  final CharterService _service;
  final Logger _log = Logger('CharterController');

  CharterController(this._service);

  /// Returns the router with all charter routes.
  Router get router {
    final router = Router();

    // Current charter
    router.get('/charter', _getCharter);

    // Versioning
    router.post('/charter/versions', _createVersion);
    router.get('/charter/versions', _getVersionHistory);
    router.get('/charter/versions/<versionId>', _getVersion);

    // Acknowledgments
    router.post(
      '/charter/versions/<versionId>/acknowledge',
      _acknowledgeVersion,
    );
    router.get(
      '/charter/versions/<versionId>/acknowledgments',
      _getAcknowledgments,
    );

    // Amendments
    router.post('/charter/amendments', _proposeAmendment);
    router.get('/charter/amendments', _listAmendments);
    router.post('/charter/amendments/<amendmentId>/vote', _voteOnAmendment);
    router.post(
      '/charter/amendments/<amendmentId>/finalize',
      _finalizeAmendment,
    );

    return router;
  }

  /// GET /charter
  ///
  /// Gets the current charter for the space, including the latest version.
  Future<Response> _getCharter(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final charter = await _service.getCharter(
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(charter);
    } on CharterException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get charter error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /charter/versions
  ///
  /// Creates a new version of the charter.
  /// Body: { "content": "...", "change_summary": "..." }
  Future<Response> _createVersion(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final content = body['content'] as String?;
      if (content == null || content.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'content', 'message': 'Charter content is required'},
          ],
        );
      }

      final result = await _service.createVersion(
        spaceId: spaceId,
        userId: userId,
        content: content,
        changeSummary: body['change_summary'] as String?,
      );

      return createdResponse(result);
    } on CharterException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create charter version error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /charter/versions
  ///
  /// Gets the full version history for the space's charter.
  Future<Response> _getVersionHistory(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final versions = await _service.getVersionHistory(
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse({'data': versions});
    } on CharterException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get version history error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /charter/versions/:versionId
  ///
  /// Gets a specific charter version.
  Future<Response> _getVersion(Request request, String versionId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final version = await _service.getVersion(
        versionId: versionId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(version);
    } on CharterException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get version error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /charter/versions/:versionId/acknowledge
  ///
  /// Acknowledges (signs) a charter version.
  Future<Response> _acknowledgeVersion(
    Request request,
    String versionId,
  ) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final result = await _service.acknowledgeVersion(
        versionId: versionId,
        spaceId: spaceId,
        userId: userId,
      );

      return createdResponse(result);
    } on CharterException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Acknowledge version error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /charter/versions/:versionId/acknowledgments
  ///
  /// Gets all acknowledgments for a charter version.
  Future<Response> _getAcknowledgments(
    Request request,
    String versionId,
  ) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final acknowledgments = await _service.getAcknowledgments(
        versionId: versionId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse({'data': acknowledgments});
    } on CharterException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get acknowledgments error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  // ---------------------------------------------------------------------------
  // Amendments
  // ---------------------------------------------------------------------------

  /// POST /charter/amendments
  ///
  /// Proposes a new amendment to the charter.
  /// Body: { "title": "...", "content": "...", "voting_duration_hours": 72 }
  Future<Response> _proposeAmendment(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final title = body['title'] as String?;
      if (title == null || title.trim().isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'title', 'message': 'Amendment title is required'},
          ],
        );
      }

      final content = body['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'content', 'message': 'Amendment content is required'},
          ],
        );
      }

      // Optional voting duration in hours
      Duration? votingDuration;
      final votingDurationHours = body['voting_duration_hours'];
      if (votingDurationHours != null) {
        final hours = votingDurationHours is int
            ? votingDurationHours
            : int.tryParse(votingDurationHours.toString());
        if (hours != null && hours > 0) {
          votingDuration = Duration(hours: hours);
        }
      }

      final result = await _service.proposeAmendment(
        spaceId: spaceId,
        userId: userId,
        title: title,
        content: content,
        votingDuration: votingDuration,
      );

      return createdResponse({'data': result});
    } on CharterException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Propose amendment error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /charter/amendments?status=
  ///
  /// Lists all amendments for the space's charter.
  /// Optional query param: status (proposed, voting, approved, rejected)
  Future<Response> _listAmendments(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final status = request.url.queryParameters['status'];

      final amendments = await _service.listAmendments(
        spaceId: spaceId,
        userId: userId,
        status: status,
      );

      return jsonResponse({'data': amendments});
    } on CharterException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('List amendments error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /charter/amendments/:amendmentId/vote
  ///
  /// Casts a vote on an amendment.
  /// Body: { "vote": "approve" | "reject" }
  Future<Response> _voteOnAmendment(Request request, String amendmentId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final vote = body['vote'] as String?;
      if (vote == null || (vote != 'approve' && vote != 'reject')) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {
              'field': 'vote',
              'message': 'Vote must be either "approve" or "reject"',
            },
          ],
        );
      }

      final result = await _service.voteOnAmendment(
        amendmentId: amendmentId,
        spaceId: spaceId,
        userId: userId,
        vote: vote,
      );

      return createdResponse({'data': result});
    } on CharterException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Vote on amendment error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /charter/amendments/:amendmentId/finalize
  ///
  /// Finalizes an amendment by tallying votes and setting the final status.
  Future<Response> _finalizeAmendment(
    Request request,
    String amendmentId,
  ) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final result = await _service.finalizeAmendment(
        amendmentId: amendmentId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse({'data': result});
    } on CharterException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Finalize amendment error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
