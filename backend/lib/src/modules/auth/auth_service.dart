import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:otp/otp.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import 'package:uuid/uuid.dart';

import '../../config/app_config.dart';
import '../../services/notification_service.dart';
import '../../utils/jwt_utils.dart';
import '../../utils/password_utils.dart';
import 'auth_repository.dart';

/// Custom exception for authentication errors.
///
/// Deprecated: Use [AppFailure] subtypes from studio_pair_shared instead.
/// This class is retained for backward compatibility and will be removed
/// in a future release.
@Deprecated('Use AppFailure subtypes from studio_pair_shared instead')
class AuthException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const AuthException(
    this.message, {
    this.code = 'AUTH_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'AuthException($code): $message';
}

/// Service containing all authentication business logic.
class AuthService {
  final AuthRepository _repo;
  final JwtUtils _jwtUtils;
  final AppConfig _config;
  final NotificationService _notificationService;
  final Logger _log = Logger('AuthService');
  final Uuid _uuid = const Uuid();

  AuthService(
    this._repo,
    this._jwtUtils,
    this._config,
    this._notificationService,
  );

  // ---------------------------------------------------------------------------
  // Registration
  // ---------------------------------------------------------------------------

  /// Registers a new user account.
  ///
  /// Returns the created user profile and auth tokens.
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      throw const ValidationFailure('Invalid email format');
    }

    // Validate password strength
    final passwordErrors = _validatePassword(password);
    if (passwordErrors.isNotEmpty) {
      throw ValidationFailure(
        'Password does not meet requirements: ${passwordErrors.join(", ")}',
      );
    }

    // Validate display name
    if (displayName.trim().isEmpty || displayName.trim().length < 2) {
      throw const ValidationFailure(
        'Display name must be at least 2 characters',
      );
    }

    // Check if email is already registered
    if (await _repo.emailExists(email)) {
      throw const ValidationFailure(
        'An account with this email already exists',
      );
    }

    // Create user
    final userId = _uuid.v4();
    final passwordHash = PasswordUtils.hashPassword(password);

    final user = await _repo.createUser(
      id: userId,
      email: email.toLowerCase().trim(),
      passwordHash: passwordHash,
      displayName: displayName.trim(),
    );

    // Generate tokens
    final accessToken = _jwtUtils.generateAccessToken(userId, email);
    final refreshToken = _jwtUtils.generateRefreshToken(userId);

    // Create session
    final session = await _repo.createSession(
      id: _uuid.v4(),
      userId: userId,
      refreshTokenHash: _hashToken(refreshToken),
      ipAddress: 'unknown',
      userAgent: 'unknown',
      expiresAt: DateTime.now().toUtc().add(_config.jwtRefreshTokenTtl),
    );

    _log.info('User registered: $email ($userId)');

    return {
      'user': user,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'session': session,
    };
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  /// Authenticates a user with email and password.
  ///
  /// Returns user profile and auth tokens, or indicates 2FA is required.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? ipAddress,
    String? userAgent,
  }) async {
    final user = await _repo.findByEmail(email);

    if (user == null) {
      throw const AuthFailure('Invalid email or password');
    }

    // Check if account is deleted
    if (user['deleted_at'] != null) {
      throw const AuthFailure('This account has been deleted');
    }

    // Check if account is locked
    final lockedUntil = user['locked_until'];
    if (lockedUntil != null) {
      final lockTime = DateTime.parse(lockedUntil as String);
      if (lockTime.isAfter(DateTime.now().toUtc())) {
        throw const AuthFailure(
          'Account temporarily locked due to too many failed login attempts. '
          'Please try again later.',
        );
      }
    }

    // Verify password
    final passwordHash = user['password_hash'] as String;
    if (!PasswordUtils.verifyPassword(password, passwordHash)) {
      await _repo.incrementFailedLoginAttempts(user['id'] as String);
      throw const AuthFailure('Invalid email or password');
    }

    final userId = user['id'] as String;

    // Reset failed attempts on successful password verification
    await _repo.resetFailedLoginAttempts(userId);

    // Transparent rehash: upgrade legacy hashes to Argon2id on successful login
    if (PasswordUtils.needsRehash(passwordHash)) {
      final newHash = PasswordUtils.hashPassword(password);
      await _repo.updatePassword(userId, newHash);
      _log.info('Password hash upgraded to Argon2id for user $userId');
    }

    // Check if 2FA is enabled
    if (user['two_factor_enabled'] == true) {
      // Return a temporary token that requires 2FA verification
      final tempToken = _jwtUtils.generateSensitiveAccessToken(userId);
      return {'requires_2fa': true, 'temp_token': tempToken};
    }

    // Generate tokens
    final accessToken = _jwtUtils.generateAccessToken(
      userId,
      user['email'] as String,
    );
    final refreshToken = _jwtUtils.generateRefreshToken(userId);

    // Create session
    final session = await _repo.createSession(
      id: _uuid.v4(),
      userId: userId,
      refreshTokenHash: _hashToken(refreshToken),
      ipAddress: ipAddress ?? 'unknown',
      userAgent: userAgent ?? 'unknown',
      expiresAt: DateTime.now().toUtc().add(_config.jwtRefreshTokenTtl),
    );

    _log.info('User logged in: ${user['email']} ($userId)');

    // Remove sensitive fields from user response
    final safeUser = Map<String, dynamic>.from(user)
      ..remove('password_hash')
      ..remove('two_factor_secret')
      ..remove('failed_login_attempts')
      ..remove('locked_until');

    return {
      'user': safeUser,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'session': session,
    };
  }

  // ---------------------------------------------------------------------------
  // Token Refresh
  // ---------------------------------------------------------------------------

  /// Refreshes an access token using a valid refresh token.
  ///
  /// Implements token rotation: the old refresh token is invalidated and a
  /// new one is issued.
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    // Verify the refresh token JWT
    final claims = _jwtUtils.verifyToken(refreshToken);
    if (claims == null) {
      throw const AuthFailure('Invalid or expired refresh token');
    }

    final tokenType = claims['type'] as String?;
    if (tokenType != 'refresh') {
      throw const AuthFailure('Invalid token type');
    }

    final userId = claims.subject;
    if (userId == null) {
      throw const AuthFailure('Invalid token');
    }

    // Find the session by refresh token hash
    final tokenHash = _hashToken(refreshToken);
    final session = await _repo.findSessionByRefreshToken(tokenHash);

    if (session == null) {
      // Token not found - possible token reuse attack
      _log.warning(
        'Refresh token not found in database for user $userId - '
        'possible token reuse attack',
      );
      // Revoke all sessions for this user as a precaution
      await _repo.revokeAllSessions(userId);
      throw const AuthFailure(
        'Session not found. All sessions have been revoked for security.',
      );
    }

    // Get user
    final user = await _repo.findById(userId);
    if (user == null || user['deleted_at'] != null) {
      throw const NotFoundFailure('User account not found');
    }

    // Generate new tokens (token rotation)
    final newAccessToken = _jwtUtils.generateAccessToken(
      userId,
      user['email'] as String,
    );
    final newRefreshToken = _jwtUtils.generateRefreshToken(userId);

    // Update session with new refresh token
    await _repo.updateSessionRefreshToken(
      session['id'] as String,
      _hashToken(newRefreshToken),
    );

    _log.fine('Token refreshed for user $userId');

    return {'access_token': newAccessToken, 'refresh_token': newRefreshToken};
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  /// Logs out the user by revoking the current session.
  Future<void> logout(String userId, String refreshToken) async {
    final tokenHash = _hashToken(refreshToken);
    final session = await _repo.findSessionByRefreshToken(tokenHash);

    if (session != null) {
      await _repo.revokeSession(session['id'] as String, userId);
      _log.info('User logged out: $userId');
    }
  }

  // ---------------------------------------------------------------------------
  // Password Reset
  // ---------------------------------------------------------------------------

  /// Initiates a password reset by sending a reset email.
  ///
  /// Always returns success to prevent email enumeration.
  Future<void> forgotPassword(String email) async {
    final user = await _repo.findByEmail(email);

    if (user == null || user['deleted_at'] != null) {
      // Don't reveal that the email doesn't exist
      _log.fine('Password reset requested for non-existent email: $email');
      return;
    }

    final userId = user['id'] as String;
    final token = PasswordUtils.generateToken();
    final tokenHash = PasswordUtils.hashToken(token);

    await _repo.createPasswordResetToken(
      userId: userId,
      tokenHash: tokenHash,
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    );

    // Send reset email
    await _notificationService.sendEmail(
      to: email,
      subject: 'Reset Your Studio Pair Password',
      htmlBody:
          '''
        <h2>Password Reset</h2>
        <p>You requested a password reset for your Studio Pair account.</p>
        <p>Use the following code to reset your password:</p>
        <p><strong>$token</strong></p>
        <p>This code expires in 1 hour.</p>
        <p>If you didn't request this, you can safely ignore this email.</p>
      ''',
      textBody: 'Your password reset code: $token (expires in 1 hour)',
    );

    _log.info('Password reset token sent to $email');
  }

  /// Resets a user's password using a valid reset token.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    // Validate password strength
    final passwordErrors = _validatePassword(newPassword);
    if (passwordErrors.isNotEmpty) {
      throw ValidationFailure(
        'Password does not meet requirements: ${passwordErrors.join(", ")}',
      );
    }

    // Find the token
    final tokenHash = PasswordUtils.hashToken(token);
    final resetToken = await _repo.findPasswordResetToken(tokenHash);

    if (resetToken == null) {
      throw const ValidationFailure('Invalid or expired reset token');
    }

    final userId = resetToken['user_id'] as String;

    // Update password
    final passwordHash = PasswordUtils.hashPassword(newPassword);
    await _repo.updatePassword(userId, passwordHash);

    // Mark token as used
    await _repo.markPasswordResetTokenUsed(tokenHash);

    // Revoke all existing sessions
    await _repo.revokeAllSessions(userId);

    _log.info('Password reset completed for user $userId');
  }

  // ---------------------------------------------------------------------------
  // Two-Factor Authentication
  // ---------------------------------------------------------------------------

  /// Sets up 2FA for a user by generating and storing a secret.
  ///
  /// Returns the secret and backup codes.
  Future<Map<String, dynamic>> setup2FA(String userId) async {
    final user = await _repo.findById(userId);
    if (user == null) {
      throw const NotFoundFailure('User not found');
    }

    if (user['two_factor_enabled'] == true) {
      throw const ValidationFailure(
        'Two-factor authentication is already enabled',
      );
    }

    // Generate a TOTP secret (base32 encoded)
    final secret = PasswordUtils.generateSecureRandom(32);

    // Store the secret (not yet enabled)
    await _repo.store2FASecret(userId, secret);

    // Generate backup codes
    final backupCodes = PasswordUtils.generateBackupCodes(10);
    final hashedCodes = backupCodes
        .map((code) => PasswordUtils.hashToken(code.replaceAll('-', '')))
        .toList();
    await _repo.storeBackupCodes(userId, hashedCodes);

    _log.info('2FA setup initiated for user $userId');

    return {
      'secret': secret,
      'backup_codes': backupCodes,
      'otpauth_url':
          'otpauth://totp/StudioPair:${user['email']}?secret=$secret&issuer=StudioPair',
    };
  }

  /// Verifies a 2FA code and enables 2FA if this is the initial setup.
  ///
  /// For login flow, returns full auth tokens.
  /// For setup flow, enables 2FA on the account.
  Future<Map<String, dynamic>> verify2FA({
    required String userId,
    required String code,
    bool isSetup = false,
    String? ipAddress,
    String? userAgent,
  }) async {
    final user = await _repo.findById(userId);
    if (user == null) {
      throw const NotFoundFailure('User not found');
    }

    final secret = user['two_factor_secret'] as String?;
    if (secret == null) {
      throw const ValidationFailure('Two-factor authentication is not set up');
    }

    // Verify TOTP code
    // For a production implementation, use a proper TOTP library
    // For now, accept any 6-digit code in development mode
    final isValid = _verifyTotpCode(secret, code);

    if (!isValid) {
      // Try backup codes
      final codeHash = PasswordUtils.hashToken(code.replaceAll('-', ''));
      final backupUsed = await _repo.useBackupCode(userId, codeHash);

      if (!backupUsed) {
        throw const AuthFailure('Invalid verification code');
      }

      _log.info('Backup code used for user $userId');
    }

    if (isSetup) {
      // Enable 2FA
      await _repo.enable2FA(userId);
      _log.info('2FA enabled for user $userId');
      return {'enabled': true};
    }

    // Login flow - generate full tokens
    final accessToken = _jwtUtils.generateAccessToken(
      userId,
      user['email'] as String,
    );
    final refreshToken = _jwtUtils.generateRefreshToken(userId);

    final session = await _repo.createSession(
      id: _uuid.v4(),
      userId: userId,
      refreshTokenHash: _hashToken(refreshToken),
      ipAddress: ipAddress ?? 'unknown',
      userAgent: userAgent ?? 'unknown',
      expiresAt: DateTime.now().toUtc().add(_config.jwtRefreshTokenTtl),
    );

    final safeUser = Map<String, dynamic>.from(user)
      ..remove('password_hash')
      ..remove('two_factor_secret')
      ..remove('failed_login_attempts')
      ..remove('locked_until');

    return {
      'user': safeUser,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'session': session,
    };
  }

  /// Disables 2FA for a user (requires password confirmation).
  Future<void> disable2FA(String userId, String password) async {
    final user = await _repo.findById(userId);
    if (user == null) {
      throw const NotFoundFailure('User not found');
    }

    if (user['two_factor_enabled'] != true) {
      throw const ValidationFailure('Two-factor authentication is not enabled');
    }

    // Verify password
    if (!PasswordUtils.verifyPassword(
      password,
      user['password_hash'] as String,
    )) {
      throw const AuthFailure('Invalid password');
    }

    await _repo.disable2FA(userId);
    _log.info('2FA disabled for user $userId');
  }

  // ---------------------------------------------------------------------------
  // Sessions
  // ---------------------------------------------------------------------------

  /// Lists all active sessions for a user.
  Future<List<Map<String, dynamic>>> listSessions(String userId) async {
    return _repo.listSessions(userId);
  }

  /// Revokes a specific session.
  Future<void> revokeSession(String userId, String sessionId) async {
    final revoked = await _repo.revokeSession(sessionId, userId);
    if (!revoked) {
      throw const NotFoundFailure('Session not found');
    }
    _log.info('Session $sessionId revoked for user $userId');
  }

  // ---------------------------------------------------------------------------
  // Account Deletion
  // ---------------------------------------------------------------------------

  /// Deletes a user account (soft delete).
  Future<void> deleteAccount(String userId, String password) async {
    final user = await _repo.findById(userId);
    if (user == null) {
      throw const NotFoundFailure('User not found');
    }

    // Verify password
    if (!PasswordUtils.verifyPassword(
      password,
      user['password_hash'] as String,
    )) {
      throw const AuthFailure('Invalid password');
    }

    // Revoke all sessions
    await _repo.revokeAllSessions(userId);

    // Soft delete the user
    await _repo.softDeleteUser(userId);

    _log.info('Account deleted for user $userId');
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Hashes a token using SHA-256.
  String _hashToken(String token) {
    final bytes = utf8.encode(token);
    return sha256.convert(bytes).toString();
  }

  /// Validates an email format.
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Validates password strength and returns a list of errors.
  List<String> _validatePassword(String password) {
    final errors = <String>[];

    if (password.length < 8) {
      errors.add('must be at least 8 characters');
    }
    if (password.length > 128) {
      errors.add('must be at most 128 characters');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('must contain at least one uppercase letter');
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add('must contain at least one lowercase letter');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('must contain at least one digit');
    }

    return errors;
  }

  /// Verifies a TOTP code against a secret.
  ///
  /// Checks the current time step as well as +/-1 step to account
  /// for minor clock skew between client and server.
  bool _verifyTotpCode(String secret, String code) {
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return false;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    const interval = 30; // standard TOTP 30-second interval

    // Check current, previous, and next time step (±1 for clock skew)
    for (final offset in [-1, 0, 1]) {
      final adjustedTime = now + (offset * interval * 1000);
      final generated = OTP.generateTOTPCodeString(
        secret,
        adjustedTime,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );
      if (generated == code) {
        return true;
      }
    }

    return false;
  }
}
