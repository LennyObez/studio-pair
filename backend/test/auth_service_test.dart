// Mockito matchers (any, argThat, etc.) return null at compile time, which
// is incompatible with non-nullable parameter types. This is a known
// limitation of Mockito with Dart null safety.
// ignore_for_file: argument_type_not_assignable

import 'package:mockito/mockito.dart';
import 'package:studio_pair_backend/src/config/app_config.dart';
import 'package:studio_pair_backend/src/modules/auth/auth_repository.dart';
import 'package:studio_pair_backend/src/modules/auth/auth_service.dart';
import 'package:studio_pair_backend/src/services/notification_service.dart';
import 'package:studio_pair_backend/src/utils/jwt_utils.dart';
import 'package:studio_pair_backend/src/utils/password_utils.dart';
import 'package:test/test.dart';

// --- Manual mocks ---

class MockAuthRepository extends Mock implements AuthRepository {}

class MockJwtUtils extends Mock implements JwtUtils {}

class MockNotificationService extends Mock implements NotificationService {}

// --- Test helpers ---

AppConfig _testConfig() {
  return const AppConfig(
    host: 'localhost',
    port: 8080,
    env: 'development',
    databaseUrl: 'postgres://test:test@localhost:5432/test',
    databasePoolSize: 1,
    jwtSecret: 'test-secret-key-for-testing',
    jwtAccessTokenTtl: Duration(minutes: 15),
    jwtRefreshTokenTtl: Duration(days: 30),
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
    encryptionMasterKey: 'test-key',
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
  group('AuthService', () {
    late MockAuthRepository mockRepo;
    late MockJwtUtils mockJwt;
    late MockNotificationService mockNotification;
    late AuthService authService;
    late AppConfig config;

    setUp(() {
      mockRepo = MockAuthRepository();
      mockJwt = MockJwtUtils();
      mockNotification = MockNotificationService();
      config = _testConfig();
      authService = AuthService(mockRepo, mockJwt, config, mockNotification);
    });

    group('register', () {
      test('throws AuthException for invalid email format', () async {
        expect(
          () => authService.register(
            email: 'not-an-email',
            password: 'StrongP@ss1',
            displayName: 'Alice',
          ),
          throwsA(
            isA<AuthException>().having((e) => e.code, 'code', 'INVALID_EMAIL'),
          ),
        );
      });

      test('throws AuthException for weak password', () async {
        expect(
          () => authService.register(
            email: 'alice@example.com',
            password: 'weak',
            displayName: 'Alice',
          ),
          throwsA(
            isA<AuthException>().having((e) => e.code, 'code', 'WEAK_PASSWORD'),
          ),
        );
      });

      test('throws AuthException for empty display name', () async {
        expect(
          () => authService.register(
            email: 'alice@example.com',
            password: 'StrongP@ss1',
            displayName: '',
          ),
          throwsA(
            isA<AuthException>().having(
              (e) => e.code,
              'code',
              'INVALID_DISPLAY_NAME',
            ),
          ),
        );
      });

      test(
        'throws AuthException for display name shorter than 2 characters',
        () async {
          expect(
            () => authService.register(
              email: 'alice@example.com',
              password: 'StrongP@ss1',
              displayName: 'A',
            ),
            throwsA(
              isA<AuthException>().having(
                (e) => e.code,
                'code',
                'INVALID_DISPLAY_NAME',
              ),
            ),
          );
        },
      );

      test('throws AuthException when email is already taken', () async {
        when(
          mockRepo.emailExists('alice@example.com'),
        ).thenAnswer((_) async => true);

        expect(
          () => authService.register(
            email: 'alice@example.com',
            password: 'StrongP@ss1',
            displayName: 'Alice',
          ),
          throwsA(
            isA<AuthException>().having((e) => e.code, 'code', 'EMAIL_TAKEN'),
          ),
        );
      });

      test('creates user and returns tokens on success', () async {
        when(
          mockRepo.emailExists('alice@example.com'),
        ).thenAnswer((_) async => false);

        when(
          mockRepo.createUser(
            id: argThat(isA<String>(), named: 'id'),
            email: argThat(isA<String>(), named: 'email'),
            passwordHash: argThat(isA<String>(), named: 'passwordHash'),
            displayName: argThat(isA<String>(), named: 'displayName'),
          ),
        ).thenAnswer(
          (_) async => {
            'id': 'user-1',
            'email': 'alice@example.com',
            'display_name': 'Alice',
          },
        );

        when(
          mockJwt.generateAccessToken(
            argThat(isA<String>()),
            argThat(isA<String>()),
          ),
        ).thenReturn('access-token-123');
        when(
          mockJwt.generateRefreshToken(argThat(isA<String>())),
        ).thenReturn('refresh-token-456');

        when(
          mockRepo.createSession(
            id: argThat(isA<String>(), named: 'id'),
            userId: argThat(isA<String>(), named: 'userId'),
            refreshTokenHash: argThat(isA<String>(), named: 'refreshTokenHash'),
            ipAddress: argThat(isA<String>(), named: 'ipAddress'),
            userAgent: argThat(isA<String>(), named: 'userAgent'),
            expiresAt: argThat(isA<DateTime>(), named: 'expiresAt'),
          ),
        ).thenAnswer((_) async => {'id': 'session-1', 'user_id': 'user-1'});

        final result = await authService.register(
          email: 'alice@example.com',
          password: 'StrongP@ss1',
          displayName: 'Alice',
        );

        expect(result, containsPair('access_token', 'access-token-123'));
        expect(result, containsPair('refresh_token', 'refresh-token-456'));
        expect(result, contains('user'));
        expect(result, contains('session'));
      });
    });

    group('login', () {
      test('throws AuthException when user is not found', () async {
        when(
          mockRepo.findByEmail('unknown@example.com'),
        ).thenAnswer((_) async => null);

        expect(
          () => authService.login(
            email: 'unknown@example.com',
            password: 'SomePassword1!',
          ),
          throwsA(
            isA<AuthException>().having(
              (e) => e.code,
              'code',
              'INVALID_CREDENTIALS',
            ),
          ),
        );
      });

      test('throws AuthException when account is deleted', () async {
        when(mockRepo.findByEmail('deleted@example.com')).thenAnswer(
          (_) async => {
            'id': 'user-1',
            'email': 'deleted@example.com',
            'password_hash': 'hash',
            'deleted_at': DateTime.now().toIso8601String(),
          },
        );

        expect(
          () => authService.login(
            email: 'deleted@example.com',
            password: 'Password1!',
          ),
          throwsA(
            isA<AuthException>().having(
              (e) => e.code,
              'code',
              'ACCOUNT_DELETED',
            ),
          ),
        );
      });

      test('throws AuthException when account is locked', () async {
        final futureTime = DateTime.now().toUtc().add(
          const Duration(minutes: 10),
        );
        when(mockRepo.findByEmail('locked@example.com')).thenAnswer(
          (_) async => {
            'id': 'user-1',
            'email': 'locked@example.com',
            'password_hash': 'hash',
            'deleted_at': null,
            'locked_until': futureTime.toIso8601String(),
          },
        );

        expect(
          () => authService.login(
            email: 'locked@example.com',
            password: 'Password1!',
          ),
          throwsA(
            isA<AuthException>().having(
              (e) => e.code,
              'code',
              'ACCOUNT_LOCKED',
            ),
          ),
        );
      });

      test(
        'throws AuthException and increments failed attempts on wrong password',
        () async {
          final passwordHash = PasswordUtils.hashPassword('CorrectPass1!');
          when(mockRepo.findByEmail('user@example.com')).thenAnswer(
            (_) async => {
              'id': 'user-1',
              'email': 'user@example.com',
              'password_hash': passwordHash,
              'deleted_at': null,
              'locked_until': null,
              'two_factor_enabled': false,
            },
          );
          when(
            mockRepo.incrementFailedLoginAttempts('user-1'),
          ).thenAnswer((_) async {});

          expect(
            () => authService.login(
              email: 'user@example.com',
              password: 'WrongPass1!',
            ),
            throwsA(
              isA<AuthException>().having(
                (e) => e.code,
                'code',
                'INVALID_CREDENTIALS',
              ),
            ),
          );
        },
      );

      test('returns 2FA requirement when TOTP is enabled', () async {
        final passwordHash = PasswordUtils.hashPassword('MyPassword1!');
        when(mockRepo.findByEmail('2fa@example.com')).thenAnswer(
          (_) async => {
            'id': 'user-2fa',
            'email': '2fa@example.com',
            'password_hash': passwordHash,
            'deleted_at': null,
            'locked_until': null,
            'two_factor_enabled': true,
          },
        );
        when(
          mockRepo.resetFailedLoginAttempts('user-2fa'),
        ).thenAnswer((_) async {});
        when(
          mockJwt.generateSensitiveAccessToken('user-2fa'),
        ).thenReturn('temp-token-xyz');

        final result = await authService.login(
          email: '2fa@example.com',
          password: 'MyPassword1!',
        );

        expect(result['requires_2fa'], isTrue);
        expect(result['temp_token'], equals('temp-token-xyz'));
      });
    });

    group('logout', () {
      test('revokes session when found', () async {
        when(
          mockRepo.findSessionByRefreshToken(argThat(isA<String>())),
        ).thenAnswer((_) async => {'id': 'session-1', 'user_id': 'user-1'});
        when(
          mockRepo.revokeSession('session-1', 'user-1'),
        ).thenAnswer((_) async => true);

        await authService.logout('user-1', 'some-refresh-token');

        verify(mockRepo.revokeSession('session-1', 'user-1')).called(1);
      });

      test('does nothing when session is not found', () async {
        when(
          mockRepo.findSessionByRefreshToken(argThat(isA<String>())),
        ).thenAnswer((_) async => null);

        await authService.logout('user-1', 'non-existent-token');

        verifyNever(
          mockRepo.revokeSession(
            argThat(isA<String>()),
            argThat(isA<String>()),
          ),
        );
      });
    });

    group('forgotPassword', () {
      test(
        'does not throw when user is not found (prevents enumeration)',
        () async {
          when(
            mockRepo.findByEmail('unknown@example.com'),
          ).thenAnswer((_) async => null);

          // Should complete without throwing
          await authService.forgotPassword('unknown@example.com');
        },
      );

      test('creates reset token and sends email for existing user', () async {
        when(mockRepo.findByEmail('user@example.com')).thenAnswer(
          (_) async => {
            'id': 'user-1',
            'email': 'user@example.com',
            'deleted_at': null,
          },
        );
        when(
          mockRepo.createPasswordResetToken(
            userId: argThat(isA<String>(), named: 'userId'),
            tokenHash: argThat(isA<String>(), named: 'tokenHash'),
            expiresAt: argThat(isA<DateTime>(), named: 'expiresAt'),
          ),
        ).thenAnswer((_) async {});
        when(
          mockNotification.sendEmail(
            to: argThat(isA<String>(), named: 'to'),
            subject: argThat(isA<String>(), named: 'subject'),
            htmlBody: argThat(isA<String>(), named: 'htmlBody'),
            textBody: argThat(isA<String>(), named: 'textBody'),
          ),
        ).thenAnswer((_) async => true);

        await authService.forgotPassword('user@example.com');

        verify(
          mockRepo.createPasswordResetToken(
            userId: 'user-1',
            tokenHash: argThat(isA<String>(), named: 'tokenHash'),
            expiresAt: argThat(isA<DateTime>(), named: 'expiresAt'),
          ),
        ).called(1);
        verify(
          mockNotification.sendEmail(
            to: 'user@example.com',
            subject: argThat(isA<String>(), named: 'subject'),
            htmlBody: argThat(isA<String>(), named: 'htmlBody'),
            textBody: argThat(isA<String>(), named: 'textBody'),
          ),
        ).called(1);
      });
    });

    group('AuthException', () {
      test('has correct default values', () {
        const exception = AuthException('test error');
        expect(exception.message, equals('test error'));
        expect(exception.code, equals('AUTH_ERROR'));
        expect(exception.statusCode, equals(400));
      });

      test('toString includes code and message', () {
        const exception = AuthException('bad request', code: 'BAD');
        expect(exception.toString(), contains('BAD'));
        expect(exception.toString(), contains('bad request'));
      });
    });
  });
}
