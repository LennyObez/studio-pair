/// Constants related to the API configuration.
abstract final class ApiConstants {
  /// Current API version.
  static const String apiVersion = 'v1';

  /// Base API path prefix.
  static const String apiPrefix = '/api/$apiVersion';

  // --- Pagination ---

  /// Default page size for paginated responses.
  static const int defaultPageSize = 20;

  /// Maximum allowed page size.
  static const int maxPageSize = 100;

  // --- Token TTLs ---

  /// Access token time-to-live in minutes.
  static const int accessTokenTtlMinutes = 15;

  /// Refresh token time-to-live in days.
  static const int refreshTokenTtlDays = 30;

  /// Email verification token TTL in hours.
  static const int emailVerificationTtlHours = 24;

  /// Password reset token TTL in hours.
  static const int passwordResetTtlHours = 1;

  /// Invite code TTL in days.
  static const int inviteCodeTtlDays = 7;

  // --- Rate Limiting ---

  /// General API rate limit (requests per minute).
  static const int rateLimitPerMinute = 60;

  /// Auth endpoints rate limit (requests per minute).
  static const int authRateLimitPerMinute = 10;

  /// File upload rate limit (requests per minute).
  static const int uploadRateLimitPerMinute = 20;

  // --- File Limits ---

  /// Maximum file upload size in bytes (50 MB).
  static const int maxFileSizeBytes = 50 * 1024 * 1024;

  /// Maximum attachment size in bytes (10 MB).
  static const int maxAttachmentSizeBytes = 10 * 1024 * 1024;

  /// Maximum avatar image size in bytes (5 MB).
  static const int maxAvatarSizeBytes = 5 * 1024 * 1024;

  /// Maximum folder nesting depth.
  static const int maxFolderDepth = 5;
}
