// Async IO is intentional in a server context — sync versions would block
// the event loop.
// ignore_for_file: avoid_slow_async_io

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

import '../config/app_config.dart';

/// Service for file storage operations.
///
/// Supports local filesystem storage for development and S3-compatible
/// object storage for production. Falls back to local storage when
/// S3 configuration is absent.
class StorageService {
  final AppConfig _config;
  final Logger _log = Logger('StorageService');
  final Uuid _uuid = const Uuid();
  final http.Client _httpClient;

  StorageService(this._config, {http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Whether S3 storage is configured and should be used.
  bool get _useS3 =>
      _config.storageProvider == 's3' &&
      _config.s3Bucket != null &&
      _config.s3Bucket!.isNotEmpty &&
      _config.s3Region != null &&
      _config.s3AccessKey != null &&
      _config.s3SecretKey != null;

  /// Initializes the storage service (creates directories, etc.).
  Future<void> initialize() async {
    if (!_useS3) {
      final dir = Directory(_config.storagePath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        _log.info('Created storage directory: ${_config.storagePath}');
      }
    } else {
      _log.info(
        'S3 storage configured: bucket=${_config.s3Bucket}, '
        'region=${_config.s3Region}',
      );
    }
  }

  /// Uploads a file and returns the storage key.
  Future<String> upload({
    required Uint8List data,
    required String filename,
    String? contentType,
    String? folder,
  }) async {
    final ext = filename.contains('.')
        ? filename.substring(filename.lastIndexOf('.'))
        : '';
    final key = '${folder ?? "uploads"}/${_uuid.v4()}$ext';
    final mime =
        contentType ?? lookupMimeType(filename) ?? 'application/octet-stream';

    if (_useS3) {
      await _s3Put(key, data, mime);
      _log.info('Uploaded file to S3: $key (${data.length} bytes)');
    } else {
      final file = File('${_config.storagePath}/$key');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(data);
      _log.info('Uploaded file to local: $key (${data.length} bytes)');
    }

    return key;
  }

  /// Downloads a file by its storage key.
  Future<Uint8List?> download(String key) async {
    if (_useS3) {
      try {
        final response = await _s3Get(key);
        if (response.statusCode == 200) {
          return response.bodyBytes;
        }
        if (response.statusCode == 404) {
          return null;
        }
        _log.warning('S3 download failed for $key: ${response.statusCode}');
        return null;
      } catch (e) {
        _log.severe('S3 download error for $key', e);
        return null;
      }
    }

    final file = File('${_config.storagePath}/$key');
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  /// Deletes a file by its storage key.
  Future<bool> delete(String key) async {
    if (_useS3) {
      try {
        final uri = _s3Uri(key);
        final headers = _s3Headers('DELETE', key);
        final response = await _httpClient.delete(uri, headers: headers);
        if (response.statusCode == 204 || response.statusCode == 200) {
          _log.info('Deleted file from S3: $key');
          return true;
        }
        _log.warning('S3 delete failed for $key: ${response.statusCode}');
        return false;
      } catch (e) {
        _log.severe('S3 delete error for $key', e);
        return false;
      }
    }

    final file = File('${_config.storagePath}/$key');
    if (await file.exists()) {
      await file.delete();
      _log.info('Deleted file from local: $key');
      return true;
    }
    return false;
  }

  /// Gets the public URL for a file.
  ///
  /// For S3, generates a pre-signed URL valid for [expiry] duration.
  /// For local storage, returns the API download path.
  String getUrl(String key, {Duration expiry = const Duration(hours: 1)}) {
    if (_useS3) {
      return _generatePresignedUrl(key, expiry: expiry);
    }

    return '/api/v1/files/download/$key';
  }

  /// Gets the MIME type for a file based on its name.
  String? getMimeType(String filename) {
    return lookupMimeType(filename);
  }

  /// Checks if a file exists.
  Future<bool> exists(String key) async {
    if (_useS3) {
      try {
        final uri = _s3Uri(key);
        final headers = _s3Headers('HEAD', key);
        final response = await _httpClient.head(uri, headers: headers);
        return response.statusCode == 200;
      } catch (e) {
        _log.severe('S3 exists check error for $key', e);
        return false;
      }
    }

    final file = File('${_config.storagePath}/$key');
    return file.exists();
  }

  /// Gets file metadata (size, content type, etc.).
  Future<Map<String, dynamic>?> getMetadata(String key) async {
    if (_useS3) {
      try {
        final uri = _s3Uri(key);
        final headers = _s3Headers('HEAD', key);
        final response = await _httpClient.head(uri, headers: headers);
        if (response.statusCode == 200) {
          return {
            'size':
                int.tryParse(response.headers['content-length'] ?? '0') ?? 0,
            'content_type': response.headers['content-type'],
            'modified': response.headers['last-modified'],
          };
        }
        return null;
      } catch (e) {
        _log.severe('S3 metadata error for $key', e);
        return null;
      }
    }

    final file = File('${_config.storagePath}/$key');
    if (await file.exists()) {
      final stat = await file.stat();
      return {
        'size': stat.size,
        'content_type': lookupMimeType(key),
        'modified': stat.modified.toIso8601String(),
      };
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // S3 Implementation Helpers
  // ---------------------------------------------------------------------------

  /// Constructs the S3 endpoint URI for a given object key.
  Uri _s3Uri(String key) {
    final bucket = _config.s3Bucket!;
    final region = _config.s3Region!;
    return Uri.parse('https://$bucket.s3.$region.amazonaws.com/$key');
  }

  /// Performs an S3 PUT operation to upload data.
  Future<void> _s3Put(String key, Uint8List data, String contentType) async {
    final uri = _s3Uri(key);
    final now = DateTime.now().toUtc();
    final dateStamp = _formatDateStamp(now);
    final amzDate = _formatAmzDate(now);
    final payloadHash = sha256.convert(data).toString();

    final headers = {
      'Host': uri.host,
      'Content-Type': contentType,
      'Content-Length': data.length.toString(),
      'x-amz-content-sha256': payloadHash,
      'x-amz-date': amzDate,
    };

    final authHeader = _buildAuthorizationHeader(
      method: 'PUT',
      uri: uri,
      headers: headers,
      payloadHash: payloadHash,
      now: now,
      dateStamp: dateStamp,
      amzDate: amzDate,
    );

    headers['Authorization'] = authHeader;

    final response = await _httpClient.put(uri, headers: headers, body: data);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw StorageException(
        'S3 upload failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Performs an S3 GET operation to download data.
  Future<http.Response> _s3Get(String key) async {
    final uri = _s3Uri(key);
    final headers = _s3Headers('GET', key);
    return _httpClient.get(uri, headers: headers);
  }

  /// Builds the standard S3 request headers for a given HTTP method and key.
  Map<String, String> _s3Headers(String method, String key) {
    final uri = _s3Uri(key);
    final now = DateTime.now().toUtc();
    final dateStamp = _formatDateStamp(now);
    final amzDate = _formatAmzDate(now);
    const payloadHash =
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'; // empty body SHA-256

    final headers = <String, String>{
      'Host': uri.host,
      'x-amz-content-sha256': payloadHash,
      'x-amz-date': amzDate,
    };

    final authHeader = _buildAuthorizationHeader(
      method: method,
      uri: uri,
      headers: headers,
      payloadHash: payloadHash,
      now: now,
      dateStamp: dateStamp,
      amzDate: amzDate,
    );

    headers['Authorization'] = authHeader;
    return headers;
  }

  /// Generates a pre-signed URL for temporary public access to an S3 object.
  ///
  /// Uses AWS Signature V4 query string authentication.
  String _generatePresignedUrl(
    String key, {
    Duration expiry = const Duration(hours: 1),
  }) {
    final bucket = _config.s3Bucket!;
    final region = _config.s3Region!;
    final accessKey = _config.s3AccessKey!;
    final now = DateTime.now().toUtc();
    final dateStamp = _formatDateStamp(now);
    final amzDate = _formatAmzDate(now);
    final expiresIn = expiry.inSeconds;
    final host = '$bucket.s3.$region.amazonaws.com';
    final credentialScope = '$dateStamp/$region/s3/aws4_request';
    final credential = '$accessKey/$credentialScope';

    final canonicalQueryString = [
      'X-Amz-Algorithm=AWS4-HMAC-SHA256',
      'X-Amz-Credential=${Uri.encodeComponent(credential)}',
      'X-Amz-Date=$amzDate',
      'X-Amz-Expires=$expiresIn',
      'X-Amz-SignedHeaders=host',
    ].join('&');

    final canonicalRequest = [
      'GET',
      '/$key',
      canonicalQueryString,
      'host:$host',
      '',
      'host',
      'UNSIGNED-PAYLOAD',
    ].join('\n');

    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    final signingKey = _deriveSigningKey(dateStamp, region);
    final signature = Hmac(
      sha256,
      signingKey,
    ).convert(utf8.encode(stringToSign)).toString();

    return 'https://$host/$key?$canonicalQueryString&X-Amz-Signature=$signature';
  }

  /// Builds the AWS Signature V4 Authorization header.
  String _buildAuthorizationHeader({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required String payloadHash,
    required DateTime now,
    required String dateStamp,
    required String amzDate,
  }) {
    final region = _config.s3Region!;
    final accessKey = _config.s3AccessKey!;

    // Build signed headers list (sorted lowercase)
    final signedHeaderKeys = headers.keys.map((k) => k.toLowerCase()).toList()
      ..sort();
    final signedHeaders = signedHeaderKeys.join(';');

    // Canonical headers
    final canonicalHeaders = signedHeaderKeys
        .map(
          (k) =>
              '$k:${headers[headers.keys.firstWhere((hk) => hk.toLowerCase() == k)]!.trim()}',
        )
        .join('\n');

    // Canonical request
    final canonicalRequest = [
      method,
      uri.path.isEmpty ? '/' : uri.path,
      uri.query,
      '$canonicalHeaders\n',
      signedHeaders,
      payloadHash,
    ].join('\n');

    // String to sign
    final credentialScope = '$dateStamp/$region/s3/aws4_request';
    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    // Signing key
    final signingKey = _deriveSigningKey(dateStamp, region);

    // Signature
    final signature = Hmac(
      sha256,
      signingKey,
    ).convert(utf8.encode(stringToSign)).toString();

    return 'AWS4-HMAC-SHA256 '
        'Credential=$accessKey/$credentialScope, '
        'SignedHeaders=$signedHeaders, '
        'Signature=$signature';
  }

  /// Derives the AWS Signature V4 signing key.
  List<int> _deriveSigningKey(String dateStamp, String region) {
    final secretKey = _config.s3SecretKey!;
    final kDate = Hmac(
      sha256,
      utf8.encode('AWS4$secretKey'),
    ).convert(utf8.encode(dateStamp)).bytes;
    final kRegion = Hmac(sha256, kDate).convert(utf8.encode(region)).bytes;
    final kService = Hmac(sha256, kRegion).convert(utf8.encode('s3')).bytes;
    final kSigning = Hmac(
      sha256,
      kService,
    ).convert(utf8.encode('aws4_request')).bytes;
    return kSigning;
  }

  /// Formats a DateTime as a date stamp (YYYYMMDD) for AWS Sig V4.
  String _formatDateStamp(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  /// Formats a DateTime as an AMZ date (YYYYMMDD'T'HHMMSS'Z') for AWS Sig V4.
  String _formatAmzDate(DateTime dt) {
    return '${_formatDateStamp(dt)}T'
        '${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}'
        '${dt.second.toString().padLeft(2, '0')}Z';
  }
}

/// Exception thrown when a storage operation fails.
class StorageException implements Exception {
  final String message;

  const StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
