import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for authentication-related database operations.
class AuthRepository {
  final Database _db;
  // ignore: unused_field
  final Logger _log = Logger('AuthRepository');

  AuthRepository(this._db);

  // ---------------------------------------------------------------------------
  // Users
  // ---------------------------------------------------------------------------

  /// Creates a new user and returns the created user row.
  Future<Map<String, dynamic>> createUser({
    required String id,
    required String email,
    required String passwordHash,
    required String displayName,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO users (id, email, password_hash, display_name, created_at, updated_at)
      VALUES (@id, @email, @passwordHash, @displayName, NOW(), NOW())
      RETURNING id, email, display_name, avatar_url, date_of_birth,
                pronouns, two_factor_enabled, created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'email': email,
        'passwordHash': passwordHash,
        'displayName': displayName,
      },
    );

    return _userRowToMap(row!);
  }

  /// Finds a user by email address.
  Future<Map<String, dynamic>?> findByEmail(String email) async {
    final row = await _db.queryOne(
      '''
      SELECT id, email, password_hash, display_name, avatar_url,
             date_of_birth, pronouns, two_factor_enabled, two_factor_secret,
             failed_login_attempts, locked_until, created_at, updated_at, deleted_at
      FROM users
      WHERE LOWER(email) = LOWER(@email)
      ''',
      parameters: {'email': email},
    );

    if (row == null) return null;
    return _fullUserRowToMap(row);
  }

  /// Finds a user by ID.
  Future<Map<String, dynamic>?> findById(String id) async {
    final row = await _db.queryOne(
      '''
      SELECT id, email, password_hash, display_name, avatar_url,
             date_of_birth, pronouns, two_factor_enabled, two_factor_secret,
             failed_login_attempts, locked_until, created_at, updated_at, deleted_at
      FROM users
      WHERE id = @id
      ''',
      parameters: {'id': id},
    );

    if (row == null) return null;
    return _fullUserRowToMap(row);
  }

  /// Checks if an email is already registered.
  Future<bool> emailExists(String email) async {
    final row = await _db.queryOne(
      'SELECT 1 FROM users WHERE LOWER(email) = LOWER(@email)',
      parameters: {'email': email},
    );
    return row != null;
  }

  /// Updates the user's password hash.
  Future<void> updatePassword(String userId, String passwordHash) async {
    await _db.execute(
      '''
      UPDATE users
      SET password_hash = @passwordHash, updated_at = NOW()
      WHERE id = @userId
      ''',
      parameters: {'userId': userId, 'passwordHash': passwordHash},
    );
  }

  /// Increments the failed login attempts counter.
  Future<void> incrementFailedLoginAttempts(String userId) async {
    await _db.execute(
      '''
      UPDATE users
      SET failed_login_attempts = failed_login_attempts + 1,
          locked_until = CASE
            WHEN failed_login_attempts >= 4
            THEN NOW() + INTERVAL '15 minutes'
            ELSE locked_until
          END,
          updated_at = NOW()
      WHERE id = @userId
      ''',
      parameters: {'userId': userId},
    );
  }

  /// Resets the failed login attempts counter after a successful login.
  Future<void> resetFailedLoginAttempts(String userId) async {
    await _db.execute(
      '''
      UPDATE users
      SET failed_login_attempts = 0, locked_until = NULL, updated_at = NOW()
      WHERE id = @userId
      ''',
      parameters: {'userId': userId},
    );
  }

  /// Soft-deletes a user account.
  Future<void> softDeleteUser(String userId) async {
    await _db.execute(
      '''
      UPDATE users
      SET deleted_at = NOW(), updated_at = NOW(),
          email = CONCAT('deleted_', id, '_', email)
      WHERE id = @userId
      ''',
      parameters: {'userId': userId},
    );
  }

  // ---------------------------------------------------------------------------
  // Two-Factor Authentication
  // ---------------------------------------------------------------------------

  /// Stores the 2FA secret for a user.
  Future<void> store2FASecret(String userId, String secret) async {
    await _db.execute(
      '''
      UPDATE users
      SET two_factor_secret = @secret, updated_at = NOW()
      WHERE id = @userId
      ''',
      parameters: {'userId': userId, 'secret': secret},
    );
  }

  /// Enables 2FA for a user.
  Future<void> enable2FA(String userId) async {
    await _db.execute(
      '''
      UPDATE users
      SET two_factor_enabled = TRUE, updated_at = NOW()
      WHERE id = @userId
      ''',
      parameters: {'userId': userId},
    );
  }

  /// Disables 2FA for a user.
  Future<void> disable2FA(String userId) async {
    await _db.execute(
      '''
      UPDATE users
      SET two_factor_enabled = FALSE, two_factor_secret = NULL, updated_at = NOW()
      WHERE id = @userId
      ''',
      parameters: {'userId': userId},
    );
  }

  /// Stores backup codes for a user (hashed).
  Future<void> storeBackupCodes(String userId, List<String> hashedCodes) async {
    // Delete existing backup codes
    await _db.execute(
      'DELETE FROM backup_codes WHERE user_id = @userId',
      parameters: {'userId': userId},
    );

    // Insert new backup codes
    for (final code in hashedCodes) {
      await _db.execute(
        '''
        INSERT INTO backup_codes (user_id, code_hash, used, created_at)
        VALUES (@userId, @codeHash, FALSE, NOW())
        ''',
        parameters: {'userId': userId, 'codeHash': code},
      );
    }
  }

  /// Marks a backup code as used. Returns true if a matching unused code was found.
  Future<bool> useBackupCode(String userId, String codeHash) async {
    final affected = await _db.execute(
      '''
      UPDATE backup_codes
      SET used = TRUE, used_at = NOW()
      WHERE user_id = @userId AND code_hash = @codeHash AND used = FALSE
      ''',
      parameters: {'userId': userId, 'codeHash': codeHash},
    );
    return affected > 0;
  }

  // ---------------------------------------------------------------------------
  // Sessions
  // ---------------------------------------------------------------------------

  /// Creates a new session record.
  Future<Map<String, dynamic>> createSession({
    required String id,
    required String userId,
    required String refreshTokenHash,
    required String ipAddress,
    required String userAgent,
    required DateTime expiresAt,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO sessions (id, user_id, refresh_token_hash, ip_address,
                           user_agent, expires_at, created_at, last_active_at)
      VALUES (@id, @userId, @refreshTokenHash, @ipAddress,
              @userAgent, @expiresAt, NOW(), NOW())
      RETURNING id, user_id, ip_address, user_agent, expires_at,
                created_at, last_active_at
      ''',
      parameters: {
        'id': id,
        'userId': userId,
        'refreshTokenHash': refreshTokenHash,
        'ipAddress': ipAddress,
        'userAgent': userAgent,
        'expiresAt': expiresAt,
      },
    );

    return _sessionRowToMap(row!);
  }

  /// Finds a session by refresh token hash.
  Future<Map<String, dynamic>?> findSessionByRefreshToken(
    String refreshTokenHash,
  ) async {
    final row = await _db.queryOne(
      '''
      SELECT id, user_id, refresh_token_hash, ip_address, user_agent,
             expires_at, created_at, last_active_at, revoked_at
      FROM sessions
      WHERE refresh_token_hash = @hash
        AND revoked_at IS NULL
        AND expires_at > NOW()
      ''',
      parameters: {'hash': refreshTokenHash},
    );

    if (row == null) return null;
    return {
      'id': row[0] as String,
      'user_id': row[1] as String,
      'refresh_token_hash': row[2] as String,
      'ip_address': row[3] as String?,
      'user_agent': row[4] as String?,
      'expires_at': (row[5] as DateTime).toIso8601String(),
      'created_at': (row[6] as DateTime).toIso8601String(),
      'last_active_at': (row[7] as DateTime).toIso8601String(),
      'revoked_at': row[8] != null
          ? (row[8] as DateTime).toIso8601String()
          : null,
    };
  }

  /// Lists all active sessions for a user.
  Future<List<Map<String, dynamic>>> listSessions(String userId) async {
    final result = await _db.query(
      '''
      SELECT id, user_id, ip_address, user_agent, expires_at,
             created_at, last_active_at
      FROM sessions
      WHERE user_id = @userId
        AND revoked_at IS NULL
        AND expires_at > NOW()
      ORDER BY last_active_at DESC
      ''',
      parameters: {'userId': userId},
    );

    return result.map(_sessionRowToMap).toList();
  }

  /// Revokes a specific session.
  Future<bool> revokeSession(String sessionId, String userId) async {
    final affected = await _db.execute(
      '''
      UPDATE sessions
      SET revoked_at = NOW()
      WHERE id = @sessionId AND user_id = @userId AND revoked_at IS NULL
      ''',
      parameters: {'sessionId': sessionId, 'userId': userId},
    );
    return affected > 0;
  }

  /// Revokes all sessions for a user (e.g., on password change).
  Future<void> revokeAllSessions(String userId) async {
    await _db.execute(
      '''
      UPDATE sessions
      SET revoked_at = NOW()
      WHERE user_id = @userId AND revoked_at IS NULL
      ''',
      parameters: {'userId': userId},
    );
  }

  /// Updates the refresh token for an existing session (token rotation).
  Future<void> updateSessionRefreshToken(
    String sessionId,
    String newRefreshTokenHash,
  ) async {
    await _db.execute(
      '''
      UPDATE sessions
      SET refresh_token_hash = @newHash, last_active_at = NOW()
      WHERE id = @sessionId
      ''',
      parameters: {'sessionId': sessionId, 'newHash': newRefreshTokenHash},
    );
  }

  // ---------------------------------------------------------------------------
  // Password Reset Tokens
  // ---------------------------------------------------------------------------

  /// Creates a password reset token.
  Future<void> createPasswordResetToken({
    required String userId,
    required String tokenHash,
    required DateTime expiresAt,
  }) async {
    // Invalidate any existing tokens for this user
    await _db.execute(
      '''
      UPDATE password_reset_tokens
      SET used = TRUE
      WHERE user_id = @userId AND used = FALSE
      ''',
      parameters: {'userId': userId},
    );

    await _db.execute(
      '''
      INSERT INTO password_reset_tokens (user_id, token_hash, expires_at, used, created_at)
      VALUES (@userId, @tokenHash, @expiresAt, FALSE, NOW())
      ''',
      parameters: {
        'userId': userId,
        'tokenHash': tokenHash,
        'expiresAt': expiresAt,
      },
    );
  }

  /// Finds a valid password reset token by its hash.
  Future<Map<String, dynamic>?> findPasswordResetToken(String tokenHash) async {
    final row = await _db.queryOne(
      '''
      SELECT user_id, token_hash, expires_at, used
      FROM password_reset_tokens
      WHERE token_hash = @tokenHash
        AND used = FALSE
        AND expires_at > NOW()
      ''',
      parameters: {'tokenHash': tokenHash},
    );

    if (row == null) return null;
    return {
      'user_id': row[0] as String,
      'token_hash': row[1] as String,
      'expires_at': (row[2] as DateTime).toIso8601String(),
      'used': row[3] as bool,
    };
  }

  /// Marks a password reset token as used.
  Future<void> markPasswordResetTokenUsed(String tokenHash) async {
    await _db.execute(
      '''
      UPDATE password_reset_tokens
      SET used = TRUE
      WHERE token_hash = @tokenHash
      ''',
      parameters: {'tokenHash': tokenHash},
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _userRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'email': row[1] as String,
      'display_name': row[2] as String,
      'avatar_url': row[3] as String?,
      'date_of_birth': row[4] != null
          ? (row[4] as DateTime).toIso8601String()
          : null,
      'pronouns': row[5] as String?,
      'two_factor_enabled': row[6] as bool,
      'created_at': (row[7] as DateTime).toIso8601String(),
      'updated_at': (row[8] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _fullUserRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'email': row[1] as String,
      'password_hash': row[2] as String,
      'display_name': row[3] as String,
      'avatar_url': row[4] as String?,
      'date_of_birth': row[5] != null
          ? (row[5] as DateTime).toIso8601String()
          : null,
      'pronouns': row[6] as String?,
      'two_factor_enabled': row[7] as bool,
      'two_factor_secret': row[8] as String?,
      'failed_login_attempts': row[9] as int,
      'locked_until': row[10] != null
          ? (row[10] as DateTime).toIso8601String()
          : null,
      'created_at': (row[11] as DateTime).toIso8601String(),
      'updated_at': (row[12] as DateTime).toIso8601String(),
      'deleted_at': row[13] != null
          ? (row[13] as DateTime).toIso8601String()
          : null,
    };
  }

  Map<String, dynamic> _sessionRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'user_id': row[1] as String,
      'ip_address': row[2] as String?,
      'user_agent': row[3] as String?,
      'expires_at': (row[4] as DateTime).toIso8601String(),
      'created_at': (row[5] as DateTime).toIso8601String(),
      'last_active_at': (row[6] as DateTime).toIso8601String(),
    };
  }
}
