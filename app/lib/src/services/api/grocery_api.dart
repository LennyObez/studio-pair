import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Grocery API service for managing grocery lists and items within a space.
class GroceryApi {
  GroceryApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Create a new grocery list.
  Future<Response> createList(String spaceId, String name) {
    return _client.post('/spaces/$spaceId/grocery/lists', data: {'name': name});
  }

  /// Get all grocery lists for a space.
  Future<Response> getLists(String spaceId) {
    return _client.get('/spaces/$spaceId/grocery/lists');
  }

  /// Get a specific grocery list by ID.
  Future<Response> getList(String spaceId, String listId) {
    return _client.get('/spaces/$spaceId/grocery/lists/$listId');
  }

  /// Update a grocery list name.
  Future<Response> updateList(String spaceId, String listId, String name) {
    return _client.patch(
      '/spaces/$spaceId/grocery/lists/$listId',
      data: {'name': name},
    );
  }

  /// Delete a grocery list.
  Future<Response> deleteList(String spaceId, String listId) {
    return _client.delete('/spaces/$spaceId/grocery/lists/$listId');
  }

  /// Add an item to a grocery list.
  Future<Response> addItem(
    String spaceId,
    String listId, {
    required String name,
    double? quantity,
    String? unit,
    String? category,
    String? note,
  }) {
    return _client.post(
      '/spaces/$spaceId/grocery/lists/$listId/items',
      data: {
        'name': name,
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit,
        if (category != null) 'category': category,
        if (note != null) 'note': note,
      },
    );
  }

  /// Update a grocery item.
  Future<Response> updateItem(
    String spaceId,
    String itemId,
    Map<String, dynamic> data,
  ) {
    return _client.patch('/spaces/$spaceId/grocery/items/$itemId', data: data);
  }

  /// Delete a grocery item.
  Future<Response> deleteItem(String spaceId, String itemId) {
    return _client.delete('/spaces/$spaceId/grocery/items/$itemId');
  }

  /// Mark a grocery item as checked.
  Future<Response> checkItem(String spaceId, String itemId) {
    return _client.post('/spaces/$spaceId/grocery/items/$itemId/check');
  }

  /// Mark a grocery item as unchecked.
  Future<Response> uncheckItem(String spaceId, String itemId) {
    return _client.post('/spaces/$spaceId/grocery/items/$itemId/uncheck');
  }

  /// Clear all checked items from a grocery list.
  Future<Response> clearChecked(String spaceId, String listId) {
    return _client.delete('/spaces/$spaceId/grocery/lists/$listId/checked');
  }

  /// Reorder items in a grocery list.
  Future<Response> reorderItems(
    String spaceId,
    String listId,
    List<String> itemIds,
  ) {
    return _client.post(
      '/spaces/$spaceId/grocery/lists/$listId/reorder',
      data: {'item_ids': itemIds},
    );
  }

  /// Get recently added grocery items.
  Future<Response> getRecentItems(String spaceId, {int? limit}) {
    return _client.get(
      '/spaces/$spaceId/grocery/recent',
      queryParameters: {if (limit != null) 'limit': limit},
    );
  }
}
