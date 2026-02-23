import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

import '../../config/database.dart';

/// Repository for space-related database operations.
class SpacesRepository {
  final Database _db;
  final Logger _log = Logger('SpacesRepository');

  SpacesRepository(this._db);

  // ---------------------------------------------------------------------------
  // Spaces
  // ---------------------------------------------------------------------------

  /// Creates a new space and returns the created space row.
  Future<Map<String, dynamic>> createSpace({
    required String id,
    required String name,
    required String type,
    String? description,
    String? iconUrl,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO spaces (id, name, type, description, icon_url, created_at, updated_at)
      VALUES (@id, @name, @type, @description, @iconUrl, NOW(), NOW())
      RETURNING id, name, type, description, icon_url, created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'name': name,
        'type': type,
        'description': description,
        'iconUrl': iconUrl,
      },
    );

    return _spaceRowToMap(row!);
  }

  /// Finds a space by ID.
  Future<Map<String, dynamic>?> findById(String id) async {
    final row = await _db.queryOne(
      '''
      SELECT id, name, type, description, icon_url, created_at, updated_at, deleted_at
      FROM spaces
      WHERE id = @id
      ''',
      parameters: {'id': id},
    );

    if (row == null) return null;
    return _spaceRowWithDeletedToMap(row);
  }

  /// Lists all spaces a user is an active member of.
  Future<List<Map<String, dynamic>>> listByUserId(String userId) async {
    final result = await _db.query(
      '''
      SELECT s.id, s.name, s.type, s.description, s.icon_url,
             s.created_at, s.updated_at,
             sm.role, sm.access_level, sm.joined_at
      FROM spaces s
      JOIN space_memberships sm ON s.id = sm.space_id
      WHERE sm.user_id = @userId
        AND sm.status = 'active'
        AND s.deleted_at IS NULL
      ORDER BY sm.joined_at DESC
      ''',
      parameters: {'userId': userId},
    );

    return result
        .map(
          (row) => {
            'id': row[0] as String,
            'name': row[1] as String,
            'type': row[2] as String,
            'description': row[3] as String?,
            'icon_url': row[4] as String?,
            'created_at': (row[5] as DateTime).toIso8601String(),
            'updated_at': (row[6] as DateTime).toIso8601String(),
            'membership': {
              'role': row[7] as String,
              'access_level': row[8] as String,
              'joined_at': (row[9] as DateTime).toIso8601String(),
            },
          },
        )
        .toList();
  }

  /// Updates a space's details.
  Future<Map<String, dynamic>?> updateSpace(
    String id, {
    String? name,
    String? description,
    String? iconUrl,
    String? type,
  }) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'id': id};

    if (name != null) {
      setClauses.add('name = @name');
      params['name'] = name;
    }
    if (description != null) {
      setClauses.add('description = @description');
      params['description'] = description;
    }
    if (iconUrl != null) {
      setClauses.add('icon_url = @iconUrl');
      params['iconUrl'] = iconUrl;
    }
    if (type != null) {
      setClauses.add('type = @type');
      params['type'] = type;
    }

    if (setClauses.isEmpty) return findById(id);

    setClauses.add('updated_at = NOW()');

    final row = await _db.queryOne('''
      UPDATE spaces
      SET ${setClauses.join(', ')}
      WHERE id = @id AND deleted_at IS NULL
      RETURNING id, name, type, description, icon_url, created_at, updated_at
      ''', parameters: params);

    if (row == null) return null;
    return _spaceRowToMap(row);
  }

  /// Soft-deletes a space (schedules for permanent deletion).
  Future<void> softDeleteSpace(String id) async {
    await _db.execute(
      '''
      UPDATE spaces
      SET deleted_at = NOW(), updated_at = NOW()
      WHERE id = @id
      ''',
      parameters: {'id': id},
    );
  }

  // ---------------------------------------------------------------------------
  // Members
  // ---------------------------------------------------------------------------

  /// Adds a member to a space.
  Future<Map<String, dynamic>> addMember({
    required String spaceId,
    required String userId,
    required String role,
    required String accessLevel,
    required String status,
    String? invitedBy,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO space_memberships (space_id, user_id, role, access_level, status,
                                 invited_by, joined_at, created_at, updated_at)
      VALUES (@spaceId, @userId, @role, @accessLevel, @status,
              @invitedBy, NOW(), NOW(), NOW())
      RETURNING space_id, user_id, role, access_level, status, joined_at
      ''',
      parameters: {
        'spaceId': spaceId,
        'userId': userId,
        'role': role,
        'accessLevel': accessLevel,
        'status': status,
        'invitedBy': invitedBy,
      },
    );

    return _memberRowToMap(row!);
  }

  /// Gets a specific member of a space.
  Future<Map<String, dynamic>?> getMember(String spaceId, String userId) async {
    final row = await _db.queryOne(
      '''
      SELECT sm.space_id, sm.user_id, sm.role, sm.access_level, sm.status,
             sm.joined_at, u.display_name, u.email, u.avatar_url
      FROM space_memberships sm
      JOIN users u ON u.id = sm.user_id
      WHERE sm.space_id = @spaceId AND sm.user_id = @userId
      ''',
      parameters: {'spaceId': spaceId, 'userId': userId},
    );

    if (row == null) return null;
    return {
      'space_id': row[0] as String,
      'user_id': row[1] as String,
      'role': row[2] as String,
      'access_level': row[3] as String,
      'status': row[4] as String,
      'joined_at': (row[5] as DateTime).toIso8601String(),
      'user': {
        'display_name': row[6] as String,
        'email': row[7] as String,
        'avatar_url': row[8] as String?,
      },
    };
  }

  /// Lists all active members of a space.
  Future<List<Map<String, dynamic>>> listMembers(String spaceId) async {
    final result = await _db.query(
      '''
      SELECT sm.space_id, sm.user_id, sm.role, sm.access_level, sm.status,
             sm.joined_at, u.display_name, u.email, u.avatar_url
      FROM space_memberships sm
      JOIN users u ON u.id = sm.user_id
      WHERE sm.space_id = @spaceId
        AND sm.status = 'active'
      ORDER BY
        CASE sm.role
          WHEN 'owner' THEN 1
          WHEN 'admin' THEN 2
          ELSE 3
        END,
        sm.joined_at ASC
      ''',
      parameters: {'spaceId': spaceId},
    );

    return result
        .map(
          (row) => {
            'space_id': row[0] as String,
            'user_id': row[1] as String,
            'role': row[2] as String,
            'access_level': row[3] as String,
            'status': row[4] as String,
            'joined_at': (row[5] as DateTime).toIso8601String(),
            'user': {
              'display_name': row[6] as String,
              'email': row[7] as String,
              'avatar_url': row[8] as String?,
            },
          },
        )
        .toList();
  }

  /// Updates a member's role and/or access level.
  Future<Map<String, dynamic>?> updateMember(
    String spaceId,
    String userId, {
    String? role,
    String? accessLevel,
  }) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'spaceId': spaceId, 'userId': userId};

    if (role != null) {
      setClauses.add('role = @role');
      params['role'] = role;
    }
    if (accessLevel != null) {
      setClauses.add('access_level = @accessLevel');
      params['accessLevel'] = accessLevel;
    }

    if (setClauses.isEmpty) return getMember(spaceId, userId);

    setClauses.add('updated_at = NOW()');

    final row = await _db.queryOne('''
      UPDATE space_memberships
      SET ${setClauses.join(', ')}
      WHERE space_id = @spaceId AND user_id = @userId AND status = 'active'
      RETURNING space_id, user_id, role, access_level, status, joined_at
      ''', parameters: params);

    if (row == null) return null;
    return _memberRowToMap(row);
  }

  /// Removes a member from a space (sets status to 'removed').
  Future<void> removeMember(String spaceId, String userId) async {
    await _db.execute(
      '''
      UPDATE space_memberships
      SET status = 'removed', updated_at = NOW()
      WHERE space_id = @spaceId AND user_id = @userId AND status = 'active'
      ''',
      parameters: {'spaceId': spaceId, 'userId': userId},
    );
  }

  /// Sets a member's status to 'left'.
  Future<void> leaveSpace(String spaceId, String userId) async {
    await _db.execute(
      '''
      UPDATE space_memberships
      SET status = 'left', updated_at = NOW()
      WHERE space_id = @spaceId AND user_id = @userId AND status = 'active'
      ''',
      parameters: {'spaceId': spaceId, 'userId': userId},
    );
  }

  /// Transfers ownership from one user to another.
  Future<void> transferOwnership(
    String spaceId,
    String fromUserId,
    String toUserId,
  ) async {
    await _db.transaction((session) async {
      // Demote current owner to admin
      await session.execute(
        Sql.named('''
        UPDATE space_memberships
        SET role = 'admin', updated_at = NOW()
        WHERE space_id = @spaceId AND user_id = @fromUserId
        '''),
        parameters: {'spaceId': spaceId, 'fromUserId': fromUserId},
      );

      // Promote new owner
      await session.execute(
        Sql.named('''
        UPDATE space_memberships
        SET role = 'owner', updated_at = NOW()
        WHERE space_id = @spaceId AND user_id = @toUserId
        '''),
        parameters: {'spaceId': spaceId, 'toUserId': toUserId},
      );
    });
  }

  /// Counts active members in a space.
  Future<int> countActiveMembers(String spaceId) async {
    final row = await _db.queryOne(
      '''
      SELECT COUNT(*) FROM space_memberships
      WHERE space_id = @spaceId AND status = 'active'
      ''',
      parameters: {'spaceId': spaceId},
    );
    return (row?[0] as int?) ?? 0;
  }

  /// Checks if a user is already a member of a space (any status).
  Future<Map<String, dynamic>?> findMembership(
    String spaceId,
    String userId,
  ) async {
    final row = await _db.queryOne(
      '''
      SELECT space_id, user_id, role, access_level, status, joined_at
      FROM space_memberships
      WHERE space_id = @spaceId AND user_id = @userId
      ''',
      parameters: {'spaceId': spaceId, 'userId': userId},
    );

    if (row == null) return null;
    return _memberRowToMap(row);
  }

  /// Reactivates a previously left/removed member.
  Future<Map<String, dynamic>?> reactivateMember(
    String spaceId,
    String userId,
  ) async {
    final row = await _db.queryOne(
      '''
      UPDATE space_memberships
      SET status = 'active', role = 'member', access_level = 'read_write',
          joined_at = NOW(), updated_at = NOW()
      WHERE space_id = @spaceId AND user_id = @userId
      RETURNING space_id, user_id, role, access_level, status, joined_at
      ''',
      parameters: {'spaceId': spaceId, 'userId': userId},
    );

    if (row == null) return null;
    return _memberRowToMap(row);
  }

  // ---------------------------------------------------------------------------
  // Invites
  // ---------------------------------------------------------------------------

  /// Creates an invite for a space.
  Future<Map<String, dynamic>> createInvite({
    required String id,
    required String spaceId,
    required String code,
    required String createdBy,
    int? maxUses,
    DateTime? expiresAt,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO space_invites (id, space_id, code, created_by, max_uses,
                                 uses, expires_at, created_at)
      VALUES (@id, @spaceId, @code, @createdBy, @maxUses, 0, @expiresAt, NOW())
      RETURNING id, space_id, code, created_by, max_uses, uses, expires_at, created_at
      ''',
      parameters: {
        'id': id,
        'spaceId': spaceId,
        'code': code,
        'createdBy': createdBy,
        'maxUses': maxUses,
        'expiresAt': expiresAt,
      },
    );

    return _inviteRowToMap(row!);
  }

  /// Finds a valid invite by code.
  Future<Map<String, dynamic>?> findInviteByCode(String code) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, code, created_by, max_uses, uses, expires_at, created_at
      FROM space_invites
      WHERE code = @code
        AND (expires_at IS NULL OR expires_at > NOW())
        AND (max_uses IS NULL OR uses < max_uses)
        AND revoked_at IS NULL
      ''',
      parameters: {'code': code},
    );

    if (row == null) return null;
    return _inviteRowToMap(row);
  }

  /// Increments the usage counter for an invite.
  Future<void> incrementInviteUses(String inviteId) async {
    await _db.execute(
      '''
      UPDATE space_invites
      SET uses = uses + 1
      WHERE id = @id
      ''',
      parameters: {'id': inviteId},
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _spaceRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'name': row[1] as String,
      'type': row[2] as String,
      'description': row[3] as String?,
      'icon_url': row[4] as String?,
      'created_at': (row[5] as DateTime).toIso8601String(),
      'updated_at': (row[6] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _spaceRowWithDeletedToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'name': row[1] as String,
      'type': row[2] as String,
      'description': row[3] as String?,
      'icon_url': row[4] as String?,
      'created_at': (row[5] as DateTime).toIso8601String(),
      'updated_at': (row[6] as DateTime).toIso8601String(),
      'deleted_at': row[7] != null
          ? (row[7] as DateTime).toIso8601String()
          : null,
    };
  }

  Map<String, dynamic> _memberRowToMap(dynamic row) {
    return {
      'space_id': row[0] as String,
      'user_id': row[1] as String,
      'role': row[2] as String,
      'access_level': row[3] as String,
      'status': row[4] as String,
      'joined_at': (row[5] as DateTime).toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // Data Separation (Unlink / Relink)
  // ---------------------------------------------------------------------------

  /// Anonymizes records created by the user in a space by setting
  /// created_by to NULL (ghost records). These are space-visible data
  /// that should remain with the space but not be attributed.
  Future<void> anonymizeUserContentInSpace(
    String spaceId,
    String userId,
  ) async {
    // Tables with created_by + space_id that should become ghost records
    const tables = [
      'activities',
      'calendar_events',
      'tasks',
      'finance_entries',
      'memories',
      'polls',
      'grocery_lists',
      'files',
    ];

    for (final table in tables) {
      await _db.execute(
        '''
        UPDATE $table
        SET created_by = NULL, updated_at = NOW()
        WHERE space_id = @spaceId AND created_by = @userId
          AND deleted_at IS NULL
        ''',
        parameters: {'spaceId': spaceId, 'userId': userId},
      );
    }

    _log.info('Anonymized content for user $userId in space $spaceId');
  }

  /// Removes personal data tied to the user within a specific space.
  /// This includes messages (sender attribution), task assignments,
  /// conversation participants, and poll votes.
  Future<void> removePersonalReferencesInSpace(
    String spaceId,
    String userId,
  ) async {
    // Anonymize message sender to preserve conversation history
    await _db.execute(
      '''
      UPDATE messages m
      SET sender_id = NULL
      FROM conversations c
      WHERE m.conversation_id = c.id
        AND c.space_id = @spaceId
        AND m.sender_id = @userId
      ''',
      parameters: {'spaceId': spaceId, 'userId': userId},
    );

    // Remove task assignments
    await _db.execute(
      '''
      DELETE FROM task_assignments ta
      USING tasks t
      WHERE ta.task_id = t.id
        AND t.space_id = @spaceId
        AND ta.user_id = @userId
      ''',
      parameters: {'spaceId': spaceId, 'userId': userId},
    );

    // Remove from conversation participants
    await _db.execute(
      '''
      DELETE FROM conversation_participants cp
      USING conversations c
      WHERE cp.conversation_id = c.id
        AND c.space_id = @spaceId
        AND cp.user_id = @userId
      ''',
      parameters: {'spaceId': spaceId, 'userId': userId},
    );

    // Remove poll votes
    await _db.execute(
      '''
      DELETE FROM poll_votes pv
      USING polls p
      WHERE pv.poll_id = p.id
        AND p.space_id = @spaceId
        AND pv.user_id = @userId
      ''',
      parameters: {'spaceId': spaceId, 'userId': userId},
    );

    _log.info('Removed personal references for user $userId in space $spaceId');
  }

  /// Deletes data that is personally owned and should not remain with
  /// the space: vault entries and location shares.
  Future<void> deletePersonalDataInSpace(String spaceId, String userId) async {
    // Vault entries are personal even within a space
    await _db.execute(
      '''
      DELETE FROM vault_entries
      WHERE space_id = @spaceId AND created_by = @userId
      ''',
      parameters: {'spaceId': spaceId, 'userId': userId},
    );

    // Location shares should stop
    await _db.execute(
      '''
      UPDATE location_shares
      SET active = false, updated_at = NOW()
      WHERE space_id = @spaceId AND user_id = @userId
      ''',
      parameters: {'spaceId': spaceId, 'userId': userId},
    );

    _log.info('Deleted personal data for user $userId in space $spaceId');
  }

  Map<String, dynamic> _inviteRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'code': row[2] as String,
      'created_by': row[3] as String,
      'max_uses': row[4] as int?,
      'uses': row[5] as int,
      'expires_at': row[6] != null
          ? (row[6] as DateTime).toIso8601String()
          : null,
      'created_at': (row[7] as DateTime).toIso8601String(),
    };
  }
}
