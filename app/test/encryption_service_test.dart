import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:studio_pair/src/services/encryption/encryption_service.dart';

void main() {
  late EncryptionService service;

  setUp(() {
    service = EncryptionService();
  });

  group('key generation', () {
    test('generateKey produces a valid base64 256-bit key', () {
      final key = service.generateKey();

      expect(key, isNotEmpty);
      final decoded = base64Decode(key);
      expect(decoded.length, equals(32)); // 256 bits
    });

    test('generateIV produces a valid base64 96-bit IV', () {
      final iv = service.generateIV();

      expect(iv, isNotEmpty);
      final decoded = base64Decode(iv);
      expect(decoded.length, equals(12)); // 96 bits
    });

    test('generateSalt produces a valid base64 128-bit salt', () {
      final salt = service.generateSalt();

      expect(salt, isNotEmpty);
      final decoded = base64Decode(salt);
      expect(decoded.length, equals(16)); // 128 bits
    });

    test('generated keys are unique on each call', () {
      final key1 = service.generateKey();
      final key2 = service.generateKey();

      expect(key1, isNot(equals(key2)));
    });
  });

  group('key derivation', () {
    test('derives a consistent key from the same password and salt', () async {
      final salt = service.generateSalt();

      final key1 = await service.deriveKeyFromPassword(
        password: 'my-secret-password',
        salt: salt,
      );
      final key2 = await service.deriveKeyFromPassword(
        password: 'my-secret-password',
        salt: salt,
      );

      expect(key1, equals(key2));
    });

    test('derives different keys for different passwords', () async {
      final salt = service.generateSalt();

      final key1 = await service.deriveKeyFromPassword(
        password: 'password-one',
        salt: salt,
      );
      final key2 = await service.deriveKeyFromPassword(
        password: 'password-two',
        salt: salt,
      );

      expect(key1, isNot(equals(key2)));
    });

    test('derives different keys for different salts', () async {
      final salt1 = service.generateSalt();
      final salt2 = service.generateSalt();

      final key1 = await service.deriveKeyFromPassword(
        password: 'same-password',
        salt: salt1,
      );
      final key2 = await service.deriveKeyFromPassword(
        password: 'same-password',
        salt: salt2,
      );

      expect(key1, isNot(equals(key2)));
    });

    test('derived key is 256 bits (32 bytes)', () async {
      final salt = service.generateSalt();

      final key = await service.deriveKeyFromPassword(
        password: 'test',
        salt: salt,
        iterations: 1000, // fewer iterations for speed in tests
      );
      final decoded = base64Decode(key);

      expect(decoded.length, equals(32));
    });
  });

  group('AES-256-GCM encrypt/decrypt round-trip', () {
    test('encrypts and decrypts a short message correctly', () async {
      final key = service.generateKey();
      const plaintext = 'Hello, Studio Pair!';

      final encrypted = await service.encrypt(plaintext: plaintext, key: key);

      expect(encrypted, contains('ciphertext'));
      expect(encrypted, contains('iv'));
      expect(encrypted, contains('tag'));
      expect(
        encrypted['ciphertext'],
        isNot(equals(base64Encode(utf8.encode(plaintext)))),
      );

      final decrypted = await service.decrypt(
        ciphertext: encrypted['ciphertext']!,
        key: key,
        iv: encrypted['iv']!,
        tag: encrypted['tag']!,
      );

      expect(decrypted, equals(plaintext));
    });

    test('encrypts and decrypts a long message correctly', () async {
      final key = service.generateKey();
      final plaintext = 'A' * 10000; // 10KB of data

      final encrypted = await service.encrypt(plaintext: plaintext, key: key);
      final decrypted = await service.decrypt(
        ciphertext: encrypted['ciphertext']!,
        key: key,
        iv: encrypted['iv']!,
        tag: encrypted['tag']!,
      );

      expect(decrypted, equals(plaintext));
    });

    test('encrypts and decrypts unicode content correctly', () async {
      final key = service.generateKey();
      const plaintext = 'Bonjour le monde! Cest la vie. 日本語テスト';

      final encrypted = await service.encrypt(plaintext: plaintext, key: key);
      final decrypted = await service.decrypt(
        ciphertext: encrypted['ciphertext']!,
        key: key,
        iv: encrypted['iv']!,
        tag: encrypted['tag']!,
      );

      expect(decrypted, equals(plaintext));
    });

    test('decryption fails with wrong key', () async {
      final key1 = service.generateKey();
      final key2 = service.generateKey();
      const plaintext = 'Secret data';

      final encrypted = await service.encrypt(plaintext: plaintext, key: key1);

      expect(
        () => service.decrypt(
          ciphertext: encrypted['ciphertext']!,
          key: key2,
          iv: encrypted['iv']!,
          tag: encrypted['tag']!,
        ),
        throwsA(isA<Object>()),
      );
    });

    test('same plaintext produces different ciphertexts (random IV)', () async {
      final key = service.generateKey();
      const plaintext = 'Same message twice';

      final encrypted1 = await service.encrypt(plaintext: plaintext, key: key);
      final encrypted2 = await service.encrypt(plaintext: plaintext, key: key);

      // Different IVs should produce different ciphertexts
      expect(encrypted1['iv'], isNot(equals(encrypted2['iv'])));
      expect(encrypted1['ciphertext'], isNot(equals(encrypted2['ciphertext'])));
    });
  });

  group('RSA key pair generation', () {
    test('generates a valid RSA-2048 key pair', () async {
      final keyPair = await service.generateKeyPair();

      expect(keyPair, contains('publicKey'));
      expect(keyPair, contains('privateKey'));

      // Verify the public key can be decoded as base64 JSON with n and e
      final publicKeyJson = jsonDecode(
        utf8.decode(base64Decode(keyPair['publicKey']!)),
      );
      expect(publicKeyJson, contains('n'));
      expect(publicKeyJson, contains('e'));
      expect(publicKeyJson['e'], equals('65537'));

      // Verify the private key can be decoded as base64 JSON with n, d, p, q
      final privateKeyJson = jsonDecode(
        utf8.decode(base64Decode(keyPair['privateKey']!)),
      );
      expect(privateKeyJson, contains('n'));
      expect(privateKeyJson, contains('d'));
      expect(privateKeyJson, contains('p'));
      expect(privateKeyJson, contains('q'));
    });

    test('generates unique key pairs on each call', () async {
      final pair1 = await service.generateKeyPair();
      final pair2 = await service.generateKeyPair();

      expect(pair1['publicKey'], isNot(equals(pair2['publicKey'])));
      expect(pair1['privateKey'], isNot(equals(pair2['privateKey'])));
    });
  });

  group('RSA encrypt with public key / decrypt with private key', () {
    test('re-encrypts a symmetric key for a recipient', () async {
      final keyPair = await service.generateKeyPair();
      final dataKey = service.generateKey(); // 256-bit symmetric key

      final encryptedKey = await service.reEncryptForRecipient(
        dataKey: dataKey,
        recipientPublicKey: keyPair['publicKey']!,
      );

      expect(encryptedKey, isNotEmpty);
      expect(encryptedKey, isNot(equals(dataKey)));
    });
  });

  group('end-to-end vault workflow', () {
    test('derive key, encrypt, decrypt simulates vault usage', () async {
      // Simulate a user setting up their vault
      final salt = service.generateSalt();
      final derivedKey = await service.deriveKeyFromPassword(
        password: 'vault-master-password',
        salt: salt,
        iterations: 1000, // reduced for test speed
      );

      // Encrypt sensitive vault data
      const secretData = '{"ssn": "123-45-6789", "pin": "9876"}';
      final encrypted = await service.encrypt(
        plaintext: secretData,
        key: derivedKey,
      );

      // Decrypt with the same derived key
      final decrypted = await service.decrypt(
        ciphertext: encrypted['ciphertext']!,
        key: derivedKey,
        iv: encrypted['iv']!,
        tag: encrypted['tag']!,
      );

      expect(decrypted, equals(secretData));
    });
  });
}
