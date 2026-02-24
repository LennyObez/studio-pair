import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:logging/logging.dart';

import '../config/app_config.dart';

/// Utility class for JWT token generation and verification.
class JwtUtils {
  final AppConfig _config;
  final Logger _log = Logger('JwtUtils');

  JwtUtils(this._config);

  /// Generates a short-lived access token for the given user.
  String generateAccessToken(String userId, String email) {
    final claimSet = JwtClaim(
      issuer: 'studio-pair',
      subject: userId,
      issuedAt: DateTime.now().toUtc(),
      expiry: DateTime.now().toUtc().add(_config.jwtAccessTokenTtl),
      otherClaims: <String, dynamic>{'email': email, 'type': 'access'},
    );

    return issueJwtHS256(claimSet, _config.jwtSecret);
  }

  /// Generates a long-lived refresh token for the given user.
  String generateRefreshToken(String userId) {
    final claimSet = JwtClaim(
      issuer: 'studio-pair',
      subject: userId,
      issuedAt: DateTime.now().toUtc(),
      expiry: DateTime.now().toUtc().add(_config.jwtRefreshTokenTtl),
      otherClaims: <String, dynamic>{'type': 'refresh'},
    );

    return issueJwtHS256(claimSet, _config.jwtSecret);
  }

  /// Generates a very short-lived access token for sensitive operations (5 min).
  String generateSensitiveAccessToken(String userId) {
    final claimSet = JwtClaim(
      issuer: 'studio-pair',
      subject: userId,
      issuedAt: DateTime.now().toUtc(),
      expiry: DateTime.now().toUtc().add(const Duration(minutes: 5)),
      otherClaims: <String, dynamic>{'type': 'sensitive'},
    );

    return issueJwtHS256(claimSet, _config.jwtSecret);
  }

  /// Verifies a JWT token and returns the claim set, or null if invalid.
  JwtClaim? verifyToken(String token) {
    try {
      final claimSet = verifyJwtHS256Signature(token, _config.jwtSecret);
      claimSet.validate(issuer: 'studio-pair');
      return claimSet;
    } on JwtException catch (e) {
      _log.fine('JWT verification failed: $e');
      return null;
    } catch (e) {
      _log.warning('Unexpected error verifying JWT', e);
      return null;
    }
  }

  /// Extracts the user ID (subject) from a valid token.
  String? getUserIdFromToken(String token) {
    final claim = verifyToken(token);
    return claim?.subject;
  }

  /// Extracts the token type from a valid token.
  String? getTokenType(String token) {
    final claim = verifyToken(token);
    if (claim == null) return null;
    return claim['type'] as String?;
  }
}
