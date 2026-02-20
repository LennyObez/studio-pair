import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';

// ── Filter state providers ──────────────────────────────────────────────

/// Filter by card type: 'debit', 'credit', 'loyalty', or null for all.
final cardTypeFilter = StateProvider<String?>((ref) => null);

// ── Async notifier ──────────────────────────────────────────────────────

/// Cards notifier backed by the [CardsRepository].
///
/// The [build] method fetches cards from the repository (API + cache)
/// whenever the current space changes.
class CardsNotifier extends AutoDisposeAsyncNotifier<List<CachedCard>> {
  @override
  Future<List<CachedCard>> build() async {
    final repo = ref.watch(cardsRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    if (spaceId == null) return [];
    return repo.getCards(spaceId);
  }

  /// Create a new card and refresh the list.
  Future<bool> createCard({
    required String cardType,
    required String displayName,
    String? provider,
    String? lastFour,
    int? expiryMonth,
    int? expiryYear,
    String? cardColor,
    String? loyaltyNumber,
    String? loyaltyCustomerName,
    String? loyaltyBarcodeData,
    String? loyaltyStoreName,
  }) async {
    final repo = ref.read(cardsRepositoryProvider);
    final spaceId = ref.read(currentSpaceProvider)?.id;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.createCard(
        cardType: cardType,
        displayName: displayName,
        provider: provider,
        lastFour: lastFour,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cardColor: cardColor,
        loyaltyNumber: loyaltyNumber,
        loyaltyCustomerName: loyaltyCustomerName,
        loyaltyBarcodeData: loyaltyBarcodeData,
        loyaltyStoreName: loyaltyStoreName,
      );
      if (spaceId == null) return <CachedCard>[];
      return repo.getCards(spaceId);
    });
    return !state.hasError;
  }

  /// Update a card and refresh the list.
  Future<bool> updateCard(String cardId, Map<String, dynamic> data) async {
    final repo = ref.read(cardsRepositoryProvider);
    final spaceId = ref.read(currentSpaceProvider)?.id;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.updateCard(cardId, data);
      if (spaceId == null) return <CachedCard>[];
      return repo.getCards(spaceId);
    });
    return !state.hasError;
  }

  /// Delete a card and refresh the list.
  Future<bool> deleteCard(String cardId) async {
    final repo = ref.read(cardsRepositoryProvider);
    final spaceId = ref.read(currentSpaceProvider)?.id;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteCard(cardId);
      if (spaceId == null) return <CachedCard>[];
      return repo.getCards(spaceId);
    });
    return !state.hasError;
  }

  /// Share a card and refresh the list.
  Future<bool> shareCard(
    String cardId, {
    String? spaceId,
    List<String>? userIds,
  }) async {
    final repo = ref.read(cardsRepositoryProvider);
    final currentSpaceId = ref.read(currentSpaceProvider)?.id;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.shareCard(cardId, spaceId: spaceId, userIds: userIds);
      if (currentSpaceId == null) return <CachedCard>[];
      return repo.getCards(currentSpaceId);
    });
    return !state.hasError;
  }
}

/// Cards async provider.
final cardsProvider =
    AsyncNotifierProvider.autoDispose<CardsNotifier, List<CachedCard>>(
      CardsNotifier.new,
    );

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for the filtered list of cards.
final cardListProvider = Provider<List<CachedCard>>((ref) {
  final cards = ref.watch(cardsProvider).valueOrNull ?? [];
  final typeFilter = ref.watch(cardTypeFilter);
  if (typeFilter == null) return cards;
  return cards.where((c) => c.type == typeFilter).toList();
});

/// Convenience provider for payment cards only (debit + credit).
final paymentCardsProvider = Provider<List<CachedCard>>((ref) {
  final cards = ref.watch(cardsProvider).valueOrNull ?? [];
  return cards.where((c) => c.type == 'debit' || c.type == 'credit').toList();
});

/// Convenience provider for loyalty cards only.
final loyaltyCardsProvider = Provider<List<CachedCard>>((ref) {
  final cards = ref.watch(cardsProvider).valueOrNull ?? [];
  return cards.where((c) => c.type == 'loyalty').toList();
});
