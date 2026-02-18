import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../services/notification_service.dart';
import '../../services/websocket_service.dart';
import '../spaces/spaces_repository.dart';
import 'messaging_repository.dart';

/// Custom exception for messaging-related errors.
class MessagingException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const MessagingException(
    this.message, {
    this.code = 'MESSAGING_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'MessagingException($code): $message';
}

/// Service containing all messaging-related business logic.
class MessagingService {
  final MessagingRepository _repo;
  final SpacesRepository _spacesRepo;
  final NotificationService _notificationService;
  final WebSocketService? _webSocketService;
  final Logger _log = Logger('MessagingService');
  final Uuid _uuid = const Uuid();

  /// Valid conversation types.
  static const _validConversationTypes = ['chat', 'mail', 'private_capsule'];

  /// Maximum time in minutes after creation that a message can be edited.
  static const _editDeadlineMinutes = 15;

  MessagingService(
    this._repo,
    this._spacesRepo,
    this._notificationService, {
    WebSocketService? webSocketService,
  }) : _webSocketService = webSocketService;

  // ---------------------------------------------------------------------------
  // Conversations
  // ---------------------------------------------------------------------------

  /// Creates a new conversation.
  ///
  /// Validates the conversation type, verifies all participants are active
  /// space members, and creates the conversation with all participants.
  Future<Map<String, dynamic>> createConversation({
    required String spaceId,
    required String userId,
    required String type,
    String? title,
    required List<String> participantIds,
  }) async {
    // Validate conversation type
    if (!_validConversationTypes.contains(type)) {
      throw MessagingException(
        'Invalid conversation type. Must be one of: ${_validConversationTypes.join(", ")}',
        code: 'INVALID_CONVERSATION_TYPE',
        statusCode: 422,
      );
    }

    // Verify creator is a space member
    await _verifySpaceMembership(spaceId, userId);

    // Ensure creator is included in participants
    final allParticipantIds = <String>{userId, ...participantIds}.toList();

    // Validate all participants are active space members
    for (final participantId in allParticipantIds) {
      if (participantId == userId) continue; // Already verified above
      final membership = await _spacesRepo.getMember(spaceId, participantId);
      if (membership == null || membership['status'] != 'active') {
        throw MessagingException(
          'User $participantId is not an active member of this space',
          code: 'PARTICIPANT_NOT_MEMBER',
          statusCode: 422,
        );
      }
    }

    final conversationId = _uuid.v4();

    final conversation = await _repo.createConversation(
      id: conversationId,
      spaceId: spaceId,
      type: type,
      title: title?.trim(),
      createdBy: userId,
      participantIds: allParticipantIds,
    );

    _log.info(
      'Conversation created: $conversationId (type=$type) in space $spaceId',
    );

    return conversation;
  }

  /// Gets a single conversation by ID.
  ///
  /// Verifies the requesting user is a participant.
  Future<Map<String, dynamic>> getConversation({
    required String conversationId,
    required String userId,
  }) async {
    // Verify user is a participant
    await _verifyParticipant(conversationId, userId);

    final conversation = await _repo.getConversationById(conversationId);
    if (conversation == null) {
      throw const MessagingException(
        'Conversation not found',
        code: 'CONVERSATION_NOT_FOUND',
        statusCode: 404,
      );
    }

    return conversation;
  }

  /// Gets conversations for a user in a space.
  ///
  /// Supports cursor-based pagination and optional type filtering.
  Future<List<Map<String, dynamic>>> getConversations({
    required String spaceId,
    required String userId,
    String? type,
    String? cursor,
    int limit = 25,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Validate type if provided
    if (type != null && !_validConversationTypes.contains(type)) {
      throw MessagingException(
        'Invalid conversation type. Must be one of: ${_validConversationTypes.join(", ")}',
        code: 'INVALID_CONVERSATION_TYPE',
        statusCode: 422,
      );
    }

    final clampedLimit = limit.clamp(1, 100);

    return _repo.getConversations(
      spaceId: spaceId,
      userId: userId,
      type: type,
      cursor: cursor,
      limit: clampedLimit,
    );
  }

  /// Updates a conversation (e.g., title).
  ///
  /// Only the creator or a space admin can update a conversation.
  Future<Map<String, dynamic>> updateConversation({
    required String conversationId,
    required String userId,
    required String userRole,
    required Map<String, dynamic> updates,
  }) async {
    final conversation = await _repo.getConversationById(conversationId);
    if (conversation == null) {
      throw const MessagingException(
        'Conversation not found',
        code: 'CONVERSATION_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify permission: creator or admin
    final isCreator = conversation['created_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdmin) {
      throw const MessagingException(
        'Only the conversation creator or a space admin can update this conversation',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    final updated = await _repo.updateConversation(conversationId, updates);
    if (updated == null) {
      throw const MessagingException(
        'Conversation not found',
        code: 'CONVERSATION_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('Conversation updated: $conversationId by $userId');

    return updated;
  }

  // ---------------------------------------------------------------------------
  // Messages
  // ---------------------------------------------------------------------------

  /// Sends a message in a conversation.
  ///
  /// Verifies the user is a participant, validates content, creates the
  /// message, and notifies other participants.
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String userId,
    required String content,
    String contentType = 'text',
    String? replyToMessageId,
  }) async {
    // Verify user is a participant
    await _verifyParticipant(conversationId, userId);

    // Validate content
    if (content.trim().isEmpty) {
      throw const MessagingException(
        'Message content cannot be empty',
        code: 'INVALID_CONTENT',
        statusCode: 422,
      );
    }

    // Validate replyToMessageId if provided
    if (replyToMessageId != null) {
      final replyTo = await _repo.getMessageById(replyToMessageId);
      if (replyTo == null) {
        throw const MessagingException(
          'Reply-to message not found',
          code: 'REPLY_MESSAGE_NOT_FOUND',
          statusCode: 404,
        );
      }
      if (replyTo['conversation_id'] != conversationId) {
        throw const MessagingException(
          'Reply-to message does not belong to this conversation',
          code: 'INVALID_REPLY',
          statusCode: 422,
        );
      }
    }

    final messageId = _uuid.v4();

    final message = await _repo.createMessage(
      id: messageId,
      conversationId: conversationId,
      senderId: userId,
      contentEncrypted: content,
      contentType: contentType,
      replyToMessageId: replyToMessageId,
    );

    // Notify other participants
    final conversation = await _repo.getConversationById(conversationId);
    if (conversation != null) {
      final participants =
          conversation['participants'] as List<Map<String, dynamic>>;
      for (final participant in participants) {
        final participantId = participant['user_id'] as String;
        if (participantId == userId) continue;

        await _notificationService.notify(
          userId: participantId,
          type: 'messaging.new_message',
          title: 'New message',
          body: conversation['title'] != null
              ? 'New message in "${conversation['title']}"'
              : 'You have a new message',
          spaceId: conversation['space_id'] as String,
          data: {'conversation_id': conversationId, 'message_id': messageId},
        );
      }
    }

    // Broadcast via WebSocket for real-time delivery
    if (_webSocketService != null && conversation != null) {
      final spaceId = conversation['space_id'] as String;
      _webSocketService.broadcastToSpace(spaceId, {
        'type': WsEventType.messageNew,
        'conversation_id': conversationId,
        'message': message,
      }, excludeUserId: userId);
    }

    _log.info('Message sent: $messageId in conversation $conversationId');

    return message;
  }

  /// Edits a message.
  ///
  /// Verifies the user is the sender and that the message is within the
  /// 15-minute edit deadline.
  Future<Map<String, dynamic>> editMessage({
    required String messageId,
    required String userId,
    required String content,
  }) async {
    final message = await _repo.getMessageById(messageId);
    if (message == null || message['deleted_at'] != null) {
      throw const MessagingException(
        'Message not found',
        code: 'MESSAGE_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify sender
    if (message['sender_id'] != userId) {
      throw const MessagingException(
        'Only the message sender can edit this message',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Check edit deadline (15 minutes from creation)
    final createdAt = DateTime.parse(message['created_at'] as String);
    final deadline = createdAt.add(
      const Duration(minutes: _editDeadlineMinutes),
    );
    if (DateTime.now().toUtc().isAfter(deadline)) {
      throw const MessagingException(
        'Message can only be edited within 15 minutes of creation',
        code: 'EDIT_DEADLINE_PASSED',
        statusCode: 422,
      );
    }

    // Validate content
    if (content.trim().isEmpty) {
      throw const MessagingException(
        'Message content cannot be empty',
        code: 'INVALID_CONTENT',
        statusCode: 422,
      );
    }

    final updated = await _repo.updateMessage(messageId, content);
    if (updated == null) {
      throw const MessagingException(
        'Message not found',
        code: 'MESSAGE_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Broadcast edit via WebSocket
    if (_webSocketService != null) {
      final conversationId = message['conversation_id'] as String;
      final conversation = await _repo.getConversationById(conversationId);
      if (conversation != null) {
        final spaceId = conversation['space_id'] as String;
        _webSocketService.broadcastToSpace(spaceId, {
          'type': WsEventType.messageUpdated,
          'conversation_id': conversationId,
          'message': updated,
        }, excludeUserId: userId);
      }
    }

    _log.info('Message edited: $messageId by $userId');

    return updated;
  }

  /// Deletes a message (soft delete).
  ///
  /// Only the message sender can delete it.
  Future<void> deleteMessage({
    required String messageId,
    required String userId,
  }) async {
    final message = await _repo.getMessageById(messageId);
    if (message == null || message['deleted_at'] != null) {
      throw const MessagingException(
        'Message not found',
        code: 'MESSAGE_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify sender
    if (message['sender_id'] != userId) {
      throw const MessagingException(
        'Only the message sender can delete this message',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.softDeleteMessage(messageId);

    // Broadcast delete via WebSocket
    if (_webSocketService != null) {
      final conversationId = message['conversation_id'] as String;
      final conversation = await _repo.getConversationById(conversationId);
      if (conversation != null) {
        final spaceId = conversation['space_id'] as String;
        _webSocketService.broadcastToSpace(spaceId, {
          'type': WsEventType.messageDeleted,
          'conversation_id': conversationId,
          'message_id': messageId,
        }, excludeUserId: userId);
      }
    }

    _log.info('Message deleted: $messageId by $userId');
  }

  /// Marks a message as read for a user.
  Future<void> markRead({
    required String messageId,
    required String userId,
  }) async {
    final message = await _repo.getMessageById(messageId);
    if (message == null) {
      throw const MessagingException(
        'Message not found',
        code: 'MESSAGE_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify user is a participant of the conversation
    final conversationId = message['conversation_id'] as String;
    await _verifyParticipant(conversationId, userId);

    await _repo.createReadReceipt(messageId, userId);

    _log.fine('Message $messageId marked as read by $userId');
  }

  /// Gets paginated messages for a conversation.
  ///
  /// Verifies the user is a participant.
  Future<List<Map<String, dynamic>>> getMessages({
    required String conversationId,
    required String userId,
    String? cursor,
    int limit = 25,
  }) async {
    // Verify user is a participant
    await _verifyParticipant(conversationId, userId);

    final clampedLimit = limit.clamp(1, 100);

    return _repo.getMessages(
      conversationId,
      cursor: cursor,
      limit: clampedLimit,
    );
  }

  /// Searches messages in a conversation.
  ///
  /// Only available for standard tier conversations (not private_capsule).
  Future<List<Map<String, dynamic>>> searchMessages({
    required String conversationId,
    required String userId,
    required String query,
  }) async {
    // Verify user is a participant
    await _verifyParticipant(conversationId, userId);

    // Check conversation type - search not allowed for private_capsule
    final conversation = await _repo.getConversationById(conversationId);
    if (conversation == null) {
      throw const MessagingException(
        'Conversation not found',
        code: 'CONVERSATION_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (conversation['type'] == 'private_capsule') {
      throw const MessagingException(
        'Search is not available for private capsule conversations',
        code: 'SEARCH_NOT_ALLOWED',
        statusCode: 403,
      );
    }

    if (query.trim().isEmpty) {
      throw const MessagingException(
        'Search query cannot be empty',
        code: 'INVALID_QUERY',
        statusCode: 422,
      );
    }

    return _repo.searchMessages(conversationId, query.trim());
  }

  // ---------------------------------------------------------------------------
  // Participants
  // ---------------------------------------------------------------------------

  /// Adds a participant to a conversation.
  ///
  /// Only the conversation creator or a space admin can add participants.
  Future<void> addParticipant({
    required String conversationId,
    required String userId,
    required String userRole,
    required String participantId,
  }) async {
    final conversation = await _repo.getConversationById(conversationId);
    if (conversation == null) {
      throw const MessagingException(
        'Conversation not found',
        code: 'CONVERSATION_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify permission: creator or admin
    final isCreator = conversation['created_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdmin) {
      throw const MessagingException(
        'Only the conversation creator or a space admin can add participants',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Verify the new participant is a space member
    final spaceId = conversation['space_id'] as String;
    final membership = await _spacesRepo.getMember(spaceId, participantId);
    if (membership == null || membership['status'] != 'active') {
      throw const MessagingException(
        'User is not an active member of this space',
        code: 'PARTICIPANT_NOT_MEMBER',
        statusCode: 422,
      );
    }

    // Check if already a participant
    final alreadyParticipant = await _repo.isParticipant(
      conversationId,
      participantId,
    );
    if (alreadyParticipant) {
      throw const MessagingException(
        'User is already a participant of this conversation',
        code: 'ALREADY_PARTICIPANT',
        statusCode: 409,
      );
    }

    await _repo.addParticipant(conversationId, participantId);

    // Notify the new participant
    await _notificationService.notify(
      userId: participantId,
      type: 'messaging.added_to_conversation',
      title: 'Added to conversation',
      body: conversation['title'] != null
          ? 'You were added to "${conversation['title']}"'
          : 'You were added to a conversation',
      spaceId: spaceId,
      data: {'conversation_id': conversationId},
    );

    _log.info(
      'Participant $participantId added to conversation $conversationId',
    );
  }

  /// Removes a participant from a conversation.
  ///
  /// The conversation creator or a space admin can remove others.
  /// A participant can also remove themselves (leave).
  Future<void> removeParticipant({
    required String conversationId,
    required String userId,
    required String userRole,
    required String participantId,
  }) async {
    final conversation = await _repo.getConversationById(conversationId);
    if (conversation == null) {
      throw const MessagingException(
        'Conversation not found',
        code: 'CONVERSATION_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Self-leave is always allowed
    final isSelfLeave = userId == participantId;

    if (!isSelfLeave) {
      // Verify permission: creator or admin to remove others
      final isCreator = conversation['created_by'] == userId;
      final isAdmin = userRole == 'admin' || userRole == 'owner';
      if (!isCreator && !isAdmin) {
        throw const MessagingException(
          'Only the conversation creator or a space admin can remove participants',
          code: 'FORBIDDEN',
          statusCode: 403,
        );
      }
    }

    // Verify the target is actually a participant
    final isTarget = await _repo.isParticipant(conversationId, participantId);
    if (!isTarget) {
      throw const MessagingException(
        'User is not a participant of this conversation',
        code: 'NOT_PARTICIPANT',
        statusCode: 404,
      );
    }

    await _repo.removeParticipant(conversationId, participantId);

    _log.info(
      'Participant $participantId removed from conversation $conversationId',
    );
  }

  // ---------------------------------------------------------------------------
  // Unread Counts
  // ---------------------------------------------------------------------------

  /// Gets unread message counts for all of a user's conversations in a space.
  Future<List<Map<String, dynamic>>> getUnreadCounts({
    required String spaceId,
    required String userId,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Get user's conversations
    final conversations = await _repo.getConversations(
      spaceId: spaceId,
      userId: userId,
      limit: 100,
    );

    final counts = <Map<String, dynamic>>[];
    for (final conversation in conversations) {
      final conversationId = conversation['id'] as String;
      final count = await _repo.getUnreadCount(conversationId, userId);
      counts.add({'conversation_id': conversationId, 'unread_count': count});
    }

    return counts;
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
      throw const MessagingException(
        'You do not have access to this space',
        code: 'SPACE_ACCESS_DENIED',
        statusCode: 403,
      );
    }
    return membership;
  }

  /// Verifies that a user is an active participant of a conversation.
  Future<void> _verifyParticipant(String conversationId, String userId) async {
    final isParticipant = await _repo.isParticipant(conversationId, userId);
    if (!isParticipant) {
      throw const MessagingException(
        'You are not a participant of this conversation',
        code: 'NOT_PARTICIPANT',
        statusCode: 403,
      );
    }
  }
}
