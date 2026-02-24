import 'package:drift/drift.dart';
import 'package:studio_pair/src/services/api/grocery_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/grocery_dao.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Repository that wraps the Grocery API and DAO to provide an
/// offline-first data layer with batch cache upserts.
class GroceryRepository {
  GroceryRepository(this._api, this._dao);

  final GroceryApi _api;
  final GroceryDao _dao;

  /// Returns cached grocery lists, then fetches fresh from API and updates cache.
  Future<List<CachedGroceryList>> getLists(String spaceId) async {
    try {
      final response = await _api.getLists(spaceId);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedGroceryLists,
          jsonList
              .map(
                (json) => CachedGroceryListsCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  name: json['name'] as String,
                  createdBy: json['created_by'] as String? ?? '',
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
      return _dao.getLists(spaceId).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getLists(spaceId).first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load grocery lists: $e');
    }
  }

  /// Creates a new grocery list via the API.
  Future<Map<String, dynamic>> createList(String spaceId, String name) async {
    try {
      final response = await _api.createList(spaceId, name);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to create grocery list: $e');
    }
  }

  /// Gets a specific grocery list by ID, with cache fallback.
  Future<Map<String, dynamic>> getList(String spaceId, String listId) async {
    try {
      final response = await _api.getList(spaceId, listId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getList(listId);
      if (cached != null) return {'id': cached.id, 'name': cached.name};
      throw UnknownFailure('Failed to get grocery list: $e');
    }
  }

  /// Updates a grocery list name via the API.
  Future<Map<String, dynamic>> updateList(
    String spaceId,
    String listId,
    String name,
  ) async {
    try {
      final response = await _api.updateList(spaceId, listId, name);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update grocery list: $e');
    }
  }

  /// Deletes a grocery list via the API and removes from cache.
  Future<void> deleteList(String spaceId, String listId) async {
    try {
      await _api.deleteList(spaceId, listId);
      await _dao.deleteList(listId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete grocery list: $e');
    }
  }

  /// Adds an item to a grocery list via the API.
  Future<Map<String, dynamic>> addItem(
    String spaceId,
    String listId, {
    required String name,
    double? quantity,
    String? unit,
    String? category,
    String? note,
  }) async {
    try {
      final response = await _api.addItem(
        spaceId,
        listId,
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        note: note,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to add grocery item: $e');
    }
  }

  /// Updates a grocery item via the API.
  Future<Map<String, dynamic>> updateItem(
    String spaceId,
    String itemId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _api.updateItem(spaceId, itemId, data);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update grocery item: $e');
    }
  }

  /// Deletes a grocery item via the API and removes from cache.
  Future<void> deleteItem(String spaceId, String itemId) async {
    try {
      await _api.deleteItem(spaceId, itemId);
      await _dao.deleteItem(itemId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete grocery item: $e');
    }
  }

  /// Marks a grocery item as checked via the API.
  Future<Map<String, dynamic>> checkItem(String spaceId, String itemId) async {
    try {
      final response = await _api.checkItem(spaceId, itemId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to check grocery item: $e');
    }
  }

  /// Marks a grocery item as unchecked via the API.
  Future<Map<String, dynamic>> uncheckItem(
    String spaceId,
    String itemId,
  ) async {
    try {
      final response = await _api.uncheckItem(spaceId, itemId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to uncheck grocery item: $e');
    }
  }

  /// Clears all checked items from a grocery list via the API.
  Future<void> clearChecked(String spaceId, String listId) async {
    try {
      await _api.clearChecked(spaceId, listId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to clear checked items: $e');
    }
  }

  /// Reorders items in a grocery list via the API.
  Future<void> reorderItems(
    String spaceId,
    String listId,
    List<String> itemIds,
  ) async {
    try {
      await _api.reorderItems(spaceId, listId, itemIds);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to reorder items: $e');
    }
  }

  /// Gets recently added grocery items.
  Future<List<Map<String, dynamic>>> getRecentItems(
    String spaceId, {
    int? limit,
  }) async {
    try {
      final response = await _api.getRecentItems(spaceId, limit: limit);
      return _parseList(response.data);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get recent items: $e');
    }
  }

  /// Watches cached grocery lists for a space (reactive stream).
  Stream<List<CachedGroceryList>> watchLists(String spaceId) {
    return _dao.getLists(spaceId);
  }

  /// Watches cached grocery items for a list (reactive stream).
  Stream<List<CachedGroceryItem>> watchItems(String listId) {
    return _dao.getItems(listId);
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
