import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

import '../../config/database.dart';

/// Repository for grocery list and item database operations.
class GroceryRepository {
  final Database _db;
  // ignore: unused_field
  final Logger _log = Logger('GroceryRepository');

  GroceryRepository(this._db);

  // ---------------------------------------------------------------------------
  // Lists
  // ---------------------------------------------------------------------------

  /// Creates a new grocery list and returns the created list row.
  Future<Map<String, dynamic>> createList({
    required String id,
    required String spaceId,
    required String name,
    required String createdBy,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO grocery_lists (id, space_id, name, created_by, created_at, updated_at)
      VALUES (@id, @spaceId, @name, @createdBy, NOW(), NOW())
      RETURNING id, space_id, name, created_by, created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'spaceId': spaceId,
        'name': name,
        'createdBy': createdBy,
      },
    );

    return _listRowToMap(row!);
  }

  /// Gets a grocery list by ID, including its items.
  Future<Map<String, dynamic>?> getListById(String listId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, name, created_by, created_at, updated_at, deleted_at
      FROM grocery_lists
      WHERE id = @listId AND deleted_at IS NULL
      ''',
      parameters: {'listId': listId},
    );

    if (row == null) return null;

    final list = _listRowWithDeletedToMap(row);

    // Fetch items for this list
    final items = await getItems(listId);
    list['items'] = items;

    return list;
  }

  /// Gets all grocery lists for a space.
  Future<List<Map<String, dynamic>>> getLists(String spaceId) async {
    final result = await _db.query(
      '''
      SELECT id, space_id, name, created_by, created_at, updated_at
      FROM grocery_lists
      WHERE space_id = @spaceId AND deleted_at IS NULL
      ORDER BY created_at DESC
      ''',
      parameters: {'spaceId': spaceId},
    );

    return result.map(_listRowToMap).toList();
  }

  /// Updates a grocery list's name.
  Future<Map<String, dynamic>?> updateList(String listId, String name) async {
    final row = await _db.queryOne(
      '''
      UPDATE grocery_lists
      SET name = @name, updated_at = NOW()
      WHERE id = @listId AND deleted_at IS NULL
      RETURNING id, space_id, name, created_by, created_at, updated_at
      ''',
      parameters: {'listId': listId, 'name': name},
    );

    if (row == null) return null;
    return _listRowToMap(row);
  }

  /// Soft-deletes a grocery list.
  Future<void> softDeleteList(String listId) async {
    await _db.execute(
      '''
      UPDATE grocery_lists
      SET deleted_at = NOW(), updated_at = NOW()
      WHERE id = @listId
      ''',
      parameters: {'listId': listId},
    );
  }

  // ---------------------------------------------------------------------------
  // Items
  // ---------------------------------------------------------------------------

  /// Creates a new grocery item and returns the created item row.
  Future<Map<String, dynamic>> createItem({
    required String id,
    required String listId,
    required String name,
    double? quantity,
    String? unit,
    String? category,
    String? note,
    required int displayOrder,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO grocery_items (
        id, list_id, name, quantity, unit, category, note,
        display_order, is_checked, created_at, updated_at
      )
      VALUES (
        @id, @listId, @name, @quantity, @unit, @category, @note,
        @displayOrder, FALSE, NOW(), NOW()
      )
      RETURNING id, list_id, name, quantity, unit, category, note,
                display_order, is_checked, checked_by, checked_at,
                created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'listId': listId,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'category': category,
        'note': note,
        'displayOrder': displayOrder,
      },
    );

    return _itemRowToMap(row!);
  }

  /// Gets items for a grocery list with optional filtering.
  Future<List<Map<String, dynamic>>> getItems(
    String listId, {
    bool? checkedOnly,
    bool? uncheckedOnly,
    String? category,
  }) async {
    final whereClauses = <String>['list_id = @listId'];
    final params = <String, dynamic>{'listId': listId};

    if (checkedOnly == true) {
      whereClauses.add('is_checked = TRUE');
    } else if (uncheckedOnly == true) {
      whereClauses.add('is_checked = FALSE');
    }

    if (category != null) {
      whereClauses.add('category = @category');
      params['category'] = category;
    }

    final result = await _db.query('''
      SELECT id, list_id, name, quantity, unit, category, note,
             display_order, is_checked, checked_by, checked_at,
             created_at, updated_at
      FROM grocery_items
      WHERE ${whereClauses.join(' AND ')}
      ORDER BY category NULLS LAST, display_order ASC, created_at ASC
      ''', parameters: params);

    return result.map(_itemRowToMap).toList();
  }

  /// Updates a grocery item with the given field updates.
  Future<Map<String, dynamic>?> updateItem(
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'itemId': itemId};

    if (updates.containsKey('name')) {
      setClauses.add('name = @name');
      params['name'] = updates['name'];
    }
    if (updates.containsKey('quantity')) {
      setClauses.add('quantity = @quantity');
      params['quantity'] = updates['quantity'];
    }
    if (updates.containsKey('unit')) {
      setClauses.add('unit = @unit');
      params['unit'] = updates['unit'];
    }
    if (updates.containsKey('category')) {
      setClauses.add('category = @category');
      params['category'] = updates['category'];
    }
    if (updates.containsKey('note')) {
      setClauses.add('note = @note');
      params['note'] = updates['note'];
    }

    if (setClauses.isEmpty) {
      // Nothing to update, return current item
      return getItemById(itemId);
    }

    setClauses.add('updated_at = NOW()');

    final row = await _db.queryOne('''
      UPDATE grocery_items
      SET ${setClauses.join(', ')}
      WHERE id = @itemId
      RETURNING id, list_id, name, quantity, unit, category, note,
                display_order, is_checked, checked_by, checked_at,
                created_at, updated_at
      ''', parameters: params);

    if (row == null) return null;
    return _itemRowToMap(row);
  }

  /// Gets a single grocery item by ID.
  Future<Map<String, dynamic>?> getItemById(String itemId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, list_id, name, quantity, unit, category, note,
             display_order, is_checked, checked_by, checked_at,
             created_at, updated_at
      FROM grocery_items
      WHERE id = @itemId
      ''',
      parameters: {'itemId': itemId},
    );

    if (row == null) return null;
    return _itemRowToMap(row);
  }

  /// Marks an item as checked.
  Future<Map<String, dynamic>?> checkItem(String itemId, String userId) async {
    final row = await _db.queryOne(
      '''
      UPDATE grocery_items
      SET is_checked = TRUE, checked_by = @userId, checked_at = NOW(),
          updated_at = NOW()
      WHERE id = @itemId
      RETURNING id, list_id, name, quantity, unit, category, note,
                display_order, is_checked, checked_by, checked_at,
                created_at, updated_at
      ''',
      parameters: {'itemId': itemId, 'userId': userId},
    );

    if (row == null) return null;
    return _itemRowToMap(row);
  }

  /// Marks an item as unchecked.
  Future<Map<String, dynamic>?> uncheckItem(String itemId) async {
    final row = await _db.queryOne(
      '''
      UPDATE grocery_items
      SET is_checked = FALSE, checked_by = NULL, checked_at = NULL,
          updated_at = NOW()
      WHERE id = @itemId
      RETURNING id, list_id, name, quantity, unit, category, note,
                display_order, is_checked, checked_by, checked_at,
                created_at, updated_at
      ''',
      parameters: {'itemId': itemId},
    );

    if (row == null) return null;
    return _itemRowToMap(row);
  }

  /// Hard-deletes a grocery item.
  Future<void> deleteItem(String itemId) async {
    await _db.execute(
      'DELETE FROM grocery_items WHERE id = @itemId',
      parameters: {'itemId': itemId},
    );
  }

  /// Hard-deletes all checked items in a list.
  Future<int> clearCheckedItems(String listId) async {
    return _db.execute(
      'DELETE FROM grocery_items WHERE list_id = @listId AND is_checked = TRUE',
      parameters: {'listId': listId},
    );
  }

  /// Updates display order for a list of item IDs.
  Future<void> reorderItems(String listId, List<String> itemIds) async {
    await _db.transaction((session) async {
      for (var i = 0; i < itemIds.length; i++) {
        await session.execute(
          Sql.named('''
          UPDATE grocery_items
          SET display_order = @displayOrder, updated_at = NOW()
          WHERE id = @itemId AND list_id = @listId
          '''),
          parameters: {
            'displayOrder': i,
            'itemId': itemIds[i],
            'listId': listId,
          },
        );
      }
    });
  }

  /// Gets recently purchased (checked) items across all lists in a space.
  Future<List<Map<String, dynamic>>> getRecentItems(
    String spaceId, {
    int limit = 20,
  }) async {
    final result = await _db.query(
      '''
      SELECT DISTINCT ON (gi.name) gi.id, gi.list_id, gi.name, gi.quantity,
             gi.unit, gi.category, gi.note, gi.display_order, gi.is_checked,
             gi.checked_by, gi.checked_at, gi.created_at, gi.updated_at
      FROM grocery_items gi
      JOIN grocery_lists gl ON gl.id = gi.list_id
      WHERE gl.space_id = @spaceId
        AND gl.deleted_at IS NULL
        AND gi.is_checked = TRUE
        AND gi.checked_at IS NOT NULL
      ORDER BY gi.name, gi.checked_at DESC
      LIMIT @limit
      ''',
      parameters: {'spaceId': spaceId, 'limit': limit},
    );

    return result.map(_itemRowToMap).toList();
  }

  /// Gets the maximum display order for items in a list.
  Future<int> getMaxDisplayOrder(String listId) async {
    final row = await _db.queryOne(
      '''
      SELECT COALESCE(MAX(display_order), -1)
      FROM grocery_items
      WHERE list_id = @listId
      ''',
      parameters: {'listId': listId},
    );

    return (row?[0] as int?) ?? -1;
  }

  /// Gets the item IDs belonging to a specific list.
  Future<List<String>> getItemIdsForList(String listId) async {
    final result = await _db.query(
      '''
      SELECT id FROM grocery_items WHERE list_id = @listId
      ''',
      parameters: {'listId': listId},
    );

    return result.map((row) => row[0] as String).toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _listRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'name': row[2] as String,
      'created_by': row[3] as String,
      'created_at': (row[4] as DateTime).toIso8601String(),
      'updated_at': (row[5] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _listRowWithDeletedToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'name': row[2] as String,
      'created_by': row[3] as String,
      'created_at': (row[4] as DateTime).toIso8601String(),
      'updated_at': (row[5] as DateTime).toIso8601String(),
      'deleted_at': row[6] != null
          ? (row[6] as DateTime).toIso8601String()
          : null,
    };
  }

  Map<String, dynamic> _itemRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'list_id': row[1] as String,
      'name': row[2] as String,
      'quantity': row[3] as double?,
      'unit': row[4] as String?,
      'category': row[5] as String?,
      'note': row[6] as String?,
      'display_order': row[7] as int,
      'is_checked': row[8] as bool,
      'checked_by': row[9] as String?,
      'checked_at': row[10] != null
          ? (row[10] as DateTime).toIso8601String()
          : null,
      'created_at': (row[11] as DateTime).toIso8601String(),
      'updated_at': (row[12] as DateTime).toIso8601String(),
    };
  }
}
