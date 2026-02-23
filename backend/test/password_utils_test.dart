import 'package:studio_pair_backend/src/utils/password_utils.dart';
import 'package:test/test.dart';

void main() {
  group('PasswordUtils', () {
    group('hashPassword', () {
      test('produces a non-empty hash', () {
        final hash = PasswordUtils.hashPassword('MySecureP@ss1');
        expect(hash, isNotEmpty);
      });

      test('hash format is algorithm:iterations:salt:hash', () {
        final hash = PasswordUtils.hashPassword('TestPassword1!');
        final parts = hash.split(':');
        expect(parts.length, equals(4));
        expect(parts[0], equals('PBKDF2'));
        expect(int.tryParse(parts[1]), isNotNull);
        expect(parts[2], isNotEmpty); // salt in base64
        expect(parts[3], isNotEmpty); // hash in base64
      });

      test('uses 100000 iterations', () {
        final hash = PasswordUtils.hashPassword('Password123!');
        final parts = hash.split(':');
        expect(int.parse(parts[1]), equals(100000));
      });

      test('different passwords produce different hashes', () {
        final hash1 = PasswordUtils.hashPassword('Password1!');
        final hash2 = PasswordUtils.hashPassword('Password2!');
        expect(hash1, isNot(equals(hash2)));
      });

      test('same password produces different hashes (random salt)', () {
        final hash1 = PasswordUtils.hashPassword('SamePassword1!');
        final hash2 = PasswordUtils.hashPassword('SamePassword1!');
        // Due to random salt, the hashes should differ
        expect(hash1, isNot(equals(hash2)));
      });
    });

    group('verifyPassword', () {
      test('verifies a correct password', () {
        final hash = PasswordUtils.hashPassword('CorrectHorse!1');
        expect(PasswordUtils.verifyPassword('CorrectHorse!1', hash), isTrue);
      });

      test('rejects an incorrect password', () {
        final hash = PasswordUtils.hashPassword('CorrectHorse!1');
        expect(PasswordUtils.verifyPassword('WrongHorse!1', hash), isFalse);
      });

      test('rejects an empty password', () {
        final hash = PasswordUtils.hashPassword('SomePassword1!');
        expect(PasswordUtils.verifyPassword('', hash), isFalse);
      });

      test('returns false for malformed stored hash', () {
        expect(PasswordUtils.verifyPassword('test', 'not:a:valid'), isFalse);
        expect(PasswordUtils.verifyPassword('test', ''), isFalse);
        expect(PasswordUtils.verifyPassword('test', 'garbage'), isFalse);
      });

      test('returns false for wrong algorithm in stored hash', () {
        // Construct a hash string with wrong algorithm prefix
        final hash = PasswordUtils.hashPassword('Test1!password');
        final parts = hash.split(':');
        final wrongAlgoHash = 'BCRYPT:${parts[1]}:${parts[2]}:${parts[3]}';
        expect(
          PasswordUtils.verifyPassword('Test1!password', wrongAlgoHash),
          isFalse,
        );
      });
    });

    group('generateSecureRandom', () {
      test('generates string of requested length', () {
        final random = PasswordUtils.generateSecureRandom(32);
        expect(random.length, equals(32));
      });

      test('generates different values on each call', () {
        final r1 = PasswordUtils.generateSecureRandom(32);
        final r2 = PasswordUtils.generateSecureRandom(32);
        expect(r1, isNot(equals(r2)));
      });

      test('generates only alphanumeric characters', () {
        final random = PasswordUtils.generateSecureRandom(100);
        expect(random, matches(RegExp(r'^[a-zA-Z0-9]+$')));
      });

      test('generates empty string for zero length', () {
        final random = PasswordUtils.generateSecureRandom(0);
        expect(random, isEmpty);
      });
    });

    group('generateInviteCode', () {
      test('generates an 8-character code', () {
        final code = PasswordUtils.generateInviteCode();
        expect(code.length, equals(8));
      });

      test('generates uppercase alphanumeric characters', () {
        final code = PasswordUtils.generateInviteCode();
        // Allowed chars: ABCDEFGHJKLMNPQRSTUVWXYZ23456789
        expect(code, matches(RegExp(r'^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]+$')));
      });

      test('does not contain confusing characters (0, O, 1, I)', () {
        // Generate multiple codes and check none contain confusing chars
        for (var i = 0; i < 20; i++) {
          final code = PasswordUtils.generateInviteCode();
          expect(code, isNot(contains('0')));
          expect(code, isNot(contains('O')));
          expect(code, isNot(contains('1')));
          expect(code, isNot(contains('I')));
        }
      });
    });

    group('generateBackupCodes', () {
      test('generates the requested number of codes', () {
        final codes = PasswordUtils.generateBackupCodes(10);
        expect(codes.length, equals(10));
      });

      test('codes are in XXXXX-XXXXX format', () {
        final codes = PasswordUtils.generateBackupCodes(5);
        for (final code in codes) {
          expect(code, matches(RegExp(r'^.{5}-.{5}$')));
        }
      });

      test('generates unique codes', () {
        final codes = PasswordUtils.generateBackupCodes(10);
        final uniqueCodes = codes.toSet();
        expect(uniqueCodes.length, equals(codes.length));
      });
    });

    group('generateToken', () {
      test('generates a 64-character token', () {
        final token = PasswordUtils.generateToken();
        expect(token.length, equals(64));
      });

      test('generates different tokens each time', () {
        final t1 = PasswordUtils.generateToken();
        final t2 = PasswordUtils.generateToken();
        expect(t1, isNot(equals(t2)));
      });
    });

    group('hashToken', () {
      test('produces a non-empty hash', () {
        final hash = PasswordUtils.hashToken('some-token');
        expect(hash, isNotEmpty);
      });

      test('same input produces same hash (deterministic)', () {
        final hash1 = PasswordUtils.hashToken('my-token');
        final hash2 = PasswordUtils.hashToken('my-token');
        expect(hash1, equals(hash2));
      });

      test('different inputs produce different hashes', () {
        final hash1 = PasswordUtils.hashToken('token-a');
        final hash2 = PasswordUtils.hashToken('token-b');
        expect(hash1, isNot(equals(hash2)));
      });

      test('produces a 64-character hex string (SHA-256)', () {
        final hash = PasswordUtils.hashToken('test');
        expect(hash.length, equals(64));
        expect(hash, matches(RegExp(r'^[0-9a-f]+$')));
      });
    });
  });
}
