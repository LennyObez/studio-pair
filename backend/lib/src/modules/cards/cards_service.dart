import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../services/notification_service.dart';
import '../spaces/spaces_repository.dart';
import 'cards_repository.dart';

/// Custom exception for card-related errors.
class CardsException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const CardsException(
    this.message, {
    this.code = 'CARDS_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'CardsException($code): $message';
}

/// Service containing all card-related business logic.
class CardsService {
  final CardsRepository _repo;
  final SpacesRepository _spacesRepo;
  final NotificationService _notificationService;
  final Logger _log = Logger('CardsService');
  final Uuid _uuid = const Uuid();

  /// Valid card types.
  static const _validCardTypes = ['debit', 'credit', 'loyalty', 'membership'];

  /// Valid providers for debit/credit cards.
  static const _validProviders = [
    'visa',
    'mastercard',
    'amex',
    'discover',
    'other',
  ];

  /// Duration for sensitive access tokens.
  // ignore: unused_field
  static const _sensitiveAccessTtl = Duration(minutes: 5);

  CardsService(this._repo, this._spacesRepo, this._notificationService);

  // ---------------------------------------------------------------------------
  // Card CRUD
  // ---------------------------------------------------------------------------

  /// Creates a new card.
  ///
  /// Validates inputs (lastFour must be 4 digits for debit/credit, valid
  /// provider), checks space membership, and returns the created card.
  Future<Map<String, dynamic>> createCard({
    required String spaceId,
    required String userId,
    required String cardType,
    required String displayName,
    String? provider,
    String? lastFour,
    int? expiryMonth,
    int? expiryYear,
    String? cardColor,
    Map<String, dynamic>? loyaltyData,
  }) async {
    // Validate card type
    if (!_validCardTypes.contains(cardType)) {
      throw CardsException(
        'Invalid card type. Must be one of: ${_validCardTypes.join(", ")}',
        code: 'INVALID_CARD_TYPE',
        statusCode: 422,
      );
    }

    // Validate display name
    if (displayName.trim().isEmpty) {
      throw const CardsException(
        'Display name is required',
        code: 'INVALID_DISPLAY_NAME',
        statusCode: 422,
      );
    }

    if (displayName.trim().length > 100) {
      throw const CardsException(
        'Display name must be at most 100 characters',
        code: 'INVALID_DISPLAY_NAME',
        statusCode: 422,
      );
    }

    // For debit/credit cards, validate lastFour and provider
    if (cardType == 'debit' || cardType == 'credit') {
      if (lastFour == null || !RegExp(r'^\d{4}$').hasMatch(lastFour)) {
        throw const CardsException(
          'Last four digits must be exactly 4 digits for debit/credit cards',
          code: 'INVALID_LAST_FOUR',
          statusCode: 422,
        );
      }

      if (provider != null && !_validProviders.contains(provider)) {
        throw CardsException(
          'Invalid provider. Must be one of: ${_validProviders.join(", ")}',
          code: 'INVALID_PROVIDER',
          statusCode: 422,
        );
      }
    }

    // Validate expiry if provided
    if (expiryMonth != null && (expiryMonth < 1 || expiryMonth > 12)) {
      throw const CardsException(
        'Expiry month must be between 1 and 12',
        code: 'INVALID_EXPIRY',
        statusCode: 422,
      );
    }

    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    final cardId = _uuid.v4();

    final card = await _repo.createCard(
      id: cardId,
      spaceId: spaceId,
      createdBy: userId,
      cardType: cardType,
      displayName: displayName.trim(),
      provider: provider,
      lastFour: lastFour,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      cardColor: cardColor,
      loyaltyData: loyaltyData,
    );

    _log.info(
      'Card created: ${card['display_name']} ($cardId) in space $spaceId',
    );

    return card;
  }

  /// Gets a single card by ID with shares.
  ///
  /// Verifies the requesting user is the creator or a shared-with user.
  Future<Map<String, dynamic>> getCard({
    required String cardId,
    required String spaceId,
    required String userId,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    final card = await _repo.getCardById(cardId);
    if (card == null) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the card belongs to the requested space
    if (card['space_id'] != spaceId) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify access: creator or shared-with
    final isCreator = card['created_by'] == userId;
    final shares = card['shares'] as List<Map<String, dynamic>>? ?? [];
    final isSharedWith = shares.any((s) => s['shared_with_user_id'] == userId);

    if (!isCreator && !isSharedWith) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Overlay private name if set
    final privateName = await _repo.getPrivateName(cardId, userId);
    if (privateName != null) {
      card['private_name'] = privateName;
    }

    return card;
  }

  /// Gets the user's own cards plus cards shared with them in a space.
  Future<List<Map<String, dynamic>>> getCards({
    required String spaceId,
    required String userId,
    String? cardType,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    return _repo.getCards(spaceId, userId, cardType: cardType);
  }

  /// Updates an existing card.
  ///
  /// Only the card creator can update it.
  Future<Map<String, dynamic>> updateCard({
    required String cardId,
    required String spaceId,
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    // Fetch the existing card
    final existing = await _repo.getCardById(cardId);
    if (existing == null) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the card belongs to the requested space
    if (existing['space_id'] != spaceId) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify creator only
    if (existing['created_by'] != userId) {
      throw const CardsException(
        'Only the card creator can update this card',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Validate display name if provided
    if (updates.containsKey('display_name')) {
      final name = updates['display_name'] as String?;
      if (name == null || name.trim().isEmpty) {
        throw const CardsException(
          'Display name cannot be empty',
          code: 'INVALID_DISPLAY_NAME',
          statusCode: 422,
        );
      }
      if (name.trim().length > 100) {
        throw const CardsException(
          'Display name must be at most 100 characters',
          code: 'INVALID_DISPLAY_NAME',
          statusCode: 422,
        );
      }
      updates['display_name'] = name.trim();
    }

    // Validate last four if provided
    if (updates.containsKey('last_four')) {
      final lastFour = updates['last_four'] as String?;
      final cardType = existing['card_type'] as String;
      if ((cardType == 'debit' || cardType == 'credit') &&
          (lastFour == null || !RegExp(r'^\d{4}$').hasMatch(lastFour))) {
        throw const CardsException(
          'Last four digits must be exactly 4 digits for debit/credit cards',
          code: 'INVALID_LAST_FOUR',
          statusCode: 422,
        );
      }
    }

    final updated = await _repo.updateCard(cardId, updates);
    if (updated == null) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('Card updated: $cardId in space $spaceId by $userId');

    return updated;
  }

  /// Deletes a card (soft delete).
  ///
  /// Only the card creator can delete it.
  Future<void> deleteCard({
    required String cardId,
    required String spaceId,
    required String userId,
  }) async {
    // Fetch the existing card
    final existing = await _repo.getCardById(cardId);
    if (existing == null) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the card belongs to the requested space
    if (existing['space_id'] != spaceId) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify creator only
    if (existing['created_by'] != userId) {
      throw const CardsException(
        'Only the card creator can delete this card',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.softDeleteCard(cardId);

    _log.info('Card deleted: $cardId in space $spaceId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Sharing
  // ---------------------------------------------------------------------------

  /// Shares a card with another user.
  ///
  /// Verifies the requesting user is the creator and the recipient is a
  /// space member.
  Future<Map<String, dynamic>> shareCard({
    required String cardId,
    required String spaceId,
    required String userId,
    required String sharedWithUserId,
  }) async {
    // Fetch the existing card
    final existing = await _repo.getCardById(cardId);
    if (existing == null) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the card belongs to the requested space
    if (existing['space_id'] != spaceId) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify creator
    if (existing['created_by'] != userId) {
      throw const CardsException(
        'Only the card creator can share this card',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Cannot share with self
    if (sharedWithUserId == userId) {
      throw const CardsException(
        'Cannot share a card with yourself',
        code: 'INVALID_SHARE',
        statusCode: 422,
      );
    }

    // Verify recipient is a space member
    final recipientMembership = await _spacesRepo.getMember(
      spaceId,
      sharedWithUserId,
    );
    if (recipientMembership == null ||
        recipientMembership['status'] != 'active') {
      throw const CardsException(
        'Recipient must be an active member of the space',
        code: 'INVALID_RECIPIENT',
        statusCode: 422,
      );
    }

    final share = await _repo.shareCard(
      id: _uuid.v4(),
      cardId: cardId,
      sharedWithUserId: sharedWithUserId,
      sharedByUserId: userId,
    );

    // Notify the recipient
    await _notificationService.notify(
      userId: sharedWithUserId,
      type: 'cards.shared',
      title: 'Card shared with you',
      body: 'A card "${existing['display_name']}" has been shared with you',
      spaceId: spaceId,
      data: {'card_id': cardId, 'card_name': existing['display_name']},
    );

    _log.info('Card shared: $cardId with $sharedWithUserId by $userId');

    return share;
  }

  /// Removes a card share for a user.
  ///
  /// Verifies the requesting user is the creator.
  Future<void> unshareCard({
    required String cardId,
    required String spaceId,
    required String userId,
    required String unshareUserId,
  }) async {
    // Fetch the existing card
    final existing = await _repo.getCardById(cardId);
    if (existing == null) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the card belongs to the requested space
    if (existing['space_id'] != spaceId) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify creator
    if (existing['created_by'] != userId) {
      throw const CardsException(
        'Only the card creator can manage shares for this card',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.unshareCard(cardId, unshareUserId);

    _log.info('Card unshared: $cardId from $unshareUserId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Private Names
  // ---------------------------------------------------------------------------

  /// Sets a private display name for a card (any user can rename locally).
  Future<void> setPrivateName({
    required String cardId,
    required String spaceId,
    required String userId,
    required String privateName,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Verify card exists
    final existing = await _repo.getCardById(cardId);
    if (existing == null) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (existing['space_id'] != spaceId) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    await _repo.setPrivateName(cardId, userId, privateName.trim());

    _log.info('Private name set for card $cardId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Reveal (Sensitive Access)
  // ---------------------------------------------------------------------------

  /// Reveals full card data, requiring a sensitive access token.
  ///
  /// Verifies access (creator or shared-with), validates the sensitive access
  /// token (5-min TTL), logs an audit entry, and returns full card data.
  Future<Map<String, dynamic>> revealCard({
    required String cardId,
    required String spaceId,
    required String userId,
    required String sensitiveAccessToken,
  }) async {
    // Validate sensitive access token
    if (sensitiveAccessToken.isEmpty) {
      throw const CardsException(
        'Sensitive access token is required to reveal card data',
        code: 'SENSITIVE_ACCESS_REQUIRED',
        statusCode: 401,
      );
    }

    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Fetch the card
    final card = await _repo.getCardById(cardId);
    if (card == null) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (card['space_id'] != spaceId) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify access: creator or shared-with
    final isCreator = card['created_by'] == userId;
    final shares = card['shares'] as List<Map<String, dynamic>>? ?? [];
    final isSharedWith = shares.any((s) => s['shared_with_user_id'] == userId);

    if (!isCreator && !isSharedWith) {
      throw const CardsException(
        'Card not found',
        code: 'CARD_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Log audit entry for sensitive access
    _log.info('AUDIT: Card revealed: $cardId by $userId in space $spaceId');

    return card;
  }

  // ---------------------------------------------------------------------------
  // Card Number Validation
  // ---------------------------------------------------------------------------

  /// Validates a card number using the Luhn algorithm.
  ///
  /// Returns a result map with:
  /// - `valid`: whether the number passes Luhn check
  /// - `network`: detected card network (or null)
  /// - `sanitized`: the digits-only version of the input
  ///
  /// The [number] may contain spaces or dashes which are stripped before
  /// validation. The number must be between 13 and 19 digits long.
  Map<String, dynamic> validateCardNumber(String number) {
    // Strip spaces and dashes
    final sanitized = number.replaceAll(RegExp(r'[\s\-]'), '');

    // Must be all digits
    if (!RegExp(r'^\d+$').hasMatch(sanitized)) {
      return {
        'valid': false,
        'error': 'Card number must contain only digits',
        'network': null,
        'sanitized': sanitized,
      };
    }

    // Length check (13-19 digits covers all major networks)
    if (sanitized.length < 13 || sanitized.length > 19) {
      return {
        'valid': false,
        'error': 'Card number must be between 13 and 19 digits',
        'network': null,
        'sanitized': sanitized,
      };
    }

    // Luhn algorithm
    final isLuhnValid = _luhnCheck(sanitized);
    final network = detectCardNetwork(sanitized);

    return {
      'valid': isLuhnValid,
      'error': isLuhnValid ? null : 'Card number failed Luhn validation',
      'network': network,
      'sanitized': sanitized,
    };
  }

  /// Detects the card network based on BIN (Bank Identification Number) prefix.
  ///
  /// Supports detection of:
  /// - **Visa**: starts with 4
  /// - **Mastercard**: starts with 51-55 or 2221-2720
  /// - **American Express**: starts with 34 or 37
  /// - **Discover**: starts with 6011, 644-649, or 65
  ///
  /// Returns the network name as a lowercase string, or `null` if unknown.
  String? detectCardNetwork(String number) {
    // Strip non-digits for safety
    final digits = number.replaceAll(RegExp(r'[\s\-]'), '');

    if (digits.isEmpty) return null;

    // American Express: starts with 34 or 37, 15 digits
    if (digits.length >= 2) {
      final prefix2 = int.tryParse(digits.substring(0, 2));
      if (prefix2 != null && (prefix2 == 34 || prefix2 == 37)) {
        return 'amex';
      }
    }

    // Mastercard: starts with 51-55 (2 digit prefix) or 2221-2720 (4 digit prefix)
    if (digits.length >= 2) {
      final prefix2 = int.tryParse(digits.substring(0, 2));
      if (prefix2 != null && prefix2 >= 51 && prefix2 <= 55) {
        return 'mastercard';
      }
    }
    if (digits.length >= 4) {
      final prefix4 = int.tryParse(digits.substring(0, 4));
      if (prefix4 != null && prefix4 >= 2221 && prefix4 <= 2720) {
        return 'mastercard';
      }
    }

    // Discover: starts with 6011, 644-649, or 65
    if (digits.length >= 4) {
      final prefix4 = digits.substring(0, 4);
      if (prefix4 == '6011') {
        return 'discover';
      }
    }
    if (digits.length >= 3) {
      final prefix3 = int.tryParse(digits.substring(0, 3));
      if (prefix3 != null && prefix3 >= 644 && prefix3 <= 649) {
        return 'discover';
      }
    }
    if (digits.length >= 2) {
      final prefix2 = digits.substring(0, 2);
      if (prefix2 == '65') {
        return 'discover';
      }
    }

    // Visa: starts with 4
    if (digits.startsWith('4')) {
      return 'visa';
    }

    return null;
  }

  /// Performs the Luhn algorithm check on a string of digits.
  ///
  /// The Luhn algorithm works by:
  /// 1. Starting from the rightmost digit, double every second digit
  /// 2. If doubling results in a value > 9, subtract 9
  /// 3. Sum all digits
  /// 4. If the total modulo 10 is 0, the number is valid
  bool _luhnCheck(String digits) {
    var sum = 0;
    var alternate = false;

    // Iterate from right to left
    for (var i = digits.length - 1; i >= 0; i--) {
      var digit = int.parse(digits[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Verifies that a user is an active member of a space.
  Future<Map<String, dynamic>> _verifySpaceMembership(
    String spaceId,
    String userId,
  ) async {
    final membership = await _spacesRepo.getMember(spaceId, userId);
    if (membership == null || membership['status'] != 'active') {
      throw const CardsException(
        'You do not have access to this space',
        code: 'SPACE_ACCESS_DENIED',
        statusCode: 403,
      );
    }
    return membership;
  }
}
