import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for charter-related database operations.
class CharterRepository {
  final Database _db;
  // ignore: unused_field
  final Logger _log = Logger('CharterRepository');

  CharterRepository(this._db);

  // ---------------------------------------------------------------------------
  // Charters
  // ---------------------------------------------------------------------------

  /// Gets the charter for a space, creating one if it does not exist.
  Future<Map<String, dynamic>> getOrCreateCharter(String spaceId) async {
    // Try to find existing charter
    final existing = await _db.queryOne(
      '''
      SELECT id, space_id, created_at, updated_at
      FROM charters
      WHERE space_id = @spaceId
      ''',
      parameters: {'spaceId': spaceId},
    );

    if (existing != null) {
      return _charterRowToMap(existing);
    }

    // Create a new charter
    final row = await _db.queryOne(
      '''
      INSERT INTO charters (id, space_id, created_at, updated_at)
      VALUES (gen_random_uuid(), @spaceId, NOW(), NOW())
      RETURNING id, space_id, created_at, updated_at
      ''',
      parameters: {'spaceId': spaceId},
    );

    return _charterRowToMap(row!);
  }

  /// Gets the charter for a space with the current (latest) version content.
  Future<Map<String, dynamic>?> getCharter(String spaceId) async {
    final charter = await _db.queryOne(
      '''
      SELECT id, space_id, created_at, updated_at
      FROM charters
      WHERE space_id = @spaceId
      ''',
      parameters: {'spaceId': spaceId},
    );

    if (charter == null) return null;

    final charterMap = _charterRowToMap(charter);
    final charterId = charterMap['id'] as String;

    // Fetch the latest version
    final latestVersion = await _db.queryOne(
      '''
      SELECT id, charter_id, version_number, content, edited_by,
             change_summary, created_at
      FROM charter_versions
      WHERE charter_id = @charterId
      ORDER BY version_number DESC
      LIMIT 1
      ''',
      parameters: {'charterId': charterId},
    );

    if (latestVersion != null) {
      charterMap['current_version'] = _versionRowToMap(latestVersion);
    } else {
      charterMap['current_version'] = null;
    }

    return charterMap;
  }

  // ---------------------------------------------------------------------------
  // Versions
  // ---------------------------------------------------------------------------

  /// Creates a new version of the charter, incrementing the version number.
  Future<Map<String, dynamic>> createVersion({
    required String id,
    required String charterId,
    required String content,
    required String editedBy,
    String? changeSummary,
  }) async {
    // Get the next version number
    final countRow = await _db.queryOne(
      '''
      SELECT COALESCE(MAX(version_number), 0)
      FROM charter_versions
      WHERE charter_id = @charterId
      ''',
      parameters: {'charterId': charterId},
    );
    final nextVersion = ((countRow?[0] as int?) ?? 0) + 1;

    final row = await _db.queryOne(
      '''
      INSERT INTO charter_versions (
        id, charter_id, version_number, content, edited_by,
        change_summary, created_at
      )
      VALUES (
        @id, @charterId, @versionNumber, @content, @editedBy,
        @changeSummary, NOW()
      )
      RETURNING id, charter_id, version_number, content, edited_by,
                change_summary, created_at
      ''',
      parameters: {
        'id': id,
        'charterId': charterId,
        'versionNumber': nextVersion,
        'content': content,
        'editedBy': editedBy,
        'changeSummary': changeSummary,
      },
    );

    // Update the charter's updated_at timestamp
    await _db.execute(
      '''
      UPDATE charters SET updated_at = NOW() WHERE id = @charterId
      ''',
      parameters: {'charterId': charterId},
    );

    return _versionRowToMap(row!);
  }

  /// Gets a specific version by ID.
  Future<Map<String, dynamic>?> getVersion(String versionId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, charter_id, version_number, content, edited_by,
             change_summary, created_at
      FROM charter_versions
      WHERE id = @versionId
      ''',
      parameters: {'versionId': versionId},
    );

    if (row == null) return null;
    return _versionRowToMap(row);
  }

  /// Gets all versions for a charter, ordered by version number descending.
  Future<List<Map<String, dynamic>>> getVersionHistory(String charterId) async {
    final result = await _db.query(
      '''
      SELECT id, charter_id, version_number, content, edited_by,
             change_summary, created_at
      FROM charter_versions
      WHERE charter_id = @charterId
      ORDER BY version_number DESC
      ''',
      parameters: {'charterId': charterId},
    );

    return result.map(_versionRowToMap).toList();
  }

  // ---------------------------------------------------------------------------
  // Acknowledgments
  // ---------------------------------------------------------------------------

  /// Records an acknowledgment of a charter version by a user.
  Future<Map<String, dynamic>> acknowledgeVersion({
    required String id,
    required String versionId,
    required String userId,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO charter_acknowledgments (id, version_id, user_id, acknowledged_at)
      VALUES (@id, @versionId, @userId, NOW())
      ON CONFLICT (version_id, user_id) DO NOTHING
      RETURNING id, version_id, user_id, acknowledged_at
      ''',
      parameters: {'id': id, 'versionId': versionId, 'userId': userId},
    );

