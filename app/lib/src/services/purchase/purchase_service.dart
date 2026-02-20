import 'dart:async';
import 'dart:developer';

import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:studio_pair/src/services/api/entitlements_api.dart';

/// Product IDs configured in Google Play Console and App Store Connect.
const kMonthlyProductId = 'studio_pair_premium_monthly';
const kYearlyProductId = 'studio_pair_premium_yearly';

const _productIds = <String>{kMonthlyProductId, kYearlyProductId};

/// Status of a purchase operation.
enum PurchaseStatus { idle, pending, purchased, restored, error }

/// Service wrapping the `in_app_purchase` plugin.
///
/// Connects to the store, loads available products, listens to purchases,
/// and sends receipts to the backend for verification.
class PurchaseService {
  PurchaseService({required EntitlementsApi entitlementsApi})
    : _entitlementsApi = entitlementsApi;

  final EntitlementsApi _entitlementsApi;
  final iap.InAppPurchase _iap = iap.InAppPurchase.instance;

  StreamSubscription<List<iap.PurchaseDetails>>? _subscription;
  final _statusController = StreamController<PurchaseStatus>.broadcast();

  /// Stream of purchase status changes.
  Stream<PurchaseStatus> get statusStream => _statusController.stream;

  /// Whether the store is available on this device.
  bool isAvailable = false;

  /// Products loaded from the store.
  List<iap.ProductDetails> products = [];

  /// The space ID to associate purchases with.
  String? _activeSpaceId;

  /// Initializes the purchase service: checks store availability, loads
  /// products, and starts listening to the purchase stream.
  Future<void> initialize() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      log('Store is not available', name: 'PurchaseService');
      return;
    }

    // Load products
    final response = await _iap.queryProductDetails(_productIds);
    if (response.error != null) {
      log(
        'Error loading products: ${response.error!.message}',
        name: 'PurchaseService',
      );
    }
    products = response.productDetails;

    // Listen to purchase updates (must be set up before restoring)
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) {
        log('Purchase stream error: $error', name: 'PurchaseService');
        _statusController.add(PurchaseStatus.error);
      },
    );
  }

  /// Initiates a purchase for the given product and space.
  Future<void> purchasePremium({
    required String productId,
    required String spaceId,
  }) async {
    if (!isAvailable) {
      _statusController.add(PurchaseStatus.error);
      throw Exception('Store is not available');
    }

    _activeSpaceId = spaceId;
    _statusController.add(PurchaseStatus.pending);

    final product = products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product $productId not found'),
    );

    final purchaseParam = iap.PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Restores previous purchases (e.g. on a new device or reinstall).
  Future<void> restorePurchases() async {
    _statusController.add(PurchaseStatus.pending);
    await _iap.restorePurchases();
  }

  /// Handles incoming purchase updates from the store.
  Future<void> _onPurchaseUpdate(List<iap.PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case iap.PurchaseStatus.purchased:
        case iap.PurchaseStatus.restored:
          await _verifyAndComplete(purchase);
        case iap.PurchaseStatus.pending:
          _statusController.add(PurchaseStatus.pending);
        case iap.PurchaseStatus.error:
          log(
            'Purchase error: ${purchase.error?.message}',
            name: 'PurchaseService',
          );
          _statusController.add(PurchaseStatus.error);
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
        case iap.PurchaseStatus.canceled:
          _statusController.add(PurchaseStatus.idle);
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
      }
    }
  }

  /// Sends the receipt to the backend for verification, then completes the
  /// purchase with the store.
  Future<void> _verifyAndComplete(iap.PurchaseDetails purchase) async {
    final spaceId = _activeSpaceId;
    if (spaceId == null) {
      log('No active space ID for verification', name: 'PurchaseService');
      _statusController.add(PurchaseStatus.error);
      return;
    }

    try {
      final platform = purchase.verificationData.source;
      final receipt = purchase.verificationData.serverVerificationData;

      await _entitlementsApi.verifyReceipt(
        spaceId,
        receipt: receipt,
        platform: platform,
        productId: purchase.productID,
      );

      final status = purchase.status == iap.PurchaseStatus.restored
          ? PurchaseStatus.restored
          : PurchaseStatus.purchased;
      _statusController.add(status);

      // Complete the purchase only after backend confirms verification
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    } catch (e) {
      log('Receipt verification failed: $e', name: 'PurchaseService');
      _statusController.add(PurchaseStatus.error);
      // Do not call completePurchase on failure — let the user retry
    }
  }

  /// Releases resources.
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}
