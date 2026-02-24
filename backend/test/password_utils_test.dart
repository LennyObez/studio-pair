import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';
import 'package:studio_pair_backend/src/utils/password_utils.dart';
import 'package:test/test.dart';

/// Generates a legacy PBKDF2 hash for testing backward compatibility.
///
/// This replicates the old hashing logic so we can verify the migration path.
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

void main() {
  group('PasswordUtils', () {
    group('hashPassword (Argon2id)', () {
      test('produces a non-empty hash', () {
        final hash = PasswordUtils.hashPassword('MySecureP@ss1');
        expect(hash, isNotEmpty);
      });

      test('hash starts with \$argon2id\$', () {
        final hash = PasswordUtils.hashPassword('TestPassword1!');
        expect(hash, startsWith('\$argon2id\$'));
      });

      test('hash is in PHC format with expected parameters', () {
        final hash = PasswordUtils.hashPassword('TestPassword1!');
        // Format: $argon2id$v=19$m=65536,t=3,p=4$<salt>$<hash>
        expect(hash, contains('v=19'));
        expect(hash, contains('m=65536'));
        expect(hash, contains('t=3'));
        expect(hash, contains('p=4'));
      });

      test('different passwords produce different hashes', () {
        final hash1 = PasswordUtils.hashPassword('Password1!');
        final hash2 = PasswordUtils.hashPassword('Password2!');
        expect(hash1, isNot(equals(hash2)));
      });

      test('same password produces different hashes (random salt)', () {
        final hash1 = PasswordUtils.hashPassword('SamePassword1!');
        final hash2 = PasswordUtils.hashPassword('SamePassword1!');
        expect(hash1, isNot(equals(hash2)));
      });
    });

    group('verifyPassword', () {
      test('verifies a correct password against Argon2id hash', () {
        final hash = PasswordUtils.hashPassword('CorrectHorse!1');
        expect(PasswordUtils.verifyPassword('CorrectHorse!1', hash), isTrue);
      });

      test('rejects an incorrect password against Argon2id hash', () {
        final hash = PasswordUtils.hashPassword('CorrectHorse!1');
        expect(PasswordUtils.verifyPassword('WrongHorse!1', hash), isFalse);
      });

      test('rejects an empty password against Argon2id hash', () {
        final hash = PasswordUtils.hashPassword('SomePassword1!');
        expect(PasswordUtils.verifyPassword('', hash), isFalse);
      });

      test('verifies a correct password against legacy PBKDF2 hash', () {
        final legacyHash = _legacyPbkdf2Hash('LegacyPass1!');
        expect(
          PasswordUtils.verifyPassword('LegacyPass1!', legacyHash),
          isTrue,
        );
      });

      test('rejects an incorrect password against legacy PBKDF2 hash', () {
        final legacyHash = _legacyPbkdf2Hash('LegacyPass1!');
        expect(
          PasswordUtils.verifyPassword('WrongPass1!', legacyHash),
          isFalse,
        );
      });

      test('returns false for malformed stored hash', () {
        expect(PasswordUtils.verifyPassword('test', 'not:a:valid'), isFalse);
        expect(PasswordUtils.verifyPassword('test', ''), isFalse);
        expect(PasswordUtils.verifyPassword('test', 'garbage'), isFalse);
      });

      test('returns false for wrong algorithm in legacy hash format', () {
        final hash = _legacyPbkdf2Hash('Test1!password');
        final parts = hash.split(':');
        final wrongAlgoHash = 'BCRYPT:${parts[1]}:${parts[2]}:${parts[3]}';
        expect(
          PasswordUtils.verifyPassword('Test1!password', wrongAlgoHash),
          isFalse,
        );
      });
    });

    group('needsRehash', () {
      test('returns false for Argon2id hashes', () {
        final hash = PasswordUtils.hashPassword('TestPassword1!');
        expect(PasswordUtils.needsRehash(hash), isFalse);
      });

      test('returns true for legacy PBKDF2 hashes', () {
        final legacyHash = _legacyPbkdf2Hash('TestPassword1!');
        expect(PasswordUtils.needsRehash(legacyHash), isTrue);
      });

      test('returns true for unknown hash formats', () {
        expect(PasswordUtils.needsRehash('BCRYPT:some:data:here'), isTrue);
        expect(PasswordUtils.needsRehash('unknown-format'), isTrue);
      });
    });

    group('transparent upgrade path', () {
      test('legacy PBKDF2 hash can be verified then rehashed to Argon2id', () {
        const password = 'MigrationTest1!';

        // Simulate existing PBKDF2 hash in database
        final legacyHash = _legacyPbkdf2Hash(password);
        expect(legacyHash, startsWith('PBKDF2:'));
        expect(PasswordUtils.needsRehash(legacyHash), isTrue);

        // Verify with old hash
        expect(PasswordUtils.verifyPassword(password, legacyHash), isTrue);

        // Rehash with Argon2id
        final newHash = PasswordUtils.hashPassword(password);
        expect(newHash, startsWith('\$argon2id\$'));
        expect(PasswordUtils.needsRehash(newHash), isFalse);

        // Verify with new hash
        expect(PasswordUtils.verifyPassword(password, newHash), isTrue);
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
