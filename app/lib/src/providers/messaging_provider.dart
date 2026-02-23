import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/websocket_provider.dart';
import 'package:studio_pair/src/services/api/messaging_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/messages_dao.dart';
import 'package:studio_pair/src/services/websocket/websocket_service.dart';

/// Conversation model.
class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    required this.type,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.participantNames = const [],
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      type: json['type'] ?? 'chat',
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      participantNames: (json['participants'] as List?)?.cast<String>() ?? [],
    );
  }

  final String id;
  final String title;
  final String type; // chat, mail, private_capsule
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final List<String> participantNames;
}

/// Message model.
class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.contentType,
    this.replyToId,
    required this.createdAt,
    this.editedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      content: json['content'],
      contentType: json['content_type'] ?? 'text',
      replyToId: json['reply_to_id'],
      createdAt: DateTime.parse(json['sent_at']),
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'])
          : null,
    );
  }

  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final String contentType; // text, image, file
  final String? replyToId;
  final DateTime createdAt;
  final DateTime? editedAt;
}

/// Messaging state.
class MessagingState {
  const MessagingState({
    this.conversations = const [],
    this.currentConversation,
    this.messages = const [],
    this.isLoading = false,
    this.isCached = false,
    this.error,
    this.cursor,
    this.hasMore = false,
    this.typingUsers = const {},
  });

  final List<Conversation> conversations;
  final Conversation? currentConversation;
  final List<Message> messages;
  final bool isLoading;
  final bool isCached;
  final String? error;
  final String? cursor;
  final bool hasMore;
  final Set<String> typingUsers;

  MessagingState copyWith({
    List<Conversation>? conversations,
    Conversation? currentConversation,
    List<Message>? messages,
    bool? isLoading,
    bool? isCached,
    String? error,
    String? cursor,
    bool? hasMore,
    bool clearError = false,
    bool clearCurrentConversation = false,
    bool clearCursor = false,
    Set<String>? typingUsers,
  }) {
    return MessagingState(
      conversations: conversations ?? this.conversations,
      currentConversation: clearCurrentConversation
          ? null
          : (currentConversation ?? this.currentConversation),
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      error: clearError ? null : (error ?? this.error),
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      hasMore: hasMore ?? this.hasMore,
      typingUsers: typingUsers ?? this.typingUsers,
    );
  }
}

/// Messaging state notifier managing conversations and messages.
class MessagingNotifier extends StateNotifier<MessagingState> {
  MessagingNotifier(this._api, this._dao, {AppWebSocketService? wsService})
    : super(const MessagingState()) {
    if (wsService != null) {
      _wsSubscription = wsService.events.listen(_handleWebSocketEvent);
    }
  }

