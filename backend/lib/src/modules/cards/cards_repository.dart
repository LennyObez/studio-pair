import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for card-related database operations.
class CardsRepository {
  final Database _db;
  // ignore: unused_field
  final Logger _log = Logger('CardsRepository');

  CardsRepository(this._db);

  // ---------------------------------------------------------------------------
  // Cards
  // ---------------------------------------------------------------------------

  /// Creates a new card and returns the created card row.
  Future<Map<String, dynamic>> createCard({
    required String id,
    required String spaceId,
    required String createdBy,
    required String cardType,
    required String displayName,
    String? provider,
    String? lastFour,
    int? expiryMonth,
    int? expiryYear,
    String? cardColor,
    Map<String, dynamic>? loyaltyData,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO cards (
        id, space_id, created_by, card_type, display_name, provider,
        last_four, expiry_month, expiry_year, card_color, loyalty_data,
        created_at, updated_at
      )
      VALUES (
        @id, @spaceId, @createdBy, @cardType, @displayName, @provider,
        @lastFour, @expiryMonth, @expiryYear, @cardColor,
        @loyaltyData::jsonb, NOW(), NOW()
      )
      RETURNING id, space_id, created_by, card_type, display_name, provider,
                last_four, expiry_month, expiry_year, card_color,
                loyalty_data, created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'spaceId': spaceId,
        'createdBy': createdBy,
        'cardType': cardType,
        'displayName': displayName,
        'provider': provider,
        'lastFour': lastFour,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'cardColor': cardColor,
        'loyaltyData': loyaltyData,
      },
    );

