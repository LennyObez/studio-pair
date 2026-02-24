import 'package:studio_pair_backend/src/config/app_config.dart';
import 'package:studio_pair_backend/src/utils/jwt_utils.dart';
import 'package:test/test.dart';

/// Creates a test AppConfig with minimal required fields.
AppConfig _testConfig({
  String jwtSecret = 'test-secret-key-for-jwt-testing-1234567890',
  Duration accessTokenTtl = const Duration(minutes: 15),
  Duration refreshTokenTtl = const Duration(days: 30),
}) {
  return AppConfig(
    host: 'localhost',
    port: 8080,
    env: 'test',
    databaseUrl: 'postgres://test:test@localhost:5432/test',
    databasePoolSize: 1,
    jwtSecret: jwtSecret,
    jwtAccessTokenTtl: accessTokenTtl,
    jwtRefreshTokenTtl: refreshTokenTtl,
    smtpHost: 'localhost',
    smtpPort: 587,
    smtpUsername: '',
    smtpPassword: '',
    smtpFromEmail: 'test@test.com',
    smtpFromName: 'Test',
    fcmServerKey: '',
    apnsKeyId: '',
    apnsTeamId: '',
    apnsBundleId: '',
    tmdbApiKey: '',
    rawgApiKey: '',
    spotifyClientId: '',
    spotifyClientSecret: '',
    googlePlacesApiKey: '',
    youtubeApiKey: '',
    storageProvider: 'local',
    storagePath: './test_uploads',
    encryptionMasterKey: 'test-encryption-key',
    aiApiKey: '',
    aiProvider: 'anthropic',
    aiModel: 'test-model',
    googlePlayServiceAccountJson: '',
    appStoreIssuerId: '',
    appStoreKeyId: '',
    appStorePrivateKey: '',
    appStoreSharedSecret: '',
  );
}

