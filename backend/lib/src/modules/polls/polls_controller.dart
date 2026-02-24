import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'polls_service.dart';

/// Controller for polls and decision-making endpoints.
class PollsController {
  final PollsService _service;
  final Logger _log = Logger('PollsController');

  PollsController(this._service);

  /// Returns the router with all poll routes.
  Router get router {
    final router = Router();

    // Polls CRUD
    router.post('/polls', _createPoll);
    router.get('/polls', _getPolls);
    router.get('/polls/<pollId>', _getPoll);

    // Lifecycle
    router.post('/polls/<pollId>/close', _closePoll);

    // Voting
    router.post('/polls/<pollId>/vote', _castVote);
    router.delete('/polls/<pollId>/vote/<optionId>', _removeVote);

    // Results
    router.get('/polls/<pollId>/results', _getResults);

    // Random pick (for indecisive couples!)
    router.get('/polls/<pollId>/random', _getRandomPick);

    return router;
  }

  /// POST /polls
  ///
  /// Creates a new poll with options.
  /// Body: {
  ///   "question": "...",
  ///   "poll_type": "single|multiple|ranked",
  ///   "is_anonymous": false,
  ///   "deadline": "ISO 8601",
  ///   "options": [
  ///     { "label": "...", "image_url": "..." },
  ///     ...
  ///   ]
  /// }
  Future<Response> _createPoll(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final question = body['question'] as String?;
      final pollType = body['poll_type'] as String? ?? 'single';
      final rawOptions = body['options'] as List<dynamic>?;

      if (question == null || question.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'question', 'message': 'Poll question is required'},
          ],
        );
      }

      if (rawOptions == null || rawOptions.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'options', 'message': 'At least 2 options are required'},
          ],
        );
      }

      final options = rawOptions.map((e) => e as Map<String, dynamic>).toList();

      // Parse optional deadline
      DateTime? deadline;
      final deadlineStr = body['deadline'] as String?;
      if (deadlineStr != null) {
        deadline = DateTime.tryParse(deadlineStr);
        if (deadline == null) {
          return validationErrorResponse(
            'Invalid deadline format. Use ISO 8601 format.',
            errors: [
              {'field': 'deadline', 'message': 'Invalid date format'},
            ],
          );
        }
      }

      final result = await _service.createPoll(
        spaceId: spaceId,
        userId: userId,
        question: question,
        pollType: pollType,
        options: options,
        isAnonymous: body['is_anonymous'] as bool? ?? false,
        deadline: deadline,
      );

      return createdResponse(result);
    } on PollsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create poll error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /polls?active=&cursor=&limit=
  ///
  /// Gets polls for the space with optional active filter and pagination.
  Future<Response> _getPolls(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final pagination = getPaginationParams(request);

      final activeStr = request.url.queryParameters['active'];
      bool? isActive;
      if (activeStr != null) {
        isActive = activeStr == 'true';
      }

      final polls = await _service.getPolls(
        spaceId: spaceId,
        userId: userId,
        isActive: isActive,
        cursor: pagination.cursor,
        limit: pagination.limit,
      );

      final hasMore = polls.length >= pagination.limit;
      final nextCursor = hasMore && polls.isNotEmpty
          ? polls.last['created_at'] as String
          : null;

      return paginatedResponse(polls, cursor: nextCursor, hasMore: hasMore);
    } on PollsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get polls error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /polls/:pollId
  ///
  /// Gets a single poll by ID with options and vote counts.
  Future<Response> _getPoll(Request request, String pollId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final poll = await _service.getPoll(
        pollId: pollId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(poll);
    } on PollsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get poll error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /polls/:pollId/close
  ///
  /// Closes a poll (creator or admin only).
  Future<Response> _closePoll(Request request, String pollId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final membership = getMembership(request);
      final userRole = membership?.role ?? 'member';

      await _service.closePoll(
        pollId: pollId,
        spaceId: spaceId,
        userId: userId,
        userRole: userRole,
      );

      return jsonResponse({'message': 'Poll closed'});
    } on PollsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Close poll error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /polls/:pollId/vote
  ///
  /// Casts a vote on a poll option.
  /// Body: { "option_id": "...", "rank": 1 }
  Future<Response> _castVote(Request request, String pollId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final optionId = body['option_id'] as String?;
      if (optionId == null || optionId.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'option_id', 'message': 'Option ID is required'},
          ],
        );
      }

      final rank = (body['rank'] as num?)?.toInt();

      final result = await _service.vote(
        pollId: pollId,
        spaceId: spaceId,
        userId: userId,
        optionId: optionId,
        rank: rank,
      );

      return createdResponse(result);
    } on PollsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Cast vote error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /polls/:pollId/vote/:optionId
  ///
  /// Removes a vote from a poll option.
  Future<Response> _removeVote(
    Request request,
    String pollId,
    String optionId,
  ) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      await _service.removeVote(
        pollId: pollId,
        spaceId: spaceId,
        userId: userId,
        optionId: optionId,
      );

      return noContentResponse();
    } on PollsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Remove vote error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /polls/:pollId/results
  ///
  /// Gets the results for a poll (options with vote counts and percentages).
  Future<Response> _getResults(Request request, String pollId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final results = await _service.getResults(
        pollId: pollId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(results);
    } on PollsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get results error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /polls/:pollId/random
  ///
  /// Randomly picks one of the poll options (when you just can't decide).
  Future<Response> _getRandomPick(Request request, String pollId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final option = await _service.getRandomPick(
        pollId: pollId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(option);
    } on PollsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Random pick error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
