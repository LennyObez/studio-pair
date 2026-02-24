import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../services/entitlement_service.dart';
import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'entitlements_repository.dart';
import 'entitlements_service.dart';

/// Controller for entitlement and subscription endpoints.
class EntitlementsController {
  final EntitlementsRepository _repo;
  final EntitlementsSubscriptionService _subscriptionService;
  final EntitlementService _entitlementService;
  final Logger _log = Logger('EntitlementsController');

  EntitlementsController(
    this._repo,
    this._subscriptionService,
    this._entitlementService,
  );

  /// Returns the router with all entitlement routes (space-scoped).
  Router get router {
    final router = Router();

    // Entitlement summary
    router.get('/', _getEntitlementSummary);

    // Subscription management
    router.get('/subscriptions/status', _getSubscriptionStatus);
    router.post('/subscriptions/verify', _verifyReceipt);
    router.post('/subscriptions/cancel', _cancelSubscription);

    return router;
  }

  /// Returns a router for public webhook endpoints (no auth required).
  Router get webhookRouter {
    final router = Router();

    router.post('/google-play', _handleGooglePlayWebhook);
    router.post('/app-store', _handleAppStoreWebhook);

    return router;
  }

  /// GET /api/v1/spaces/<spaceId>/entitlements/
  ///
  /// Returns the entitlement summary including tier, limits, and usage.
  Future<Response> _getEntitlementSummary(Request request) async {
    try {
      final spaceId = getSpaceId(request);

      final summary = await _entitlementService.getEntitlementSummary(spaceId);
      return jsonResponse({'data': summary});
    } catch (e, stackTrace) {
      _log.severe('Get entitlement summary error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/entitlements/subscriptions/status
  ///
  /// Returns the current subscription record for the space.
  Future<Response> _getSubscriptionStatus(Request request) async {
    try {
      final spaceId = getSpaceId(request);

      final subscription = await _repo.getActiveSubscription(spaceId);
      if (subscription == null) {
        return jsonResponse({
          'data': {'status': 'none', 'tier': 'free'},
        });
      }

      return jsonResponse({'data': subscription});
    } catch (e, stackTrace) {
      _log.severe('Get subscription status error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/entitlements/subscriptions/verify
  ///
  /// Verifies a purchase receipt from the client and activates the
  /// subscription.
  ///
  /// Body: { "receipt": "...", "platform": "google_play|app_store",
  ///         "product_id": "..." }
  Future<Response> _verifyReceipt(Request request) async {
    try {
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final receipt = body['receipt'] as String?;
      final platform = body['platform'] as String?;
      final productId = body['product_id'] as String?;

      if (receipt == null || receipt.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'receipt', 'message': 'Receipt is required'},
          ],
        );
      }

      if (platform == null ||
          !{'google_play', 'app_store'}.contains(platform)) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {
              'field': 'platform',
              'message':
                  'Platform is required and must be "google_play" or "app_store"',
            },
          ],
        );
      }

      if (productId == null || productId.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'product_id', 'message': 'Product ID is required'},
          ],
        );
      }

      final subscription = await _subscriptionService.verifyReceipt(
        spaceId: spaceId,
        receipt: receipt,
        platform: platform,
        productId: productId,
      );

      return createdResponse({'data': subscription});
    } on EntitlementException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Verify receipt error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/entitlements/subscriptions/cancel
  ///
  /// Cancels the active subscription. It remains active until the current
  /// billing period ends.
  Future<Response> _cancelSubscription(Request request) async {
    try {
      final spaceId = getSpaceId(request);

      await _subscriptionService.cancelSubscription(spaceId);

      return jsonResponse({
        'data': {
          'message':
              'Subscription canceled. '
              'Premium benefits remain until the end of your billing period.',
        },
      });
    } on EntitlementException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Cancel subscription error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/webhooks/google-play
  ///
  /// Handles Google Play Real-Time Developer Notifications.
  Future<Response> _handleGooglePlayWebhook(Request request) async {
    try {
      final body = await readJsonBody(request);

      await _subscriptionService.handleGooglePlayNotification(body);

      return jsonResponse({'status': 'ok'});
    } catch (e, stackTrace) {
      _log.severe('Google Play webhook error', e, stackTrace);
      // Always return 200 to acknowledge receipt
      return jsonResponse({'status': 'error'});
    }
  }

  /// POST /api/v1/webhooks/app-store
  ///
  /// Handles App Store Server Notification v2.
  Future<Response> _handleAppStoreWebhook(Request request) async {
    try {
      final body = await readJsonBody(request);

      await _subscriptionService.handleAppStoreNotification(body);

      return jsonResponse({'status': 'ok'});
    } catch (e, stackTrace) {
      _log.severe('App Store webhook error', e, stackTrace);
      // Always return 200 to acknowledge receipt
      return jsonResponse({'status': 'error'});
    }
  }
}
