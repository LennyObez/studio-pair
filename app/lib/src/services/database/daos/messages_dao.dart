import 'package:drift/drift.dart';
import '../app_database.dart';

part 'messages_dao.g.dart';

@DriftAccessor(tables: [CachedConversations, CachedMessages])
class MessagesDao extends DatabaseAccessor<AppDatabase>
    with _$MessagesDaoMixin {
  MessagesDao(super.db);

  // ==================== Conversations ====================

  /// Inserts or updates a cached conversation.
  Future<void> upsertConversation(CachedConversationsCompanion conversation) {
    return into(cachedConversations).insertOnConflictUpdate(conversation);
  }

  /// Watches all conversations for a given space, ordered by last message time.
  Stream<List<CachedConversation>> getConversations(String spaceId) {
    return (select(cachedConversations)
          ..where((t) => t.spaceId.equals(spaceId))
          ..orderBy([(t) => OrderingTerm.desc(t.lastMessageAt)]))
        .watch();
  }

  /// Retrieves a single conversation by its ID, or null if not found.
  Future<CachedConversation?> getConversationById(String id) {
    return (select(
      cachedConversations,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Deletes a conversation and all its messages from the local cache.
  Future<void> deleteConversation(String id) async {
    await (delete(
      cachedMessages,
    )..where((t) => t.conversationId.equals(id))).go();
    await (delete(cachedConversations)..where((t) => t.id.equals(id))).go();
  }

  // ==================== Messages ====================

  /// Inserts or updates a cached message.
  Future<void> upsertMessage(CachedMessagesCompanion message) {
    return into(cachedMessages).insertOnConflictUpdate(message);
  }

  /// Watches all messages in a conversation, ordered by creation time.
  Stream<List<CachedMessage>> getMessages(String conversationId) {
    return (select(cachedMessages)
          ..where((t) => t.conversationId.equals(conversationId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// Retrieves the latest messages in a conversation with a configurable limit.
  Future<List<CachedMessage>> getLatestMessages(
    String conversationId, {
    int limit = 50,
  }) {
    return (select(cachedMessages)
          ..where((t) => t.conversationId.equals(conversationId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Retrieves a single message by its ID, or null if not found.
  Future<CachedMessage?> getMessageById(String id) {
    return (select(
      cachedMessages,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Deletes a message from the local cache.
  Future<int> deleteMessage(String id) {
    return (delete(cachedMessages)..where((t) => t.id.equals(id))).go();
  }

  /// Bulk inserts messages for a conversation (used during initial sync).
  Future<void> bulkInsertMessages(
    List<CachedMessagesCompanion> messages,
  ) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(cachedMessages, messages);
    });
  }
}
