import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

import '../../config/database.dart';

/// Repository for messaging-related database operations.
class MessagingRepository {
  final Database _db;
  // ignore: unused_field
  final Logger _log = Logger('MessagingRepository');

  MessagingRepository(this._db);

  // ---------------------------------------------------------------------------
  // Conversations
  // ---------------------------------------------------------------------------

  /// Creates a new conversation with participants within a transaction.
  ///
  /// Inserts the conversation row and all participant rows atomically.
  Future<Map<String, dynamic>> createConversation({
    required String id,
    required String spaceId,
    required String type,
    String? title,
    required String createdBy,
    required List<String> participantIds,
  }) async {
    return _db.transaction((session) async {
      // Insert conversation
      final convResult = await session.execute(
        Sql.named('''
        INSERT INTO conversations (
          id, space_id, type, title, created_by, created_at, updated_at
        )
        VALUES (
          @id, @spaceId, @type, @title, @createdBy, NOW(), NOW()
        )
        RETURNING id, space_id, type, title, created_by, created_at, updated_at
        '''),
        parameters: {
          'id': id,
          'spaceId': spaceId,
          'type': type,
          'title': title,
          'createdBy': createdBy,
        },
      );

      final convRow = convResult.first;

      // Insert all participants
      for (final participantId in participantIds) {
        await session.execute(
          Sql.named('''
          INSERT INTO conversation_participants (
            conversation_id, user_id, joined_at
          )
          VALUES (@conversationId, @userId, NOW())
          '''),
          parameters: {'conversationId': id, 'userId': participantId},
        );
      }

      final conversation = _conversationRowToMap(convRow);

      // Fetch participants with user info
      final participantResult = await session.execute(
        Sql.named('''
        SELECT cp.user_id, cp.joined_at, cp.left_at,
               u.display_name, u.email, u.avatar_url
        FROM conversation_participants cp
        JOIN users u ON u.id = cp.user_id
        WHERE cp.conversation_id = @conversationId AND cp.left_at IS NULL
        ORDER BY cp.joined_at ASC
        '''),
        parameters: {'conversationId': id},
      );

      conversation['participants'] = participantResult
          .map(_participantRowToMap)
          .toList();

      return conversation;
    });
  }

