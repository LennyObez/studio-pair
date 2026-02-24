import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:studio_pair_backend/src/config/app_config.dart';
import 'package:studio_pair_backend/src/modules/auth/auth_repository.dart';
import 'package:studio_pair_backend/src/modules/auth/auth_service.dart';
import 'package:studio_pair_backend/src/services/notification_service.dart';
import 'package:studio_pair_backend/src/utils/jwt_utils.dart';
import 'package:studio_pair_backend/src/utils/password_utils.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import 'package:test/test.dart';

import 'auth_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthRepository>(),
  MockSpec<JwtUtils>(),
  MockSpec<NotificationService>(),
])
// --- Test helpers ---
/// Generates a legacy PBKDF2 hash for testing backward compatibility.
String _legacyPbkdf2Hash(String plaintext) {
  const saltLength = 32;
  const hashLength = 64;
  const iterations = 100000;
  const algorithm = 'PBKDF2';

  final random = Random.secure();
  final salt = Uint8List.fromList(
    List.generate(saltLength, (_) => random.nextInt(256)),
  );

  final params = Pbkdf2Parameters(salt, iterations, hashLength);
  final derivator = KeyDerivator('SHA-256/HMAC/PBKDF2')..init(params);
  final hash = derivator.process(Uint8List.fromList(utf8.encode(plaintext)));

  final saltBase64 = base64Encode(salt);
  final hashBase64 = base64Encode(hash);

  return '$algorithm:$iterations:$saltBase64:$hashBase64';
}

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
      test('throws ValidationFailure for invalid email format', () async {
        expect(
          () => authService.register(
            email: 'not-an-email',
            password: 'StrongP@ss1',
            displayName: 'Alice',
          ),
          throwsA(
            isA<ValidationFailure>().having(
              (e) => e.message,
              'message',
              'Invalid email format',
            ),
          ),
        );
      });

      test('throws ValidationFailure for weak password', () async {
        expect(
          () => authService.register(
            email: 'alice@example.com',
            password: 'weak',
            displayName: 'Alice',
          ),
          throwsA(
            isA<ValidationFailure>().having(
              (e) => e.message,
              'message',
              contains('Password does not meet requirements'),
            ),
          ),
        );
      });

      test('throws ValidationFailure for empty display name', () async {
        expect(
          () => authService.register(
            email: 'alice@example.com',
            password: 'StrongP@ss1',
            displayName: '',
          ),
          throwsA(
            isA<ValidationFailure>().having(
              (e) => e.message,
              'message',
              'Display name must be at least 2 characters',
            ),
          ),
        );
      });

      test(
        'throws ValidationFailure for display name shorter than 2 characters',
        () async {
          expect(
            () => authService.register(
              email: 'alice@example.com',
              password: 'StrongP@ss1',
              displayName: 'A',
            ),
            throwsA(
              isA<ValidationFailure>().having(
                (e) => e.message,
                'message',
                'Display name must be at least 2 characters',
              ),
            ),
          );
        },
      );

      test('throws ValidationFailure when email is already taken', () async {
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
            isA<ValidationFailure>().having(
              (e) => e.message,
              'message',
              'An account with this email already exists',
            ),
          ),
        );
      });

      test('creates user and returns tokens on success', () async {
        when(
          mockRepo.emailExists('alice@example.com'),
        ).thenAnswer((_) async => false);

        when(
          mockRepo.createUser(
            id: anyNamed('id'),
            email: anyNamed('email'),
            passwordHash: anyNamed('passwordHash'),
            displayName: anyNamed('displayName'),
          ),
        ).thenAnswer(
          (_) async => {
            'id': 'user-1',
            'email': 'alice@example.com',
            'display_name': 'Alice',
          },
        );

        when(
          mockJwt.generateAccessToken(any, any),
        ).thenReturn('access-token-123');
        when(mockJwt.generateRefreshToken(any)).thenReturn('refresh-token-456');

        when(
          mockRepo.createSession(
            id: anyNamed('id'),
            userId: anyNamed('userId'),
            refreshTokenHash: anyNamed('refreshTokenHash'),
            ipAddress: anyNamed('ipAddress'),
            userAgent: anyNamed('userAgent'),
            expiresAt: anyNamed('expiresAt'),
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

      test('registers new users with Argon2id hash', () async {
        when(
          mockRepo.emailExists('new@example.com'),
        ).thenAnswer((_) async => false);

        // Capture the password hash passed to createUser
        String? capturedHash;
        when(
          mockRepo.createUser(
            id: anyNamed('id'),
            email: anyNamed('email'),
            passwordHash: anyNamed('passwordHash'),
            displayName: anyNamed('displayName'),
          ),
        ).thenAnswer((invocation) async {
          capturedHash =
              invocation.namedArguments[const Symbol('passwordHash')] as String;
          return {
            'id': 'user-new',
            'email': 'new@example.com',
            'display_name': 'New User',
          };
        });

        when(mockJwt.generateAccessToken(any, any)).thenReturn('access-token');
        when(mockJwt.generateRefreshToken(any)).thenReturn('refresh-token');
        when(
          mockRepo.createSession(
            id: anyNamed('id'),
            userId: anyNamed('userId'),
            refreshTokenHash: anyNamed('refreshTokenHash'),
            ipAddress: anyNamed('ipAddress'),
            userAgent: anyNamed('userAgent'),
            expiresAt: anyNamed('expiresAt'),
          ),
        ).thenAnswer((_) async => {'id': 'session-1', 'user_id': 'user-new'});

        await authService.register(
          email: 'new@example.com',
          password: 'StrongP@ss1',
          displayName: 'New User',
        );

        expect(capturedHash, isNotNull);
        expect(capturedHash, startsWith('\$argon2id\$'));
      });
    });

    group('login', () {
      test('throws AuthFailure when user is not found', () async {
        when(
          mockRepo.findByEmail('unknown@example.com'),
        ).thenAnswer((_) async => null);

        expect(
          () => authService.login(
            email: 'unknown@example.com',
            password: 'SomePassword1!',
          ),
          throwsA(
            isA<AuthFailure>().having(
              (e) => e.message,
              'message',
              'Invalid email or password',
            ),
          ),
        );
      });

      test('throws AuthFailure when account is deleted', () async {
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
            isA<AuthFailure>().having(
              (e) => e.message,
              'message',
              'This account has been deleted',
            ),
          ),
        );
      });

      test('throws AuthFailure when account is locked', () async {
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
            isA<AuthFailure>().having(
              (e) => e.message,
              'message',
              contains('Account temporarily locked'),
            ),
          ),
        );
      });

      test(
        'throws AuthFailure and increments failed attempts on wrong password',
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
              isA<AuthFailure>().having(
                (e) => e.message,
                'message',
                'Invalid email or password',
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

      test('does not rehash when login uses Argon2id hash', () async {
        final argon2Hash = PasswordUtils.hashPassword('MyPassword1!');
        when(mockRepo.findByEmail('argon2@example.com')).thenAnswer(
          (_) async => {
            'id': 'user-a2',
            'email': 'argon2@example.com',
            'password_hash': argon2Hash,
            'deleted_at': null,
            'locked_until': null,
            'two_factor_enabled': false,
          },
        );
        when(
          mockRepo.resetFailedLoginAttempts('user-a2'),
        ).thenAnswer((_) async {});
        when(mockJwt.generateAccessToken(any, any)).thenReturn('access-token');
        when(mockJwt.generateRefreshToken(any)).thenReturn('refresh-token');
        when(
          mockRepo.createSession(
            id: anyNamed('id'),
            userId: anyNamed('userId'),
            refreshTokenHash: anyNamed('refreshTokenHash'),
            ipAddress: anyNamed('ipAddress'),
            userAgent: anyNamed('userAgent'),
            expiresAt: anyNamed('expiresAt'),
          ),
        ).thenAnswer((_) async => {'id': 'session-1', 'user_id': 'user-a2'});

        await authService.login(
          email: 'argon2@example.com',
          password: 'MyPassword1!',
        );

        // Should NOT call updatePassword since hash is already Argon2id
        verifyNever(mockRepo.updatePassword(any, any));
      });

      test(
        'transparently rehashes legacy PBKDF2 hash to Argon2id on login',
        () async {
          final legacyHash = _legacyPbkdf2Hash('LegacyPass1!');
          when(mockRepo.findByEmail('legacy@example.com')).thenAnswer(
            (_) async => {
              'id': 'user-legacy',
              'email': 'legacy@example.com',
              'password_hash': legacyHash,
              'deleted_at': null,
              'locked_until': null,
              'two_factor_enabled': false,
            },
          );
          when(
            mockRepo.resetFailedLoginAttempts('user-legacy'),
          ).thenAnswer((_) async {});
          when(mockRepo.updatePassword(any, any)).thenAnswer((_) async {});
          when(
            mockJwt.generateAccessToken(any, any),
          ).thenReturn('access-token');
          when(mockJwt.generateRefreshToken(any)).thenReturn('refresh-token');
          when(
            mockRepo.createSession(
              id: anyNamed('id'),
              userId: anyNamed('userId'),
              refreshTokenHash: anyNamed('refreshTokenHash'),
              ipAddress: anyNamed('ipAddress'),
              userAgent: anyNamed('userAgent'),
              expiresAt: anyNamed('expiresAt'),
            ),
          ).thenAnswer(
            (_) async => {'id': 'session-1', 'user_id': 'user-legacy'},
          );

          final result = await authService.login(
            email: 'legacy@example.com',
            password: 'LegacyPass1!',
          );

          // Login should succeed
          expect(result, containsPair('access_token', 'access-token'));

          // Should call updatePassword with an Argon2id hash
          final captured = verify(
            mockRepo.updatePassword('user-legacy', captureAny),
          ).captured;
          expect(captured, hasLength(1));
          expect(captured.first as String, startsWith('\$argon2id\$'));
        },
      );
    });

    group('logout', () {
      test('revokes session when found', () async {
        when(
          mockRepo.findSessionByRefreshToken(any),
        ).thenAnswer((_) async => {'id': 'session-1', 'user_id': 'user-1'});
        when(
          mockRepo.revokeSession('session-1', 'user-1'),
        ).thenAnswer((_) async => true);

        await authService.logout('user-1', 'some-refresh-token');

        verify(mockRepo.revokeSession('session-1', 'user-1')).called(1);
      });

      test('does nothing when session is not found', () async {
        when(
          mockRepo.findSessionByRefreshToken(any),
        ).thenAnswer((_) async => null);

        await authService.logout('user-1', 'non-existent-token');

        verifyNever(mockRepo.revokeSession(any, any));
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
            userId: anyNamed('userId'),
            tokenHash: anyNamed('tokenHash'),
            expiresAt: anyNamed('expiresAt'),
          ),
        ).thenAnswer((_) async {});
        when(
          mockNotification.sendEmail(
            to: anyNamed('to'),
            subject: anyNamed('subject'),
            htmlBody: anyNamed('htmlBody'),
            textBody: anyNamed('textBody'),
          ),
        ).thenAnswer((_) async => true);

        await authService.forgotPassword('user@example.com');

        verify(
          mockRepo.createPasswordResetToken(
            userId: 'user-1',
            tokenHash: anyNamed('tokenHash'),
            expiresAt: anyNamed('expiresAt'),
          ),
        ).called(1);
        verify(
          mockNotification.sendEmail(
            to: 'user@example.com',
            subject: anyNamed('subject'),
            htmlBody: anyNamed('htmlBody'),
            textBody: anyNamed('textBody'),
          ),
        ).called(1);
      });
    });

    group('AppFailure', () {
      test('AuthFailure has correct message', () {
        const failure = AuthFailure('test error');
        expect(failure.message, equals('test error'));
        expect(failure, isA<AppFailure>());
      });

      test('ValidationFailure has correct message', () {
        const failure = ValidationFailure('bad input');
        expect(failure.message, equals('bad input'));
        expect(failure, isA<AppFailure>());
      });

      test('NotFoundFailure has correct message', () {
        const failure = NotFoundFailure('not found');
        expect(failure.message, equals('not found'));
        expect(failure, isA<AppFailure>());
      });

      test('toString includes type and message', () {
        const failure = AuthFailure('bad request');
        expect(failure.toString(), contains('AuthFailure'));
        expect(failure.toString(), contains('bad request'));
      });
    });
  });
}