    return _cardRowToMap(row!);
  }

  /// Gets a card by ID, including its shares.
  Future<Map<String, dynamic>?> getCardById(String cardId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, created_by, card_type, display_name, provider,
             last_four, expiry_month, expiry_year, card_color,
             loyalty_data, created_at, updated_at, deleted_at
      FROM cards
      WHERE id = @cardId AND deleted_at IS NULL
      ''',
      parameters: {'cardId': cardId},
    );

    if (row == null) return null;

    final card = _cardRowWithDeletedToMap(row);

    // Fetch shares with user info
    final shareRows = await _db.query(
      '''
      SELECT cs.id, cs.card_id, cs.shared_with_user_id, cs.shared_by_user_id,
             cs.created_at, u.display_name, u.email, u.avatar_url
      FROM card_shares cs
      JOIN users u ON u.id = cs.shared_with_user_id
      WHERE cs.card_id = @cardId
      ORDER BY cs.created_at ASC
      ''',
      parameters: {'cardId': cardId},
    );

    card['shares'] = shareRows.map(_shareWithUserRowToMap).toList();

    return card;
  }

  /// Gets cards for a user in a space (own cards + cards shared with user).
  Future<List<Map<String, dynamic>>> getCards(
    String spaceId,
    String userId, {
    String? cardType,
  }) async {
    final conditions = <String>[
      'c.deleted_at IS NULL',
      'c.space_id = @spaceId',
      '(c.created_by = @userId OR cs.shared_with_user_id = @userId)',
    ];
    final params = <String, dynamic>{'spaceId': spaceId, 'userId': userId};

    if (cardType != null) {
      conditions.add('c.card_type = @cardType');
      params['cardType'] = cardType;
    }

    final whereClause = conditions.join(' AND ');

    final result = await _db.query('''
      SELECT DISTINCT c.id, c.space_id, c.created_by, c.card_type,
             c.display_name, c.provider, c.last_four, c.expiry_month,
             c.expiry_year, c.card_color, c.loyalty_data,
             c.created_at, c.updated_at
      FROM cards c
      LEFT JOIN card_shares cs ON cs.card_id = c.id
      WHERE $whereClause
      ORDER BY c.created_at DESC
      ''', parameters: params);

    return result.map(_cardRowToMap).toList();
  }

  /// Updates a card with the given fields.
  Future<Map<String, dynamic>?> updateCard(
    String cardId,
    Map<String, dynamic> updates,
  ) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'cardId': cardId};

    if (updates.containsKey('display_name')) {
      setClauses.add('display_name = @displayName');
      params['displayName'] = updates['display_name'];
    }
    if (updates.containsKey('provider')) {
      setClauses.add('provider = @provider');
      params['provider'] = updates['provider'];
    }
    if (updates.containsKey('last_four')) {
      setClauses.add('last_four = @lastFour');
      params['lastFour'] = updates['last_four'];
    }
    if (updates.containsKey('expiry_month')) {
      setClauses.add('expiry_month = @expiryMonth');
      params['expiryMonth'] = updates['expiry_month'];
    }
    if (updates.containsKey('expiry_year')) {
      setClauses.add('expiry_year = @expiryYear');
      params['expiryYear'] = updates['expiry_year'];
    }
    if (updates.containsKey('card_color')) {
      setClauses.add('card_color = @cardColor');
      params['cardColor'] = updates['card_color'];
    }
    if (updates.containsKey('loyalty_data')) {
      setClauses.add('loyalty_data = @loyaltyData::jsonb');
      params['loyaltyData'] = updates['loyalty_data'];
    }

    if (setClauses.isEmpty) return getCardById(cardId);

    setClauses.add('updated_at = NOW()');

    final row = await _db.queryOne('''
      UPDATE cards
      SET ${setClauses.join(', ')}
      WHERE id = @cardId AND deleted_at IS NULL
      RETURNING id, space_id, created_by, card_type, display_name, provider,
                last_four, expiry_month, expiry_year, card_color,
                loyalty_data, created_at, updated_at
      ''', parameters: params);

    if (row == null) return null;
    return _cardRowToMap(row);
  }

  /// Soft-deletes a card.
  Future<void> softDeleteCard(String cardId) async {
    await _db.execute(
      '''
      UPDATE cards
      SET deleted_at = NOW(), updated_at = NOW()
      WHERE id = @cardId AND deleted_at IS NULL
      ''',
      parameters: {'cardId': cardId},
    );
  }

  // ---------------------------------------------------------------------------
  // Card Shares
  // ---------------------------------------------------------------------------

  /// Shares a card with another user.
  Future<Map<String, dynamic>> shareCard({
    required String id,
    required String cardId,
    required String sharedWithUserId,
    required String sharedByUserId,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO card_shares (
        id, card_id, shared_with_user_id, shared_by_user_id, created_at
      )
      VALUES (@id, @cardId, @sharedWithUserId, @sharedByUserId, NOW())
      RETURNING id, card_id, shared_with_user_id, shared_by_user_id, created_at
      ''',
      parameters: {
        'id': id,
        'cardId': cardId,
        'sharedWithUserId': sharedWithUserId,
        'sharedByUserId': sharedByUserId,
      },
    );

    return _shareRowToMap(row!);
  }

  /// Removes a card share for a user.
  Future<void> unshareCard(String cardId, String userId) async {
    await _db.execute(
      '''
      DELETE FROM card_shares
      WHERE card_id = @cardId AND shared_with_user_id = @userId
      ''',
      parameters: {'cardId': cardId, 'userId': userId},
    );
  }

  // ---------------------------------------------------------------------------
  // Private Names
  // ---------------------------------------------------------------------------

  /// Sets or updates a private name for a card (upsert).
  Future<void> setPrivateName(
    String cardId,
    String userId,
    String privateName,
  ) async {
    await _db.execute(
      '''
      INSERT INTO card_private_names (card_id, user_id, private_name, updated_at)
      VALUES (@cardId, @userId, @privateName, NOW())
      ON CONFLICT (card_id, user_id)
      DO UPDATE SET private_name = @privateName, updated_at = NOW()
      ''',
      parameters: {
        'cardId': cardId,
        'userId': userId,
        'privateName': privateName,
      },
    );
  }

  /// Gets the private name for a card set by a specific user.
  Future<String?> getPrivateName(String cardId, String userId) async {
    final row = await _db.queryOne(
      '''
      SELECT private_name
      FROM card_private_names
      WHERE card_id = @cardId AND user_id = @userId
      ''',
      parameters: {'cardId': cardId, 'userId': userId},
    );

    if (row == null) return null;
    return row[0] as String;
  }

  /// Gets all cards shared with a specific user.
  Future<List<Map<String, dynamic>>> getSharedCards(String userId) async {
    final result = await _db.query(
      '''
      SELECT c.id, c.space_id, c.created_by, c.card_type, c.display_name,
             c.provider, c.last_four, c.expiry_month, c.expiry_year,
             c.card_color, c.loyalty_data, c.created_at, c.updated_at
      FROM cards c
      JOIN card_shares cs ON cs.card_id = c.id
      WHERE cs.shared_with_user_id = @userId
        AND c.deleted_at IS NULL
      ORDER BY c.created_at DESC
      ''',
      parameters: {'userId': userId},
    );

    return result.map(_cardRowToMap).toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _cardRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_by': row[2] as String,
      'card_type': row[3] as String,
      'display_name': row[4] as String,
      'provider': row[5] as String?,
      'last_four': row[6] as String?,
      'expiry_month': row[7] as int?,
      'expiry_year': row[8] as int?,
      'card_color': row[9] as String?,
      'loyalty_data': row[10],
      'created_at': (row[11] as DateTime).toIso8601String(),
      'updated_at': (row[12] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _cardRowWithDeletedToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_by': row[2] as String,
      'card_type': row[3] as String,
      'display_name': row[4] as String,
      'provider': row[5] as String?,
      'last_four': row[6] as String?,
      'expiry_month': row[7] as int?,
      'expiry_year': row[8] as int?,
      'card_color': row[9] as String?,
      'loyalty_data': row[10],
      'created_at': (row[11] as DateTime).toIso8601String(),
      'updated_at': (row[12] as DateTime).toIso8601String(),
      'deleted_at': row[13] != null
          ? (row[13] as DateTime).toIso8601String()
          : null,
    };
  }

  Map<String, dynamic> _shareRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'card_id': row[1] as String,
      'shared_with_user_id': row[2] as String,
      'shared_by_user_id': row[3] as String,
      'created_at': (row[4] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _shareWithUserRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'card_id': row[1] as String,
      'shared_with_user_id': row[2] as String,
      'shared_by_user_id': row[3] as String,
      'created_at': (row[4] as DateTime).toIso8601String(),
      'user': {
        'display_name': row[5] as String,
        'email': row[6] as String,
        'avatar_url': row[7] as String?,
      },
    };
  }
}
