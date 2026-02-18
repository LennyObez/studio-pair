import 'dart:math';

import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for polls-related database operations.
class PollsRepository {
  final Database _db;
  // ignore: unused_field
  final Logger _log = Logger('PollsRepository');
  final Random _random = Random();

  PollsRepository(this._db);

  // ---------------------------------------------------------------------------
  // Polls
  // ---------------------------------------------------------------------------

  /// Creates a new poll and returns the created row.
  Future<Map<String, dynamic>> createPoll({
    required String id,
    required String spaceId,
    required String createdBy,
    required String question,
    required String pollType,
    bool isAnonymous = false,
    DateTime? deadline,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO polls (
        id, space_id, created_by, question, poll_type,
        is_anonymous, deadline, is_closed, created_at, updated_at
      )
      VALUES (
        @id, @spaceId, @createdBy, @question, @pollType,
        @isAnonymous, @deadline, false, NOW(), NOW()
      )
      RETURNING id, space_id, created_by, question, poll_type,
                is_anonymous, deadline, is_closed, created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'spaceId': spaceId,
        'createdBy': createdBy,
        'question': question,
        'pollType': pollType,
        'isAnonymous': isAnonymous,
        'deadline': deadline,
      },
    );

    return _pollRowToMap(row!);
  }

  /// Gets a poll by ID, including its options and vote counts.
  Future<Map<String, dynamic>?> getPollById(String pollId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, created_by, question, poll_type,
             is_anonymous, deadline, is_closed, created_at, updated_at
      FROM polls
      WHERE id = @pollId AND deleted_at IS NULL
      ''',
      parameters: {'pollId': pollId},
    );

    if (row == null) return null;

    final poll = _pollRowToMap(row);

    // Fetch options with vote counts
    final optionRows = await _db.query(
      '''
      SELECT po.id, po.poll_id, po.label, po.image_url, po.display_order,
             po.created_at,
             COUNT(pv.id) AS vote_count
      FROM poll_options po
      LEFT JOIN poll_votes pv ON pv.option_id = po.id
      WHERE po.poll_id = @pollId
      GROUP BY po.id, po.poll_id, po.label, po.image_url,
               po.display_order, po.created_at
      ORDER BY po.display_order ASC
      ''',
      parameters: {'pollId': pollId},
    );

    poll['options'] = optionRows.map(_optionWithCountRowToMap).toList();

    return poll;
  }

  /// Gets polls for a space with optional active filter and cursor pagination.
  Future<List<Map<String, dynamic>>> getPolls(
    String spaceId, {
    bool? isActive,
    String? cursor,
    int limit = 25,
  }) async {
    final conditions = <String>['space_id = @spaceId', 'deleted_at IS NULL'];
    final params = <String, dynamic>{'spaceId': spaceId, 'limit': limit};

    if (isActive != null) {
      if (isActive) {
        conditions.add('is_closed = false');
      } else {
        conditions.add('is_closed = true');
      }
    }

    if (cursor != null) {
      conditions.add('created_at < @cursor');
      params['cursor'] = DateTime.parse(cursor);
    }

    final result = await _db.query('''
      SELECT id, space_id, created_by, question, poll_type,
             is_anonymous, deadline, is_closed, created_at, updated_at
      FROM polls
      WHERE ${conditions.join(' AND ')}
      ORDER BY created_at DESC
      LIMIT @limit
      ''', parameters: params);

    return result.map(_pollRowToMap).toList();
  }

  /// Closes a poll by setting is_closed to true.
  Future<void> closePoll(String pollId) async {
    await _db.execute(
      '''
      UPDATE polls
      SET is_closed = true, updated_at = NOW()
      WHERE id = @pollId AND deleted_at IS NULL
      ''',
      parameters: {'pollId': pollId},
    );
  }

  // ---------------------------------------------------------------------------
  // Options
  // ---------------------------------------------------------------------------

  /// Adds an option to a poll.
  Future<Map<String, dynamic>> addOption({
    required String id,
    required String pollId,
    required String label,
    String? imageUrl,
    int displayOrder = 0,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO poll_options (
        id, poll_id, label, image_url, display_order, created_at
      )
      VALUES (@id, @pollId, @label, @imageUrl, @displayOrder, NOW())
      RETURNING id, poll_id, label, image_url, display_order, created_at
      ''',
      parameters: {
        'id': id,
        'pollId': pollId,
        'label': label,
        'imageUrl': imageUrl,
        'displayOrder': displayOrder,
      },
    );

    return _optionRowToMap(row!);
  }

  // ---------------------------------------------------------------------------
  // Votes
  // ---------------------------------------------------------------------------

  /// Casts a vote for a poll option (supports rank for ranked choice).
  Future<Map<String, dynamic>> castVote({
    required String id,
    required String optionId,
    required String userId,
    int? rank,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO poll_votes (id, option_id, user_id, rank, created_at)
      VALUES (@id, @optionId, @userId, @rank, NOW())
      ON CONFLICT (option_id, user_id)
      DO UPDATE SET rank = @rank
      RETURNING id, option_id, user_id, rank, created_at
      ''',
      parameters: {
        'id': id,
        'optionId': optionId,
        'userId': userId,
        'rank': rank,
      },
    );

    return _voteRowToMap(row!);
  }

  /// Removes a vote for a specific option by a user.
  Future<void> removeVote(String optionId, String userId) async {
    await _db.execute(
      '''
      DELETE FROM poll_votes
      WHERE option_id = @optionId AND user_id = @userId
      ''',
      parameters: {'optionId': optionId, 'userId': userId},
    );
  }

  /// Gets the results for a poll (options with vote counts and percentages).
  Future<Map<String, dynamic>> getResults(String pollId) async {
    final optionRows = await _db.query(
      '''
      SELECT po.id, po.poll_id, po.label, po.image_url, po.display_order,
             po.created_at,
             COUNT(pv.id) AS vote_count
      FROM poll_options po
      LEFT JOIN poll_votes pv ON pv.option_id = po.id
      WHERE po.poll_id = @pollId
      GROUP BY po.id, po.poll_id, po.label, po.image_url,
               po.display_order, po.created_at
      ORDER BY po.display_order ASC
      ''',
      parameters: {'pollId': pollId},
    );

    final options = optionRows.map(_optionWithCountRowToMap).toList();

    // Calculate total votes and percentages
    final totalVotes = options.fold<int>(
      0,
      (sum, opt) => sum + (opt['vote_count'] as int),
    );

    for (final option in options) {
      final count = option['vote_count'] as int;
      option['percentage'] = totalVotes > 0
          ? ((count / totalVotes) * 100).round()
          : 0;
    }

    return {'poll_id': pollId, 'total_votes': totalVotes, 'options': options};
  }

  /// Gets a user's votes for a specific poll.
  Future<List<Map<String, dynamic>>> getUserVotes(
    String pollId,
    String userId,
  ) async {
    final result = await _db.query(
      '''
      SELECT pv.id, pv.option_id, pv.user_id, pv.rank, pv.created_at
      FROM poll_votes pv
      JOIN poll_options po ON po.id = pv.option_id
      WHERE po.poll_id = @pollId AND pv.user_id = @userId
      ORDER BY pv.rank ASC NULLS LAST
      ''',
      parameters: {'pollId': pollId, 'userId': userId},
    );

    return result.map(_voteRowToMap).toList();
  }

  /// Gets a random option from a poll.
  Future<Map<String, dynamic>?> getRandomOption(String pollId) async {
    final optionRows = await _db.query(
      '''
      SELECT id, poll_id, label, image_url, display_order, created_at
      FROM poll_options
      WHERE poll_id = @pollId
      ORDER BY display_order ASC
      ''',
      parameters: {'pollId': pollId},
    );

    if (optionRows.isEmpty) return null;

    final randomIndex = _random.nextInt(optionRows.length);
    return _optionRowToMap(optionRows[randomIndex]);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _pollRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_by': row[2] as String,
      'question': row[3] as String,
      'poll_type': row[4] as String,
      'is_anonymous': row[5] as bool,
      'deadline': row[6] != null
          ? (row[6] as DateTime).toIso8601String()
          : null,
      'is_closed': row[7] as bool,
      'created_at': (row[8] as DateTime).toIso8601String(),
      'updated_at': (row[9] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _optionRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'poll_id': row[1] as String,
      'label': row[2] as String,
      'image_url': row[3] as String?,
      'display_order': row[4] as int,
      'created_at': (row[5] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _optionWithCountRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'poll_id': row[1] as String,
      'label': row[2] as String,
      'image_url': row[3] as String?,
      'display_order': row[4] as int,
      'created_at': (row[5] as DateTime).toIso8601String(),
      'vote_count': row[6] as int,
    };
  }

  Map<String, dynamic> _voteRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'option_id': row[1] as String,
      'user_id': row[2] as String,
      'rank': row[3] as int?,
      'created_at': (row[4] as DateTime).toIso8601String(),
    };
  }
}
