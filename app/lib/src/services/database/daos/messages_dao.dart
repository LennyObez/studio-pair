import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'messages_dao.g.dart';

@DriftAccessor(tables: [CachedConversations, CachedMessages])
class MessagesDao extends DatabaseAccessor<AppDatabase>
    with _$MessagesDaoMixin {
  MessagesDao(super.db);

  // ==================== Conversations ====================

  /// Inserts or updates a cached conversation.
  Future<void> upsertConversation(CachedConversationsCompanion conversation) {
    try {
      return into(cachedConversations).insertOnConflictUpdate(conversation);
    } catch (e) {
      throw StorageFailure('Failed to upsert conversation: $e');
    }
  }

  /// Watches all conversations for a given space, ordered by last message time.
  Stream<List<CachedConversation>> getConversations(String spaceId) {
    try {
      return (select(cachedConversations)
            ..where((t) => t.spaceId.equals(spaceId))
            ..orderBy([(t) => OrderingTerm.desc(t.lastMessageAt)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get conversations: $e');
    }
  }

  /// Retrieves a single conversation by its ID, or null if not found.
  Future<CachedConversation?> getConversationById(String id) {
    try {
      return (select(
        cachedConversations,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      throw StorageFailure('Failed to get conversation by id: $e');
    }
  }

  /// Deletes a conversation and all its messages from the local cache.
  Future<void> deleteConversation(String id) async {
    try {
      await (delete(
        cachedMessages,
      )..where((t) => t.conversationId.equals(id))).go();
      await (delete(cachedConversations)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete conversation: $e');
    }
  }

  // ==================== Messages ====================

  /// Inserts or updates a cached message.
  Future<void> upsertMessage(CachedMessagesCompanion message) {
    try {
      return into(cachedMessages).insertOnConflictUpdate(message);
    } catch (e) {
      throw StorageFailure('Failed to upsert message: $e');
    }
  }

  /// Watches all messages in a conversation, ordered by creation time.
  Stream<List<CachedMessage>> getMessages(String conversationId) {
    try {
      return (select(cachedMessages)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get messages: $e');
    }
  }

  /// Retrieves the latest messages in a conversation with a configurable limit.
  Future<List<CachedMessage>> getLatestMessages(
    String conversationId, {
    int limit = 50,
  }) {
    try {
      return (select(cachedMessages)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .get();
    } catch (e) {
      throw StorageFailure('Failed to get latest messages: $e');
    }
  }

  /// Retrieves a single message by its ID, or null if not found.
  Future<CachedMessage?> getMessageById(String id) {
    try {
      return (select(
        cachedMessages,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      throw StorageFailure('Failed to get message by id: $e');
    }
  }

  /// Deletes a message from the local cache.
  Future<int> deleteMessage(String id) {
    try {
      return (delete(cachedMessages)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete message: $e');
    }
  }

  /// Bulk inserts messages for a conversation (used during initial sync).
  Future<void> bulkInsertMessages(
    List<CachedMessagesCompanion> messages,
  ) async {
    try {
      await batch((batch) {
        batch.insertAllOnConflictUpdate(cachedMessages, messages);
      });
    } catch (e) {
      throw StorageFailure('Failed to bulk insert messages: $e');
    }
  }

  /// Batch upserts conversations into cache.
  Future<void> upsertConversations(
    List<CachedConversationsCompanion> conversations,
  ) {
    try {
      return batch((b) {
        b.insertAll(
          cachedConversations,
          conversations,
          mode: InsertMode.insertOrReplace,
        );
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert conversations: $e');
    }
  }

  /// Batch upserts messages into cache.
  Future<void> upsertMessages(List<CachedMessagesCompanion> messages) {
    try {
      return batch((b) {
        b.insertAll(cachedMessages, messages, mode: InsertMode.insertOrReplace);
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert messages: $e');
    }
  }
}
