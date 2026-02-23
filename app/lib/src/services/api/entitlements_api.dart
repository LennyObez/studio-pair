import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Entitlements and subscription API service.
class EntitlementsApi {
  EntitlementsApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Get the entitlement summary (tier, limits, usage) for a space.
  Future<Response> getEntitlementSummary(String spaceId) {
    return _client.get('/spaces/$spaceId/entitlements/');
  }

  /// Verify a purchase receipt with the backend.
  Future<Response> verifyReceipt(
    String spaceId, {
    required String receipt,
    required String platform,
    required String productId,
  }) {
    return _client.post(
      '/spaces/$spaceId/entitlements/subscriptions/verify',
      data: {'receipt': receipt, 'platform': platform, 'product_id': productId},
    );
  }

  /// Get the current subscription status for a space.
  Future<Response> getSubscriptionStatus(String spaceId) {
    return _client.get('/spaces/$spaceId/entitlements/subscriptions/status');
  }

  /// Cancel the active subscription for a space.
  Future<Response> cancelSubscription(String spaceId) {
    return _client.post('/spaces/$spaceId/entitlements/subscriptions/cancel');
  }
}
