import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for activity-related database operations.
class ActivitiesRepository {
  final Database _db;
  final Logger _log = Logger('ActivitiesRepository');

  ActivitiesRepository(this._db);

  // ---------------------------------------------------------------------------
  // Activities CRUD
  // ---------------------------------------------------------------------------

  /// Creates a new activity and returns the created row.
  Future<Map<String, dynamic>> createActivity({
    required String id,
    required String spaceId,
    required String createdBy,
    required String title,
    String? description,
    String? category,
    String? thumbnailUrl,
    String? trailerUrl,
    String? externalId,
    String? externalSource,
    String privacy = 'shared',
    String mode = 'unlinked',
    Map<String, dynamic>? metadata,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO activities (
        id, space_id, created_by, title, description, category,
        thumbnail_url, trailer_url, external_id, external_source,
        privacy, mode, metadata, status, created_at, updated_at
      )
      VALUES (
        @id, @spaceId, @createdBy, @title, @description, @category,
        @thumbnailUrl, @trailerUrl, @externalId, @externalSource,
        @privacy, @mode, @metadata::jsonb, 'active', NOW(), NOW()
      )
      RETURNING id, space_id, created_by, title, description, category,
                thumbnail_url, trailer_url, external_id, external_source,
                privacy, mode, metadata, status, completed_at,
                completed_notes, deleted_at, created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'spaceId': spaceId,
        'createdBy': createdBy,
        'title': title,
        'description': description,
        'category': category,
        'thumbnailUrl': thumbnailUrl,
        'trailerUrl': trailerUrl,
        'externalId': externalId,
        'externalSource': externalSource,
        'privacy': privacy,
        'mode': mode,
        'metadata': metadata != null ? _encodeJson(metadata) : null,
      },
    );

