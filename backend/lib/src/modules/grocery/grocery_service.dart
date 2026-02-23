import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../services/notification_service.dart';
import 'grocery_repository.dart';

/// Custom exception for grocery-related errors.
class GroceryException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const GroceryException(
    this.message, {
    this.code = 'GROCERY_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'GroceryException($code): $message';
}

/// Service containing all grocery list business logic.
class GroceryService {
  final GroceryRepository _repo;
  // ignore: unused_field
  final NotificationService _notificationService;
  final Logger _log = Logger('GroceryService');
  final Uuid _uuid = const Uuid();

  GroceryService(this._repo, this._notificationService);

  // ---------------------------------------------------------------------------
  // Lists
  // ---------------------------------------------------------------------------

  /// Creates a new grocery list.
  Future<Map<String, dynamic>> createList({
    required String spaceId,
    required String name,
    required String createdBy,
  }) async {
    // Validate name
    if (name.trim().isEmpty) {
      throw const GroceryException(
        'List name is required',
        code: 'INVALID_NAME',
        statusCode: 422,
      );
    }

    if (name.trim().length > 200) {
      throw const GroceryException(
        'List name must be at most 200 characters',
        code: 'INVALID_NAME',
        statusCode: 422,
      );
    }

    final listId = _uuid.v4();
    final list = await _repo.createList(
      id: listId,
      spaceId: spaceId,
      name: name.trim(),
      createdBy: createdBy,
    );

    _log.info(
      'Grocery list created: ${list['name']} ($listId) in space $spaceId',
    );
    return list;
  }

  /// Gets a grocery list by ID with its items.
  Future<Map<String, dynamic>> getList(String listId) async {
    final list = await _repo.getListById(listId);
    if (list == null) {
      throw const GroceryException(
        'Grocery list not found',
        code: 'LIST_NOT_FOUND',
        statusCode: 404,
      );
    }
    return list;
  }

  /// Gets all grocery lists for a space.
  Future<List<Map<String, dynamic>>> getLists(String spaceId) async {
    return _repo.getLists(spaceId);
  }

  /// Updates a grocery list name.
  Future<Map<String, dynamic>> updateList({
    required String listId,
    required String name,
  }) async {
    if (name.trim().isEmpty) {
      throw const GroceryException(
        'List name is required',
        code: 'INVALID_NAME',
        statusCode: 422,
      );
    }

    if (name.trim().length > 200) {
      throw const GroceryException(
        'List name must be at most 200 characters',
        code: 'INVALID_NAME',
        statusCode: 422,
      );
    }

    final updated = await _repo.updateList(listId, name.trim());
    if (updated == null) {
      throw const GroceryException(
        'Grocery list not found',
        code: 'LIST_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('Grocery list updated: $listId');
    return updated;
  }

  /// Deletes a grocery list. Only the creator or an admin can delete.
  Future<void> deleteList({
    required String listId,
    required String userId,
    required String userRole,
  }) async {
    final list = await _repo.getListById(listId);
    if (list == null) {
      throw const GroceryException(
        'Grocery list not found',
        code: 'LIST_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Check ownership or admin
    final isCreator = list['created_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdmin) {
      throw const GroceryException(
        'Only the list creator or an admin can delete this list',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.softDeleteList(listId);
    _log.info('Grocery list deleted: $listId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Items
  // ---------------------------------------------------------------------------

  /// Adds an item to a grocery list.
  Future<Map<String, dynamic>> addItem({
    required String listId,
    required String name,
    double? quantity,
    String? unit,
    String? category,
    String? note,
  }) async {
    // Validate name
    if (name.trim().isEmpty) {
      throw const GroceryException(
        'Item name is required',
        code: 'INVALID_ITEM_NAME',
        statusCode: 422,
      );
    }

    if (name.trim().length > 200) {
      throw const GroceryException(
        'Item name must be at most 200 characters',
        code: 'INVALID_ITEM_NAME',
        statusCode: 422,
      );
    }

    // Verify the list exists
    final list = await _repo.getListById(listId);
    if (list == null) {
      throw const GroceryException(
        'Grocery list not found',
        code: 'LIST_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Auto-assign display order
    final maxOrder = await _repo.getMaxDisplayOrder(listId);
    final displayOrder = maxOrder + 1;

    final itemId = _uuid.v4();
    final item = await _repo.createItem(
      id: itemId,
      listId: listId,
      name: name.trim(),
      quantity: quantity,
      unit: unit?.trim(),
      category: category?.trim(),
      note: note?.trim(),
      displayOrder: displayOrder,
    );

    _log.info('Grocery item added: ${item['name']} ($itemId) to list $listId');
    return item;
  }

  /// Updates a grocery item.
  Future<Map<String, dynamic>> updateItem({
    required String itemId,
    required Map<String, dynamic> updates,
  }) async {
    // Validate name if provided
    if (updates.containsKey('name')) {
      final name = updates['name'] as String?;
      if (name == null || name.trim().isEmpty) {
        throw const GroceryException(
          'Item name cannot be empty',
          code: 'INVALID_ITEM_NAME',
          statusCode: 422,
        );
      }
      updates['name'] = name.trim();
    }

    final updated = await _repo.updateItem(itemId, updates);
    if (updated == null) {
      throw const GroceryException(
        'Grocery item not found',
        code: 'ITEM_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('Grocery item updated: $itemId');
    return updated;
  }

  /// Checks an item (any space member can check).
  Future<Map<String, dynamic>> checkItem({
    required String itemId,
    required String userId,
  }) async {
    final updated = await _repo.checkItem(itemId, userId);
    if (updated == null) {
      throw const GroceryException(
        'Grocery item not found',
        code: 'ITEM_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('Grocery item checked: $itemId by $userId');
    return updated;
  }

  /// Unchecks an item (any space member can uncheck).
  Future<Map<String, dynamic>> uncheckItem(String itemId) async {
    final updated = await _repo.uncheckItem(itemId);
    if (updated == null) {
      throw const GroceryException(
        'Grocery item not found',
        code: 'ITEM_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('Grocery item unchecked: $itemId');
    return updated;
  }

  /// Deletes a grocery item (any member can delete).
  Future<void> deleteItem(String itemId) async {
    final item = await _repo.getItemById(itemId);
    if (item == null) {
      throw const GroceryException(
        'Grocery item not found',
        code: 'ITEM_NOT_FOUND',
        statusCode: 404,
      );
    }

    await _repo.deleteItem(itemId);
    _log.info('Grocery item deleted: $itemId');
  }

  /// Clears all checked items from a list. Only admin or list creator.
  Future<int> clearChecked({
    required String listId,
    required String userId,
    required String userRole,
  }) async {
    final list = await _repo.getListById(listId);
    if (list == null) {
      throw const GroceryException(
        'Grocery list not found',
        code: 'LIST_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Check permission: admin or list creator
    final isCreator = list['created_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdmin) {
      throw const GroceryException(
        'Only the list creator or an admin can clear checked items',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    final count = await _repo.clearCheckedItems(listId);
    _log.info('Cleared $count checked items from list $listId');
    return count;
  }

  /// Reorders items in a list. Validates all item IDs belong to the list.
  Future<void> reorderItems({
    required String listId,
    required List<String> itemIds,
  }) async {
    // Verify the list exists
    final list = await _repo.getListById(listId);
    if (list == null) {
      throw const GroceryException(
        'Grocery list not found',
        code: 'LIST_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (itemIds.isEmpty) {
      throw const GroceryException(
        'Item IDs list cannot be empty',
        code: 'INVALID_ITEM_IDS',
        statusCode: 422,
      );
    }

    // Validate all item IDs belong to this list
    final existingIds = await _repo.getItemIdsForList(listId);
    final existingSet = existingIds.toSet();
    for (final itemId in itemIds) {
      if (!existingSet.contains(itemId)) {
        throw GroceryException(
          'Item $itemId does not belong to this list',
          code: 'INVALID_ITEM_ID',
          statusCode: 422,
        );
      }
    }

    await _repo.reorderItems(listId, itemIds);
    _log.info('Reordered ${itemIds.length} items in list $listId');
  }

  /// Gets recently purchased items across all lists in a space.
  Future<List<Map<String, dynamic>>> getRecentItems(
    String spaceId, {
    int limit = 20,
  }) async {
    return _repo.getRecentItems(spaceId, limit: limit);
  }
}
