import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../services/enrichment_service.dart';
import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'activities_service.dart';

/// Controller for activity/date-planning endpoints.
class ActivitiesController {
  final ActivitiesService _service;
  final EnrichmentService? _enrichmentService;
  final Logger _log = Logger('ActivitiesController');

  ActivitiesController(this._service, {EnrichmentService? enrichmentService})
    : _enrichmentService = enrichmentService;

  /// Returns the router with all activity routes.
  Router get router {
    final router = Router();

    // Collection routes (must be registered before parameterised routes)
    router.get('/search', _searchActivities);
    router.get('/enrich', _enrichActivity);
    router.get('/completed', _getCompletedActivities);
    router.get('/stats', _getStats);
    router.get('/columns/<userId>', _getActivitiesByColumn);

    // CRUD
    router.post('/', _createActivity);
    router.get('/', _listActivities);
    router.get('/<activityId>', _getActivity);
    router.patch('/<activityId>', _updateActivity);
    router.delete('/<activityId>', _deleteActivity);

    // Restore
    router.post('/<activityId>/restore', _restoreActivity);

    // Voting
    router.post('/<activityId>/vote', _vote);
    router.delete('/<activityId>/vote', _removeVote);
    router.get('/<activityId>/votes', _getVotes);

    // Completion
    router.post('/<activityId>/complete', _completeActivity);

    return router;
  }

