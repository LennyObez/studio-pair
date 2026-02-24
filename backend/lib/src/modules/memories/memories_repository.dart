import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for memories-related database operations.
class MemoriesRepository {
  final Database _db;
  // ignore: unused_field
  final Logger _log = Logger('MemoriesRepository');

  MemoriesRepository(this._db);

  // ---------------------------------------------------------------------------
  // Memories
  // ---------------------------------------------------------------------------

  /// Creates a new memory and returns the created row.
  Future<Map<String, dynamic>> createMemory({
    required String id,
    required String spaceId,
    required String createdBy,
    required String title,
    required DateTime date,
    String? location,
    double? locationLat,
    double? locationLng,
    String? description,
    String? linkedActivityId,
    bool isMilestone = false,
    String? milestoneType,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO memories (
        id, space_id, created_by, title, date, location,
        location_lat, location_lng, description, linked_activity_id,
        is_milestone, milestone_type, created_at, updated_at
      )
      VALUES (
        @id, @spaceId, @createdBy, @title, @date, @location,
        @locationLat, @locationLng, @description, @linkedActivityId,
        @isMilestone, @milestoneType, NOW(), NOW()
      )
      RETURNING id, space_id, created_by, title, date, location,
                location_lat, location_lng, description, linked_activity_id,
                is_milestone, milestone_type, created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'spaceId': spaceId,
        'createdBy': createdBy,
        'title': title,
        'date': date,
        'location': location,
        'locationLat': locationLat,
        'locationLng': locationLng,
        'description': description,
        'linkedActivityId': linkedActivityId,
        'isMilestone': isMilestone,
        'milestoneType': milestoneType,
      },
    );

