import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../config/app_config.dart';
import 'entitlements_repository.dart';

/// Custom exception for entitlement-related errors.
class EntitlementException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const EntitlementException(
    this.message, {
    this.code = 'ENTITLEMENT_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'EntitlementException($code): $message';
}

/// Maps client-facing platform strings to the database enum values.
const _platformToDbEnum = {'google_play': 'android', 'app_store': 'ios'};

/// Service handling subscription verification and lifecycle management.
///
/// Verifies receipts from Google Play and App Store, manages subscription
/// status transitions, and delegates tier upgrades/downgrades to the
/// repository.
class EntitlementsSubscriptionService {
  final EntitlementsRepository _repo;
  final AppConfig _config;
  final Logger _log = Logger('EntitlementsSubscriptionService');
  final Uuid _uuid = const Uuid();

  EntitlementsSubscriptionService(this._repo, this._config);

  // ---------------------------------------------------------------------------
  // Receipt verification
  // ---------------------------------------------------------------------------

  /// Verifies a purchase receipt and activates the subscription.
  ///
  /// [platform] should be 'google_play' or 'app_store' (client-facing).
  Future<Map<String, dynamic>> verifyReceipt({
    required String spaceId,
    required String receipt,
    required String platform,
    required String productId,
  }) async {
    _log.info('Verifying $platform receipt for space $spaceId');

    final dbPlatform = _platformToDbEnum[platform];
    if (dbPlatform == null) {
      throw const EntitlementException(
        'Unsupported platform',
        code: 'UNSUPPORTED_PLATFORM',
        statusCode: 400,
      );
    }

    Map<String, dynamic> verification;

    switch (platform) {
      case 'google_play':
        verification = await _verifyGooglePlayReceipt(
          receipt: receipt,
          productId: productId,
        );
      case 'app_store':
        verification = await _verifyAppStoreReceipt(receipt: receipt);
      default:
        throw const EntitlementException(
          'Unsupported platform',
          code: 'UNSUPPORTED_PLATFORM',
          statusCode: 400,
        );
    }

    final periodStart = verification['period_start'] as DateTime;
    final periodEnd = verification['period_end'] as DateTime;

    // Create subscription record
    final subscription = await _repo.createSubscription(
      spaceId: spaceId,
      platform: dbPlatform,
      planId: productId,
      externalSubscriptionId:
          verification['external_subscription_id'] as String?,
      status: 'active',
      startedAt: periodStart,
      expiresAt: periodEnd,
    );

    // Upgrade the space to premium
    await _repo.upgradeToPremium(
      spaceId,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );

    _log.info('Space $spaceId upgraded to premium');
    return subscription;
  }

  /// Verifies a Google Play purchase token via the Android Publisher API.
  Future<Map<String, dynamic>> _verifyGooglePlayReceipt({
    required String receipt,
    required String productId,
  }) async {
    final serviceAccountPath = _config.googlePlayServiceAccountJson;
    if (serviceAccountPath.isEmpty) {
      _log.warning('Google Play service account not configured');
      if (_config.isDevelopment) {
        return _mockVerification(receipt);
      }
      throw const EntitlementException(
        'Google Play verification not configured',
        code: 'VERIFICATION_NOT_CONFIGURED',
        statusCode: 503,
      );
    }

    // TODO: Implement actual Google Play API call:
    // 1. Load service account JSON from `serviceAccountPath`
    // 2. Obtain OAuth2 access token via googleapis_auth
    // 3. GET https://androidpublisher.googleapis.com/androidpublisher/v3/
    //    applications/{packageName}/purchases/subscriptions/
    //    {subscriptionId}/tokens/{token}
    // 4. Extract startTimeMillis, expiryTimeMillis, orderId
    _log.info('Verifying Google Play token for product $productId');
    return _mockVerification(receipt);
  }

  /// Verifies an App Store receipt via the App Store Server API v2.
  Future<Map<String, dynamic>> _verifyAppStoreReceipt({
    required String receipt,
  }) async {
    final issuerId = _config.appStoreIssuerId;
    if (issuerId.isEmpty) {
      _log.warning('App Store credentials not configured');
      if (_config.isDevelopment) {
        return _mockVerification(receipt);
      }
      throw const EntitlementException(
        'App Store verification not configured',
        code: 'VERIFICATION_NOT_CONFIGURED',
        statusCode: 503,
      );
    }

    // TODO: Implement actual App Store Server API v2 call:
    // 1. Build JWT with { alg: ES256, kid: appStoreKeyId }
    //    payload: { iss: appStoreIssuerId, aud: "appstoreconnect-v1" }
    //    signed with appStorePrivateKey
    // 2. GET https://api.storekit.itunes.apple.com/inApps/v1/
    //    subscriptions/{originalTransactionId}
    // 3. Decode signed JWS transaction info from response
    _log.info('Verifying App Store receipt');
    return _mockVerification(receipt);
  }

  /// Returns mock verification data for development/testing.
  Map<String, dynamic> _mockVerification(String receipt) {
    final now = DateTime.now().toUtc();
    return {
      'period_start': now,
      'period_end': now.add(const Duration(days: 30)),
      'external_subscription_id': 'mock_${_uuid.v4().substring(0, 8)}',
    };
  }

  // ---------------------------------------------------------------------------
  // Webhook handlers
  // ---------------------------------------------------------------------------

  /// Handles a Google Play Real-Time Developer Notification.
  ///
  /// Google Play sends a Pub/Sub envelope; the caller should extract and
  /// base64-decode `message.data` before passing it here.
  Future<void> handleGooglePlayNotification(
    Map<String, dynamic> notification,
  ) async {
    _log.info('Processing Google Play notification');

    final subscriptionNotification =
        notification['subscriptionNotification'] as Map<String, dynamic>?;
    if (subscriptionNotification == null) return;

    final purchaseToken = subscriptionNotification['purchaseToken'] as String?;
    final notificationType =
        subscriptionNotification['notificationType'] as int?;

    if (purchaseToken == null || notificationType == null) return;

    final subscription = await _repo.findSubscriptionByExternalId(
      purchaseToken,
      'android',
    );
    if (subscription == null) {
      _log.warning('No subscription found for Google Play token');
      return;
    }

    final subscriptionId = subscription['id'] as String;
    final spaceId = subscription['space_id'] as String;

    // Google Play notification types:
    // 1 = RECOVERED, 2 = RENEWED, 3 = CANCELED,
    // 4 = PURCHASED, 5 = ON_HOLD, 6 = IN_GRACE_PERIOD,
    // 7 = RESTARTED, 12 = REVOKED, 13 = EXPIRED
    switch (notificationType) {
      case 1: // RECOVERED
      case 2: // RENEWED
      case 4: // PURCHASED
      case 7: // RESTARTED
        // TODO: In production, fetch the actual expiry from Google Play API
        // instead of using a hardcoded 30-day period.
        final now = DateTime.now().toUtc();
        await _repo.updateSubscriptionStatus(subscriptionId, 'active');
        await _repo.upgradeToPremium(
          spaceId,
          periodStart: now,
          periodEnd: now.add(const Duration(days: 30)),
        );
      case 3: // CANCELED
        await _repo.updateSubscriptionStatus(
          subscriptionId,
          'canceled',
          canceledAt: DateTime.now().toUtc(),
        );
      case 12: // REVOKED
      case 13: // EXPIRED
        await _repo.updateSubscriptionStatus(subscriptionId, 'expired');
        await _repo.downgradeToFree(spaceId);
      case 5: // ON_HOLD
      case 6: // IN_GRACE_PERIOD
        await _repo.updateSubscriptionStatus(subscriptionId, 'past_due');
    }
  }

  /// Handles an App Store Server Notification v2.
  ///
  /// The caller should decode the outer JWS `signedPayload` before passing
  /// the decoded JSON here.
  Future<void> handleAppStoreNotification(
    Map<String, dynamic> notification,
  ) async {
    _log.info('Processing App Store notification');

    final notificationType = notification['notificationType'] as String?;
    final data = notification['data'] as Map<String, dynamic>?;
    if (notificationType == null || data == null) return;

    // In production, decode and verify the JWS signedTransactionInfo.
    // For now, read originalTransactionId from the decoded payload.
    final originalTransactionId = data['originalTransactionId'] as String?;
    if (originalTransactionId == null) {
      _log.warning('Missing originalTransactionId in App Store notification');
      return;
    }

    final subscription = await _repo.findSubscriptionByExternalId(
      originalTransactionId,
      'ios',
    );
    if (subscription == null) {
      _log.warning('No subscription found for App Store transaction');
      return;
    }

    final subscriptionId = subscription['id'] as String;
    final spaceId = subscription['space_id'] as String;

    switch (notificationType) {
      case 'DID_RENEW':
      case 'SUBSCRIBED':
        // TODO: In production, extract actual expiry from decoded JWS.
        final now = DateTime.now().toUtc();
        await _repo.updateSubscriptionStatus(subscriptionId, 'active');
        await _repo.upgradeToPremium(
          spaceId,
          periodStart: now,
          periodEnd: now.add(const Duration(days: 30)),
        );
      case 'DID_CHANGE_RENEWAL_STATUS':
        final subtype = notification['subtype'] as String?;
        if (subtype == 'AUTO_RENEW_DISABLED') {
          await _repo.updateSubscriptionStatus(
            subscriptionId,
            'canceled',
            canceledAt: DateTime.now().toUtc(),
          );
        }
      case 'EXPIRED':
      case 'REVOKE':
        await _repo.updateSubscriptionStatus(subscriptionId, 'expired');
        await _repo.downgradeToFree(spaceId);
      case 'DID_FAIL_TO_RENEW':
      case 'GRACE_PERIOD_EXPIRED':
        await _repo.updateSubscriptionStatus(subscriptionId, 'past_due');
    }
  }

  // ---------------------------------------------------------------------------
  // Cancellation
  // ---------------------------------------------------------------------------

  /// Marks a subscription as canceled. The subscription stays active until
  /// its current period ends.
  Future<void> cancelSubscription(String spaceId) async {
    final subscription = await _repo.getActiveSubscription(spaceId);
    if (subscription == null) {
      throw const EntitlementException(
        'No active subscription found',
        code: 'NO_SUBSCRIPTION',
        statusCode: 404,
      );
    }

    await _repo.updateSubscriptionStatus(
      subscription['id'] as String,
      'canceled',
      canceledAt: DateTime.now().toUtc(),
    );

    _log.info('Subscription for space $spaceId marked as canceled');
  }
}