    if (row == null) {
      // Already acknowledged, fetch existing
      final existing = await _db.queryOne(
        '''
        SELECT id, version_id, user_id, acknowledged_at
        FROM charter_acknowledgments
        WHERE version_id = @versionId AND user_id = @userId
        ''',
        parameters: {'versionId': versionId, 'userId': userId},
      );
      return _acknowledgmentRowToMap(existing!);
    }

    return _acknowledgmentRowToMap(row);
  }

  /// Gets all acknowledgments for a charter version.
  Future<List<Map<String, dynamic>>> getAcknowledgments(
    String versionId,
  ) async {
    final result = await _db.query(
      '''
      SELECT ca.id, ca.version_id, ca.user_id, ca.acknowledged_at,
             u.display_name, u.avatar_url
      FROM charter_acknowledgments ca
      JOIN users u ON u.id = ca.user_id
      WHERE ca.version_id = @versionId
      ORDER BY ca.acknowledged_at ASC
      ''',
      parameters: {'versionId': versionId},
    );

    return result.map(_acknowledgmentWithUserRowToMap).toList();
  }

  /// Gets members who have NOT acknowledged a specific version.
  Future<List<Map<String, dynamic>>> getPendingAcknowledgments(
    String versionId,
    List<String> spaceMemberIds,
  ) async {
    if (spaceMemberIds.isEmpty) return [];

    final result = await _db.query(
      '''
      SELECT u.id, u.display_name, u.avatar_url
      FROM users u
      WHERE u.id = ANY(@memberIds)
        AND u.id NOT IN (
          SELECT user_id FROM charter_acknowledgments
          WHERE version_id = @versionId
        )
      ORDER BY u.display_name ASC
      ''',
      parameters: {'versionId': versionId, 'memberIds': spaceMemberIds},
    );

    return result
        .map(
          (row) => {
            'id': row[0] as String,
            'display_name': row[1] as String,
            'avatar_url': row[2] as String?,
          },
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Amendments
  // ---------------------------------------------------------------------------

  /// Creates a new charter amendment proposal.
  Future<Map<String, dynamic>> createAmendment({
    required String id,
    required String charterId,
    required String spaceId,
    required String proposedBy,
    required String title,
    required String content,
    DateTime? votingEndsAt,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO charter_amendments (
        id, charter_id, space_id, proposed_by, title, content,
        status, created_at, voting_ends_at
      )
      VALUES (
        @id, @charterId, @spaceId, @proposedBy, @title, @content,
        'proposed', NOW(), @votingEndsAt
      )
      RETURNING id, charter_id, space_id, proposed_by, title, content,
                status, created_at, voting_ends_at, resolved_at
      ''',
      parameters: {
        'id': id,
        'charterId': charterId,
        'spaceId': spaceId,
        'proposedBy': proposedBy,
        'title': title,
        'content': content,
        'votingEndsAt': votingEndsAt,
      },
    );

    return _amendmentRowToMap(row!);
  }

  /// Lists all amendments for a charter, ordered by creation date descending.
  Future<List<Map<String, dynamic>>> listAmendments(
    String charterId, {
    String? status,
  }) async {
    var sql = '''
      SELECT id, charter_id, space_id, proposed_by, title, content,
             status, created_at, voting_ends_at, resolved_at
      FROM charter_amendments
      WHERE charter_id = @charterId
    ''';
    final params = <String, dynamic>{'charterId': charterId};

    if (status != null) {
      sql += ' AND status = @status';
      params['status'] = status;
    }

    sql += ' ORDER BY created_at DESC';

    final result = await _db.query(sql, parameters: params);
    return result.map(_amendmentRowToMap).toList();
  }

  /// Gets a single amendment by ID.
  Future<Map<String, dynamic>?> getAmendment(String amendmentId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, charter_id, space_id, proposed_by, title, content,
             status, created_at, voting_ends_at, resolved_at
      FROM charter_amendments
      WHERE id = @amendmentId
      ''',
      parameters: {'amendmentId': amendmentId},
    );

    if (row == null) return null;
    return _amendmentRowToMap(row);
  }

  /// Casts a vote on an amendment. Uses ON CONFLICT to handle re-votes.
  Future<Map<String, dynamic>> castVote({
    required String id,
    required String amendmentId,
    required String userId,
    required String vote,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO charter_amendment_votes (id, amendment_id, user_id, vote, created_at)
      VALUES (@id, @amendmentId, @userId, @vote, NOW())
      ON CONFLICT (amendment_id, user_id) DO UPDATE SET
        vote = EXCLUDED.vote,
        created_at = NOW()
      RETURNING id, amendment_id, user_id, vote, created_at
      ''',
      parameters: {
        'id': id,
        'amendmentId': amendmentId,
        'userId': userId,
        'vote': vote,
      },
    );

    return _voteRowToMap(row!);
  }

  /// Gets all votes for an amendment.
  Future<List<Map<String, dynamic>>> getAmendmentVotes(
    String amendmentId,
  ) async {
    final result = await _db.query(
      '''
      SELECT cav.id, cav.amendment_id, cav.user_id, cav.vote, cav.created_at,
             u.display_name, u.avatar_url
      FROM charter_amendment_votes cav
      JOIN users u ON u.id = cav.user_id
      WHERE cav.amendment_id = @amendmentId
      ORDER BY cav.created_at ASC
      ''',
      parameters: {'amendmentId': amendmentId},
    );

    return result.map((row) {
      return {
        'id': row[0] as String,
        'amendment_id': row[1] as String,
        'user_id': row[2] as String,
        'vote': row[3] as String,
        'created_at': (row[4] as DateTime).toIso8601String(),
        'user': {
          'display_name': row[5] as String,
          'avatar_url': row[6] as String?,
        },
      };
    }).toList();
  }

  /// Gets the vote tally for an amendment.
  Future<Map<String, int>> getAmendmentVoteTally(String amendmentId) async {
    final result = await _db.query(
      '''
      SELECT vote, COUNT(*) as count
      FROM charter_amendment_votes
      WHERE amendment_id = @amendmentId
      GROUP BY vote
      ''',
      parameters: {'amendmentId': amendmentId},
    );

    final tally = <String, int>{'approve': 0, 'reject': 0};
    for (final row in result) {
      tally[row[0] as String] = row[1] as int;
    }
    return tally;
  }

  /// Updates an amendment's status and optionally its resolved_at timestamp.
  Future<Map<String, dynamic>?> finalizeAmendment(
    String amendmentId,
    String status,
  ) async {
    final row = await _db.queryOne(
      '''
      UPDATE charter_amendments
      SET status = @status, resolved_at = NOW()
      WHERE id = @amendmentId
      RETURNING id, charter_id, space_id, proposed_by, title, content,
                status, created_at, voting_ends_at, resolved_at
      ''',
      parameters: {'amendmentId': amendmentId, 'status': status},
    );

    if (row == null) return null;
    return _amendmentRowToMap(row);
  }

  /// Updates an amendment's status to 'voting' and sets the voting end date.
  Future<Map<String, dynamic>?> startVoting(
    String amendmentId,
    DateTime votingEndsAt,
  ) async {
    final row = await _db.queryOne(
      '''
      UPDATE charter_amendments
      SET status = 'voting', voting_ends_at = @votingEndsAt
      WHERE id = @amendmentId AND status = 'proposed'
      RETURNING id, charter_id, space_id, proposed_by, title, content,
                status, created_at, voting_ends_at, resolved_at
      ''',
      parameters: {'amendmentId': amendmentId, 'votingEndsAt': votingEndsAt},
    );

    if (row == null) return null;
    return _amendmentRowToMap(row);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _charterRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_at': (row[2] as DateTime).toIso8601String(),
      'updated_at': (row[3] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _versionRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'charter_id': row[1] as String,
      'version_number': row[2] as int,
      'content': row[3] as String,
      'edited_by': row[4] as String,
      'change_summary': row[5] as String?,
      'created_at': (row[6] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _acknowledgmentRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'version_id': row[1] as String,
      'user_id': row[2] as String,
      'acknowledged_at': (row[3] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _acknowledgmentWithUserRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'version_id': row[1] as String,
      'user_id': row[2] as String,
      'acknowledged_at': (row[3] as DateTime).toIso8601String(),
      'user': {
        'display_name': row[4] as String,
        'avatar_url': row[5] as String?,
      },
    };
  }

  Map<String, dynamic> _amendmentRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'charter_id': row[1] as String,
      'space_id': row[2] as String,
      'proposed_by': row[3] as String,
      'title': row[4] as String,
      'content': row[5] as String,
      'status': row[6] as String,
      'created_at': (row[7] as DateTime).toIso8601String(),
      'voting_ends_at': (row[8] as DateTime?)?.toIso8601String(),
      'resolved_at': (row[9] as DateTime?)?.toIso8601String(),
    };
  }

  Map<String, dynamic> _voteRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'amendment_id': row[1] as String,
      'user_id': row[2] as String,
      'vote': row[3] as String,
      'created_at': (row[4] as DateTime).toIso8601String(),
    };
  }
}
