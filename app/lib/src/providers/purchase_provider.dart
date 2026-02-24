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
    this.availableProducts = const [],
    this.activeSubscription,
    this.entitlementSummary,
  });

  /// Current subscription tier ('free' or 'premium').
  final String tier;

  /// Products available for purchase from the store.
  final List<iap.ProductDetails> availableProducts;

  /// Active subscription details from the backend, if any.
  final Map<String, dynamic>? activeSubscription;

  /// Full entitlement summary from the backend.
  final Map<String, dynamic>? entitlementSummary;

  bool get isPremium => tier == 'premium';

  PurchaseState copyWith({
    String? tier,
    List<iap.ProductDetails>? availableProducts,
    Map<String, dynamic>? activeSubscription,
    Map<String, dynamic>? entitlementSummary,
    bool clearSubscription = false,
  }) {
    return PurchaseState(
      tier: tier ?? this.tier,
      availableProducts: availableProducts ?? this.availableProducts,
      activeSubscription: clearSubscription
          ? null
          : (activeSubscription ?? this.activeSubscription),
      entitlementSummary: entitlementSummary ?? this.entitlementSummary,
    );
  }
}

/// Notifier managing purchase state and entitlement data.
class PurchaseNotifier extends AsyncNotifier<PurchaseState> {
  EntitlementsApi get _api => ref.read(entitlementsApiProvider);
  PurchaseService get _purchaseService => ref.read(purchaseServiceProvider);

  StreamSubscription<PurchaseStatus>? _statusSubscription;

  @override
  Future<PurchaseState> build() async {
    final purchaseService = ref.watch(purchaseServiceProvider);

    _statusSubscription = purchaseService.statusStream.listen(_onStatusChange);

    ref.onDispose(() {
      _statusSubscription?.cancel();
    });

    return const PurchaseState();
  }

  /// Initialize the purchase service and load products.
  Future<void> initialize() async {
    await _purchaseService.initialize();
    final currentData = state.valueOrNull ?? const PurchaseState();
    state = AsyncData(
      currentData.copyWith(availableProducts: _purchaseService.products),
    );
  }

  /// Load entitlement and subscription data from the backend.
  Future<void> loadEntitlements(String spaceId) async {
    final previousData = state.valueOrNull ?? const PurchaseState();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _api.getEntitlementSummary(spaceId);
      final data = response.data as Map<String, dynamic>;
      final summary = data['data'] as Map<String, dynamic>? ?? data;

      var updatedData = previousData.copyWith(
        tier: summary['tier'] as String? ?? 'free',
        entitlementSummary: summary,
      );

      // Also load subscription status
      try {
        final subResponse = await _api.getSubscriptionStatus(spaceId);
        final subData = subResponse.data as Map<String, dynamic>;
        final subscription = subData['data'] as Map<String, dynamic>?;
        updatedData = updatedData.copyWith(activeSubscription: subscription);
      } catch (_) {
        // No active subscription is fine
      }

      return updatedData;
    });
  }

  /// Initiate a purchase for the given product and space.
  Future<void> purchase(String productId, String spaceId) async {
    final previousData = state.valueOrNull ?? const PurchaseState();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _purchaseService.purchasePremium(
        productId: productId,
        spaceId: spaceId,
      );
      return previousData;
    });
  }

  /// Restore previous purchases.
  Future<void> restore() async {
    final previousData = state.valueOrNull ?? const PurchaseState();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _purchaseService.restorePurchases();
      return previousData;
    });
  }

  /// Cancel the active subscription via the backend.
  Future<void> cancel(String spaceId) async {
    final previousData = state.valueOrNull ?? const PurchaseState();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _api.cancelSubscription(spaceId);
      final cleared = previousData.copyWith(clearSubscription: true);
      return cleared;
    });

    // Reload entitlements to reflect the change
    if (!state.hasError) {
      await loadEntitlements(spaceId);
    }
  }

  void _onStatusChange(PurchaseStatus status) {
    final currentData = state.valueOrNull ?? const PurchaseState();
    switch (status) {
      case PurchaseStatus.purchased:
        state = AsyncData(currentData.copyWith(tier: 'premium'));
      case PurchaseStatus.restored:
        state = AsyncData(currentData.copyWith(tier: 'premium'));
      case PurchaseStatus.error:
        state = AsyncError(
          'Purchase failed. Please try again.',
          StackTrace.current,
        );
      case PurchaseStatus.pending:
        state = const AsyncLoading();
      case PurchaseStatus.idle:
        state = AsyncData(currentData);
    }
  }
}
