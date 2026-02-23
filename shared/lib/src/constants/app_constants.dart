/// Constants related to the application configuration and business rules.
abstract final class AppConstants {
  /// Application name.
  static const String appName = 'Studio Pair';

  /// Supported languages (ISO 639-1 codes).
  static const List<String> supportedLanguages = ['en', 'fr', 'nl', 'de'];

  /// Default language.
  static const String defaultLanguage = 'en';

  // --- Space Limits ---

  /// Maximum members per space on the free tier.
  static const int maxMembersFree = 2;

  /// Maximum members per space on the premium tier.
  static const int maxMembersPremium = 20;

  /// Maximum number of spaces a user can own on the free tier.
  static const int maxSpacesFree = 1;

  /// Maximum number of spaces a user can own on premium (effectively unlimited).
  static const int maxSpacesPremium = 999;

  // --- Storage Limits ---

  /// Storage limit for free tier in bytes (500 MB).
  static const int storageLimitFreeBytes = 500 * 1024 * 1024;

  /// Storage limit for premium tier in bytes (50 GB).
  static const int storageLimitPremiumBytes = 50 * 1024 * 1024 * 1024;

  // --- History Retention ---

  /// History retention in days for the free tier.
  static const int historyRetentionDaysFree = 90;

  /// History retention in days for the premium tier (effectively unlimited).
  static const int historyRetentionDaysPremium = 36500;

  // --- Calendar Connections ---

  /// Maximum calendar connections for free tier.
  static const int calendarConnectionsFree = 1;

  /// Maximum calendar connections for premium tier.
  static const int calendarConnectionsPremium = 10;

  // --- AI Credits ---

  /// AI credits per period for free tier.
  static const int aiCreditsFree = 10;

  /// AI credits per period for premium tier.
  static const int aiCreditsPremium = 500;

  // --- Message Edit ---

  /// Window in minutes during which a message can be edited.
  static const int editWindowMinutes = 15;

  // --- Sensitive Content ---

  /// Auto-hide delay in seconds for sensitive content.
  static const int autoHideSeconds = 30;

  /// TTL in minutes for sensitive access (e.g., viewing card details).
  static const int sensitiveAccessTtlMinutes = 5;
}
