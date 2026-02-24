import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/providers/websocket_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/websocket/websocket_service.dart';

// ── Selection state ─────────────────────────────────────────────────────

/// Currently selected conversation ID.
final currentConversationIdProvider = StateProvider<String?>((ref) => null);

/// Set of user IDs currently typing.
final typingUsersProvider = StateProvider<Set<String>>((ref) => {});

// ── Conversations notifier ──────────────────────────────────────────────

/// Conversations notifier backed by the [MessagingRepository].
class ConversationsNotifier
    extends AutoDisposeAsyncNotifier<List<CachedConversation>> {
  StreamSubscription<WebSocketEvent>? _wsSubscription;

  @override
  Future<List<CachedConversation>> build() async {
    final repo = ref.watch(messagingRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;

    // Listen for real-time WebSocket events.
    final wsService = ref.watch(webSocketServiceProvider);
    unawaited(_wsSubscription?.cancel());
    _wsSubscription = wsService.events.listen(_handleWebSocketEvent);
    ref.onDispose(() => _wsSubscription?.cancel());

    if (spaceId == null) return [];
    return repo.getConversations(spaceId);
  }

  void _handleWebSocketEvent(WebSocketEvent event) {
    // Typing events are handled via a separate state provider.
    switch (event.type) {
      case 'typing.start':
        final userId = event.data['user_id'] as String?;
        if (userId != null) {
          ref.read(typingUsersProvider.notifier).state = {
            ...ref.read(typingUsersProvider),
            userId,
          };
        }
        break;
      case 'typing.stop':
        final userId = event.data['user_id'] as String?;
        if (userId != null) {
          ref.read(typingUsersProvider.notifier).state = ref
              .read(typingUsersProvider)
              .where((u) => u != userId)
              .toSet();
        }
        break;
      default:
        break;
    }
  }

  /// Create a new conversation and refresh the list.
  Future<bool> createConversation(
    String spaceId, {
    required String title,
    required String type,
    required List<String> participantIds,
  }) async {
    final repo = ref.read(messagingRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.createConversation(
        spaceId,
        title: title,
        type: type,
        participantIds: participantIds,
      );
      return repo.getConversations(spaceId);
    });
    return !state.hasError;
  }
}

/// Conversations async provider.
final conversationsProvider =
    AsyncNotifierProvider.autoDispose<
      ConversationsNotifier,
      List<CachedConversation>
    >(ConversationsNotifier.new);

// ── Messages notifier ───────────────────────────────────────────────────

/// Messages notifier for messages within the current conversation.
class MessagesNotifier extends AutoDisposeAsyncNotifier<List<CachedMessage>> {
  StreamSubscription<WebSocketEvent>? _wsSubscription;

  @override
  Future<List<CachedMessage>> build() async {
    final repo = ref.watch(messagingRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    final conversationId = ref.watch(currentConversationIdProvider);

    // Listen for real-time WebSocket events for message updates.
    final wsService = ref.watch(webSocketServiceProvider);
    unawaited(_wsSubscription?.cancel());
    _wsSubscription = wsService.events.listen(_handleMessageEvent);
    ref.onDispose(() => _wsSubscription?.cancel());

    if (spaceId == null || conversationId == null) return [];
    return repo.getMessages(spaceId, conversationId);
  }

  void _handleMessageEvent(WebSocketEvent event) {
    final currentMessages = state.valueOrNull ?? [];
    switch (event.type) {
      case 'message.new':
        // Invalidate to re-fetch from cache/API for consistency.
        ref.invalidateSelf();
        break;
      case 'message.deleted':
        final msgId = event.data['message_id'] as String?;
        if (msgId != null) {
          state = AsyncData(
            currentMessages.where((m) => m.id != msgId).toList(),
          );
        }
        break;
      default:
        break;
    }
  }

  /// Send a message in a conversation and refresh.
  Future<bool> sendMessage(
    String spaceId,
    String conversationId,
    String content, {
    String? contentType,
    String? replyToId,
  }) async {
    final repo = ref.read(messagingRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.sendMessage(
        spaceId,
        conversationId,
        content: content,
        contentType: contentType,
        replyToId: replyToId,
      );
      return repo.getMessages(spaceId, conversationId);
    });
    return !state.hasError;
  }

  /// Edit a message and refresh.
  Future<bool> editMessage(
    String spaceId,
    String conversationId,
    String messageId,
    String content,
  ) async {
    final repo = ref.read(messagingRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.editMessage(spaceId, conversationId, messageId, content);
      return repo.getMessages(spaceId, conversationId);
    });
    return !state.hasError;
  }

  /// Delete a message and refresh.
  Future<bool> deleteMessage(
    String spaceId,
    String conversationId,
    String messageId,
  ) async {
    final repo = ref.read(messagingRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteMessage(spaceId, conversationId, messageId);
      return repo.getMessages(spaceId, conversationId);
    });
    return !state.hasError;
  }
}

/// Messages async provider.
final messagesProvider =
    AsyncNotifierProvider.autoDispose<MessagesNotifier, List<CachedMessage>>(
      MessagesNotifier.new,
    );

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider wrapping the old name for backward-compat usage.
final messagingProvider = conversationsProvider;

/// Convenience provider for the conversation list.
final conversationListProvider = Provider<List<CachedConversation>>((ref) {
  return ref.watch(conversationsProvider).valueOrNull ?? [];
});

/// Convenience provider for messages in the current conversation.
final currentMessagesProvider = Provider<List<CachedMessage>>((ref) {
  return ref.watch(messagesProvider).valueOrNull ?? [];
});
