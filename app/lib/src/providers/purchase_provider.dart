import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/entitlements_api.dart';
import 'package:studio_pair/src/services/purchase/purchase_service.dart';

/// State for the purchase/entitlements provider.
class PurchaseState {
  const PurchaseState({
    this.tier = 'free',
    this.isLoading = false,
    this.error,
    this.availableProducts = const [],
    this.activeSubscription,
    this.entitlementSummary,
  });

  /// Current subscription tier ('free' or 'premium').
  final String tier;

  /// Whether a purchase or load operation is in progress.
  final bool isLoading;

  /// Last error message, if any.
  final String? error;

  /// Products available for purchase from the store.
  final List<iap.ProductDetails> availableProducts;

  /// Active subscription details from the backend, if any.
  final Map<String, dynamic>? activeSubscription;

  /// Full entitlement summary from the backend.
  final Map<String, dynamic>? entitlementSummary;

  bool get isPremium => tier == 'premium';

  PurchaseState copyWith({
    String? tier,
    bool? isLoading,
    String? error,
    List<iap.ProductDetails>? availableProducts,
    Map<String, dynamic>? activeSubscription,
    Map<String, dynamic>? entitlementSummary,
    bool clearError = false,
    bool clearSubscription = false,
  }) {
    return PurchaseState(
      tier: tier ?? this.tier,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      availableProducts: availableProducts ?? this.availableProducts,
      activeSubscription: clearSubscription
          ? null
          : (activeSubscription ?? this.activeSubscription),
      entitlementSummary: entitlementSummary ?? this.entitlementSummary,
    );
  }
}

/// Notifier managing purchase state and entitlement data.
class PurchaseNotifier extends StateNotifier<PurchaseState> {
  PurchaseNotifier({
    required EntitlementsApi entitlementsApi,
    required PurchaseService purchaseService,
  }) : _api = entitlementsApi,
       _purchaseService = purchaseService,
       super(const PurchaseState()) {
    _statusSubscription = _purchaseService.statusStream.listen(_onStatusChange);
  }

  final EntitlementsApi _api;
  final PurchaseService _purchaseService;
  StreamSubscription<PurchaseStatus>? _statusSubscription;

  /// Initialize the purchase service and load products.
  Future<void> initialize() async {
    await _purchaseService.initialize();
    state = state.copyWith(availableProducts: _purchaseService.products);
  }

  /// Load entitlement and subscription data from the backend.
  Future<void> loadEntitlements(String spaceId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.getEntitlementSummary(spaceId);
      final data = response.data as Map<String, dynamic>;
      final summary = data['data'] as Map<String, dynamic>? ?? data;

      state = state.copyWith(
        tier: summary['tier'] as String? ?? 'free',
        entitlementSummary: summary,
        isLoading: false,
      );

      // Also load subscription status
      try {
        final subResponse = await _api.getSubscriptionStatus(spaceId);
        final subData = subResponse.data as Map<String, dynamic>;
        final subscription = subData['data'] as Map<String, dynamic>?;
        state = state.copyWith(activeSubscription: subscription);
      } catch (_) {
        // No active subscription is fine
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  /// Initiate a purchase for the given product and space.
  Future<void> purchase(String productId, String spaceId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _purchaseService.purchasePremium(
        productId: productId,
        spaceId: spaceId,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  /// Restore previous purchases.
  Future<void> restore() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _purchaseService.restorePurchases();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  /// Cancel the active subscription via the backend.
  Future<void> cancel(String spaceId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.cancelSubscription(spaceId);
      state = state.copyWith(isLoading: false, clearSubscription: true);
      // Reload entitlements to reflect the change
      await loadEntitlements(spaceId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  void _onStatusChange(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.purchased:
        state = state.copyWith(tier: 'premium', isLoading: false);
      case PurchaseStatus.restored:
        state = state.copyWith(tier: 'premium', isLoading: false);
      case PurchaseStatus.error:
        state = state.copyWith(
          isLoading: false,
          error: 'Purchase failed. Please try again.',
        );
      case PurchaseStatus.pending:
        state = state.copyWith(isLoading: true);
      case PurchaseStatus.idle:
        state = state.copyWith(isLoading: false);
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _purchaseService.dispose();
    super.dispose();
  }
}
