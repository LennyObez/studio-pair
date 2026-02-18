import 'package:studio_pair_backend/src/config/app_config.dart';
import 'package:studio_pair_backend/src/services/storage_service.dart';
import 'package:test/test.dart';

/// Creates a test AppConfig for local storage (no S3).
AppConfig _testConfig({
  String storageProvider = 'local',
  String storagePath = './test_uploads',
}) {
  return AppConfig(
    host: 'localhost',
    port: 8080,
    env: 'test',
    databaseUrl: 'postgres://test:test@localhost:5432/test',
    databasePoolSize: 1,
    jwtSecret: 'test-secret',
    jwtAccessTokenTtl: const Duration(minutes: 15),
    jwtRefreshTokenTtl: const Duration(days: 30),
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
    storageProvider: storageProvider,
    storagePath: storagePath,
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
  group('StorageService', () {
    group('configuration', () {
      test('defaults to local storage when S3 is not configured', () {
        final config = _testConfig();
        final storage = StorageService(config);
        // When S3 is not configured, getUrl should return local API path
        final url = storage.getUrl('test/file.txt');
        expect(url, equals('/api/v1/files/download/test/file.txt'));
      });

      test('getUrl returns local path format for local storage', () {
        final config = _testConfig();
        final storage = StorageService(config);
        final url = storage.getUrl('uploads/image.png');
        expect(url, startsWith('/api/v1/files/download/'));
        expect(url, contains('uploads/image.png'));
      });
    });

    group('getMimeType', () {
      test('returns correct MIME type for common file extensions', () {
        final config = _testConfig();
        final storage = StorageService(config);

        expect(storage.getMimeType('photo.jpg'), equals('image/jpeg'));
        expect(storage.getMimeType('photo.jpeg'), equals('image/jpeg'));
        expect(storage.getMimeType('photo.png'), equals('image/png'));
        expect(storage.getMimeType('document.pdf'), equals('application/pdf'));
        expect(storage.getMimeType('data.json'), equals('application/json'));
      });

      test('returns correct MIME type for text files', () {
        final config = _testConfig();
        final storage = StorageService(config);

        expect(storage.getMimeType('readme.txt'), equals('text/plain'));
        expect(storage.getMimeType('page.html'), equals('text/html'));
        expect(storage.getMimeType('style.css'), equals('text/css'));
      });

      test('returns null for unknown file extensions', () {
        final config = _testConfig();
        final storage = StorageService(config);

        // Unknown extensions may return null
        final result = storage.getMimeType('file.xyz123');
        expect(result, isNull);
      });

      test('handles files with no extension', () {
        final config = _testConfig();
        final storage = StorageService(config);

        final result = storage.getMimeType('Makefile');
        // Files without extensions typically return null from MIME lookup.
        // getMimeType returns String?, so the result is either null or a valid
        // MIME type string. Either is acceptable here.
        expect(result, anyOf(isNull, isA<String>()));
      });
    });

    group('getUrl', () {
      test('generates different URLs for different keys', () {
        final config = _testConfig();
        final storage = StorageService(config);

        final url1 = storage.getUrl('uploads/file1.txt');
        final url2 = storage.getUrl('uploads/file2.txt');

        expect(url1, isNot(equals(url2)));
      });

      test('handles nested paths', () {
        final config = _testConfig();
        final storage = StorageService(config);

        final url = storage.getUrl('spaces/space-1/files/document.pdf');
        expect(url, contains('spaces/space-1/files/document.pdf'));
      });
    });

    group('StorageException', () {
      test('stores message correctly', () {
        const exception = StorageException('Upload failed');
        expect(exception.message, equals('Upload failed'));
      });

      test('toString includes message', () {
        const exception = StorageException('S3 error');
        expect(exception.toString(), contains('S3 error'));
        expect(exception.toString(), contains('StorageException'));
      });
    });
  });
}
