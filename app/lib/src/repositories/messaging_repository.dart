import 'package:drift/drift.dart';
import 'package:studio_pair/src/services/api/messaging_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/messages_dao.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Repository that wraps the Messaging API and DAO to provide an
/// offline-first data layer with batch cache upserts.
class MessagingRepository {
  MessagingRepository(this._api, this._dao);

  final MessagingApi _api;
  final MessagesDao _dao;

  /// Returns cached conversations, then fetches fresh from API and updates cache.
  Future<List<CachedConversation>> getConversations(String spaceId) async {
    try {
      final response = await _api.listConversations(spaceId);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedConversations,
          jsonList
              .map(
                (json) => CachedConversationsCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  type: json['type'] as String? ?? 'group',
                  title: Value(json['title'] as String?),
                  createdBy: json['created_by'] as String? ?? '',
                  lastMessagePreview: Value(
                    json['last_message_preview'] as String?,
                  ),
                  lastMessageAt: Value(
                    DateTime.tryParse(json['last_message_at'] as String? ?? ''),
                  ),
                  createdAt:
                      DateTime.tryParse(json['created_at'] as String? ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(json['updated_at'] as String? ?? '') ??
                      DateTime.now(),
                  syncedAt: DateTime.now(),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
      return _dao.getConversations(spaceId).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getConversations(spaceId).first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load conversations: $e');
    }
  }

  /// Creates a new conversation via the API.
  Future<Map<String, dynamic>> createConversation(
    String spaceId, {
    required String title,
    required String type,
    required List<String> participantIds,
  }) async {
    try {
      final response = await _api.createConversation(
        spaceId,
        title: title,
        type: type,
        participantIds: participantIds,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to create conversation: $e');
    }
  }

  /// Gets a specific conversation by ID, with cache fallback.
  Future<Map<String, dynamic>> getConversation(
    String spaceId,
    String conversationId,
  ) async {
    try {
      final response = await _api.getConversation(spaceId, conversationId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getConversationById(conversationId);
      if (cached != null) return {'id': cached.id, 'title': cached.title};
      throw UnknownFailure('Failed to get conversation: $e');
    }
  }

  /// Returns cached messages, then fetches fresh from API and updates cache.
  Future<List<CachedMessage>> getMessages(
    String spaceId,
    String conversationId,
  ) async {
    try {
      final response = await _api.getMessages(spaceId, conversationId);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedMessages,
          jsonList
              .map(
                (json) => CachedMessagesCompanion.insert(
                  id: json['id'] as String,
                  conversationId:
                      json['conversation_id'] as String? ?? conversationId,
                  senderId: json['sender_id'] as String? ?? '',
                  content: json['content'] as String? ?? '',
                  contentType: json['content_type'] as String? ?? 'text',
                  replyToMessageId: Value(
                    json['reply_to_message_id'] as String?,
                  ),
                  createdAt:
                      DateTime.tryParse(json['created_at'] as String? ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(json['updated_at'] as String? ?? '') ??
                      DateTime.now(),
                  syncedAt: DateTime.now(),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
      return _dao.getMessages(conversationId).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getMessages(conversationId).first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load messages: $e');
    }
  }

  /// Sends a message in a conversation via the API.
  Future<Map<String, dynamic>> sendMessage(
    String spaceId,
    String conversationId, {
    required String content,
    String? contentType,
    String? replyToId,
  }) async {
    try {
      final response = await _api.sendMessage(
        spaceId,
        conversationId,
        content: content,
        contentType: contentType,
        replyToId: replyToId,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to send message: $e');
    }
  }

  /// Edits an existing message via the API.
  Future<Map<String, dynamic>> editMessage(
    String spaceId,
    String conversationId,
    String messageId,
    String content,
  ) async {
    try {
      final response = await _api.editMessage(
        spaceId,
        conversationId,
        messageId,
        content,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to edit message: $e');
    }
  }

  /// Deletes a message via the API and removes from cache.
  Future<void> deleteMessage(
    String spaceId,
    String conversationId,
    String messageId,
  ) async {
    try {
      await _api.deleteMessage(spaceId, conversationId, messageId);
      await _dao.deleteMessage(messageId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete message: $e');
    }
  }

  /// Searches messages within a space.
  Future<List<Map<String, dynamic>>> searchMessages(
    String spaceId,
    String query,
  ) async {
    try {
      final response = await _api.searchMessages(spaceId, query);
      return _parseList(response.data);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to search messages: $e');
    }
  }

  /// Watches cached conversations for a space (reactive stream).
  Stream<List<CachedConversation>> watchConversations(String spaceId) {
    return _dao.getConversations(spaceId);
  }

  /// Watches cached messages for a conversation (reactive stream).
  Stream<List<CachedMessage>> watchMessages(String conversationId) {
    return _dao.getMessages(conversationId);
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
