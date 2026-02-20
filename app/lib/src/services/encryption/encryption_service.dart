import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// Client-side encryption service for the Private Capsule (Vault).
///
/// Provides AES-256-GCM encryption with PBKDF2 key derivation and
/// RSA-2048 key pair generation for secure key exchange.
class EncryptionService {
  EncryptionService();

  final _secureRandom = _createSecureRandom();

  /// Generate a random encryption key (256-bit).
  String generateKey() {
    final bytes = _secureRandom.nextBytes(32);
    return base64Encode(bytes);
  }

  /// Generate a random initialization vector (96-bit for GCM).
  String generateIV() {
    final bytes = _secureRandom.nextBytes(12);
    return base64Encode(bytes);
  }

  /// Generate a random salt for key derivation.
  String generateSalt() {
    final bytes = _secureRandom.nextBytes(16);
    return base64Encode(bytes);
  }

  /// Derive an encryption key from a password using PBKDF2 with SHA-256.
  Future<String> deriveKeyFromPassword({
    required String password,
    required String salt,
    int iterations = 100000,
  }) async {
    final saltBytes = base64Decode(salt);
    final passwordBytes = utf8.encode(password);

    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    derivator.init(
      Pbkdf2Parameters(
        Uint8List.fromList(saltBytes),
        iterations,
        32, // 256-bit key
      ),
    );

    final keyBytes = derivator.process(Uint8List.fromList(passwordBytes));
    return base64Encode(keyBytes);
  }

  /// Encrypt plaintext using AES-256-GCM.
  ///
  /// Returns a map with `ciphertext` (IV + ciphertext + auth tag, base64),
  /// `iv` (base64), and `tag` (base64).
  Future<Map<String, String>> encrypt({
    required String plaintext,
    required String key,
  }) async {
    final keyBytes = base64Decode(key);
    final ivBytes = _secureRandom.nextBytes(12);
    final plaintextBytes = utf8.encode(plaintext);

    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(
      true,
      AEADParameters(
        KeyParameter(Uint8List.fromList(keyBytes)),
        128, // 128-bit auth tag
        Uint8List.fromList(ivBytes),
        Uint8List(0), // no AAD
      ),
    );

    final output = cipher.process(Uint8List.fromList(plaintextBytes));

    // GCM appends the auth tag to the ciphertext
    // The last 16 bytes are the tag
    final ciphertextOnly = output.sublist(0, output.length - 16);
    final tag = output.sublist(output.length - 16);

    return {
      'ciphertext': base64Encode(ciphertextOnly),
      'iv': base64Encode(ivBytes),
      'tag': base64Encode(tag),
    };
  }

  /// Decrypt ciphertext using AES-256-GCM.
  ///
  /// Throws if the auth tag does not verify.
  Future<String> decrypt({
    required String ciphertext,
    required String key,
    required String iv,
    required String tag,
  }) async {
    final keyBytes = base64Decode(key);
    final ivBytes = base64Decode(iv);
    final ciphertextBytes = base64Decode(ciphertext);
    final tagBytes = base64Decode(tag);

    // GCM expects ciphertext + tag concatenated
    final input = Uint8List(ciphertextBytes.length + tagBytes.length);
    input.setAll(0, ciphertextBytes);
    input.setAll(ciphertextBytes.length, tagBytes);

    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(
      false,
      AEADParameters(
        KeyParameter(Uint8List.fromList(keyBytes)),
        128,
        Uint8List.fromList(ivBytes),
        Uint8List(0),
      ),
    );

    final decrypted = cipher.process(input);
    return utf8.decode(decrypted);
  }

  /// Re-encrypt a symmetric key for sharing with another user.
  ///
  /// Encrypts the data key with the recipient's RSA public key using
  /// OAEP padding with SHA-256.
  Future<String> reEncryptForRecipient({
    required String dataKey,
    required String recipientPublicKey,
  }) async {
    final publicKey = _decodeRsaPublicKey(recipientPublicKey);
    final dataKeyBytes = base64Decode(dataKey);

    final encryptor = OAEPEncoding.withSHA256(RSAEngine());
    encryptor.init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    final encrypted = encryptor.process(Uint8List.fromList(dataKeyBytes));
    return base64Encode(encrypted);
  }

  /// Generate an RSA-2048 key pair for key exchange.
  ///
  /// Returns base64-encoded `privateKey` and `publicKey`.
  Future<Map<String, String>> generateKeyPair() async {
    final keyGen = RSAKeyGenerator();
    keyGen.init(
      ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        _secureRandom,
      ),
    );

    final pair = keyGen.generateKeyPair();
    final publicKey = pair.publicKey as RSAPublicKey;
    final privateKey = pair.privateKey as RSAPrivateKey;

    return {
      'publicKey': _encodeRsaPublicKey(publicKey),
      'privateKey': _encodeRsaPrivateKey(privateKey),
    };
  }

  // ── RSA Key Encoding Helpers ────────────────────────────────────────────

  /// Encodes an RSA public key as base64 JSON (modulus + exponent).
  String _encodeRsaPublicKey(RSAPublicKey key) {
    final map = {
      'n': key.modulus.toString(),
      'e': key.publicExponent.toString(),
    };
    return base64Encode(utf8.encode(jsonEncode(map)));
  }

  /// Encodes an RSA private key as base64 JSON.
  String _encodeRsaPrivateKey(RSAPrivateKey key) {
    final map = {
      'n': key.modulus.toString(),
      'd': key.privateExponent.toString(),
      'p': key.p.toString(),
      'q': key.q.toString(),
    };
    return base64Encode(utf8.encode(jsonEncode(map)));
  }

  /// Decodes an RSA public key from base64 JSON.
  RSAPublicKey _decodeRsaPublicKey(String encoded) {
    final json = jsonDecode(utf8.decode(base64Decode(encoded)));
    return RSAPublicKey(
      BigInt.parse(json['n'] as String),
      BigInt.parse(json['e'] as String),
    );
  }

  /// Creates a seeded secure random number generator.
  static SecureRandom _createSecureRandom() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }
}
