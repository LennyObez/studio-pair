import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for entitlement and subscription database operations.
///
/// Column names match the schema in `database/migrations/004_entitlements.sql`.
class EntitlementsRepository {
  final Database _db;
  final Logger _log = Logger('EntitlementsRepository');

  EntitlementsRepository(this._db);

  // ---------------------------------------------------------------------------
  // Entitlements
  // ---------------------------------------------------------------------------

  /// Gets the entitlement row for a space.
  ///
  /// The `entitlements` table uses `space_id` as its primary key (1:1 with
  /// spaces).
  Future<Map<String, dynamic>?> getEntitlements(String spaceId) async {
    final row = await _db.queryOne(
      '''
      SELECT space_id, tier,
             storage_bytes_used, storage_bytes_limit,
             max_members,
             calendar_connections_count, calendar_connections_limit,
             ai_credits_used_this_period, ai_credits_limit,
             history_retention_days,
             current_period_start, current_period_end,
             created_at, updated_at
      FROM entitlements
      WHERE space_id = @spaceId
      ''',
      parameters: {'spaceId': spaceId},
    );

    if (row == null) return null;
    return {
      'space_id': row[0] as String,
      'tier': row[1] as String,
      'storage_bytes_used': row[2] as int,
      'storage_bytes_limit': row[3] as int,
      'max_members': row[4] as int,
      'calendar_connections_count': row[5] as int,
      'calendar_connections_limit': row[6] as int,
      'ai_credits_used_this_period': row[7] as int,
      'ai_credits_limit': row[8] as int,
      'history_retention_days': row[9] as int,
      'current_period_start': row[10] != null
          ? (row[10] as DateTime).toIso8601String()
          : null,
      'current_period_end': row[11] != null
          ? (row[11] as DateTime).toIso8601String()
          : null,
      'created_at': (row[12] as DateTime).toIso8601String(),
      'updated_at': (row[13] as DateTime).toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // Subscriptions
  // ---------------------------------------------------------------------------

  /// Gets the active (or recently canceled) subscription for a space.
  ///
  /// Platform enum values: 'ios', 'android', 'web'.
  Future<Map<String, dynamic>?> getActiveSubscription(String spaceId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, platform, external_subscription_id,
             status, plan_id, amount_cents, currency,
             started_at, expires_at, canceled_at,
             created_at, updated_at
      FROM subscriptions
      WHERE space_id = @spaceId
        AND status IN ('active', 'canceled')
      ORDER BY created_at DESC
      LIMIT 1
      ''',
      parameters: {'spaceId': spaceId},
    );

    if (row == null) return null;
    return _subscriptionRowToMap(row);
  }

  /// Creates a new subscription record.
  ///
  /// If the space already has an active subscription on this platform, it
  /// expires the old one first.
  Future<Map<String, dynamic>> createSubscription({
    required String spaceId,
    required String platform,
    required String planId,
    String? externalSubscriptionId,
    required String status,
    int? amountCents,
    String currency = 'EUR',
    required DateTime startedAt,
    DateTime? expiresAt,
  }) async {
    // Expire any existing active subscription for this space+platform
    await _db.execute(
      '''
      UPDATE subscriptions
      SET status = 'expired', updated_at = NOW()
      WHERE space_id = @spaceId
        AND platform = @platform::subscription_platform
        AND status IN ('active', 'past_due')
      ''',
      parameters: {'spaceId': spaceId, 'platform': platform},
    );

    final row = await _db.queryOne(
      '''
      INSERT INTO subscriptions (
        space_id, platform, external_subscription_id,
        status, plan_id, amount_cents, currency,
        started_at, expires_at, created_at, updated_at
      )
      VALUES (
        @spaceId, @platform::subscription_platform, @externalSubscriptionId,
        @status::subscription_status, @planId, @amountCents, @currency,
        @startedAt, @expiresAt, NOW(), NOW()
      )
      RETURNING id, space_id, platform, external_subscription_id,
                status, plan_id, amount_cents, currency,
                started_at, expires_at, canceled_at,
                created_at, updated_at
      ''',
      parameters: {
        'spaceId': spaceId,
        'platform': platform,
        'externalSubscriptionId': externalSubscriptionId,
        'status': status,
        'planId': planId,
        'amountCents': amountCents,
        'currency': currency,
        'startedAt': startedAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
      },
    );

    return _subscriptionRowToMap(row!);
  }

  /// Upgrades a space to the premium tier with expanded limits.
  ///
  /// Uses values that respect the schema CHECK constraints:
  /// - `storage_bytes_limit > 0`
  /// - `max_members >= 2`
  /// - `calendar_connections_limit >= 0`
  /// - `ai_credits_limit >= 0`
  /// - `history_retention_days > 0`
  Future<void> upgradeToPremium(
    String spaceId, {
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    _log.info('Upgrading space $spaceId to premium');

    // 50 GB in bytes
    const premiumStorageBytes = 53687091200;
    // ~100 years = effectively unlimited
    const premiumHistoryDays = 36500;

    await _db.execute(
      '''
      UPDATE entitlements
      SET tier = 'premium',
          storage_bytes_limit = $premiumStorageBytes,
          max_members = 20,
          calendar_connections_limit = 10,
          ai_credits_limit = 500,
          history_retention_days = $premiumHistoryDays,
          current_period_start = @periodStart,
          current_period_end = @periodEnd,
          updated_at = NOW()
      WHERE space_id = @spaceId
      ''',
      parameters: {
        'spaceId': spaceId,
        'periodStart': periodStart.toIso8601String(),
        'periodEnd': periodEnd.toIso8601String(),
      },
    );
  }

  /// Downgrades a space to the free tier with default limits.
  Future<void> downgradeToFree(String spaceId) async {
    _log.info('Downgrading space $spaceId to free');

    // 500 MB in bytes
    const freeStorageBytes = 524288000;

    await _db.execute(
      '''
      UPDATE entitlements
      SET tier = 'free',
          storage_bytes_limit = $freeStorageBytes,
          max_members = 2,
          calendar_connections_limit = 1,
          ai_credits_limit = 10,
          history_retention_days = 90,
          current_period_start = NULL,
          current_period_end = NULL,
          updated_at = NOW()
      WHERE space_id = @spaceId
      ''',
      parameters: {'spaceId': spaceId},
    );
  }

  /// Updates the status of a subscription (used by webhook handlers).
  Future<void> updateSubscriptionStatus(
    String subscriptionId,
    String status, {
    DateTime? canceledAt,
    DateTime? expiresAt,
  }) async {
    final setClauses = <String>[
      'status = @status::subscription_status',
      'updated_at = NOW()',
    ];
    final params = <String, dynamic>{
      'subscriptionId': subscriptionId,
      'status': status,
    };

    if (canceledAt != null) {
      setClauses.add('canceled_at = @canceledAt');
      params['canceledAt'] = canceledAt.toIso8601String();
    }

    if (expiresAt != null) {
      setClauses.add('expires_at = @expiresAt');
      params['expiresAt'] = expiresAt.toIso8601String();
    }

    await _db.execute('''
      UPDATE subscriptions
      SET ${setClauses.join(', ')}
      WHERE id = @subscriptionId
      ''', parameters: params);
  }

  /// Finds a subscription by its external subscription ID (used for webhook
  /// reconciliation — e.g. Google Play purchase token or App Store original
  /// transaction ID).
  ///
  /// Platform values: 'ios', 'android'.
  Future<Map<String, dynamic>?> findSubscriptionByExternalId(
    String externalId,
    String platform,
  ) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, platform, external_subscription_id,
             status, plan_id, amount_cents, currency,
             started_at, expires_at, canceled_at,
             created_at, updated_at
      FROM subscriptions
      WHERE external_subscription_id = @externalId
        AND platform = @platform::subscription_platform
      ORDER BY created_at DESC
      LIMIT 1
      ''',
      parameters: {'externalId': externalId, 'platform': platform},
    );

    if (row == null) return null;
    return _subscriptionRowToMap(row);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _subscriptionRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'platform': (row[2] as String),
      'external_subscription_id': row[3] as String?,
      'status': (row[4] as String),
      'plan_id': row[5] as String?,
      'amount_cents': row[6] as int?,
      'currency': (row[7] as String),
      'started_at': (row[8] as DateTime).toIso8601String(),
      'expires_at': row[9] != null
          ? (row[9] as DateTime).toIso8601String()
          : null,
      'canceled_at': row[10] != null
          ? (row[10] as DateTime).toIso8601String()
          : null,
      'created_at': (row[11] as DateTime).toIso8601String(),
      'updated_at': (row[12] as DateTime).toIso8601String(),
    };
  }
}