    return _memoryRowToMap(row!);
  }

  /// Gets a memory by ID, including media, participants, comments, and reactions.
  Future<Map<String, dynamic>?> getMemoryById(String memoryId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, created_by, title, date, location,
             location_lat, location_lng, description, linked_activity_id,
             is_milestone, milestone_type, created_at, updated_at
      FROM memories
      WHERE id = @memoryId AND deleted_at IS NULL
      ''',
      parameters: {'memoryId': memoryId},
    );

    if (row == null) return null;

    final memory = _memoryRowToMap(row);

    // Fetch media
    final mediaRows = await _db.query(
      '''
      SELECT id, memory_id, file_id, caption, is_cover,
             is_private, display_order, created_at
      FROM memory_media
      WHERE memory_id = @memoryId
      ORDER BY display_order ASC
      ''',
      parameters: {'memoryId': memoryId},
    );
    memory['media'] = mediaRows.map(_mediaRowToMap).toList();

    // Fetch participants
    final participantRows = await _db.query(
      '''
      SELECT mp.id, mp.memory_id, mp.user_id, mp.created_at,
             u.display_name, u.avatar_url
      FROM memory_participants mp
      JOIN users u ON u.id = mp.user_id
      WHERE mp.memory_id = @memoryId
      ORDER BY mp.created_at ASC
      ''',
      parameters: {'memoryId': memoryId},
    );
    memory['participants'] = participantRows.map(_participantRowToMap).toList();

    // Fetch comments
    final commentRows = await _db.query(
      '''
      SELECT mc.id, mc.memory_id, mc.user_id, mc.content, mc.created_at,
             u.display_name, u.avatar_url
      FROM memory_comments mc
      JOIN users u ON u.id = mc.user_id
      WHERE mc.memory_id = @memoryId
      ORDER BY mc.created_at ASC
      ''',
      parameters: {'memoryId': memoryId},
    );
    memory['comments'] = commentRows.map(_commentRowToMap).toList();

    // Fetch reactions
    final reactionRows = await _db.query(
      '''
      SELECT mr.id, mr.memory_id, mr.user_id, mr.emoji, mr.created_at,
             u.display_name
      FROM memory_reactions mr
      JOIN users u ON u.id = mr.user_id
      WHERE mr.memory_id = @memoryId
      ORDER BY mr.created_at ASC
      ''',
      parameters: {'memoryId': memoryId},
    );
    memory['reactions'] = reactionRows.map(_reactionRowToMap).toList();

    return memory;
  }

  /// Gets memories for a space with optional filters and cursor pagination.
  Future<List<Map<String, dynamic>>> getMemories(
    String spaceId, {
    DateTime? startDate,
    DateTime? endDate,
    String? createdBy,
    bool? isMilestone,
    String? cursor,
    int limit = 25,
  }) async {
    final conditions = <String>['space_id = @spaceId', 'deleted_at IS NULL'];
    final params = <String, dynamic>{'spaceId': spaceId, 'limit': limit};

    if (startDate != null) {
      conditions.add('date >= @startDate');
      params['startDate'] = startDate;
    }
    if (endDate != null) {
      conditions.add('date <= @endDate');
      params['endDate'] = endDate;
    }
    if (createdBy != null) {
      conditions.add('created_by = @createdBy');
      params['createdBy'] = createdBy;
    }
    if (isMilestone != null) {
      conditions.add('is_milestone = @isMilestone');
      params['isMilestone'] = isMilestone;
    }
    if (cursor != null) {
      conditions.add('created_at < @cursor');
      params['cursor'] = DateTime.parse(cursor);
    }

    final result = await _db.query('''
      SELECT id, space_id, created_by, title, date, location,
             location_lat, location_lng, description, linked_activity_id,
             is_milestone, milestone_type, created_at, updated_at
      FROM memories
      WHERE ${conditions.join(' AND ')}
      ORDER BY date DESC, created_at DESC
      LIMIT @limit
      ''', parameters: params);

    return result.map(_memoryRowToMap).toList();
  }

  /// Updates a memory with the given fields.
  Future<Map<String, dynamic>?> updateMemory(
    String memoryId,
    Map<String, dynamic> updates,
  ) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'memoryId': memoryId};

    if (updates.containsKey('title')) {
      setClauses.add('title = @title');
      params['title'] = updates['title'];
    }
    if (updates.containsKey('date')) {
      setClauses.add('date = @date');
      params['date'] = updates['date'];
    }
    if (updates.containsKey('location')) {
      setClauses.add('location = @location');
      params['location'] = updates['location'];
    }
    if (updates.containsKey('location_lat')) {
      setClauses.add('location_lat = @locationLat');
      params['locationLat'] = updates['location_lat'];
    }
    if (updates.containsKey('location_lng')) {
      setClauses.add('location_lng = @locationLng');
      params['locationLng'] = updates['location_lng'];
    }
    if (updates.containsKey('description')) {
      setClauses.add('description = @description');
      params['description'] = updates['description'];
    }
    if (updates.containsKey('is_milestone')) {
      setClauses.add('is_milestone = @isMilestone');
      params['isMilestone'] = updates['is_milestone'];
    }
    if (updates.containsKey('milestone_type')) {
      setClauses.add('milestone_type = @milestoneType');
      params['milestoneType'] = updates['milestone_type'];
    }

    if (setClauses.isEmpty) return getMemoryById(memoryId);

    setClauses.add('updated_at = NOW()');

    final row = await _db.queryOne('''
      UPDATE memories
      SET ${setClauses.join(', ')}
      WHERE id = @memoryId AND deleted_at IS NULL
      RETURNING id, space_id, created_by, title, date, location,
                location_lat, location_lng, description, linked_activity_id,
                is_milestone, milestone_type, created_at, updated_at
      ''', parameters: params);

    if (row == null) return null;
    return _memoryRowToMap(row);
  }

  /// Soft-deletes a memory.
  Future<void> softDeleteMemory(String memoryId) async {
    await _db.execute(
      '''
      UPDATE memories
      SET deleted_at = NOW(), updated_at = NOW()
      WHERE id = @memoryId AND deleted_at IS NULL
      ''',
      parameters: {'memoryId': memoryId},
    );
  }

  // ---------------------------------------------------------------------------
  // Media
  // ---------------------------------------------------------------------------

  /// Adds a media item to a memory.
  Future<Map<String, dynamic>> addMedia({
    required String id,
    required String memoryId,
    required String fileId,
    String? caption,
    bool isCover = false,
    bool isPrivate = false,
    int displayOrder = 0,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO memory_media (
        id, memory_id, file_id, caption, is_cover,
        is_private, display_order, created_at
      )
      VALUES (
        @id, @memoryId, @fileId, @caption, @isCover,
        @isPrivate, @displayOrder, NOW()
      )
      RETURNING id, memory_id, file_id, caption, is_cover,
                is_private, display_order, created_at
      ''',
      parameters: {
        'id': id,
        'memoryId': memoryId,
        'fileId': fileId,
        'caption': caption,
        'isCover': isCover,
        'isPrivate': isPrivate,
        'displayOrder': displayOrder,
      },
    );

    return _mediaRowToMap(row!);
  }

  /// Removes a media item.
  Future<void> removeMedia(String mediaId) async {
    await _db.execute(
      '''
      DELETE FROM memory_media
      WHERE id = @mediaId
      ''',
      parameters: {'mediaId': mediaId},
    );
  }

  // ---------------------------------------------------------------------------
  // Participants
  // ---------------------------------------------------------------------------

  /// Adds a participant to a memory.
  Future<void> addParticipant({
    required String id,
    required String memoryId,
    required String userId,
  }) async {
    await _db.execute(
      '''
      INSERT INTO memory_participants (id, memory_id, user_id, created_at)
      VALUES (@id, @memoryId, @userId, NOW())
      ON CONFLICT (memory_id, user_id) DO NOTHING
      ''',
      parameters: {'id': id, 'memoryId': memoryId, 'userId': userId},
    );
  }

  // ---------------------------------------------------------------------------
  // Comments
  // ---------------------------------------------------------------------------

  /// Adds a comment to a memory.
  Future<Map<String, dynamic>> addComment({
    required String id,
    required String memoryId,
    required String userId,
    required String content,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO memory_comments (id, memory_id, user_id, content, created_at)
      VALUES (@id, @memoryId, @userId, @content, NOW())
      RETURNING id, memory_id, user_id, content, created_at
      ''',
      parameters: {
        'id': id,
        'memoryId': memoryId,
        'userId': userId,
        'content': content,
      },
    );

    return {
      'id': row![0] as String,
      'memory_id': row[1] as String,
      'user_id': row[2] as String,
      'content': row[3] as String,
      'created_at': (row[4] as DateTime).toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // Reactions
  // ---------------------------------------------------------------------------

  /// Adds or updates a reaction on a memory (upsert).
  Future<Map<String, dynamic>> addReaction({
    required String id,
    required String memoryId,
    required String userId,
    required String emoji,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO memory_reactions (id, memory_id, user_id, emoji, created_at)
      VALUES (@id, @memoryId, @userId, @emoji, NOW())
      ON CONFLICT (memory_id, user_id)
      DO UPDATE SET emoji = @emoji
      RETURNING id, memory_id, user_id, emoji, created_at
      ''',
      parameters: {
        'id': id,
        'memoryId': memoryId,
        'userId': userId,
        'emoji': emoji,
      },
    );

    return {
      'id': row![0] as String,
      'memory_id': row[1] as String,
      'user_id': row[2] as String,
      'emoji': row[3] as String,
      'created_at': (row[4] as DateTime).toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // On This Day
  // ---------------------------------------------------------------------------

  /// Gets memories from a given month/day across previous years.
  Future<List<Map<String, dynamic>>> getOnThisDay(
    String spaceId,
    int month,
    int day,
  ) async {
    final result = await _db.query(
      '''
      SELECT id, space_id, created_by, title, date, location,
             location_lat, location_lng, description, linked_activity_id,
             is_milestone, milestone_type, created_at, updated_at
      FROM memories
      WHERE space_id = @spaceId
        AND deleted_at IS NULL
        AND EXTRACT(MONTH FROM date) = @month
        AND EXTRACT(DAY FROM date) = @day
        AND date < CURRENT_DATE
      ORDER BY date DESC
      ''',
      parameters: {'spaceId': spaceId, 'month': month, 'day': day},
    );

    return result.map(_memoryRowToMap).toList();
  }

  /// Gets all milestone memories for a space.
  Future<List<Map<String, dynamic>>> getMilestones(String spaceId) async {
    final result = await _db.query(
      '''
      SELECT id, space_id, created_by, title, date, location,
             location_lat, location_lng, description, linked_activity_id,
             is_milestone, milestone_type, created_at, updated_at
      FROM memories
      WHERE space_id = @spaceId
        AND deleted_at IS NULL
        AND is_milestone = true
      ORDER BY date DESC
      ''',
      parameters: {'spaceId': spaceId},
    );

    return result.map(_memoryRowToMap).toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _memoryRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_by': row[2] as String,
      'title': row[3] as String,
      'date': (row[4] as DateTime).toIso8601String(),
      'location': row[5] as String?,
      'location_lat': row[6] as double?,
      'location_lng': row[7] as double?,
      'description': row[8] as String?,
      'linked_activity_id': row[9] as String?,
      'is_milestone': row[10] as bool,
      'milestone_type': row[11] as String?,
      'created_at': (row[12] as DateTime).toIso8601String(),
      'updated_at': (row[13] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _mediaRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'memory_id': row[1] as String,
      'file_id': row[2] as String,
      'caption': row[3] as String?,
      'is_cover': row[4] as bool,
      'is_private': row[5] as bool,
      'display_order': row[6] as int,
      'created_at': (row[7] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _participantRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'memory_id': row[1] as String,
      'user_id': row[2] as String,
      'created_at': (row[3] as DateTime).toIso8601String(),
      'user': {
        'display_name': row[4] as String,
        'avatar_url': row[5] as String?,
      },
    };
  }

  Map<String, dynamic> _commentRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'memory_id': row[1] as String,
      'user_id': row[2] as String,
      'content': row[3] as String,
      'created_at': (row[4] as DateTime).toIso8601String(),
      'user': {
        'display_name': row[5] as String,
        'avatar_url': row[6] as String?,
      },
    };
  }

  Map<String, dynamic> _reactionRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'memory_id': row[1] as String,
      'user_id': row[2] as String,
      'emoji': row[3] as String,
      'created_at': (row[4] as DateTime).toIso8601String(),
      'user': {'display_name': row[5] as String},
    };
  }
}