  /// Gets a conversation by ID, including its participants.
  Future<Map<String, dynamic>?> getConversationById(
    String conversationId,
  ) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, type, title, created_by, created_at, updated_at
      FROM conversations
      WHERE id = @conversationId
      ''',
      parameters: {'conversationId': conversationId},
    );

    if (row == null) return null;

    final conversation = _conversationRowToMap(row);

    // Fetch participants with user info
    final participantRows = await _db.query(
      '''
      SELECT cp.user_id, cp.joined_at, cp.left_at,
             u.display_name, u.email, u.avatar_url
      FROM conversation_participants cp
      JOIN users u ON u.id = cp.user_id
      WHERE cp.conversation_id = @conversationId AND cp.left_at IS NULL
      ORDER BY cp.joined_at ASC
      ''',
      parameters: {'conversationId': conversationId},
    );

    conversation['participants'] = participantRows
        .map(_participantRowToMap)
        .toList();

    return conversation;
  }

  /// Gets conversations for a user in a space, ordered by last update time.
  ///
  /// Supports cursor-based pagination and optional type filtering.
  Future<List<Map<String, dynamic>>> getConversations({
    required String spaceId,
    required String userId,
    String? type,
    String? cursor,
    int limit = 25,
  }) async {
    var sql = '''
      SELECT c.id, c.space_id, c.type, c.title, c.created_by,
             c.created_at, c.updated_at
      FROM conversations c
      JOIN conversation_participants cp ON cp.conversation_id = c.id
      WHERE c.space_id = @spaceId
        AND cp.user_id = @userId
        AND cp.left_at IS NULL
    ''';

    final params = <String, dynamic>{
      'spaceId': spaceId,
      'userId': userId,
      'limit': limit,
    };

    if (type != null) {
      sql += ' AND c.type = @type';
      params['type'] = type;
    }

    if (cursor != null) {
      sql += ' AND c.updated_at < @cursor';
      params['cursor'] = DateTime.parse(cursor);
    }

    sql += ' ORDER BY c.updated_at DESC LIMIT @limit';

    final result = await _db.query(sql, parameters: params);

    return result.map(_conversationRowToMap).toList();
  }

  /// Updates a conversation with the given fields.
  Future<Map<String, dynamic>?> updateConversation(
    String conversationId,
    Map<String, dynamic> updates,
  ) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'conversationId': conversationId};

    if (updates.containsKey('title')) {
      setClauses.add('title = @title');
      params['title'] = updates['title'];
    }

    if (setClauses.isEmpty) return getConversationById(conversationId);

    setClauses.add('updated_at = NOW()');

    final row = await _db.queryOne('''
      UPDATE conversations
      SET ${setClauses.join(', ')}
      WHERE id = @conversationId
      RETURNING id, space_id, type, title, created_by, created_at, updated_at
      ''', parameters: params);

    if (row == null) return null;
    return _conversationRowToMap(row);
  }

  // ---------------------------------------------------------------------------
  // Participants
  // ---------------------------------------------------------------------------

  /// Adds a participant to a conversation.
  Future<void> addParticipant(String conversationId, String userId) async {
    await _db.execute(
      '''
      INSERT INTO conversation_participants (
        conversation_id, user_id, joined_at
      )
      VALUES (@conversationId, @userId, NOW())
      ''',
      parameters: {'conversationId': conversationId, 'userId': userId},
    );
  }

  /// Removes a participant from a conversation by setting left_at.
  Future<void> removeParticipant(String conversationId, String userId) async {
    await _db.execute(
      '''
      UPDATE conversation_participants
      SET left_at = NOW()
      WHERE conversation_id = @conversationId
        AND user_id = @userId
        AND left_at IS NULL
      ''',
      parameters: {'conversationId': conversationId, 'userId': userId},
    );
  }

  /// Gets all active participants for a conversation with user info.
  Future<List<Map<String, dynamic>>> getParticipants(
    String conversationId,
  ) async {
    final result = await _db.query(
      '''
      SELECT cp.user_id, cp.joined_at, cp.left_at,
             u.display_name, u.email, u.avatar_url
      FROM conversation_participants cp
      JOIN users u ON u.id = cp.user_id
      WHERE cp.conversation_id = @conversationId AND cp.left_at IS NULL
      ORDER BY cp.joined_at ASC
      ''',
      parameters: {'conversationId': conversationId},
    );

    return result.map(_participantRowToMap).toList();
  }

  /// Checks if a user is an active participant of a conversation.
  Future<bool> isParticipant(String conversationId, String userId) async {
    final row = await _db.queryOne(
      '''
      SELECT 1
      FROM conversation_participants
      WHERE conversation_id = @conversationId
        AND user_id = @userId
        AND left_at IS NULL
      ''',
      parameters: {'conversationId': conversationId, 'userId': userId},
    );

    return row != null;
  }

  // ---------------------------------------------------------------------------
  // Messages
  // ---------------------------------------------------------------------------

  /// Creates a new message and updates the conversation's updated_at timestamp.
  Future<Map<String, dynamic>> createMessage({
    required String id,
    required String conversationId,
    required String senderId,
    required String contentEncrypted,
    String contentType = 'text',
    String? replyToMessageId,
  }) async {
    return _db.transaction((session) async {
      // Insert message
      final msgResult = await session.execute(
        Sql.named('''
        INSERT INTO messages (
          id, conversation_id, sender_id, content_encrypted,
          content_type, reply_to_message_id,
          is_edited, created_at, updated_at
        )
        VALUES (
          @id, @conversationId, @senderId, @contentEncrypted,
          @contentType, @replyToMessageId,
          false, NOW(), NOW()
        )
        RETURNING id, conversation_id, sender_id, content_encrypted,
                  content_type, reply_to_message_id, is_edited,
                  created_at, updated_at, deleted_at
        '''),
        parameters: {
          'id': id,
          'conversationId': conversationId,
          'senderId': senderId,
          'contentEncrypted': contentEncrypted,
          'contentType': contentType,
          'replyToMessageId': replyToMessageId,
        },
      );

      // Update conversation updated_at
      await session.execute(
        Sql.named('''
        UPDATE conversations
        SET updated_at = NOW()
        WHERE id = @conversationId
        '''),
        parameters: {'conversationId': conversationId},
      );

      return _messageRowToMap(msgResult.first);
    });
  }

  /// Gets paginated messages for a conversation, ordered by creation time descending.
  ///
  /// Includes sender info for each message.
  Future<List<Map<String, dynamic>>> getMessages(
    String conversationId, {
    String? cursor,
    int limit = 25,
  }) async {
    var sql = '''
      SELECT m.id, m.conversation_id, m.sender_id, m.content_encrypted,
             m.content_type, m.reply_to_message_id, m.is_edited,
             m.created_at, m.updated_at, m.deleted_at,
             u.display_name, u.email, u.avatar_url
      FROM messages m
      JOIN users u ON u.id = m.sender_id
      WHERE m.conversation_id = @conversationId
    ''';

    final params = <String, dynamic>{
      'conversationId': conversationId,
      'limit': limit,
    };

    if (cursor != null) {
      sql += ' AND m.created_at < @cursor';
      params['cursor'] = DateTime.parse(cursor);
    }

    sql += ' ORDER BY m.created_at DESC LIMIT @limit';

    final result = await _db.query(sql, parameters: params);

    return result.map(_messageWithSenderRowToMap).toList();
  }

  /// Gets a single message by ID.
  Future<Map<String, dynamic>?> getMessageById(String messageId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, conversation_id, sender_id, content_encrypted,
             content_type, reply_to_message_id, is_edited,
             created_at, updated_at, deleted_at
      FROM messages
      WHERE id = @messageId
      ''',
      parameters: {'messageId': messageId},
    );

    if (row == null) return null;
    return _messageRowToMap(row);
  }

  /// Updates a message's content and marks it as edited.
  Future<Map<String, dynamic>?> updateMessage(
    String messageId,
    String contentEncrypted,
  ) async {
    final row = await _db.queryOne(
      '''
      UPDATE messages
      SET content_encrypted = @contentEncrypted,
          is_edited = true,
          updated_at = NOW()
      WHERE id = @messageId AND deleted_at IS NULL
      RETURNING id, conversation_id, sender_id, content_encrypted,
                content_type, reply_to_message_id, is_edited,
                created_at, updated_at, deleted_at
      ''',
      parameters: {
        'messageId': messageId,
        'contentEncrypted': contentEncrypted,
      },
    );

    if (row == null) return null;
    return _messageRowToMap(row);
  }

  /// Soft-deletes a message by setting deleted_at.
  Future<void> softDeleteMessage(String messageId) async {
    await _db.execute(
      '''
      UPDATE messages
      SET deleted_at = NOW(), updated_at = NOW()
      WHERE id = @messageId AND deleted_at IS NULL
      ''',
      parameters: {'messageId': messageId},
    );
  }

  // ---------------------------------------------------------------------------
  // Read Receipts
  // ---------------------------------------------------------------------------

  /// Creates or updates a read receipt for a user on a message (upsert).
  Future<void> createReadReceipt(String messageId, String userId) async {
    await _db.execute(
      '''
      INSERT INTO message_read_receipts (message_id, user_id, read_at)
      VALUES (@messageId, @userId, NOW())
      ON CONFLICT (message_id, user_id)
      DO UPDATE SET read_at = NOW()
      ''',
      parameters: {'messageId': messageId, 'userId': userId},
    );
  }

  /// Gets all read receipts for a message with user info.
  Future<List<Map<String, dynamic>>> getReadReceipts(String messageId) async {
    final result = await _db.query(
      '''
      SELECT mrr.message_id, mrr.user_id, mrr.read_at,
             u.display_name, u.email, u.avatar_url
      FROM message_read_receipts mrr
      JOIN users u ON u.id = mrr.user_id
      WHERE mrr.message_id = @messageId
      ORDER BY mrr.read_at ASC
      ''',
      parameters: {'messageId': messageId},
    );

    return result.map(_readReceiptRowToMap).toList();
  }

  /// Gets the count of unread messages in a conversation for a user.
  ///
  /// Counts messages created after the user's most recent read receipt
  /// in the conversation.
  Future<int> getUnreadCount(String conversationId, String userId) async {
    final row = await _db.queryOne(
      '''
      SELECT COUNT(*)
      FROM messages m
      WHERE m.conversation_id = @conversationId
        AND m.sender_id != @userId
        AND m.deleted_at IS NULL
        AND m.created_at > COALESCE(
          (
            SELECT MAX(mrr.read_at)
            FROM message_read_receipts mrr
            JOIN messages rm ON rm.id = mrr.message_id
            WHERE rm.conversation_id = @conversationId
              AND mrr.user_id = @userId
          ),
          '1970-01-01'::timestamp
        )
      ''',
      parameters: {'conversationId': conversationId, 'userId': userId},
    );

    return (row?[0] as int?) ?? 0;
  }

  /// Searches messages in a conversation by content (standard tier only).
  ///
  /// Only searches non-deleted messages using ILIKE pattern matching.
  Future<List<Map<String, dynamic>>> searchMessages(
    String conversationId,
    String query,
  ) async {
    final result = await _db.query(
      '''
      SELECT m.id, m.conversation_id, m.sender_id, m.content_encrypted,
             m.content_type, m.reply_to_message_id, m.is_edited,
             m.created_at, m.updated_at, m.deleted_at,
             u.display_name, u.email, u.avatar_url
      FROM messages m
      JOIN users u ON u.id = m.sender_id
      WHERE m.conversation_id = @conversationId
        AND m.deleted_at IS NULL
        AND m.content_encrypted ILIKE @query
      ORDER BY m.created_at DESC
      LIMIT 50
      ''',
      parameters: {'conversationId': conversationId, 'query': '%$query%'},
    );

    return result.map(_messageWithSenderRowToMap).toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _conversationRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'type': row[2] as String,
      'title': row[3] as String?,
      'created_by': row[4] as String,
      'created_at': (row[5] as DateTime).toIso8601String(),
      'updated_at': (row[6] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _participantRowToMap(dynamic row) {
    return {
      'user_id': row[0] as String,
      'joined_at': (row[1] as DateTime).toIso8601String(),
      'left_at': row[2] != null ? (row[2] as DateTime).toIso8601String() : null,
      'user': {
        'display_name': row[3] as String,
        'email': row[4] as String,
        'avatar_url': row[5] as String?,
      },
    };
  }

  Map<String, dynamic> _messageRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'conversation_id': row[1] as String,
      'sender_id': row[2] as String,
      'content_encrypted': row[3] as String,
      'content_type': row[4] as String,
      'reply_to_message_id': row[5] as String?,
      'is_edited': row[6] as bool,
      'created_at': (row[7] as DateTime).toIso8601String(),
      'updated_at': (row[8] as DateTime).toIso8601String(),
      'deleted_at': row[9] != null
          ? (row[9] as DateTime).toIso8601String()
          : null,
    };
  }

  Map<String, dynamic> _messageWithSenderRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'conversation_id': row[1] as String,
      'sender_id': row[2] as String,
      'content_encrypted': row[3] as String,
      'content_type': row[4] as String,
      'reply_to_message_id': row[5] as String?,
      'is_edited': row[6] as bool,
      'created_at': (row[7] as DateTime).toIso8601String(),
      'updated_at': (row[8] as DateTime).toIso8601String(),
      'deleted_at': row[9] != null
          ? (row[9] as DateTime).toIso8601String()
          : null,
      'sender': {
        'display_name': row[10] as String,
        'email': row[11] as String,
        'avatar_url': row[12] as String?,
      },
    };
  }

  Map<String, dynamic> _readReceiptRowToMap(dynamic row) {
    return {
      'message_id': row[0] as String,
      'user_id': row[1] as String,
      'read_at': (row[2] as DateTime).toIso8601String(),
      'user': {
        'display_name': row[3] as String,
        'email': row[4] as String,
        'avatar_url': row[5] as String?,
      },
    };
  }
}