  final MessagingApi _api;
  final MessagesDao _dao;
  StreamSubscription<WebSocketEvent>? _wsSubscription;

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }

  /// Handle incoming WebSocket events for real-time updates.
  void _handleWebSocketEvent(WebSocketEvent event) {
    switch (event.type) {
      case 'message.new':
        final msg = Message.fromJson(event.data);
        if (state.currentConversation?.id == event.data['conversation_id']) {
          state = state.copyWith(messages: [...state.messages, msg]);
        }
        break;
      case 'message.updated':
        final msg = Message.fromJson(event.data);
        final updated = state.messages.map((m) {
          return m.id == msg.id ? msg : m;
        }).toList();
        state = state.copyWith(messages: updated);
        break;
      case 'message.deleted':
        final msgId = event.data['message_id'] as String?;
        if (msgId != null) {
          state = state.copyWith(
            messages: state.messages.where((m) => m.id != msgId).toList(),
          );
        }
        break;
      case 'typing.start':
        final userId = event.data['user_id'] as String?;
        if (userId != null) {
          state = state.copyWith(typingUsers: {...state.typingUsers, userId});
        }
        break;
      case 'typing.stop':
        final userId = event.data['user_id'] as String?;
        if (userId != null) {
          state = state.copyWith(
            typingUsers: state.typingUsers.where((u) => u != userId).toSet(),
          );
        }
        break;
    }
  }

  /// Load conversations for a space with optional type filter.
  Future<void> loadConversations(String spaceId, {String? type}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // 1. Load from cache first
    try {
      final cached = await _dao.getConversations(spaceId).first;
      if (cached.isNotEmpty) {
        final conversations = cached
            .map(
              (c) => Conversation(
                id: c.id,
                title: c.title ?? '',
                type: c.type,
                lastMessage: c.lastMessagePreview,
                lastMessageAt: c.lastMessageAt,
              ),
            )
            .toList();
        state = state.copyWith(
          conversations: conversations,
          isLoading: false,
          isCached: true,
        );
      }
    } catch (_) {
      // Cache read failed, continue to API
    }

    // 2. Try API in background
    try {
      final response = await _api.listConversations(spaceId, type: type);
      final items = parseList(response.data);
      final conversations = items.map(Conversation.fromJson).toList();

      // Upsert into cache
      for (final item in conversations) {
        await _dao.upsertConversation(
          CachedConversationsCompanion(
            id: Value(item.id),
            spaceId: Value(spaceId),
            type: Value(item.type),
            title: Value(item.title),
            createdBy: const Value(''),
            lastMessagePreview: Value(item.lastMessage),
            lastMessageAt: Value(item.lastMessageAt),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
            syncedAt: Value(DateTime.now()),
          ),
        );
      }

      state = state.copyWith(
        conversations: conversations,
        isLoading: false,
        isCached: false,
      );
    } catch (e) {
      if (state.conversations.isEmpty) {
        state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Select a conversation to view its messages.
  void selectConversation(String conversationId) {
    final conversation = state.conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => state.conversations.first,
    );
    state = state.copyWith(currentConversation: conversation);
  }

  /// Load messages for a conversation.
  Future<void> loadMessages(String spaceId, String conversationId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.getMessages(spaceId, conversationId);
      final items = parseList(response.data);
      final messages = items.map(Message.fromJson).toList();

      // Extract cursor / hasMore from response if present
      final responseData = response.data;
      String? nextCursor;
      var hasMore = false;
      if (responseData is Map) {
        nextCursor = responseData['cursor'] as String?;
        hasMore = responseData['has_more'] as bool? ?? false;
      }

      state = state.copyWith(
        messages: messages,
        isLoading: false,
        cursor: nextCursor,
        hasMore: hasMore,
        clearCursor: nextCursor == null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  /// Send a new message in a conversation.
  Future<bool> sendMessage(
    String spaceId,
    String conversationId,
    String content, {
    String type = 'text',
    String? replyToId,
  }) async {
    try {
      final response = await _api.sendMessage(
        spaceId,
        conversationId,
        content: content,
        contentType: type,
        replyToId: replyToId,
      );

      final newMessage = Message.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(messages: [...state.messages, newMessage]);

      // Update the conversation's last message
      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == conversationId) {
          return Conversation(
            id: conv.id,
            title: conv.title,
            type: conv.type,
            lastMessage: content,
            lastMessageAt: DateTime.now(),
            unreadCount: conv.unreadCount,
            participantNames: conv.participantNames,
          );
        }
        return conv;
      }).toList();

      state = state.copyWith(conversations: updatedConversations);
      return true;
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return false;
    }
  }

  /// Edit an existing message.
  Future<bool> editMessage(
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
      final updated = Message.fromJson(response.data as Map<String, dynamic>);

      final updatedMessages = state.messages.map((msg) {
        if (msg.id == messageId) {
          return updated;
        }
        return msg;
      }).toList();

      state = state.copyWith(messages: updatedMessages);
      return true;
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return false;
    }
  }

  /// Delete a message.
  Future<bool> deleteMessage(
    String spaceId,
    String conversationId,
    String messageId,
  ) async {
    try {
      await _api.deleteMessage(spaceId, conversationId, messageId);

      state = state.copyWith(
        messages: state.messages.where((m) => m.id != messageId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return false;
    }
  }

  /// Create a new conversation.
  Future<bool> createConversation(
    String spaceId,
    String title,
    String type,
    List<String> participantIds,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.createConversation(
        spaceId,
        title: title,
        type: type,
        participantIds: participantIds,
      );

      final newConversation = Conversation.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        conversations: [...state.conversations, newConversation],
        currentConversation: newConversation,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Search messages across conversations.
  Future<List<Message>> searchMessages(String spaceId, String query) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.searchMessages(spaceId, query);
      final items = parseList(response.data);
      final results = items.map(Message.fromJson).toList();

      state = state.copyWith(isLoading: false);
      return results;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return [];
    }
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Messaging state provider.
final messagingProvider =
    StateNotifierProvider<MessagingNotifier, MessagingState>((ref) {
      return MessagingNotifier(
        ref.watch(messagingApiProvider),
        ref.watch(messagesDaoProvider),
        wsService: ref.watch(webSocketServiceProvider),
      );
    });

/// Convenience provider for the conversation list.
final conversationListProvider = Provider<List<Conversation>>((ref) {
  return ref.watch(messagingProvider).conversations;
});

/// Convenience provider for messages in the current conversation.
final currentMessagesProvider = Provider<List<Message>>((ref) {
  return ref.watch(messagingProvider).messages;
});

/// Convenience provider for total unread messages across all conversations.
final totalUnreadMessagesProvider = Provider<int>((ref) {
  return ref
      .watch(messagingProvider)
      .conversations
      .fold(0, (sum, conv) => sum + conv.unreadCount);
});
