import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'messaging_service.dart';

/// Controller for messaging and conversation endpoints.
class MessagingController {
  final MessagingService _service;
  final Logger _log = Logger('MessagingController');

  MessagingController(this._service);

  /// Returns the router with all messaging routes.
  Router get router {
    final router = Router();

    // Unread counts (must be registered before /conversations/<conversationId>
    // to avoid "unread" being captured as a conversationId parameter)
    router.get('/conversations/unread', _getUnreadCounts);

    // Conversations CRUD
    router.post('/conversations', _createConversation);
    router.get('/conversations', _getConversations);
    router.get('/conversations/<conversationId>', _getConversation);
    router.patch('/conversations/<conversationId>', _updateConversation);

    // Participants
    router.post(
      '/conversations/<conversationId>/participants',
      _addParticipant,
    );
    router.delete(
      '/conversations/<conversationId>/participants/<participantId>',
      _removeParticipant,
    );

    // Messages
    router.get('/conversations/<conversationId>/messages', _getMessages);
    router.post('/conversations/<conversationId>/messages', _sendMessage);
    router.patch('/messages/<messageId>', _editMessage);
    router.delete('/messages/<messageId>', _deleteMessage);

    // Read receipts
    router.post('/messages/<messageId>/read', _markRead);

    // Search
    router.get('/conversations/<conversationId>/search', _searchMessages);

    return router;
  }

