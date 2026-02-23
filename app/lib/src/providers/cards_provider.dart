import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/cards_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/cards_dao.dart';

/// Card item model (debit, credit, or loyalty card).
class CardItem {
  const CardItem({
    required this.id,
    required this.cardType,
    required this.displayName,
    this.provider,
    this.lastFour,
    this.expiryMonth,
    this.expiryYear,
    this.cardColor,
    this.loyaltyNumber,
    this.loyaltyStoreName,
    this.isShared = false,
  });

  factory CardItem.fromJson(Map<String, dynamic> json) {
    return CardItem(
      id: json['id'],
      cardType: json['card_type'],
      displayName: json['display_name'],
      provider: json['provider'],
      lastFour: json['last_four'],
      expiryMonth: json['expiry_month'],
      expiryYear: json['expiry_year'],
      cardColor: json['card_color'],
      loyaltyNumber: json['loyalty_number'],
      loyaltyStoreName: json['loyalty_store_name'],
      isShared: json['is_shared'] ?? false,
    );
  }

  final String id;

  /// Card type: 'debit', 'credit', or 'loyalty'.
  final String cardType;
  final String displayName;

  /// Card network provider: 'Visa', 'Mastercard', etc.
  final String? provider;
  final String? lastFour;
  final int? expiryMonth;
  final int? expiryYear;
  final String? cardColor;
  final String? loyaltyNumber;
  final String? loyaltyStoreName;
  final bool isShared;
}

/// Cards state.
class CardsState {
  const CardsState({
    this.cards = const [],
    this.selectedType,
    this.isLoading = false,
    this.isCached = false,
    this.error,
  });

  final List<CardItem> cards;

  /// Filter by card type: 'debit', 'credit', 'loyalty', or null for all.
  final String? selectedType;
  final bool isLoading;
  final bool isCached;
  final String? error;

  CardsState copyWith({
    List<CardItem>? cards,
    String? selectedType,
    bool? isLoading,
    bool? isCached,
    String? error,
    bool clearError = false,
    bool clearSelectedType = false,
  }) {
    return CardsState(
      cards: cards ?? this.cards,
      selectedType: clearSelectedType
          ? null
          : (selectedType ?? this.selectedType),
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Cards state notifier managing payment and loyalty cards.
class CardsNotifier extends StateNotifier<CardsState> {
  CardsNotifier(this._api, this._dao) : super(const CardsState());

  final CardsApi _api;
  final CardsDao _dao;

  /// Load all cards.
  Future<void> loadCards({String? spaceId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // 1. Load from cache first
    if (spaceId != null) {
      try {
        final cached = await _dao.getCards(spaceId).first;
        if (cached.isNotEmpty) {
          final cards = cached
              .map(
                (c) => CardItem(
                  id: c.id,
                  cardType: c.type,
                  displayName: c.holderName,
                  provider: c.provider,
                  lastFour: c.lastFourDigits,
                  loyaltyNumber: c.loyaltyNumber,
                  loyaltyStoreName: c.storeName,
                ),
              )
              .toList();
          state = state.copyWith(
            cards: cards,
            isLoading: false,
            isCached: true,
          );
        }
      } catch (_) {
        // Cache read failed, continue to API
      }
    }

    // 2. Try API in background
    try {
      final response = await _api.listCards();
      final items = parseList(response.data);
      final cards = items.map(CardItem.fromJson).toList();

      // Upsert into cache
      if (spaceId != null) {
        for (final item in cards) {
          await _dao.upsertCard(
            CachedCardsCompanion(
              id: Value(item.id),
              spaceId: Value(spaceId),
              createdBy: const Value(''),
              type: Value(item.cardType),
              holderName: Value(item.displayName),
              lastFourDigits: Value(item.lastFour),
              provider: Value(item.provider),
              expiryDate: Value(
                item.expiryMonth != null && item.expiryYear != null
                    ? '${item.expiryMonth}/${item.expiryYear}'
                    : null,
              ),
              storeName: Value(item.loyaltyStoreName),
              loyaltyNumber: Value(item.loyaltyNumber),
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
              syncedAt: Value(DateTime.now()),
            ),
          );
        }
      }

      state = state.copyWith(cards: cards, isLoading: false, isCached: false);
    } catch (e) {
      if (state.cards.isEmpty) {
        state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Create a new card.
  Future<bool> createCard({
    required String cardType,
    required String displayName,
    String? provider,
    String? lastFour,
    int? expiryMonth,
    int? expiryYear,
    String? cardColor,
    String? loyaltyNumber,
    String? loyaltyStoreName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.createCard(
        cardType: cardType,
        displayName: displayName,
        provider: provider,
        lastFour: lastFour,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cardColor: cardColor,
        loyaltyNumber: loyaltyNumber,
        loyaltyStoreName: loyaltyStoreName,
      );

      final newCard = CardItem.fromJson(response.data as Map<String, dynamic>);

      state = state.copyWith(
        cards: [...state.cards, newCard],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Update an existing card.
  Future<bool> updateCard(String cardId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.updateCard(cardId, data);
      final updated = CardItem.fromJson(response.data as Map<String, dynamic>);

      final updatedCards = state.cards.map((card) {
        if (card.id == cardId) {
          return updated;
        }
        return card;
      }).toList();

      state = state.copyWith(cards: updatedCards, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Delete a card.
  Future<bool> deleteCard(String cardId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.deleteCard(cardId);

      state = state.copyWith(
        cards: state.cards.where((c) => c.id != cardId).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Share a card with a space or specific users.
  Future<bool> shareCard(
    String cardId, {
    String? spaceId,
    List<String>? userIds,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.shareCard(cardId, spaceId: spaceId, userIds: userIds);

      // Reload cards to get updated share status
      await loadCards();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Set the card type filter.
  void setTypeFilter(String? type) {
    if (type == null) {
      state = state.copyWith(clearSelectedType: true);
    } else {
      state = state.copyWith(selectedType: type);
    }
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Cards state provider.
final cardsProvider = StateNotifierProvider<CardsNotifier, CardsState>((ref) {
  return CardsNotifier(
    ref.watch(cardsApiProvider),
    ref.watch(cardsDaoProvider),
  );
});

/// Convenience provider for the filtered list of cards.
final cardListProvider = Provider<List<CardItem>>((ref) {
  final cardsState = ref.watch(cardsProvider);
  if (cardsState.selectedType == null) {
    return cardsState.cards;
  }
  return cardsState.cards
      .where((c) => c.cardType == cardsState.selectedType)
      .toList();
});

/// Convenience provider for payment cards only (debit + credit).
final paymentCardsProvider = Provider<List<CardItem>>((ref) {
  return ref
      .watch(cardsProvider)
      .cards
      .where((c) => c.cardType == 'debit' || c.cardType == 'credit')
      .toList();
});

/// Convenience provider for loyalty cards only.
final loyaltyCardsProvider = Provider<List<CardItem>>((ref) {
  return ref
      .watch(cardsProvider)
      .cards
      .where((c) => c.cardType == 'loyalty')
      .toList();
});