    return _activityRowToMap(row!);
  }

  /// Gets an activity by ID, including aggregate vote info.
  Future<Map<String, dynamic>?> getActivityById(String activityId) async {
    final row = await _db.queryOne(
      '''
      SELECT a.id, a.space_id, a.created_by, a.title, a.description,
             a.category, a.thumbnail_url, a.trailer_url,
             a.external_id, a.external_source, a.privacy, a.mode,
             a.metadata, a.status, a.completed_at, a.completed_notes,
             a.deleted_at, a.created_at, a.updated_at,
             COALESCE(AVG(v.score), 0) AS avg_score,
             COUNT(v.id) AS vote_count
      FROM activities a
      LEFT JOIN activity_votes v ON v.activity_id = a.id
      WHERE a.id = @activityId
      GROUP BY a.id
      ''',
      parameters: {'activityId': activityId},
    );

    if (row == null) return null;
    return _activityWithVotesRowToMap(row);
  }

  /// Gets activities for a space with filtering and cursor-based pagination.
  Future<List<Map<String, dynamic>>> getActivities(
    String spaceId, {
    String? category,
    String? status,
    String? privacy,
    String? mode,
    String? createdBy,
    String? cursor,
    int limit = 25,
  }) async {
    final conditions = <String>['a.space_id = @spaceId'];
    final params = <String, dynamic>{
      'spaceId': spaceId,
      'limit': limit + 1, // fetch one extra to check for more
    };

    if (category != null) {
      conditions.add('a.category = @category');
      params['category'] = category;
    }

    if (status != null) {
      conditions.add('a.status = @status');
      params['status'] = status;
    } else {
      // Default: exclude deleted
      conditions.add("a.status != 'deleted'");
    }

    if (privacy != null) {
      conditions.add('a.privacy = @privacy');
      params['privacy'] = privacy;
    }

    if (mode != null) {
      conditions.add('a.mode = @mode');
      params['mode'] = mode;
    }

    if (createdBy != null) {
      conditions.add('a.created_by = @createdBy');
      params['createdBy'] = createdBy;
    }

    if (cursor != null) {
      conditions.add('a.created_at < @cursor::timestamptz');
      params['cursor'] = cursor;
    }

    final where = conditions.join(' AND ');

    final result = await _db.query('''
      SELECT a.id, a.space_id, a.created_by, a.title, a.description,
             a.category, a.thumbnail_url, a.trailer_url,
             a.external_id, a.external_source, a.privacy, a.mode,
             a.metadata, a.status, a.completed_at, a.completed_notes,
             a.deleted_at, a.created_at, a.updated_at,
             COALESCE(AVG(v.score), 0) AS avg_score,
             COUNT(v.id) AS vote_count
      FROM activities a
      LEFT JOIN activity_votes v ON v.activity_id = a.id
      WHERE $where
      GROUP BY a.id
      ORDER BY a.created_at DESC
      LIMIT @limit
      ''', parameters: params);

    return result.map(_activityWithVotesRowToMap).toList();
  }

  /// Gets activities created by a specific user within a space (their "column").
  Future<List<Map<String, dynamic>>> getActivitiesByColumn(
    String spaceId,
    String userId,
  ) async {
    final result = await _db.query(
      '''
      SELECT a.id, a.space_id, a.created_by, a.title, a.description,
             a.category, a.thumbnail_url, a.trailer_url,
             a.external_id, a.external_source, a.privacy, a.mode,
             a.metadata, a.status, a.completed_at, a.completed_notes,
             a.deleted_at, a.created_at, a.updated_at,
             COALESCE(AVG(v.score), 0) AS avg_score,
             COUNT(v.id) AS vote_count
      FROM activities a
      LEFT JOIN activity_votes v ON v.activity_id = a.id
      WHERE a.space_id = @spaceId
        AND a.created_by = @userId
        AND a.status != 'deleted'
      GROUP BY a.id
      ORDER BY a.created_at DESC
      ''',
      parameters: {'spaceId': spaceId, 'userId': userId},
    );

    return result.map(_activityWithVotesRowToMap).toList();
  }

  /// Updates an activity with the given fields.
  Future<Map<String, dynamic>?> updateActivity(
    String activityId,
    Map<String, dynamic> updates,
  ) async {
    if (updates.isEmpty) return getActivityById(activityId);

    final setClauses = <String>[];
    final params = <String, dynamic>{'activityId': activityId};

    if (updates.containsKey('title')) {
      setClauses.add('title = @title');
      params['title'] = updates['title'];
    }
    if (updates.containsKey('description')) {
      setClauses.add('description = @description');
      params['description'] = updates['description'];
    }
    if (updates.containsKey('category')) {
      setClauses.add('category = @category');
      params['category'] = updates['category'];
    }
    if (updates.containsKey('thumbnail_url')) {
      setClauses.add('thumbnail_url = @thumbnailUrl');
      params['thumbnailUrl'] = updates['thumbnail_url'];
    }
    if (updates.containsKey('trailer_url')) {
      setClauses.add('trailer_url = @trailerUrl');
      params['trailerUrl'] = updates['trailer_url'];
    }
    if (updates.containsKey('privacy')) {
      setClauses.add('privacy = @privacy');
      params['privacy'] = updates['privacy'];
    }
    if (updates.containsKey('mode')) {
      setClauses.add('mode = @mode');
      params['mode'] = updates['mode'];
    }
    if (updates.containsKey('metadata')) {
      setClauses.add('metadata = @metadata::jsonb');
      params['metadata'] = _encodeJson(
        updates['metadata'] as Map<String, dynamic>,
      );
    }

    setClauses.add('updated_at = NOW()');

    final setClause = setClauses.join(', ');

    final row = await _db.queryOne('''
      UPDATE activities
      SET $setClause
      WHERE id = @activityId AND status != 'deleted'
      RETURNING id, space_id, created_by, title, description, category,
                thumbnail_url, trailer_url, external_id, external_source,
                privacy, mode, metadata, status, completed_at,
                completed_notes, deleted_at, created_at, updated_at
      ''', parameters: params);

    if (row == null) return null;
    return _activityRowToMap(row);
  }

  /// Soft-deletes an activity by setting deleted_at and status to 'deleted'.
  Future<bool> softDeleteActivity(String activityId) async {
    final affected = await _db.execute(
      '''
      UPDATE activities
      SET deleted_at = NOW(), status = 'deleted', updated_at = NOW()
      WHERE id = @activityId AND status != 'deleted'
      ''',
      parameters: {'activityId': activityId},
    );
    return affected > 0;
  }

  /// Restores a soft-deleted activity (within 30-day window).
  Future<Map<String, dynamic>?> restoreActivity(String activityId) async {
    final row = await _db.queryOne(
      '''
      UPDATE activities
      SET deleted_at = NULL, status = 'active', updated_at = NOW()
      WHERE id = @activityId
        AND status = 'deleted'
        AND deleted_at IS NOT NULL
        AND deleted_at > NOW() - INTERVAL '30 days'
      RETURNING id, space_id, created_by, title, description, category,
                thumbnail_url, trailer_url, external_id, external_source,
                privacy, mode, metadata, status, completed_at,
                completed_notes, deleted_at, created_at, updated_at
      ''',
      parameters: {'activityId': activityId},
    );

    if (row == null) return null;
    return _activityRowToMap(row);
  }

  /// Permanently deletes activities that have been soft-deleted for more than
  /// 30 days.
  Future<int> permanentDeleteExpired() async {
    final affected = await _db.execute('''
      DELETE FROM activities
      WHERE status = 'deleted'
        AND deleted_at IS NOT NULL
        AND deleted_at < NOW() - INTERVAL '30 days'
      ''');
    _log.info('Permanently deleted $affected expired activities');
    return affected;
  }

  /// Marks an activity as completed.
  Future<Map<String, dynamic>?> completeActivity(
    String activityId, {
    String? notes,
  }) async {
    final row = await _db.queryOne(
      '''
      UPDATE activities
      SET status = 'completed',
          completed_at = NOW(),
          completed_notes = @notes,
          updated_at = NOW()
      WHERE id = @activityId AND status = 'active'
      RETURNING id, space_id, created_by, title, description, category,
                thumbnail_url, trailer_url, external_id, external_source,
                privacy, mode, metadata, status, completed_at,
                completed_notes, deleted_at, created_at, updated_at
      ''',
      parameters: {'activityId': activityId, 'notes': notes},
    );

    if (row == null) return null;
    return _activityRowToMap(row);
  }

  /// Full-text searches activities within a space using tsvector.
  Future<List<Map<String, dynamic>>> searchActivities(
    String spaceId,
    String query,
  ) async {
    final result = await _db.query(
      '''
      SELECT a.id, a.space_id, a.created_by, a.title, a.description,
             a.category, a.thumbnail_url, a.trailer_url,
             a.external_id, a.external_source, a.privacy, a.mode,
             a.metadata, a.status, a.completed_at, a.completed_notes,
             a.deleted_at, a.created_at, a.updated_at,
             COALESCE(AVG(v.score), 0) AS avg_score,
             COUNT(v.id) AS vote_count
      FROM activities a
      LEFT JOIN activity_votes v ON v.activity_id = a.id
      WHERE a.space_id = @spaceId
        AND a.status != 'deleted'
        AND (
          to_tsvector('english', COALESCE(a.title, '') || ' ' || COALESCE(a.description, ''))
          @@ plainto_tsquery('english', @query)
          OR a.title ILIKE '%' || @query || '%'
          OR a.description ILIKE '%' || @query || '%'
        )
      GROUP BY a.id
      ORDER BY a.created_at DESC
      LIMIT 50
      ''',
      parameters: {'spaceId': spaceId, 'query': query},
    );

    return result.map(_activityWithVotesRowToMap).toList();
  }

  /// Gets completed activities for a space with cursor-based pagination.
  Future<List<Map<String, dynamic>>> getCompletedActivities(
    String spaceId, {
    String? cursor,
    int limit = 25,
  }) async {
    final params = <String, dynamic>{'spaceId': spaceId, 'limit': limit + 1};

    var cursorClause = '';
    if (cursor != null) {
      cursorClause = 'AND a.completed_at < @cursor::timestamptz';
      params['cursor'] = cursor;
    }

    final result = await _db.query('''
      SELECT a.id, a.space_id, a.created_by, a.title, a.description,
             a.category, a.thumbnail_url, a.trailer_url,
             a.external_id, a.external_source, a.privacy, a.mode,
             a.metadata, a.status, a.completed_at, a.completed_notes,
             a.deleted_at, a.created_at, a.updated_at,
             COALESCE(AVG(v.score), 0) AS avg_score,
             COUNT(v.id) AS vote_count
      FROM activities a
      LEFT JOIN activity_votes v ON v.activity_id = a.id
      WHERE a.space_id = @spaceId
        AND a.status = 'completed'
        $cursorClause
      GROUP BY a.id
      ORDER BY a.completed_at DESC
      LIMIT @limit
      ''', parameters: params);

    return result.map(_activityWithVotesRowToMap).toList();
  }

  /// Gets per-user activity statistics (category breakdown) within a space.
  Future<List<Map<String, dynamic>>> getActivityStats(
    String spaceId,
    String userId,
  ) async {
    final result = await _db.query(
      '''
      SELECT category,
             COUNT(*) AS total,
             COUNT(*) FILTER (WHERE status = 'active') AS active_count,
             COUNT(*) FILTER (WHERE status = 'completed') AS completed_count
      FROM activities
      WHERE space_id = @spaceId
        AND created_by = @userId
        AND status != 'deleted'
      GROUP BY category
      ORDER BY total DESC
      ''',
      parameters: {'spaceId': spaceId, 'userId': userId},
    );

    return result.map((row) {
      return {
        'category': row[0] as String?,
        'total': row[1] as int,
        'active': row[2] as int,
        'completed': row[3] as int,
      };
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Votes
  // ---------------------------------------------------------------------------

  /// Inserts or updates a vote for a user on an activity.
  Future<Map<String, dynamic>> upsertVote({
    required String activityId,
    required String userId,
    required int score,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO activity_votes (activity_id, user_id, score, created_at, updated_at)
      VALUES (@activityId, @userId, @score, NOW(), NOW())
      ON CONFLICT (activity_id, user_id)
      DO UPDATE SET score = @score, updated_at = NOW()
      RETURNING id, activity_id, user_id, score, created_at, updated_at
      ''',
      parameters: {'activityId': activityId, 'userId': userId, 'score': score},
    );

    return _voteRowToMap(row!);
  }

  /// Deletes a vote for a user on an activity.
  Future<bool> deleteVote(String activityId, String userId) async {
    final affected = await _db.execute(
      '''
      DELETE FROM activity_votes
      WHERE activity_id = @activityId AND user_id = @userId
      ''',
      parameters: {'activityId': activityId, 'userId': userId},
    );
    return affected > 0;
  }

  /// Gets all votes for an activity, including user display names.
  Future<List<Map<String, dynamic>>> getVotesForActivity(
    String activityId,
  ) async {
    final result = await _db.query(
      '''
      SELECT v.id, v.activity_id, v.user_id, v.score,
             v.created_at, v.updated_at,
             u.display_name, u.avatar_url
      FROM activity_votes v
      JOIN users u ON u.id = v.user_id
      WHERE v.activity_id = @activityId
      ORDER BY v.created_at DESC
      ''',
      parameters: {'activityId': activityId},
    );

    return result.map((row) {
      return {
        'id': row[0] as String,
        'activity_id': row[1] as String,
        'user_id': row[2] as String,
        'score': row[3] as int,
        'created_at': (row[4] as DateTime).toIso8601String(),
        'updated_at': (row[5] as DateTime).toIso8601String(),
        'user': {
          'display_name': row[6] as String,
          'avatar_url': row[7] as String?,
        },
      };
    }).toList();
  }

  /// Gets aggregate vote information for an activity.
  Future<Map<String, dynamic>> getAggregateVotes(String activityId) async {
    // Get average and count
    final summaryRow = await _db.queryOne(
      '''
      SELECT COALESCE(AVG(score), 0) AS average,
             COUNT(*) AS count
      FROM activity_votes
      WHERE activity_id = @activityId
      ''',
      parameters: {'activityId': activityId},
    );

    final average = (summaryRow![0] as num).toDouble();
    final count = summaryRow[1] as int;

    // Get score distribution
    final distResult = await _db.query(
      '''
      SELECT score, COUNT(*) AS cnt
      FROM activity_votes
      WHERE activity_id = @activityId
      GROUP BY score
      ORDER BY score
      ''',
      parameters: {'activityId': activityId},
    );

    final scores = <String, int>{'1': 0, '2': 0, '3': 0, '4': 0, '5': 0};

    for (final row in distResult) {
      final score = row[0] as int;
      final cnt = row[1] as int;
      scores[score.toString()] = cnt;
    }

    return {'average': average, 'count': count, 'scores': scores};
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Encodes a map as a JSON string for storage in a jsonb column.
  String _encodeJson(Map<String, dynamic> data) {
    // Use a simple JSON serialization approach
    final buffer = StringBuffer('{');
    var first = true;
    for (final entry in data.entries) {
      if (!first) buffer.write(',');
      first = false;
      buffer.write('"${entry.key}":');
      if (entry.value is String) {
        buffer.write('"${entry.value}"');
      } else if (entry.value == null) {
        buffer.write('null');
      } else {
        buffer.write('${entry.value}');
      }
    }
    buffer.write('}');
    return buffer.toString();
  }

  Map<String, dynamic> _activityRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_by': row[2] as String,
      'title': row[3] as String,
      'description': row[4] as String?,
      'category': row[5] as String?,
      'thumbnail_url': row[6] as String?,
      'trailer_url': row[7] as String?,
      'external_id': row[8] as String?,
      'external_source': row[9] as String?,
      'privacy': row[10] as String,
      'mode': row[11] as String,
      'metadata': row[12],
      'status': row[13] as String,
      'completed_at': row[14] != null
          ? (row[14] as DateTime).toIso8601String()
          : null,
      'completed_notes': row[15] as String?,
      'deleted_at': row[16] != null
          ? (row[16] as DateTime).toIso8601String()
          : null,
      'created_at': (row[17] as DateTime).toIso8601String(),
      'updated_at': (row[18] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _activityWithVotesRowToMap(dynamic row) {
    final activity = _activityRowToMap(row);
    activity['avg_score'] = (row[19] as num).toDouble();
    activity['vote_count'] = row[20] as int;
    return activity;
  }

  Map<String, dynamic> _voteRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'activity_id': row[1] as String,
      'user_id': row[2] as String,
      'score': row[3] as int,
      'created_at': (row[4] as DateTime).toIso8601String(),
      'updated_at': (row[5] as DateTime).toIso8601String(),
    };
  }
}