void main() {
  group('JwtUtils', () {
    late JwtUtils jwtUtils;

    setUp(() {
      jwtUtils = JwtUtils(_testConfig());
    });

    group('generateAccessToken', () {
      test('generates a non-empty token', () {
        final token = jwtUtils.generateAccessToken(
          'user-123',
          'user@example.com',
        );
        expect(token, isNotEmpty);
      });

      test('generates a token with three parts (JWT format)', () {
        final token = jwtUtils.generateAccessToken(
          'user-123',
          'user@example.com',
        );
        final parts = token.split('.');
        expect(parts.length, equals(3));
      });

      test('token can be verified', () {
        final token = jwtUtils.generateAccessToken(
          'user-123',
          'user@example.com',
        );
        final claims = jwtUtils.verifyToken(token);
        expect(claims, isNotNull);
      });

      test('token contains the correct subject (user ID)', () {
        final token = jwtUtils.generateAccessToken(
          'user-123',
          'user@example.com',
        );
        final claims = jwtUtils.verifyToken(token);
        expect(claims!.subject, equals('user-123'));
      });

      test('token contains the correct type claim', () {
        final token = jwtUtils.generateAccessToken(
          'user-123',
          'user@example.com',
        );
        final claims = jwtUtils.verifyToken(token);
        expect(claims!['type'], equals('access'));
      });

      test('token contains the email claim', () {
        final token = jwtUtils.generateAccessToken(
          'user-123',
          'user@example.com',
        );
        final claims = jwtUtils.verifyToken(token);
        expect(claims!['email'], equals('user@example.com'));
      });
    });

    group('generateRefreshToken', () {
      test('generates a non-empty token', () {
        final token = jwtUtils.generateRefreshToken('user-456');
        expect(token, isNotEmpty);
      });

      test('token can be verified', () {
        final token = jwtUtils.generateRefreshToken('user-456');
        final claims = jwtUtils.verifyToken(token);
        expect(claims, isNotNull);
      });

      test('token contains the correct subject', () {
        final token = jwtUtils.generateRefreshToken('user-456');
        final claims = jwtUtils.verifyToken(token);
        expect(claims!.subject, equals('user-456'));
      });

      test('token contains the correct type claim', () {
        final token = jwtUtils.generateRefreshToken('user-456');
        final claims = jwtUtils.verifyToken(token);
        expect(claims!['type'], equals('refresh'));
      });
    });

    group('generateSensitiveAccessToken', () {
      test('generates a non-empty token', () {
        final token = jwtUtils.generateSensitiveAccessToken('user-789');
        expect(token, isNotEmpty);
      });

      test('token can be verified', () {
        final token = jwtUtils.generateSensitiveAccessToken('user-789');
        final claims = jwtUtils.verifyToken(token);
        expect(claims, isNotNull);
      });

      test('token contains the correct type claim', () {
        final token = jwtUtils.generateSensitiveAccessToken('user-789');
        final claims = jwtUtils.verifyToken(token);
        expect(claims!['type'], equals('sensitive'));
      });

      test('token contains the correct subject', () {
        final token = jwtUtils.generateSensitiveAccessToken('user-789');
        final claims = jwtUtils.verifyToken(token);
        expect(claims!.subject, equals('user-789'));
      });
    });

    group('verifyToken', () {
      test('returns claims for a valid token', () {
        final token = jwtUtils.generateAccessToken('user-123', 'test@test.com');
        final claims = jwtUtils.verifyToken(token);
        expect(claims, isNotNull);
        expect(claims!.issuer, equals('studio-pair'));
      });

      test('returns null for a completely invalid token', () {
        final claims = jwtUtils.verifyToken('not.a.valid.token');
        expect(claims, isNull);
      });

      test('returns null for an empty token', () {
        final claims = jwtUtils.verifyToken('');
        expect(claims, isNull);
      });

      test('returns null for a token signed with a different secret', () {
        final otherConfig = _testConfig(
          jwtSecret: 'different-secret-key-1234567890',
        );
        final otherJwt = JwtUtils(otherConfig);
        final token = otherJwt.generateAccessToken('user-123', 'test@test.com');

        final claims = jwtUtils.verifyToken(token);
        expect(claims, isNull);
      });

      test('returns null for an expired token', () {
        final shortLivedConfig = _testConfig(
          accessTokenTtl: const Duration(seconds: -1),
        );
        final shortLivedJwt = JwtUtils(shortLivedConfig);
        final token = shortLivedJwt.generateAccessToken(
          'user-123',
          'test@test.com',
        );

        final claims = jwtUtils.verifyToken(token);
        expect(claims, isNull);
      });
    });

    group('getUserIdFromToken', () {
      test('extracts user ID from a valid token', () {
        final token = jwtUtils.generateAccessToken('user-abc', 'abc@test.com');
        final userId = jwtUtils.getUserIdFromToken(token);
        expect(userId, equals('user-abc'));
      });

      test('returns null for an invalid token', () {
        final userId = jwtUtils.getUserIdFromToken('invalid');
        expect(userId, isNull);
      });
    });

    group('getTokenType', () {
      test('returns "access" for an access token', () {
        final token = jwtUtils.generateAccessToken('user-123', 'test@test.com');
        final tokenType = jwtUtils.getTokenType(token);
        expect(tokenType, equals('access'));
      });

      test('returns "refresh" for a refresh token', () {
        final token = jwtUtils.generateRefreshToken('user-123');
        final tokenType = jwtUtils.getTokenType(token);
        expect(tokenType, equals('refresh'));
      });

      test('returns "sensitive" for a sensitive access token', () {
        final token = jwtUtils.generateSensitiveAccessToken('user-123');
        final tokenType = jwtUtils.getTokenType(token);
        expect(tokenType, equals('sensitive'));
      });

      test('returns null for an invalid token', () {
        final tokenType = jwtUtils.getTokenType('garbage');
        expect(tokenType, isNull);
      });
    });

    group('token differentiation', () {
      test('access and refresh tokens are different for same user', () {
        final accessToken = jwtUtils.generateAccessToken('user-123', 'u@t.com');
        final refreshToken = jwtUtils.generateRefreshToken('user-123');
        expect(accessToken, isNot(equals(refreshToken)));
      });

      test('tokens for different users are different', () {
        final token1 = jwtUtils.generateAccessToken('user-1', 'u1@t.com');
        final token2 = jwtUtils.generateAccessToken('user-2', 'u2@t.com');
        expect(token1, isNot(equals(token2)));
      });
    });
  });
}
