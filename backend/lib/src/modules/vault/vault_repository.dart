import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for vault-related database operations.
class VaultRepository {
  final Database _db;
  // ignore: unused_field
  final Logger _log = Logger('VaultRepository');

  VaultRepository(this._db);

  // ---------------------------------------------------------------------------
  // Vault Entries
  // ---------------------------------------------------------------------------

  /// Creates a new vault entry and returns the created entry row.
  Future<Map<String, dynamic>> createEntry({
    required String id,
    required String spaceId,
    required String createdBy,
    required String domain,
    String? faviconUrl,
    String? label,
    required String encryptedBlob,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO vault_entries (
        id, space_id, created_by, domain, favicon_url, label,
        encrypted_blob, created_at, updated_at
      )
      VALUES (
        @id, @spaceId, @createdBy, @domain, @faviconUrl, @label,
        @encryptedBlob, NOW(), NOW()
      )
      RETURNING id, space_id, created_by, domain, favicon_url, label,
                encrypted_blob, created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'spaceId': spaceId,
        'createdBy': createdBy,
        'domain': domain,
        'faviconUrl': faviconUrl,
        'label': label,
        'encryptedBlob': encryptedBlob,
      },
    );

    return _entryRowToMap(row!);
  }

  /// Gets a vault entry by ID.
  Future<Map<String, dynamic>?> getEntryById(String entryId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, created_by, domain, favicon_url, label,
             encrypted_blob, created_at, updated_at, deleted_at
      FROM vault_entries
      WHERE id = @entryId AND deleted_at IS NULL
      ''',
      parameters: {'entryId': entryId},
    );

    if (row == null) return null;

    final entry = _entryRowWithDeletedToMap(row);

    // Fetch shares with user info
    final shareRows = await _db.query(
      '''
      SELECT vs.id, vs.vault_entry_id, vs.shared_with_user_id,
             vs.encrypted_symmetric_key, vs.shared_by, vs.created_at,
             u.display_name, u.email, u.avatar_url
      FROM vault_shares vs
      JOIN users u ON u.id = vs.shared_with_user_id
      WHERE vs.vault_entry_id = @entryId
      ORDER BY vs.created_at ASC
      ''',
      parameters: {'entryId': entryId},
    );

    entry['shares'] = shareRows.map(_shareWithUserRowToMap).toList();

    return entry;
  }

  /// Gets vault entries for a user in a space (own + shared), with optional
  /// filters grouped by domain.
  Future<List<Map<String, dynamic>>> getEntries(
    String spaceId,
    String userId, {
    String? domain,
    String? search,
    String? cursor,
    int limit = 25,
  }) async {
    final conditions = <String>[
      've.deleted_at IS NULL',
      've.space_id = @spaceId',
      '(ve.created_by = @userId OR vs.shared_with_user_id = @userId)',
    ];
    final params = <String, dynamic>{
      'spaceId': spaceId,
      'userId': userId,
      'limit': limit + 1, // Fetch one extra for cursor detection
    };

    if (domain != null) {
      conditions.add('ve.domain = @domain');
      params['domain'] = domain;
    }
    if (search != null && search.isNotEmpty) {
      conditions.add('(ve.domain ILIKE @search OR ve.label ILIKE @search)');
      params['search'] = '%$search%';
    }
    if (cursor != null) {
      conditions.add('ve.created_at < @cursor');
      params['cursor'] = DateTime.parse(cursor);
    }

    final whereClause = conditions.join(' AND ');

    final result = await _db.query('''
      SELECT DISTINCT ve.id, ve.space_id, ve.created_by, ve.domain,
             ve.favicon_url, ve.label, ve.encrypted_blob,
             ve.created_at, ve.updated_at
      FROM vault_entries ve
      LEFT JOIN vault_shares vs ON vs.vault_entry_id = ve.id
      WHERE $whereClause
      ORDER BY ve.domain ASC, ve.created_at DESC
      LIMIT @limit
      ''', parameters: params);

    return result.map(_entryRowToMap).toList();
  }

  /// Updates a vault entry with the given fields.
  Future<Map<String, dynamic>?> updateEntry(
    String entryId,
    Map<String, dynamic> updates,
  ) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'entryId': entryId};

    if (updates.containsKey('domain')) {
      setClauses.add('domain = @domain');
      params['domain'] = updates['domain'];
    }
    if (updates.containsKey('favicon_url')) {
      setClauses.add('favicon_url = @faviconUrl');
      params['faviconUrl'] = updates['favicon_url'];
    }
    if (updates.containsKey('label')) {
      setClauses.add('label = @label');
      params['label'] = updates['label'];
    }
    if (updates.containsKey('encrypted_blob')) {
      setClauses.add('encrypted_blob = @encryptedBlob');
      params['encryptedBlob'] = updates['encrypted_blob'];
    }

    if (setClauses.isEmpty) return getEntryById(entryId);

    setClauses.add('updated_at = NOW()');

    final row = await _db.queryOne('''
      UPDATE vault_entries
      SET ${setClauses.join(', ')}
      WHERE id = @entryId AND deleted_at IS NULL
      RETURNING id, space_id, created_by, domain, favicon_url, label,
                encrypted_blob, created_at, updated_at
      ''', parameters: params);

    if (row == null) return null;
    return _entryRowToMap(row);
  }

  /// Soft-deletes a vault entry.
  Future<void> softDeleteEntry(String entryId) async {
    await _db.execute(
      '''
      UPDATE vault_entries
      SET deleted_at = NOW(), updated_at = NOW()
      WHERE id = @entryId AND deleted_at IS NULL
      ''',
      parameters: {'entryId': entryId},
    );
  }

  // ---------------------------------------------------------------------------
  // Vault Shares
  // ---------------------------------------------------------------------------

  /// Shares a vault entry with another user, providing the re-encrypted
  /// symmetric key.
  Future<Map<String, dynamic>> shareEntry({
    required String id,
    required String entryId,
    required String sharedWithUserId,
    required String encryptedSymmetricKey,
    required String sharedByUserId,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO vault_shares (
        id, vault_entry_id, shared_with_user_id, encrypted_symmetric_key,
        shared_by, created_at
      )
      VALUES (@id, @entryId, @sharedWithUserId, @encryptedSymmetricKey,
              @sharedByUserId, NOW())
      RETURNING id, vault_entry_id, shared_with_user_id, encrypted_symmetric_key,
                shared_by, created_at
      ''',
      parameters: {
        'id': id,
        'entryId': entryId,
        'sharedWithUserId': sharedWithUserId,
        'encryptedSymmetricKey': encryptedSymmetricKey,
        'sharedByUserId': sharedByUserId,
      },
    );

    return _shareRowToMap(row!);
  }

  /// Removes a vault entry share for a user.
  Future<void> unshareEntry(String entryId, String userId) async {
    await _db.execute(
      '''
      DELETE FROM vault_shares
      WHERE vault_entry_id = @entryId AND shared_with_user_id = @userId
      ''',
      parameters: {'entryId': entryId, 'userId': userId},
    );
  }

  /// Gets all vault entries shared with a specific user.
  Future<List<Map<String, dynamic>>> getSharedEntries(String userId) async {
    final result = await _db.query(
      '''
      SELECT ve.id, ve.space_id, ve.created_by, ve.domain, ve.favicon_url,
             ve.label, ve.encrypted_blob, ve.created_at, ve.updated_at
      FROM vault_entries ve
      JOIN vault_shares vs ON vs.vault_entry_id = ve.id
      WHERE vs.shared_with_user_id = @userId
        AND ve.deleted_at IS NULL
      ORDER BY ve.domain ASC, ve.created_at DESC
      ''',
      parameters: {'userId': userId},
    );

    return result.map(_entryRowToMap).toList();
  }

  /// Gets domain groupings for a user in a space.
  Future<List<Map<String, dynamic>>> getDomainGroups(
    String spaceId,
    String userId,
  ) async {
    final result = await _db.query(
      '''
      SELECT ve.domain, MIN(ve.favicon_url) AS favicon_url, COUNT(*) AS count
      FROM vault_entries ve
      LEFT JOIN vault_shares vs ON vs.vault_entry_id = ve.id
      WHERE ve.space_id = @spaceId
        AND ve.deleted_at IS NULL
        AND (ve.created_by = @userId OR vs.shared_with_user_id = @userId)
      GROUP BY ve.domain
      ORDER BY ve.domain ASC
      ''',
      parameters: {'spaceId': spaceId, 'userId': userId},
    );

    return result
        .map(
          (row) => {
            'domain': row[0] as String,
            'favicon_url': row[1] as String?,
            'count': row[2] as int,
          },
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _entryRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_by': row[2] as String,
      'domain': row[3] as String,
      'favicon_url': row[4] as String?,
      'label': row[5] as String?,
      'encrypted_blob': row[6] as String,
      'created_at': (row[7] as DateTime).toIso8601String(),
      'updated_at': (row[8] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _entryRowWithDeletedToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_by': row[2] as String,
      'domain': row[3] as String,
      'favicon_url': row[4] as String?,
      'label': row[5] as String?,
      'encrypted_blob': row[6] as String,
      'created_at': (row[7] as DateTime).toIso8601String(),
      'updated_at': (row[8] as DateTime).toIso8601String(),
      'deleted_at': row[9] != null
          ? (row[9] as DateTime).toIso8601String()
          : null,
    };
  }

  Map<String, dynamic> _shareRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'vault_entry_id': row[1] as String,
      'shared_with_user_id': row[2] as String,
      'encrypted_symmetric_key': row[3] as String,
      'shared_by': row[4] as String,
      'created_at': (row[5] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _shareWithUserRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'vault_entry_id': row[1] as String,
      'shared_with_user_id': row[2] as String,
      'encrypted_symmetric_key': row[3] as String,
      'shared_by': row[4] as String,
      'created_at': (row[5] as DateTime).toIso8601String(),
      'user': {
        'display_name': row[6] as String,
        'email': row[7] as String,
        'avatar_url': row[8] as String?,
      },
    };
  }
}
