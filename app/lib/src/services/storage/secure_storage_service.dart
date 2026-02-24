import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around flutter_secure_storage for managing tokens and
/// sensitive data securely.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  final FlutterSecureStorage _storage;

  // Keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _currentSpaceIdKey = 'current_space_id';
  static const String _encryptionKeyKey = 'encryption_key';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // ── Access Token ─────────────────────────────────────────────────────

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  // ── Refresh Token ────────────────────────────────────────────────────

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  // ── Token Management ─────────────────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  Future<void> clearTokens() async {
    await deleteAccessToken();
    await deleteRefreshToken();
  }

  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  // ── User ID ──────────────────────────────────────────────────────────

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: _userIdKey);
  }

  // ── Current Space ────────────────────────────────────────────────────

  Future<void> saveCurrentSpaceId(String spaceId) async {
    await _storage.write(key: _currentSpaceIdKey, value: spaceId);
  }

  Future<String?> getCurrentSpaceId() async {
    return _storage.read(key: _currentSpaceIdKey);
  }

  // ── Encryption Key ───────────────────────────────────────────────────

  Future<void> saveEncryptionKey(String key) async {
    await _storage.write(key: _encryptionKeyKey, value: key);
  }

  Future<String?> getEncryptionKey() async {
    return _storage.read(key: _encryptionKeyKey);
  }

  // ── Biometric ────────────────────────────────────────────────────────

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  // ── Generic ──────────────────────────────────────────────────────────

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  /// Clear all stored data (use on logout).
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
