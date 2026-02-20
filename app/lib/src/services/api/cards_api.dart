import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Cards API service for managing debit, credit, and loyalty cards.
class CardsApi {
  CardsApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Create a new card.
  Future<Response> createCard({
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
  }) {
    return _client.post(
      '/cards/',
      data: {
        'card_type': cardType,
        'display_name': displayName,
        if (provider != null) 'provider': provider,
        if (lastFour != null) 'last_four': lastFour,
        if (expiryMonth != null) 'expiry_month': expiryMonth,
        if (expiryYear != null) 'expiry_year': expiryYear,
        if (cardColor != null) 'card_color': cardColor,
        if (loyaltyNumber != null) 'loyalty_number': loyaltyNumber,
        if (loyaltyCustomerName != null)
          'loyalty_customer_name': loyaltyCustomerName,
        if (loyaltyBarcodeData != null)
          'loyalty_barcode_data': loyaltyBarcodeData,
        if (loyaltyStoreName != null) 'loyalty_store_name': loyaltyStoreName,
      },
    );
  }

  /// List all cards for the current user.
  Future<Response> listCards() {
    return _client.get('/cards/');
  }

  /// Get a specific card by ID.
  Future<Response> getCard(String cardId) {
    return _client.get('/cards/$cardId');
  }

  /// Update a card.
  Future<Response> updateCard(String cardId, Map<String, dynamic> data) {
    return _client.patch('/cards/$cardId', data: data);
  }

  /// Delete a card.
  Future<Response> deleteCard(String cardId) {
    return _client.delete('/cards/$cardId');
  }

  /// Share a card with a space or specific users.
  Future<Response> shareCard(
    String cardId, {
    String? spaceId,
    List<String>? userIds,
  }) {
    return _client.post(
      '/cards/$cardId/share',
      data: {
        if (spaceId != null) 'space_id': spaceId,
        if (userIds != null) 'user_ids': userIds,
      },
    );
  }

  /// Remove a card share.
  Future<Response> unshareCard(String cardId, String shareId) {
    return _client.delete('/cards/$cardId/share/$shareId');
  }

  /// Set a private display name for a card.
  Future<Response> setPrivateName(String cardId, String privateName) {
    return _client.post(
      '/cards/$cardId/private-name',
      data: {'private_name': privateName},
    );
  }
}
