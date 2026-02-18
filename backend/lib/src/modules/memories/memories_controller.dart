import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'memories_service.dart';

/// Controller for shared memories/media timeline endpoints.
class MemoriesController {
  final MemoriesService _service;
  final Logger _log = Logger('MemoriesController');

  MemoriesController(this._service);

  /// Returns the router with all memory routes.
  Router get router {
    final router = Router();

    // Special endpoints (must be before /<memoryId> to avoid capture)
    router.get('/memories/on-this-day', _onThisDay);
    router.get('/memories/milestones', _getMilestones);

    // Memories CRUD
    router.post('/memories', _createMemory);
    router.get('/memories', _getMemories);
    router.get('/memories/<memoryId>', _getMemory);
    router.patch('/memories/<memoryId>', _updateMemory);
    router.delete('/memories/<memoryId>', _deleteMemory);

    // Media
    router.post('/memories/<memoryId>/media', _addMedia);
    router.delete('/memories/media/<mediaId>', _removeMedia);

    // Comments & Reactions
    router.post('/memories/<memoryId>/comments', _addComment);
    router.post('/memories/<memoryId>/reactions', _addReaction);

    return router;
  }

  /// POST /memories
  ///
  /// Creates a new memory.
  /// Body: {
  ///   "title": "...",
  ///   "date": "ISO 8601",
  ///   "location": "...",
  ///   "location_lat": 0.0,
  ///   "location_lng": 0.0,
  ///   "description": "...",
  ///   "linked_activity_id": "...",
  ///   "is_milestone": false,
  ///   "milestone_type": "..."
  /// }
  Future<Response> _createMemory(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final title = body['title'] as String?;
      final dateStr = body['date'] as String?;

      if (title == null || dateStr == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (title == null)
              {'field': 'title', 'message': 'Title is required'},
            if (dateStr == null)
              {'field': 'date', 'message': 'Date is required'},
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

      final result = await _service.createMemory(
        spaceId: spaceId,
        userId: userId,
        title: title,
        date: date,
        location: body['location'] as String?,
        locationLat: (body['location_lat'] as num?)?.toDouble(),
        locationLng: (body['location_lng'] as num?)?.toDouble(),
        description: body['description'] as String?,
        linkedActivityId: body['linked_activity_id'] as String?,
        isMilestone: body['is_milestone'] as bool? ?? false,
        milestoneType: body['milestone_type'] as String?,
      );

      return createdResponse(result);
    } on MemoriesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create memory error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /memories?startDate=&endDate=&milestone=&cursor=&limit=
  ///
  /// Gets a paginated timeline of memories.
  Future<Response> _getMemories(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final pagination = getPaginationParams(request);

      final startDateStr = request.url.queryParameters['startDate'];
      final endDateStr = request.url.queryParameters['endDate'];
      final milestoneStr = request.url.queryParameters['milestone'];

      DateTime? startDate;
      DateTime? endDate;
      bool? isMilestone;

      if (startDateStr != null) {
        startDate = DateTime.tryParse(startDateStr);
      }
      if (endDateStr != null) {
        endDate = DateTime.tryParse(endDateStr);
      }
      if (milestoneStr != null) {
        isMilestone = milestoneStr == 'true';
      }

      final memories = await _service.getTimeline(
        spaceId: spaceId,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        isMilestone: isMilestone,
        cursor: pagination.cursor,
        limit: pagination.limit,
      );

      final hasMore = memories.length >= pagination.limit;
      final nextCursor = hasMore && memories.isNotEmpty
          ? memories.last['created_at'] as String
          : null;

      return paginatedResponse(memories, cursor: nextCursor, hasMore: hasMore);
    } on MemoriesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get memories error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /memories/on-this-day
  ///
  /// Returns memories from the same date in previous years.
  Future<Response> _onThisDay(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final now = DateTime.now().toUtc();
      final memories = await _service.getOnThisDay(
        spaceId: spaceId,
        userId: userId,
        month: now.month,
        day: now.day,
      );

      return jsonResponse({'data': memories});
    } on MemoriesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('On this day error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /memories/milestones
  ///
  /// Gets all milestone memories for the space.
  Future<Response> _getMilestones(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final milestones = await _service.getMilestones(
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse({'data': milestones});
    } on MemoriesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get milestones error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /memories/:memoryId
  ///
  /// Gets a single memory with media, participants, comments, and reactions.
  Future<Response> _getMemory(Request request, String memoryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final memory = await _service.getMemory(
        memoryId: memoryId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(memory);
    } on MemoriesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get memory error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /memories/:memoryId
  ///
  /// Partially updates a memory.
  /// Body: any subset of { title, date, location, location_lat, location_lng,
  ///   description, is_milestone, milestone_type }
  Future<Response> _updateMemory(Request request, String memoryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final membership = getMembership(request);
      final userRole = membership?.role ?? 'member';
      final body = await readJsonBody(request);

      final updates = <String, dynamic>{};

      if (body.containsKey('title')) {
        updates['title'] = body['title'];
      }
      if (body.containsKey('date')) {
        final date = DateTime.tryParse(body['date'] as String);
        if (date == null) {
          return validationErrorResponse(
            'Invalid date format. Use ISO 8601 format.',
          );
        }
        updates['date'] = date;
      }
      if (body.containsKey('location')) {
        updates['location'] = body['location'];
      }
      if (body.containsKey('location_lat')) {
        updates['location_lat'] = (body['location_lat'] as num?)?.toDouble();
      }
      if (body.containsKey('location_lng')) {
        updates['location_lng'] = (body['location_lng'] as num?)?.toDouble();
      }
      if (body.containsKey('description')) {
        updates['description'] = body['description'];
      }
      if (body.containsKey('is_milestone')) {
        updates['is_milestone'] = body['is_milestone'];
      }
      if (body.containsKey('milestone_type')) {
        updates['milestone_type'] = body['milestone_type'];
      }

      final result = await _service.updateMemory(
        memoryId: memoryId,
        spaceId: spaceId,
        userId: userId,
        userRole: userRole,
        updates: updates,
      );

      return jsonResponse(result);
    } on MemoriesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update memory error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /memories/:memoryId
  ///
  /// Soft-deletes a memory.
  Future<Response> _deleteMemory(Request request, String memoryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final membership = getMembership(request);
      final userRole = membership?.role ?? 'member';

      await _service.deleteMemory(
        memoryId: memoryId,
        spaceId: spaceId,
        userId: userId,
        userRole: userRole,
      );

      return noContentResponse();
    } on MemoriesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete memory error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /memories/:memoryId/media
  ///
  /// Adds a media item to a memory.
  /// Body: {
  ///   "file_id": "...",
  ///   "caption": "...",
  ///   "is_cover": false,
  ///   "is_private": false,
  ///   "display_order": 0
  /// }
  Future<Response> _addMedia(Request request, String memoryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final fileId = body['file_id'] as String?;
      if (fileId == null || fileId.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'file_id', 'message': 'File ID is required'},
          ],
        );
      }

      final result = await _service.addMedia(
        memoryId: memoryId,
        spaceId: spaceId,
        userId: userId,
        fileId: fileId,
        caption: body['caption'] as String?,
        isCover: body['is_cover'] as bool? ?? false,
        isPrivate: body['is_private'] as bool? ?? false,
        displayOrder: (body['display_order'] as num?)?.toInt() ?? 0,
      );

      return createdResponse(result);
    } on MemoriesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Add media error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /memories/media/:mediaId
  ///
  /// Removes a media item from a memory.
  Future<Response> _removeMedia(Request request, String mediaId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      await _service.removeMedia(
        mediaId: mediaId,
        spaceId: spaceId,
        userId: userId,
      );

      return noContentResponse();
    } on MemoriesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Remove media error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /memories/:memoryId/comments
  ///
  /// Adds a comment to a memory.
  /// Body: { "content": "..." }
  Future<Response> _addComment(Request request, String memoryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final content = body['content'] as String?;
      if (content == null || content.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'content', 'message': 'Comment content is required'},
          ],
        );
      }

      final result = await _service.addComment(
        memoryId: memoryId,
        spaceId: spaceId,
        userId: userId,
        content: content,
      );

      return createdResponse(result);
    } on MemoriesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Add comment error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /memories/:memoryId/reactions
  ///
  /// Adds or updates a reaction on a memory.
  /// Body: { "emoji": "..." }
  Future<Response> _addReaction(Request request, String memoryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final emoji = body['emoji'] as String?;
      if (emoji == null || emoji.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'emoji', 'message': 'Emoji is required'},
          ],
        );
      }

      final result = await _service.addReaction(
        memoryId: memoryId,
        spaceId: spaceId,
        userId: userId,
        emoji: emoji,
      );

      return createdResponse(result);
    } on MemoriesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Add reaction error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
