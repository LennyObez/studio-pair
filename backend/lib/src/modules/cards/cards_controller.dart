import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'cards_service.dart';

/// Controller for personal information card endpoints.
class CardsController {
  final CardsService _service;
  final Logger _log = Logger('CardsController');

  CardsController(this._service);

  /// Returns the router with all card routes.
  Router get router {
    final router = Router();

    // Card CRUD
    router.post('/cards', _createCard);
    router.get('/cards', _getCards);
    router.get('/cards/<cardId>', _getCard);
    router.patch('/cards/<cardId>', _updateCard);
    router.delete('/cards/<cardId>', _deleteCard);

    // Sharing
    router.post('/cards/<cardId>/share', _shareCard);
    router.delete('/cards/<cardId>/share/<userId>', _unshareCard);

    // Private name
    router.post('/cards/<cardId>/private-name', _setPrivateName);

    // Sensitive access (requires re-authentication)
    router.post('/cards/<cardId>/reveal', _revealCard);

    return router;
  }

  /// POST /cards
  ///
  /// Creates a new card.
  /// Body: {
  ///   "card_type": "debit|credit|loyalty|membership",
  ///   "display_name": "...",
  ///   "provider": "visa|mastercard|amex|discover|other",
  ///   "last_four": "1234",
  ///   "expiry_month": 12,
  ///   "expiry_year": 2027,
  ///   "card_color": "#FF5733",
  ///   "loyalty_data": { ... }
  /// }
  Future<Response> _createCard(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final cardType = body['card_type'] as String?;
      final displayName = body['display_name'] as String?;

      if (cardType == null || displayName == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (cardType == null)
              {'field': 'card_type', 'message': 'Card type is required'},
            if (displayName == null)
              {'field': 'display_name', 'message': 'Display name is required'},
          ],
        );
      }

      final result = await _service.createCard(
        spaceId: spaceId,
        userId: userId,
        cardType: cardType,
        displayName: displayName,
        provider: body['provider'] as String?,
        lastFour: body['last_four'] as String?,
        expiryMonth: body['expiry_month'] as int?,
        expiryYear: body['expiry_year'] as int?,
        cardColor: body['card_color'] as String?,
        loyaltyData: body['loyalty_data'] as Map<String, dynamic>?,
      );

      return createdResponse(result);
    } on CardsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create card error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /cards?type=
  ///
  /// Gets the user's own cards plus cards shared with them in the space.
  Future<Response> _getCards(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final cardType = request.url.queryParameters['type'];

      final cards = await _service.getCards(
        spaceId: spaceId,
        userId: userId,
        cardType: cardType,
      );

      return jsonResponse({'data': cards});
    } on CardsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get cards error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /cards/<cardId>
  ///
  /// Gets a single card by ID with shares.
  Future<Response> _getCard(Request request, String cardId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final card = await _service.getCard(
        cardId: cardId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(card);
    } on CardsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get card error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /cards/<cardId>
  ///
  /// Partially updates a card.
  /// Body: any subset of { display_name, provider, last_four, expiry_month,
  ///   expiry_year, card_color, loyalty_data }
  Future<Response> _updateCard(Request request, String cardId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      // Build the updates map
      final updates = <String, dynamic>{};

      if (body.containsKey('display_name')) {
        updates['display_name'] = body['display_name'];
      }
      if (body.containsKey('provider')) {
        updates['provider'] = body['provider'];
      }
      if (body.containsKey('last_four')) {
        updates['last_four'] = body['last_four'];
      }
      if (body.containsKey('expiry_month')) {
        updates['expiry_month'] = body['expiry_month'];
      }
      if (body.containsKey('expiry_year')) {
        updates['expiry_year'] = body['expiry_year'];
      }
      if (body.containsKey('card_color')) {
        updates['card_color'] = body['card_color'];
      }
      if (body.containsKey('loyalty_data')) {
        updates['loyalty_data'] = body['loyalty_data'];
      }

      final result = await _service.updateCard(
        cardId: cardId,
        spaceId: spaceId,
        userId: userId,
        updates: updates,
      );

      return jsonResponse(result);
    } on CardsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update card error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /cards/<cardId>
  ///
  /// Soft-deletes a card.
  Future<Response> _deleteCard(Request request, String cardId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      await _service.deleteCard(
        cardId: cardId,
        spaceId: spaceId,
        userId: userId,
      );

      return noContentResponse();
    } on CardsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete card error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /cards/<cardId>/share
  ///
  /// Shares a card with another user.
  /// Body: { "user_id": "..." }
  Future<Response> _shareCard(Request request, String cardId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final sharedWithUserId = body['user_id'] as String?;
      if (sharedWithUserId == null || sharedWithUserId.isEmpty) {
        return validationErrorResponse(
          'User ID is required',
          errors: [
            {
              'field': 'user_id',
              'message': 'User ID to share with is required',
            },
          ],
        );
      }

      final result = await _service.shareCard(
        cardId: cardId,
        spaceId: spaceId,
        userId: userId,
        sharedWithUserId: sharedWithUserId,
      );

      return createdResponse(result);
    } on CardsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Share card error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /cards/<cardId>/share/<userId>
  ///
  /// Removes a card share for a user.
  Future<Response> _unshareCard(
    Request request,
    String cardId,
    String unshareUserId,
  ) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      await _service.unshareCard(
        cardId: cardId,
        spaceId: spaceId,
        userId: userId,
        unshareUserId: unshareUserId,
      );

      return noContentResponse();
    } on CardsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Unshare card error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /cards/<cardId>/private-name
  ///
  /// Sets a private display name for a card.
  /// Body: { "name": "..." }
  Future<Response> _setPrivateName(Request request, String cardId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final privateName = body['name'] as String?;
      if (privateName == null || privateName.trim().isEmpty) {
        return validationErrorResponse(
          'Private name is required',
          errors: [
            {'field': 'name', 'message': 'Name is required'},
          ],
        );
      }

      await _service.setPrivateName(
        cardId: cardId,
        spaceId: spaceId,
        userId: userId,
        privateName: privateName,
      );

      return jsonResponse({'message': 'Private name set successfully'});
    } on CardsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Set private name error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /cards/<cardId>/reveal
  ///
  /// Reveals sensitive card data (requires sensitive access token).
  Future<Response> _revealCard(Request request, String cardId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      // Extract sensitive access token from header
      final sensitiveAccessToken =
          request.headers['x-sensitive-access-token'] ?? '';

      final result = await _service.revealCard(
        cardId: cardId,
        spaceId: spaceId,
        userId: userId,
        sensitiveAccessToken: sensitiveAccessToken,
      );

      return jsonResponse(result);
    } on CardsException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Reveal card error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
