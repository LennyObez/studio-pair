import 'package:studio_pair_shared/src/constants/api_constants.dart';
import 'package:studio_pair_shared/src/constants/app_constants.dart';
import 'package:test/test.dart';

void main() {
  group('ApiConstants', () {
    test('apiVersion is v1', () {
      expect(ApiConstants.apiVersion, equals('v1'));
    });

    test('apiPrefix includes version', () {
      expect(ApiConstants.apiPrefix, equals('/api/v1'));
    });

    group('pagination', () {
      test('defaultPageSize is positive', () {
        expect(ApiConstants.defaultPageSize, greaterThan(0));
      });

      test('maxPageSize is greater than defaultPageSize', () {
        expect(
          ApiConstants.maxPageSize,
          greaterThan(ApiConstants.defaultPageSize),
        );
      });

      test('defaultPageSize is 20', () {
        expect(ApiConstants.defaultPageSize, equals(20));
      });

      test('maxPageSize is 100', () {
        expect(ApiConstants.maxPageSize, equals(100));
      });
    });

    group('token TTLs', () {
      test('access token TTL is 15 minutes', () {
        expect(ApiConstants.accessTokenTtlMinutes, equals(15));
      });

      test('refresh token TTL is 30 days', () {
        expect(ApiConstants.refreshTokenTtlDays, equals(30));
      });

      test('email verification TTL is 24 hours', () {
        expect(ApiConstants.emailVerificationTtlHours, equals(24));
      });

      test('password reset TTL is 1 hour', () {
        expect(ApiConstants.passwordResetTtlHours, equals(1));
      });

      test('invite code TTL is 7 days', () {
        expect(ApiConstants.inviteCodeTtlDays, equals(7));
      });
    });

    group('rate limiting', () {
      test('general rate limit is 60 per minute', () {
        expect(ApiConstants.rateLimitPerMinute, equals(60));
      });

      test('auth rate limit is lower than general', () {
        expect(
          ApiConstants.authRateLimitPerMinute,
          lessThan(ApiConstants.rateLimitPerMinute),
        );
      });

      test('auth rate limit is 10 per minute', () {
        expect(ApiConstants.authRateLimitPerMinute, equals(10));
      });
    });

    group('file limits', () {
      test('max file size is 50 MB', () {
        expect(ApiConstants.maxFileSizeBytes, equals(50 * 1024 * 1024));
      });

      test('max attachment size is 10 MB', () {
        expect(ApiConstants.maxAttachmentSizeBytes, equals(10 * 1024 * 1024));
      });

      test('max avatar size is 5 MB', () {
        expect(ApiConstants.maxAvatarSizeBytes, equals(5 * 1024 * 1024));
      });

      test('max folder depth is 5', () {
        expect(ApiConstants.maxFolderDepth, equals(5));
      });

      test('file size limits are ordered correctly', () {
        expect(
          ApiConstants.maxAvatarSizeBytes,
          lessThan(ApiConstants.maxAttachmentSizeBytes),
        );
        expect(
          ApiConstants.maxAttachmentSizeBytes,
          lessThan(ApiConstants.maxFileSizeBytes),
        );
      });
    });
  });

  group('AppConstants', () {
    test('appName is Studio Pair', () {
      expect(AppConstants.appName, equals('Studio Pair'));
    });

    group('languages', () {
      test('supports English and French', () {
        expect(AppConstants.supportedLanguages, contains('en'));
        expect(AppConstants.supportedLanguages, contains('fr'));
      });

      test('default language is English', () {
        expect(AppConstants.defaultLanguage, equals('en'));
      });

      test('default language is in supported languages', () {
        expect(
          AppConstants.supportedLanguages,
          contains(AppConstants.defaultLanguage),
        );
      });
    });

    group('space limits', () {
      test('free tier allows fewer members than premium', () {
        expect(
          AppConstants.maxMembersFree,
          lessThan(AppConstants.maxMembersPremium),
        );
      });

      test('free tier allows 3 members', () {
        expect(AppConstants.maxMembersFree, equals(3));
      });

      test('premium tier allows 5 members', () {
        expect(AppConstants.maxMembersPremium, equals(5));
      });

      test('free tier allows fewer spaces than premium', () {
        expect(
          AppConstants.maxSpacesFree,
          lessThan(AppConstants.maxSpacesPremium),
        );
      });
    });

    group('storage limits', () {
      test('free tier has 500 MB storage', () {
        expect(AppConstants.storageLimitFreeBytes, equals(500 * 1024 * 1024));
      });

      test('premium tier has more storage than free', () {
        expect(
          AppConstants.storageLimitPremiumBytes,
          greaterThan(AppConstants.storageLimitFreeBytes),
        );
      });
    });

    group('history retention', () {
      test('free tier retains 90 days of history', () {
        expect(AppConstants.historyRetentionDaysFree, equals(90));
      });

      test('premium tier retains much more history', () {
        expect(
          AppConstants.historyRetentionDaysPremium,
          greaterThan(AppConstants.historyRetentionDaysFree),
        );
      });
    });

    group('calendar connections', () {
      test('free tier allows 1 calendar connection', () {
        expect(AppConstants.calendarConnectionsFree, equals(1));
      });

      test('premium tier allows 5 calendar connections', () {
        expect(AppConstants.calendarConnectionsPremium, equals(5));
      });
    });

    group('AI credits', () {
      test('free tier provides 10 AI credits', () {
        expect(AppConstants.aiCreditsFree, equals(10));
      });

      test('premium tier provides 100 AI credits', () {
        expect(AppConstants.aiCreditsPremium, equals(100));
      });

      test('premium tier provides more credits than free', () {
        expect(
          AppConstants.aiCreditsPremium,
          greaterThan(AppConstants.aiCreditsFree),
        );
      });
    });

    group('message editing', () {
      test('edit window is 15 minutes', () {
        expect(AppConstants.editWindowMinutes, equals(15));
      });
    });

    group('sensitive content', () {
      test('auto-hide delay is 30 seconds', () {
        expect(AppConstants.autoHideSeconds, equals(30));
      });

      test('sensitive access TTL is 5 minutes', () {
        expect(AppConstants.sensitiveAccessTtlMinutes, equals(5));
      });
    });
  });
}
