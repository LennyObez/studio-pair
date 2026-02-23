import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Messaging API service for conversations and messages within a space.
class MessagingApi {
  MessagingApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Create a new conversation in a space.
  Future<Response> createConversation(
    String spaceId, {
    required String title,
    required String type,
    required List<String> participantIds,
  }) {
    return _client.post(
      '/spaces/$spaceId/messaging/conversations',
      data: {'title': title, 'type': type, 'participant_ids': participantIds},
    );
  }

  /// List conversations in a space with optional filters.
  Future<Response> listConversations(
    String spaceId, {
    String? type,
    String? cursor,
    int? limit,
  }) {
    return _client.get(
      '/spaces/$spaceId/messaging/conversations',
      queryParameters: {
        if (type != null) 'type': type,
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
  }

  /// Get a specific conversation by ID.
  Future<Response> getConversation(String spaceId, String conversationId) {
    return _client.get(
      '/spaces/$spaceId/messaging/conversations/$conversationId',
    );
  }

  /// Send a message in a conversation.
  Future<Response> sendMessage(
    String spaceId,
    String conversationId, {
    required String content,
    String? contentType,
    String? replyToId,
  }) {
    return _client.post(
      '/spaces/$spaceId/messaging/conversations/$conversationId/messages',
      data: {
        'content': content,
        if (contentType != null) 'content_type': contentType,
        if (replyToId != null) 'reply_to_id': replyToId,
      },
    );
  }

  /// Get messages in a conversation with cursor-based pagination.
  Future<Response> getMessages(
    String spaceId,
    String conversationId, {
    String? cursor,
    int? limit,
  }) {
    return _client.get(
      '/spaces/$spaceId/messaging/conversations/$conversationId/messages',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
  }

  /// Edit an existing message.
  Future<Response> editMessage(
    String spaceId,
    String conversationId,
    String messageId,
    String content,
  ) {
    return _client.patch(
      '/spaces/$spaceId/messaging/conversations/$conversationId/messages/$messageId',
      data: {'content': content},
    );
  }

  /// Delete a message.
  Future<Response> deleteMessage(
    String spaceId,
    String conversationId,
    String messageId,
  ) {
    return _client.delete(
      '/spaces/$spaceId/messaging/conversations/$conversationId/messages/$messageId',
    );
  }

  /// Search messages within a space.
  Future<Response> searchMessages(String spaceId, String query) {
    return _client.get(
      '/spaces/$spaceId/messaging/search',
      queryParameters: {'q': query},
    );
  }
}
