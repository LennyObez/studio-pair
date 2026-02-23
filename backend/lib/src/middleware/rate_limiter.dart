import 'dart:async';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

import '../utils/response_utils.dart';

/// Configuration for a rate limit rule.
class RateLimitRule {
  /// Maximum number of requests allowed in the window.
  final int maxRequests;

  /// Time window for the rate limit.
  final Duration window;

  const RateLimitRule({required this.maxRequests, required this.window});
}

/// A single request record for rate tracking.
class _RequestRecord {
  final DateTime timestamp;

  _RequestRecord(this.timestamp);
}

/// Simple in-memory rate limiter with per-IP tracking using sliding windows.
class RateLimiter {
  final Logger _log = Logger('RateLimiter');

  /// Rate limit rules by path pattern.
  final Map<String, RateLimitRule> _rules;

  /// Default rate limit for unmatched paths.
  final RateLimitRule _defaultRule;

  /// Map of IP+path -> list of request timestamps.
  final Map<String, List<_RequestRecord>> _requests = {};

  /// Timer for periodic cleanup of expired entries.
  Timer? _cleanupTimer;

  RateLimiter({Map<String, RateLimitRule>? rules, RateLimitRule? defaultRule})
    : _rules = rules ?? _defaultRules,
      _defaultRule =
          defaultRule ??
          const RateLimitRule(maxRequests: 100, window: Duration(minutes: 1)) {
    // Run cleanup every 5 minutes
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanup(),
    );
  }

  /// Default rate limit rules for common endpoints.
  static final Map<String, RateLimitRule> _defaultRules = {
    '/api/v1/auth/login': const RateLimitRule(
      maxRequests: 5,
      window: Duration(minutes: 15),
    ),
    '/api/v1/auth/register': const RateLimitRule(
      maxRequests: 3,
      window: Duration(minutes: 15),
    ),
    '/api/v1/auth/forgot-password': const RateLimitRule(
      maxRequests: 3,
      window: Duration(minutes: 15),
    ),
    '/api/v1/auth/reset-password': const RateLimitRule(
      maxRequests: 5,
      window: Duration(minutes: 15),
    ),
    '/api/v1/auth/2fa/verify': const RateLimitRule(
      maxRequests: 5,
      window: Duration(minutes: 15),
    ),
  };

  /// Creates a middleware that applies rate limiting.
  Middleware get middleware {
    return (Handler innerHandler) {
      return (Request request) async {
        // Skip rate limiting for OPTIONS requests
        if (request.method == 'OPTIONS') {
          return innerHandler(request);
        }

        final ip = _getClientIp(request);
        final path = '/${request.url.path}';
        final rule = _getRule(path);
        final key = '$ip:$path';

        if (!_isAllowed(key, rule)) {
          _log.warning('Rate limit exceeded for $ip on $path');
          return rateLimitResponse(
            'Too many requests. Please try again later.',
          );
        }

        _recordRequest(key);
        return innerHandler(request);
      };
    };
  }

  /// Gets the client IP from the request.
  String _getClientIp(Request request) {
    // Check for proxy headers first
    return request.headers['x-forwarded-for']?.split(',').first.trim() ??
        request.headers['x-real-ip'] ??
        'unknown';
  }

  /// Finds the most specific rate limit rule for a path.
  RateLimitRule _getRule(String path) {
    // Exact match first
    if (_rules.containsKey(path)) {
      return _rules[path]!;
    }

    // Prefix match (find most specific)
    String? bestMatch;
    for (final pattern in _rules.keys) {
      if (path.startsWith(pattern)) {
        if (bestMatch == null || pattern.length > bestMatch.length) {
          bestMatch = pattern;
        }
      }
    }

    if (bestMatch != null) {
      return _rules[bestMatch]!;
    }

    return _defaultRule;
  }

  /// Checks whether the given key is within its rate limit.
  bool _isAllowed(String key, RateLimitRule rule) {
    final now = DateTime.now();
    final records = _requests[key];

    if (records == null || records.isEmpty) {
      return true;
    }

    // Count requests within the sliding window
    final windowStart = now.subtract(rule.window);
    final recentRequests = records
        .where((r) => r.timestamp.isAfter(windowStart))
        .length;

    return recentRequests < rule.maxRequests;
  }

  /// Records a new request for the given key.
  void _recordRequest(String key) {
    _requests.putIfAbsent(key, () => []);
    _requests[key]!.add(_RequestRecord(DateTime.now()));
  }

  /// Cleans up expired request records to prevent memory growth.
  void _cleanup() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _requests.entries) {
      // Remove all records older than the maximum possible window (15 min)
      entry.value.removeWhere(
        (r) => now.difference(r.timestamp) > const Duration(minutes: 15),
      );

      if (entry.value.isEmpty) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _requests.remove(key);
    }
  }

  /// Disposes the rate limiter and its cleanup timer.
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _requests.clear();
  }
}
