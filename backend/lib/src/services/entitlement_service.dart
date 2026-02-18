import 'package:logging/logging.dart';

import '../config/database.dart';

/// Quota check result.
class QuotaResult {
  final bool allowed;
  final int used;
  final int limit;
  final String? message;

  const QuotaResult({
    required this.allowed,
    required this.used,
    required this.limit,
    this.message,
  });

  int get remaining => (limit - used).clamp(0, limit);

  Map<String, dynamic> toJson() => {
    'allowed': allowed,
    'used': used,
    'limit': limit,
    'remaining': remaining,
    if (message != null) 'message': message,
  };
}

/// Service for managing entitlements and subscription-based feature limits.
///
/// Checks quotas and limits based on a space's subscription tier.
class EntitlementService {
  final Database _db;
  final Logger _log = Logger('EntitlementService');

  /// Free tier limits.
  static const Map<String, int> _freeLimits = {
    'storage_mb': 500, // 500 MB
    'calendar_connections': 1,
    'ai_credits_monthly': 10,
    'max_members': 2,
    'history_days': 90, // 90 days of history
    'vault_entries': 20,
    'file_uploads_monthly': 50,
  };

  /// Premium tier limits.
  static const Map<String, int> _premiumLimits = {
    'storage_mb': 50000, // 50 GB
    'calendar_connections': 10,
    'ai_credits_monthly': 500,
    'max_members': 20,
    'history_days': -1, // Unlimited
    'vault_entries': -1, // Unlimited
    'file_uploads_monthly': -1, // Unlimited
  };

  EntitlementService(this._db);

  /// Gets the limits for a given subscription tier.
  Map<String, int> _getLimits(String tier) {
    switch (tier) {
      case 'premium':
        return _premiumLimits;
      case 'free':
      default:
        return _freeLimits;
    }
  }

  /// Gets the subscription tier for a space.
  Future<String> _getSpaceTier(String spaceId) async {
    final row = await _db.queryOne(
      '''
      SELECT tier
      FROM entitlements
      WHERE space_id = @spaceId
      ''',
      parameters: {'spaceId': spaceId},
    );

    return (row?[0] as String?) ?? 'free';
  }

  /// Checks if a space has available storage quota.
  Future<QuotaResult> checkStorageQuota(
    String spaceId, {
    int additionalMb = 0,
  }) async {
    final tier = await _getSpaceTier(spaceId);
    final limits = _getLimits(tier);
    final maxMb = limits['storage_mb']!;

    if (maxMb == -1) {
      return const QuotaResult(allowed: true, used: 0, limit: -1);
    }

    // Calculate actual storage usage from files table
    final row = await _db.queryOne(
      '''
      SELECT COALESCE(SUM(size_bytes), 0) AS total_bytes
      FROM files
      WHERE space_id = @spaceId AND deleted_at IS NULL
      ''',
      parameters: {'spaceId': spaceId},
    );

    final totalBytes = (row?[0] as int?) ?? 0;
    final usedMb = (totalBytes / (1024 * 1024)).ceil();

    return QuotaResult(
      allowed: (usedMb + additionalMb) <= maxMb,
      used: usedMb,
      limit: maxMb,
      message: (usedMb + additionalMb) > maxMb
          ? 'Storage quota exceeded. Upgrade to Premium for more space.'
          : null,
    );
  }

  /// Checks if a space can add more calendar connections.
  Future<QuotaResult> checkCalendarConnectionLimit(String spaceId) async {
    final tier = await _getSpaceTier(spaceId);
    final limits = _getLimits(tier);
    final maxConnections = limits['calendar_connections']!;

    if (maxConnections == -1) {
      return const QuotaResult(allowed: true, used: 0, limit: -1);
    }

    // Count actual calendar connections
    final row = await _db.queryOne(
      '''
      SELECT COUNT(*) AS cnt
      FROM calendar_sync_connections
      WHERE space_id = @spaceId AND status = 'active'
      ''',
      parameters: {'spaceId': spaceId},
    );

    final usedConnections = (row?[0] as int?) ?? 0;

    return QuotaResult(
      allowed: usedConnections < maxConnections,
      used: usedConnections,
      limit: maxConnections,
      message: usedConnections >= maxConnections
          ? 'Calendar connection limit reached. Upgrade to Premium for more.'
          : null,
    );
  }

  /// Checks if a space has available AI credits.
  Future<QuotaResult> checkAiCredits(String spaceId) async {
    final tier = await _getSpaceTier(spaceId);
    final limits = _getLimits(tier);
    final maxCredits = limits['ai_credits_monthly']!;

    if (maxCredits == -1) {
      return const QuotaResult(allowed: true, used: 0, limit: -1);
    }

    // Count AI credits used this month from ai_usage_log
    final row = await _db.queryOne(
      '''
      SELECT COALESCE(SUM(credits_used), 0) AS total_credits
      FROM ai_usage_log
      WHERE space_id = @spaceId
        AND created_at >= date_trunc('month', NOW())
      ''',
      parameters: {'spaceId': spaceId},
    );

    final usedCredits = (row?[0] as int?) ?? 0;

    return QuotaResult(
      allowed: usedCredits < maxCredits,
      used: usedCredits,
      limit: maxCredits,
      message: usedCredits >= maxCredits
          ? 'AI credits exhausted for this month. Upgrade to Premium for more.'
          : null,
    );
  }

  /// Checks if a space can add more members.
  Future<QuotaResult> checkMemberLimit(String spaceId) async {
    final tier = await _getSpaceTier(spaceId);
    final limits = _getLimits(tier);
    final maxMembers = limits['max_members']!;

    if (maxMembers == -1) {
      return const QuotaResult(allowed: true, used: 0, limit: -1);
    }

    final row = await _db.queryOne(
      '''
      SELECT COUNT(*) as cnt
      FROM space_memberships
      WHERE space_id = @spaceId AND status = 'active'
      ''',
      parameters: {'spaceId': spaceId},
    );

    final usedMembers = (row?[0] as int?) ?? 0;

    return QuotaResult(
      allowed: usedMembers < maxMembers,
      used: usedMembers,
      limit: maxMembers,
      message: usedMembers >= maxMembers
          ? 'Member limit reached. Upgrade to Premium to add more members.'
          : null,
    );
  }

  /// Checks if a space has access to historical data beyond the free limit.
  Future<QuotaResult> checkHistoryAccess(String spaceId) async {
    final tier = await _getSpaceTier(spaceId);
    final limits = _getLimits(tier);
    final historyDays = limits['history_days']!;

    return QuotaResult(
      allowed: true,
      used: 0,
      limit: historyDays,
      message: historyDays != -1
          ? 'Free tier: access limited to last $historyDays days of history.'
          : null,
    );
  }

  /// Creates default free-tier entitlements when a space is created.
  Future<void> createDefaultEntitlement(String spaceId) async {
    _log.info('Creating default free-tier entitlement for space $spaceId');
    // The entitlement is implicit based on subscription tier.
    // When no subscription exists, the space is on the free tier.
  }

  /// Gets a summary of all entitlements for a space.
  Future<Map<String, dynamic>> getEntitlementSummary(String spaceId) async {
    final tier = await _getSpaceTier(spaceId);
    final limits = _getLimits(tier);

    final storage = await checkStorageQuota(spaceId);
    final members = await checkMemberLimit(spaceId);
    final aiCredits = await checkAiCredits(spaceId);

    return {
      'tier': tier,
      'limits': limits,
      'usage': {
        'storage': storage.toJson(),
        'members': members.toJson(),
        'ai_credits': aiCredits.toJson(),
      },
    };
  }
}
