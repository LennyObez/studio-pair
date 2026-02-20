import 'package:drift/drift.dart';
import 'package:studio_pair/src/services/api/cards_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/cards_dao.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Repository that wraps the Cards API and DAO to provide an
/// offline-first data layer with batch cache upserts.
class CardsRepository {
  CardsRepository(this._api, this._dao);

  final CardsApi _api;
  final CardsDao _dao;

  /// Returns cached cards, then fetches fresh from API and updates cache.
  /// Note: The API is user-scoped, but the DAO stores by spaceId.
  Future<List<CachedCard>> getCards(String spaceId, {String? type}) async {
    try {
      final response = await _api.listCards();
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedCards,
          jsonList
              .map(
                (json) => CachedCardsCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  createdBy: json['created_by'] as String? ?? '',
                  type:
                      json['card_type'] as String? ??
                      json['type'] as String? ??
                      '',
                  holderName:
                      json['display_name'] as String? ??
                      json['holder_name'] as String? ??
                      '',
                  lastFourDigits: Value(json['last_four'] as String?),
                  provider: Value(json['provider'] as String?),
                  expiryDate: Value(json['expiry_date'] as String?),
                  storeName: Value(json['loyalty_store_name'] as String?),
                  loyaltyNumber: Value(json['loyalty_number'] as String?),
                  encryptedData: Value(json['encrypted_data'] as String?),
                  createdAt:
                      DateTime.tryParse(json['created_at'] as String? ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(json['updated_at'] as String? ?? '') ??
                      DateTime.now(),
                  syncedAt: DateTime.now(),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
      return _dao.getCards(spaceId, type: type).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getCards(spaceId, type: type).first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load cards: $e');
    }
  }

  /// Creates a new card via the API.
  Future<Map<String, dynamic>> createCard({
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
        loyaltyCustomerName: loyaltyCustomerName,
        loyaltyBarcodeData: loyaltyBarcodeData,
        loyaltyStoreName: loyaltyStoreName,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to create card: $e');
    }
  }

  /// Gets a specific card by ID, with cache fallback.
  Future<Map<String, dynamic>> getCard(String cardId) async {
    try {
      final response = await _api.getCard(cardId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getCardById(cardId);
      if (cached != null) {
        return {'id': cached.id, 'holder_name': cached.holderName};
      }
      throw UnknownFailure('Failed to get card: $e');
    }
  }

  /// Updates a card via the API.
  Future<Map<String, dynamic>> updateCard(
    String cardId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _api.updateCard(cardId, data);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update card: $e');
    }
  }

  /// Deletes a card via the API and removes from cache.
  Future<void> deleteCard(String cardId) async {
    try {
      await _api.deleteCard(cardId);
      await _dao.deleteCard(cardId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete card: $e');
    }
  }

  /// Shares a card with a space or specific users.
  Future<Map<String, dynamic>> shareCard(
    String cardId, {
    String? spaceId,
    List<String>? userIds,
  }) async {
    try {
      final response = await _api.shareCard(
        cardId,
        spaceId: spaceId,
        userIds: userIds,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to share card: $e');
    }
  }

  /// Removes a card share.
  Future<void> unshareCard(String cardId, String shareId) async {
    try {
      await _api.unshareCard(cardId, shareId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to unshare card: $e');
    }
  }

  /// Sets a private display name for a card.
  Future<Map<String, dynamic>> setPrivateName(
    String cardId,
    String privateName,
  ) async {
    try {
      final response = await _api.setPrivateName(cardId, privateName);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to set private name: $e');
    }
  }

  /// Watches cached cards for a space (reactive stream).
  Stream<List<CachedCard>> watchCards(String spaceId, {String? type}) {
    return _dao.getCards(spaceId, type: type);
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
