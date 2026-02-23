import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/pointycastle.dart';

/// Utility class for password hashing, verification, and secure random generation.
class PasswordUtils {
  static const int _saltLength = 32;
  static const int _hashLength = 64;
  static const int _iterations = 100000;
  static const String _algorithm = 'PBKDF2';

  /// Hashes a plaintext password using PBKDF2 with a random salt.
  ///
  /// Returns a string in the format: `algorithm:iterations:salt:hash`
  static String hashPassword(String plaintext) {
    final salt = _generateRandomBytes(_saltLength);
    final hash = _pbkdf2(plaintext, salt, _iterations, _hashLength);

    final saltBase64 = base64Encode(salt);
    final hashBase64 = base64Encode(hash);

    return '$_algorithm:$_iterations:$saltBase64:$hashBase64';
  }

  /// Verifies a plaintext password against a stored hash string.
  static bool verifyPassword(String plaintext, String storedHash) {
    try {
      final parts = storedHash.split(':');
      if (parts.length != 4) return false;

      final algorithm = parts[0];
      final iterations = int.parse(parts[1]);
      final salt = base64Decode(parts[2]);
      final expectedHash = base64Decode(parts[3]);

      if (algorithm != _algorithm) return false;

      final actualHash = _pbkdf2(
        plaintext,
        salt,
        iterations,
        expectedHash.length,
      );

      // Constant-time comparison to prevent timing attacks
      return _constantTimeEquals(actualHash, expectedHash);
    } catch (e) {
      return false;
    }
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

  /// PBKDF2 key derivation.
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
