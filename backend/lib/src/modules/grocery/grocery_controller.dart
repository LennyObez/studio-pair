import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'grocery_service.dart';

/// Controller for shared grocery/shopping list endpoints.
class GroceryController {
  final GroceryService _service;
  final Logger _log = Logger('GroceryController');

  GroceryController(this._service);

  /// Returns the router with all grocery routes.
  Router get router {
    final router = Router();

    // Lists
    router.post('/lists', _createList);
    router.get('/lists', _listLists);
    router.get('/lists/<listId>', _getList);
    router.patch('/lists/<listId>', _updateList);
    router.delete('/lists/<listId>', _deleteList);

    // Items
    router.post('/lists/<listId>/items', _addItem);
    router.patch('/items/<itemId>', _updateItem);
    router.delete('/items/<itemId>', _deleteItem);

    // Check/Uncheck
    router.post('/items/<itemId>/check', _checkItem);
    router.post('/items/<itemId>/uncheck', _uncheckItem);

    // Batch operations
    router.delete('/lists/<listId>/checked', _clearChecked);
    router.post('/lists/<listId>/reorder', _reorderItems);

    // Recent items
    router.get('/recent', _getRecentItems);

    return router;
  }

  /// POST /api/v1/spaces/<spaceId>/grocery/lists
  ///
  /// Creates a new grocery list.
  /// Body: { "name": "..." }
  Future<Response> _createList(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final name = body['name'] as String?;
      if (name == null || name.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'name', 'message': 'List name is required'},
          ],
        );
      }

      final result = await _service.createList(
        spaceId: spaceId,
        name: name,
        createdBy: userId,
      );

      return createdResponse(result);
    } on GroceryException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create grocery list error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/grocery/lists
  ///
  /// Lists all grocery lists for the space.
  Future<Response> _listLists(Request request) async {
    try {
      final spaceId = getSpaceId(request);
      final lists = await _service.getLists(spaceId);

      return jsonResponse({'data': lists});
    } catch (e, stackTrace) {
      _log.severe('List grocery lists error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/grocery/lists/<listId>
  ///
  /// Gets a single grocery list with its items.
  Future<Response> _getList(Request request, String listId) async {
    try {
      final list = await _service.getList(listId);
      return jsonResponse(list);
    } on GroceryException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get grocery list error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /api/v1/spaces/<spaceId>/grocery/lists/<listId>
  ///
  /// Updates a grocery list.
  /// Body: { "name": "..." }
  Future<Response> _updateList(Request request, String listId) async {
    try {
      final body = await readJsonBody(request);

      final name = body['name'] as String?;
      if (name == null || name.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'name', 'message': 'List name is required'},
          ],
        );
      }

      final result = await _service.updateList(listId: listId, name: name);

      return jsonResponse(result);
    } on GroceryException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update grocery list error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /api/v1/spaces/<spaceId>/grocery/lists/<listId>
  ///
  /// Deletes a grocery list (soft delete).
  Future<Response> _deleteList(Request request, String listId) async {
    try {
      final userId = getUserId(request);
      final membership = getMembership(request);

      await _service.deleteList(
        listId: listId,
        userId: userId,
        userRole: membership?.role ?? 'member',
      );

      return noContentResponse();
    } on GroceryException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete grocery list error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/grocery/lists/<listId>/items
  ///
  /// Adds an item to a grocery list.
  /// Body: { "name": "...", "quantity": 1.0, "unit": "pcs", "category": "...", "note": "..." }
  Future<Response> _addItem(Request request, String listId) async {
    try {
      final body = await readJsonBody(request);

      final name = body['name'] as String?;
      if (name == null || name.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'name', 'message': 'Item name is required'},
          ],
        );
      }

      final quantity = body['quantity'] != null
          ? (body['quantity'] as num).toDouble()
          : null;

      final result = await _service.addItem(
        listId: listId,
        name: name,
        quantity: quantity,
        unit: body['unit'] as String?,
        category: body['category'] as String?,
        note: body['note'] as String?,
      );

      return createdResponse(result);
    } on GroceryException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Add grocery item error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /api/v1/spaces/<spaceId>/grocery/items/<itemId>
  ///
  /// Updates a grocery item.
  /// Body: { "name": "...", "quantity": 1.0, "unit": "pcs", "category": "...", "note": "..." }
  Future<Response> _updateItem(Request request, String itemId) async {
    try {
      final body = await readJsonBody(request);

      final updates = <String, dynamic>{};
      if (body.containsKey('name')) updates['name'] = body['name'];
      if (body.containsKey('quantity')) {
        updates['quantity'] = body['quantity'] != null
            ? (body['quantity'] as num).toDouble()
            : null;
      }
      if (body.containsKey('unit')) updates['unit'] = body['unit'];
      if (body.containsKey('category')) updates['category'] = body['category'];
      if (body.containsKey('note')) updates['note'] = body['note'];

      final result = await _service.updateItem(
        itemId: itemId,
        updates: updates,
      );

      return jsonResponse(result);
    } on GroceryException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update grocery item error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/grocery/items/<itemId>/check
  ///
  /// Marks a grocery item as checked.
  Future<Response> _checkItem(Request request, String itemId) async {
    try {
      final userId = getUserId(request);

      final result = await _service.checkItem(itemId: itemId, userId: userId);

      return jsonResponse(result);
    } on GroceryException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Check grocery item error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/grocery/items/<itemId>/uncheck
  ///
  /// Marks a grocery item as unchecked.
  Future<Response> _uncheckItem(Request request, String itemId) async {
    try {
      final result = await _service.uncheckItem(itemId);

      return jsonResponse(result);
    } on GroceryException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Uncheck grocery item error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /api/v1/spaces/<spaceId>/grocery/items/<itemId>
  ///
  /// Deletes a grocery item.
  Future<Response> _deleteItem(Request request, String itemId) async {
    try {
      await _service.deleteItem(itemId);
      return noContentResponse();
    } on GroceryException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete grocery item error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /api/v1/spaces/<spaceId>/grocery/lists/<listId>/checked
  ///
  /// Clears all checked items from a list.
  Future<Response> _clearChecked(Request request, String listId) async {
    try {
      final userId = getUserId(request);
      final membership = getMembership(request);

      final count = await _service.clearChecked(
        listId: listId,
        userId: userId,
        userRole: membership?.role ?? 'member',
      );

      return jsonResponse({
        'message': 'Cleared $count checked items',
        'count': count,
      });
    } on GroceryException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Clear checked items error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/grocery/lists/<listId>/reorder
  ///
  /// Reorders items in a list.
  /// Body: { "item_ids": ["id1", "id2", ...] }
  Future<Response> _reorderItems(Request request, String listId) async {
    try {
      final body = await readJsonBody(request);

      final itemIds = (body['item_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList();

      if (itemIds == null || itemIds.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'item_ids', 'message': 'Item IDs array is required'},
          ],
        );
      }

      await _service.reorderItems(listId: listId, itemIds: itemIds);

      return jsonResponse({'message': 'Items reordered successfully'});
    } on GroceryException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Reorder grocery items error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/grocery/recent
  ///
  /// Gets recently purchased items for quick re-add.
  Future<Response> _getRecentItems(Request request) async {
    try {
      final spaceId = getSpaceId(request);

      final limitStr = request.url.queryParameters['limit'];
      final limit = limitStr != null ? (int.tryParse(limitStr) ?? 20) : 20;

      final items = await _service.getRecentItems(
        spaceId,
        limit: limit.clamp(1, 100),
      );

      return jsonResponse({'data': items});
    } catch (e, stackTrace) {
      _log.severe('Get recent grocery items error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
