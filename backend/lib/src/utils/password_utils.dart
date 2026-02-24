import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

/// Utility class for password hashing, verification, and secure random generation.
///
/// New passwords are hashed with Argon2id. Legacy PBKDF2 hashes are still
/// verified for backward compatibility, but callers should re-hash on
/// successful login when [needsRehash] returns true.
class PasswordUtils {
  // ---------------------------------------------------------------------------
  // Argon2id parameters
  // ---------------------------------------------------------------------------
  static const int _argon2Memory = 65536; // 64 MB
  static const int _argon2Iterations = 3;
  static const int _argon2Parallelism = 4;
  static const int _argon2HashLength = 32;
  static const int _argon2SaltLength = 16;

  // ---------------------------------------------------------------------------
  // Legacy PBKDF2 parameters (kept for backward-compat verification only)
  // ---------------------------------------------------------------------------
  static const String _pbkdf2Algorithm = 'PBKDF2';

  /// Hashes a plaintext password using Argon2id.
  ///
  /// Returns an encoded Argon2id hash string (PHC format) starting with
  /// `$argon2id$`.
  static String hashPassword(String plaintext) {
    final salt = _generateRandomBytes(_argon2SaltLength);
    final saltBase64 = base64Encode(salt);

    final params = Argon2Parameters(
      Argon2Parameters.ARGON2_id,
      Uint8List.fromList(salt),
      desiredKeyLength: _argon2HashLength,
      iterations: _argon2Iterations,
      memory: _argon2Memory,
      lanes: _argon2Parallelism,
    );

    final argon2 = Argon2BytesGenerator()..init(params);

    final passwordBytes = Uint8List.fromList(utf8.encode(plaintext));
    final result = Uint8List(_argon2HashLength);
    argon2.deriveKey(passwordBytes, 0, result, 0);

    final hashBase64 = base64Encode(result);

    // Encode in a format we can parse back: $argon2id$v=19$m=<memory>,t=<iterations>,p=<parallelism>$<salt>$<hash>
    return '\$argon2id\$v=19\$m=$_argon2Memory,t=$_argon2Iterations,p=$_argon2Parallelism\$$saltBase64\$$hashBase64';
  }

  /// Verifies a plaintext password against a stored hash string.
  ///
  /// Automatically detects the hash format:
  /// - Argon2id hashes (starting with `$argon2id$`) are verified with Argon2id.
  /// - Legacy PBKDF2 hashes (starting with `PBKDF2:`) are verified with PBKDF2.
  static bool verifyPassword(String plaintext, String storedHash) {
    try {
      if (storedHash.startsWith('\$argon2id\$')) {
        return _verifyArgon2id(plaintext, storedHash);
      } else if (storedHash.startsWith('$_pbkdf2Algorithm:')) {
        return _verifyPbkdf2(plaintext, storedHash);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Returns true if the stored hash is NOT Argon2id and should be re-hashed.
  ///
  /// Callers should check this after a successful login and, if true, re-hash
  /// the password with [hashPassword] and persist the new hash.
  static bool needsRehash(String storedHash) {
    return !storedHash.startsWith('\$argon2id\$');
  }

  /// Generates a cryptographically secure random string of the given length.
  static String generateSecureRandom(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Generates an 8-character alphanumeric invite code.
  static String generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Omit confusing chars
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Generates a list of backup codes for 2FA recovery.
  static List<String> generateBackupCodes(int count) {
    return List.generate(count, (_) {
      final code = generateSecureRandom(10);
      // Format as XXXXX-XXXXX for readability
      return '${code.substring(0, 5)}-${code.substring(5)}';
    });
  }

  /// Generates a time-limited token for password reset, email verification, etc.
  static String generateToken() {
    return generateSecureRandom(64);
  }

  /// Hashes a token for secure storage (using SHA-256).
  static String hashToken(String token) {
    final bytes = utf8.encode(token);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ---------------------------------------------------------------------------
  // Private: Argon2id
  // ---------------------------------------------------------------------------

  /// Verifies a plaintext password against an Argon2id hash string.
  static bool _verifyArgon2id(String plaintext, String storedHash) {
    // Parse: $argon2id$v=19$m=<memory>,t=<iterations>,p=<parallelism>$<salt>$<hash>
    final parts = storedHash.split('\$');
    // parts[0] is empty (leading $), parts[1] = 'argon2id', parts[2] = 'v=19',
    // parts[3] = 'm=...,t=...,p=...', parts[4] = salt, parts[5] = hash
    if (parts.length != 6) return false;
    if (parts[1] != 'argon2id') return false;

    final paramParts = parts[3].split(',');
    if (paramParts.length != 3) return false;

    final memory = int.parse(paramParts[0].substring(2)); // m=...
    final iterations = int.parse(paramParts[1].substring(2)); // t=...
    final parallelism = int.parse(paramParts[2].substring(2)); // p=...

    final salt = base64Decode(parts[4]);
    final expectedHash = base64Decode(parts[5]);

    final params = Argon2Parameters(
      Argon2Parameters.ARGON2_id,
      Uint8List.fromList(salt),
      desiredKeyLength: expectedHash.length,
      iterations: iterations,
      memory: memory,
      lanes: parallelism,
    );

    final argon2 = Argon2BytesGenerator()..init(params);

    final passwordBytes = Uint8List.fromList(utf8.encode(plaintext));
    final result = Uint8List(expectedHash.length);
    argon2.deriveKey(passwordBytes, 0, result, 0);

    return _constantTimeEquals(result, expectedHash);
  }

  // ---------------------------------------------------------------------------
  // Private: Legacy PBKDF2 (backward compatibility only)
  // ---------------------------------------------------------------------------

  /// Verifies a plaintext password against a legacy PBKDF2 hash string.
  ///
  /// Hash format: `PBKDF2:<iterations>:<salt_base64>:<hash_base64>`
  static bool _verifyPbkdf2(String plaintext, String storedHash) {
    final parts = storedHash.split(':');
    if (parts.length != 4) return false;

    final algorithm = parts[0];
    final iterations = int.parse(parts[1]);
    final salt = base64Decode(parts[2]);
    final expectedHash = base64Decode(parts[3]);

    if (algorithm != _pbkdf2Algorithm) return false;

    final actualHash = _pbkdf2(
      plaintext,
      salt,
      iterations,
      expectedHash.length,
    );

    return _constantTimeEquals(actualHash, expectedHash);
  }

  /// PBKDF2 key derivation (legacy, kept for backward compatibility).
  static Uint8List _pbkdf2(
    String password,
    List<int> salt,
    int iterations,
    int keyLength,
  ) {
    final params = Pbkdf2Parameters(
      Uint8List.fromList(salt),
      iterations,
      keyLength,
    );

    final derivator = KeyDerivator('SHA-256/HMAC/PBKDF2')..init(params);

    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }

  // ---------------------------------------------------------------------------
  // Private: Shared helpers
  // ---------------------------------------------------------------------------

  /// Generates cryptographically secure random bytes.
  static Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }

  /// Constant-time byte comparison to prevent timing attacks.
  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}