  /// POST /api/v1/spaces/<spaceId>/activities/
  ///
  /// Creates a new activity.
  /// Body: { "title": "...", "description": "...", "category": "...",
  ///         "thumbnail_url": "...", "trailer_url": "...", "privacy": "...",
  ///         "mode": "...", "metadata": { ... } }
  Future<Response> _createActivity(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final title = body['title'] as String?;
      if (title == null || title.trim().isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'title', 'message': 'Title is required'},
          ],
        );
      }

      final result = await _service.createActivity(
        spaceId: spaceId,
        userId: userId,
        title: title,
        description: body['description'] as String?,
        category: body['category'] as String?,
        thumbnailUrl: body['thumbnail_url'] as String?,
        trailerUrl: body['trailer_url'] as String?,
        externalId: body['external_id'] as String?,
        externalSource: body['external_source'] as String?,
        privacy: body['privacy'] as String? ?? 'shared',
        mode: body['mode'] as String? ?? 'unlinked',
        metadata: body['metadata'] as Map<String, dynamic>?,
      );

      return createdResponse({'data': result});
    } on ActivityException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create activity error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/activities/?category=&status=&cursor=&limit=
  ///
  /// Lists activities for the space with optional filters and pagination.
  Future<Response> _listActivities(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final pagination = getPaginationParams(request);

      final category = request.url.queryParameters['category'];
      final status = request.url.queryParameters['status'];
      final privacy = request.url.queryParameters['privacy'];
      final mode = request.url.queryParameters['mode'];
      final createdBy = request.url.queryParameters['created_by'];

      final result = await _service.getActivities(
        spaceId: spaceId,
        userId: userId,
        category: category,
        status: status,
        privacy: privacy,
        mode: mode,
        createdBy: createdBy,
        cursor: pagination.cursor,
        limit: pagination.limit,
      );

      return paginatedResponse(
        result['data'] as List<dynamic>,
        cursor: result['cursor'] as String?,
        hasMore: result['has_more'] as bool,
      );
    } on ActivityException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('List activities error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/activities/columns/<userId>
  ///
  /// Gets activities created by a specific user (their "column").
  Future<Response> _getActivitiesByColumn(
    Request request,
    String userId,
  ) async {
    try {
      final requestingUserId = getUserId(request);
      final spaceId = getSpaceId(request);

      final activities = await _service.getActivitiesByColumn(
        spaceId: spaceId,
        columnUserId: userId,
        requestingUserId: requestingUserId,
      );

      return jsonResponse({'data': activities});
    } on ActivityException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get activities by column error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/activities/search?q=
  ///
  /// Searches activities within the space.
  Future<Response> _searchActivities(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final query = request.url.queryParameters['q'];

      if (query == null || query.trim().isEmpty) {
        return validationErrorResponse(
          'Search query parameter "q" is required',
        );
      }

      final results = await _service.searchActivities(
        spaceId: spaceId,
        userId: userId,
        query: query,
      );

      return jsonResponse({'data': results});
    } on ActivityException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Search activities error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/activities/enrich?query=&category=
  ///
  /// Enriches activity data by searching external APIs (TMDb, RAWG, YouTube).
  /// Query params:
  /// - `query` (required): the search term
  /// - `category`: one of 'movies', 'tv', 'games', 'trailers' (defaults to all)
  Future<Response> _enrichActivity(Request request) async {
    try {
      final query = request.url.queryParameters['query'];
      final category = request.url.queryParameters['category'];

      if (query == null || query.trim().isEmpty) {
        return validationErrorResponse(
          'Search query parameter "query" is required',
        );
      }

      if (_enrichmentService == null) {
        return errorResponse(
          'Enrichment service is not available',
          statusCode: 503,
          code: 'SERVICE_UNAVAILABLE',
        );
      }

      final results = <String, List<Map<String, dynamic>>>{};

      // Search based on category or return all
      if (category == null || category == 'movies') {
        final movies = await _enrichmentService.searchMovies(query);
        results['movies'] = movies.map((m) => m.toJson()).toList();
      }

      if (category == null || category == 'tv') {
        final tvShows = await _enrichmentService.searchTvShows(query);
        results['tv_shows'] = tvShows.map((s) => s.toJson()).toList();
      }

      if (category == null || category == 'games') {
        final games = await _enrichmentService.searchGames(query);
        results['games'] = games.map((g) => g.toJson()).toList();
      }

      if (category == null || category == 'trailers') {
        final trailers = await _enrichmentService.searchTrailers(query);
        results['trailers'] = trailers.map((t) => t.toJson()).toList();
      }

      return jsonResponse({'data': results});
    } catch (e, stackTrace) {
      _log.severe('Enrich activity error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/activities/completed?cursor=&limit=
  ///
  /// Gets completed activities for the space.
  Future<Response> _getCompletedActivities(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final pagination = getPaginationParams(request);

      final result = await _service.getCompletedActivities(
        spaceId: spaceId,
        userId: userId,
        cursor: pagination.cursor,
        limit: pagination.limit,
      );

      return paginatedResponse(
        result['data'] as List<dynamic>,
        cursor: result['cursor'] as String?,
        hasMore: result['has_more'] as bool,
      );
    } on ActivityException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get completed activities error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/activities/stats
  ///
  /// Gets per-user activity statistics.
  Future<Response> _getStats(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final stats = await _service.getStats(spaceId: spaceId, userId: userId);

      return jsonResponse({'data': stats});
    } on ActivityException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get stats error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/activities/<activityId>
  ///
  /// Gets a single activity by ID.
  Future<Response> _getActivity(Request request, String activityId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final activity = await _service.getActivity(
        activityId: activityId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse({'data': activity});
    } on ActivityException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get activity error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /api/v1/spaces/<spaceId>/activities/<activityId>
  ///
  /// Updates an activity.
  /// Body: { "title": "...", "description": "...", ... }
  Future<Response> _updateActivity(Request request, String activityId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      // Build the updates map from only the provided fields
      final updates = <String, dynamic>{};
      for (final key in [
        'title',
        'description',
        'category',
        'thumbnail_url',
        'trailer_url',
        'privacy',
        'mode',
        'metadata',
      ]) {
        if (body.containsKey(key)) {
          updates[key] = body[key];
        }
      }

      if (updates.isEmpty) {
        return validationErrorResponse('No fields to update');
      }

      final updated = await _service.updateActivity(
        activityId: activityId,
        spaceId: spaceId,
        userId: userId,
        updates: updates,
      );

      return jsonResponse({'data': updated});
    } on ActivityException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update activity error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /api/v1/spaces/<spaceId>/activities/<activityId>
  ///
  /// Soft-deletes an activity.
  Future<Response> _deleteActivity(Request request, String activityId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      await _service.deleteActivity(
        activityId: activityId,
        spaceId: spaceId,
        userId: userId,
      );

      return noContentResponse();
    } on ActivityException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete activity error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/activities/<activityId>/restore
  ///
  /// Restores a soft-deleted activity (within 30-day window).
  Future<Response> _restoreActivity(Request request, String activityId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final restored = await _service.restoreActivity(
        activityId: activityId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse({'data': restored});
    } on ActivityException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Restore activity error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/activities/<activityId>/vote
  ///
  /// Casts or updates a vote on an activity.
  /// Body: { "score": 1-5 }
  Future<Response> _vote(Request request, String activityId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final score = body['score'];
      if (score == null || score is! int) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {
              'field': 'score',
              'message': 'Score is required and must be an integer (1-5)',
            },
          ],
        );
      }

      final vote = await _service.vote(
        activityId: activityId,
        spaceId: spaceId,
        userId: userId,
        score: score,
      );

      return createdResponse({'data': vote});
    } on ActivityException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Vote error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /api/v1/spaces/<spaceId>/activities/<activityId>/vote
  ///
  /// Removes the current user's vote from an activity.
  Future<Response> _removeVote(Request request, String activityId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      await _service.removeVote(
        activityId: activityId,
        spaceId: spaceId,
        userId: userId,
      );

      return noContentResponse();
    } on ActivityException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Remove vote error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/activities/<activityId>/votes
  ///
  /// Gets all votes for an activity with aggregate data.
  Future<Response> _getVotes(Request request, String activityId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final result = await _service.getVotes(
        activityId: activityId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse({'data': result});
    } on ActivityException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get votes error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/activities/<activityId>/complete
  ///
  /// Marks an activity as completed.
  /// Body: { "notes": "..." }
  Future<Response> _completeActivity(Request request, String activityId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final completed = await _service.completeActivity(
        activityId: activityId,
        spaceId: spaceId,
        userId: userId,
        notes: body['notes'] as String?,
      );

      return jsonResponse({'data': completed});
    } on ActivityException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Complete activity error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
