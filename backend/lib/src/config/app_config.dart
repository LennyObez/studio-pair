import 'package:dotenv/dotenv.dart';

/// Thrown when a required environment variable is missing.
class MissingEnvVarException implements Exception {
  final String variableName;
  const MissingEnvVarException(this.variableName);

  @override
  String toString() =>
      'MissingEnvVarException: Required environment variable "$variableName" is not set.';
}

/// Application configuration loaded from environment variables.
class AppConfig {
  // Server
  final String host;
  final int port;
  final String env;

  // Database
  final String databaseUrl;
  final int databasePoolSize;

  // JWT
  final String jwtSecret;
  final Duration jwtAccessTokenTtl;
  final Duration jwtRefreshTokenTtl;

  // SMTP
  final String smtpHost;
  final int smtpPort;
  final String smtpUsername;
  final String smtpPassword;
  final String smtpFromEmail;
  final String smtpFromName;

  // Push Notifications
  final String fcmServerKey;
  final String apnsKeyId;
  final String apnsTeamId;
  final String apnsBundleId;

  // External APIs
  final String tmdbApiKey;
  final String rawgApiKey;
  final String spotifyClientId;
  final String spotifyClientSecret;
  final String googlePlacesApiKey;
  final String youtubeApiKey;

  // Storage
  final String storageProvider;
  final String storagePath;
  final String? s3Bucket;
  final String? s3Region;
  final String? s3AccessKey;
  final String? s3SecretKey;

  // Encryption
  final String encryptionMasterKey;

  // AI
  final String aiApiKey;
  final String aiProvider;
  final String aiModel;

  // In-App Purchases — Google Play
  final String googlePlayServiceAccountJson;

  // In-App Purchases — App Store
  final String appStoreIssuerId;
  final String appStoreKeyId;
  final String appStorePrivateKey;
  final String appStoreSharedSecret;

  const AppConfig({
    required this.host,
    required this.port,
    required this.env,
    required this.databaseUrl,
    required this.databasePoolSize,
    required this.jwtSecret,
    required this.jwtAccessTokenTtl,
    required this.jwtRefreshTokenTtl,
    required this.smtpHost,
    required this.smtpPort,
    required this.smtpUsername,
    required this.smtpPassword,
    required this.smtpFromEmail,
    required this.smtpFromName,
    required this.fcmServerKey,
    required this.apnsKeyId,
    required this.apnsTeamId,
    required this.apnsBundleId,
    required this.tmdbApiKey,
    required this.rawgApiKey,
    required this.spotifyClientId,
    required this.spotifyClientSecret,
    required this.googlePlacesApiKey,
    required this.youtubeApiKey,
    required this.storageProvider,
    required this.storagePath,
    this.s3Bucket,
    this.s3Region,
    this.s3AccessKey,
    this.s3SecretKey,
    required this.encryptionMasterKey,
    required this.aiApiKey,
    required this.aiProvider,
    required this.aiModel,
    required this.googlePlayServiceAccountJson,
    required this.appStoreIssuerId,
    required this.appStoreKeyId,
    required this.appStorePrivateKey,
    required this.appStoreSharedSecret,
  });

  /// Creates an [AppConfig] from a [DotEnv] instance.
  factory AppConfig.fromEnv(DotEnv env) {
    return AppConfig(
      host: env.getOrElse('HOST', () => '0.0.0.0'),
      port: int.parse(env.getOrElse('PORT', () => '8080')),
      env: env.getOrElse('ENV', () => 'development'),
      databaseUrl: _requireEnv(env, 'DATABASE_URL'),
      databasePoolSize: int.parse(
        env.getOrElse('DATABASE_POOL_SIZE', () => '10'),
      ),
      jwtSecret: _requireEnv(env, 'JWT_SECRET'),
      jwtAccessTokenTtl: Duration(
        minutes: int.parse(
          env.getOrElse('JWT_ACCESS_TOKEN_TTL_MINUTES', () => '30'),
        ),
      ),
      jwtRefreshTokenTtl: Duration(
        days: int.parse(
          env.getOrElse('JWT_REFRESH_TOKEN_TTL_DAYS', () => '30'),
        ),
      ),
      smtpHost: env.getOrElse('SMTP_HOST', () => 'smtp.example.com'),
      smtpPort: int.parse(env.getOrElse('SMTP_PORT', () => '587')),
      smtpUsername: env.getOrElse('SMTP_USERNAME', () => ''),
      smtpPassword: env.getOrElse('SMTP_PASSWORD', () => ''),
      smtpFromEmail: env.getOrElse(
        'SMTP_FROM_EMAIL',
        () => 'noreply@studiopair.app',
      ),
      smtpFromName: env.getOrElse('SMTP_FROM_NAME', () => 'Studio Pair'),
      fcmServerKey: env.getOrElse('FCM_SERVER_KEY', () => ''),
      apnsKeyId: env.getOrElse('APNS_KEY_ID', () => ''),
      apnsTeamId: env.getOrElse('APNS_TEAM_ID', () => ''),
      apnsBundleId: env.getOrElse('APNS_BUNDLE_ID', () => ''),
      tmdbApiKey: env.getOrElse('TMDB_API_KEY', () => ''),
      rawgApiKey: env.getOrElse('RAWG_API_KEY', () => ''),
      spotifyClientId: env.getOrElse('SPOTIFY_CLIENT_ID', () => ''),
      spotifyClientSecret: env.getOrElse('SPOTIFY_CLIENT_SECRET', () => ''),
      googlePlacesApiKey: env.getOrElse('GOOGLE_PLACES_API_KEY', () => ''),
      youtubeApiKey: env.getOrElse('YOUTUBE_API_KEY', () => ''),
      storageProvider: env.getOrElse('STORAGE_PROVIDER', () => 'local'),
      storagePath: env.getOrElse('STORAGE_PATH', () => './uploads'),
      s3Bucket: env['S3_BUCKET'],
      s3Region: env['S3_REGION'],
      s3AccessKey: env['S3_ACCESS_KEY'],
      s3SecretKey: env['S3_SECRET_KEY'],
      encryptionMasterKey: _requireEnv(env, 'ENCRYPTION_MASTER_KEY'),
      aiApiKey: env.getOrElse('AI_API_KEY', () => ''),
      aiProvider: env.getOrElse('AI_PROVIDER', () => 'anthropic'),
      aiModel: env.getOrElse('AI_MODEL', () => 'claude-sonnet-4-20250514'),
      googlePlayServiceAccountJson: env.getOrElse(
        'GOOGLE_PLAY_SERVICE_ACCOUNT_JSON',
        () => '',
      ),
      appStoreIssuerId: env.getOrElse('APP_STORE_ISSUER_ID', () => ''),
      appStoreKeyId: env.getOrElse('APP_STORE_KEY_ID', () => ''),
      appStorePrivateKey: env.getOrElse('APP_STORE_PRIVATE_KEY', () => ''),
      appStoreSharedSecret: env.getOrElse('APP_STORE_SHARED_SECRET', () => ''),
    );
  }

  /// Whether the app is running in development mode.
  bool get isDevelopment => env == 'development';

  /// Whether the app is running in production mode.
  bool get isProduction => env == 'production';

  /// Whether the app is running in test mode.
  bool get isTest => env == 'test';

  /// Requires a non-empty environment variable or throws.
  static String _requireEnv(DotEnv env, String key) {
    final value = env[key];
    if (value == null || value.isEmpty) {
      throw MissingEnvVarException(key);
    }
    return value;
  }
}