  /// POST /conversations
  ///
  /// Creates a new conversation.
  /// Body: {
  ///   "type": "chat|mail|private_capsule",
  ///   "title": "...",
  ///   "participant_ids": ["userId1", "userId2"]
  /// }
  Future<Response> _createConversation(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final type = body['type'] as String?;
      if (type == null || type.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'type', 'message': 'Conversation type is required'},
          ],
        );
      }

      // Parse participant IDs
      var participantIds = <String>[];
      if (body['participant_ids'] != null) {
        final rawIds = body['participant_ids'] as List<dynamic>;
        participantIds = rawIds.map((e) => e as String).toList();
      }

      final result = await _service.createConversation(
        spaceId: spaceId,
        userId: userId,
        type: type,
        title: body['title'] as String?,
        participantIds: participantIds,
      );

      return createdResponse(result);
    } on MessagingException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create conversation error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /conversations?type=&cursor=&limit=
  ///
  /// Gets conversations for the current user in the space.
  Future<Response> _getConversations(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final pagination = getPaginationParams(request);
      final type = request.url.queryParameters['type'];

      final conversations = await _service.getConversations(
        spaceId: spaceId,
        userId: userId,
        type: type,
        cursor: pagination.cursor,
        limit: pagination.limit,
      );

      final hasMore = conversations.length >= pagination.limit;
      final nextCursor = conversations.isNotEmpty
          ? conversations.last['updated_at'] as String
          : null;

      return paginatedResponse(
        conversations,
        cursor: hasMore ? nextCursor : null,
        hasMore: hasMore,
      );
    } on MessagingException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get conversations error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /conversations/<conversationId>
  ///
  /// Gets a single conversation by ID with participants.
  Future<Response> _getConversation(
    Request request,
    String conversationId,
  ) async {
    try {
      final userId = getUserId(request);

      final conversation = await _service.getConversation(
        conversationId: conversationId,
        userId: userId,
      );

      return jsonResponse(conversation);
    } on MessagingException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get conversation error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /conversations/<conversationId>
  ///
  /// Updates a conversation.
  /// Body: { "title": "..." }
  Future<Response> _updateConversation(
    Request request,
    String conversationId,
  ) async {
    try {
      final userId = getUserId(request);
      final membership = getMembership(request);
      final userRole = membership?.role ?? 'member';
      final body = await readJsonBody(request);

      final updates = <String, dynamic>{};

      if (body.containsKey('title')) {
        updates['title'] = body['title'];
      }

      final result = await _service.updateConversation(
        conversationId: conversationId,
        userId: userId,
        userRole: userRole,
        updates: updates,
      );

      return jsonResponse(result);
    } on MessagingException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update conversation error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /conversations/<conversationId>/participants
  ///
  /// Adds a participant to a conversation.
  /// Body: { "user_id": "..." }
  Future<Response> _addParticipant(
    Request request,
    String conversationId,
  ) async {
    try {
      final userId = getUserId(request);
      final membership = getMembership(request);
      final userRole = membership?.role ?? 'member';
      final body = await readJsonBody(request);

      final participantId = body['user_id'] as String?;
      if (participantId == null || participantId.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'user_id', 'message': 'User ID is required'},
          ],
        );
      }

      await _service.addParticipant(
        conversationId: conversationId,
        userId: userId,
        userRole: userRole,
        participantId: participantId,
      );

      return noContentResponse();
    } on MessagingException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Add participant error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /conversations/<conversationId>/participants/<participantId>
  ///
  /// Removes a participant from a conversation.
  Future<Response> _removeParticipant(
    Request request,
    String conversationId,
    String participantId,
  ) async {
    try {
      final userId = getUserId(request);
      final membership = getMembership(request);
      final userRole = membership?.role ?? 'member';

      await _service.removeParticipant(
        conversationId: conversationId,
        userId: userId,
        userRole: userRole,
        participantId: participantId,
      );

      return noContentResponse();
    } on MessagingException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Remove participant error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /conversations/<conversationId>/messages?cursor=&limit=
  ///
  /// Gets paginated messages for a conversation.
  Future<Response> _getMessages(Request request, String conversationId) async {
    try {
      final userId = getUserId(request);
      final pagination = getPaginationParams(request);

      final messages = await _service.getMessages(
        conversationId: conversationId,
        userId: userId,
        cursor: pagination.cursor,
        limit: pagination.limit,
      );

      final hasMore = messages.length >= pagination.limit;
      final nextCursor = messages.isNotEmpty
          ? messages.last['created_at'] as String
          : null;

      return paginatedResponse(
        messages,
        cursor: hasMore ? nextCursor : null,
        hasMore: hasMore,
      );
    } on MessagingException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get messages error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /conversations/<conversationId>/messages
  ///
  /// Sends a message in a conversation.
  /// Body: {
  ///   "content": "...",
  ///   "content_type": "text|image|file",
  ///   "reply_to_message_id": "..."
  /// }
  Future<Response> _sendMessage(Request request, String conversationId) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);

      final content = body['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'content', 'message': 'Message content is required'},
          ],
        );
      }

      final result = await _service.sendMessage(
        conversationId: conversationId,
        userId: userId,
        content: content,
        contentType: body['content_type'] as String? ?? 'text',
        replyToMessageId: body['reply_to_message_id'] as String?,
      );

      return createdResponse(result);
    } on MessagingException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Send message error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /messages/<messageId>
  ///
  /// Edits a message.
  /// Body: { "content": "..." }
  Future<Response> _editMessage(Request request, String messageId) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);

      final content = body['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'content', 'message': 'Message content is required'},
          ],
        );
      }

      final result = await _service.editMessage(
        messageId: messageId,
        userId: userId,
        content: content,
      );

      return jsonResponse(result);
    } on MessagingException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Edit message error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /messages/<messageId>
  ///
  /// Soft-deletes a message.
  Future<Response> _deleteMessage(Request request, String messageId) async {
    try {
      final userId = getUserId(request);

      await _service.deleteMessage(messageId: messageId, userId: userId);

      return noContentResponse();
    } on MessagingException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete message error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /messages/<messageId>/read
  ///
  /// Marks a message as read for the current user.
  Future<Response> _markRead(Request request, String messageId) async {
    try {
      final userId = getUserId(request);

      await _service.markRead(messageId: messageId, userId: userId);

      return noContentResponse();
    } on MessagingException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Mark read error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /conversations/<conversationId>/search?q=
  ///
  /// Searches messages in a conversation.
  Future<Response> _searchMessages(
    Request request,
    String conversationId,
  ) async {
    try {
      final userId = getUserId(request);
      final query = request.url.queryParameters['q'];

      if (query == null || query.trim().isEmpty) {
        return validationErrorResponse(
          'Missing required query parameter',
          errors: [
            {'field': 'q', 'message': 'Search query is required'},
          ],
        );
      }

      final messages = await _service.searchMessages(
        conversationId: conversationId,
        userId: userId,
        query: query,
      );

      return jsonResponse({'data': messages});
    } on MessagingException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Search messages error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /conversations/unread
  ///
  /// Gets unread message counts for the current user's conversations.
  Future<Response> _getUnreadCounts(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final counts = await _service.getUnreadCounts(
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse({'data': counts});
    } on MessagingException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get unread counts error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
