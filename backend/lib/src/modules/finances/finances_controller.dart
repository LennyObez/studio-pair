import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'finances_service.dart';

/// Controller for shared finance endpoints.
class FinancesController {
  final FinancesService _service;
  final Logger _log = Logger('FinancesController');

  FinancesController(this._service);

  /// Returns the router with all finance routes.
  Router get router {
    final router = Router();

    // Balances & Dashboard (registered before parameterized routes)
    router.get('/balances', _getBalances);
    router.get('/dashboard', _getDashboardStats);
    router.get('/trends', _getMonthlyTrend);

    // Entry CRUD
    router.post('/entries', _createEntry);
    router.get('/entries', _getEntries);
    router.get('/entries/<entryId>', _getEntry);
    router.patch('/entries/<entryId>', _updateEntry);
    router.delete('/entries/<entryId>', _deleteEntry);

    // Splits
    router.post('/entries/<entryId>/split', _createSplit);

    // Settlement
    router.post('/splits/<shareId>/settle', _settleSplitShare);

    return router;
  }

  /// POST /entries
  ///
  /// Creates a new finance entry.
  /// Body: {
  ///   "entry_type": "income|expense",
  ///   "category": "...",
  ///   "subcategory": "...",
  ///   "description": "...",
  ///   "amount_cents": 5000,
  ///   "currency": "USD",
  ///   "is_recurring": false,
  ///   "recurrence_rule": "RRULE string",
  ///   "date": "ISO 8601"
  /// }
  Future<Response> _createEntry(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final entryType = body['entry_type'] as String?;
      final category = body['category'] as String?;
      final amountCents = body['amount_cents'] as int?;
      final dateStr = body['date'] as String?;

      if (entryType == null ||
          category == null ||
          amountCents == null ||
          dateStr == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (entryType == null)
              {'field': 'entry_type', 'message': 'Entry type is required'},
            if (category == null)
              {'field': 'category', 'message': 'Category is required'},
            if (amountCents == null)
              {'field': 'amount_cents', 'message': 'Amount is required'},
            if (dateStr == null)
              {'field': 'date', 'message': 'Date is required'},
          ],
        );
      }

      final date = DateTime.tryParse(dateStr);
      if (date == null) {
        return validationErrorResponse(
          'Invalid date format. Use ISO 8601 format.',
          errors: [
            {'field': 'date', 'message': 'Invalid date format'},
          ],
        );
      }

      final result = await _service.createEntry(
        spaceId: spaceId,
        userId: userId,
        entryType: entryType,
        category: category,
        subcategory: body['subcategory'] as String?,
        description: body['description'] as String?,
        amountCents: amountCents,
        currency: body['currency'] as String? ?? 'USD',
        isRecurring: body['is_recurring'] as bool? ?? false,
        recurrenceRule: body['recurrence_rule'] as String?,
        date: date,
      );

      return createdResponse(result);
    } on FinancesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create finance entry error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /entries?type=&category=&startDate=&endDate=&cursor=&limit=
  ///
  /// Gets paginated finance entries for the current space.
  Future<Response> _getEntries(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final params = request.url.queryParameters;

      final entryType = params['type'];
      final category = params['category'];
      final createdBy = params['createdBy'];
      final isRecurringStr = params['isRecurring'];

      DateTime? startDate;
      if (params['startDate'] != null) {
        startDate = DateTime.tryParse(params['startDate']!);
        if (startDate == null) {
          return validationErrorResponse(
            'Invalid startDate format. Use ISO 8601 format.',
          );
        }
      }

      DateTime? endDate;
      if (params['endDate'] != null) {
        endDate = DateTime.tryParse(params['endDate']!);
        if (endDate == null) {
          return validationErrorResponse(
            'Invalid endDate format. Use ISO 8601 format.',
          );
        }
      }

      bool? isRecurring;
      if (isRecurringStr != null) {
        isRecurring = isRecurringStr == 'true';
      }

      final pagination = getPaginationParams(request);

      final result = await _service.getEntries(
        spaceId: spaceId,
        userId: userId,
        entryType: entryType,
        category: category,
        startDate: startDate,
        endDate: endDate,
        createdBy: createdBy,
        isRecurring: isRecurring,
        cursor: pagination.cursor,
        limit: pagination.limit,
      );

      return paginatedResponse(
        result['data'] as List<dynamic>,
        cursor: result['cursor'] as String?,
        hasMore: result['has_more'] as bool,
      );
    } on FinancesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get finance entries error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /entries/<entryId>
  ///
  /// Gets a single finance entry by ID with split details.
  Future<Response> _getEntry(Request request, String entryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final entry = await _service.getEntry(
        entryId: entryId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(entry);
    } on FinancesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get finance entry error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /entries/<entryId>
  ///
  /// Partially updates a finance entry.
  /// Body: any subset of { entry_type, category, subcategory, description,
  ///   amount_cents, currency, is_recurring, recurrence_rule, date }
  Future<Response> _updateEntry(Request request, String entryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final membership = getMembership(request);
      final userRole = membership?.role ?? 'member';
      final body = await readJsonBody(request);

      // Build the updates map
      final updates = <String, dynamic>{};

      if (body.containsKey('entry_type')) {
        updates['entry_type'] = body['entry_type'];
      }
      if (body.containsKey('category')) {
        updates['category'] = body['category'];
      }
      if (body.containsKey('subcategory')) {
        updates['subcategory'] = body['subcategory'];
      }
      if (body.containsKey('description')) {
        updates['description'] = body['description'];
      }
      if (body.containsKey('amount_cents')) {
        updates['amount_cents'] = body['amount_cents'];
      }
      if (body.containsKey('currency')) {
        updates['currency'] = body['currency'];
      }
      if (body.containsKey('is_recurring')) {
        updates['is_recurring'] = body['is_recurring'];
      }
      if (body.containsKey('recurrence_rule')) {
        updates['recurrence_rule'] = body['recurrence_rule'];
      }
      if (body.containsKey('date')) {
        final date = DateTime.tryParse(body['date'] as String);
        if (date == null) {
          return validationErrorResponse(
            'Invalid date format. Use ISO 8601 format.',
          );
        }
        updates['date'] = date;
      }

      final result = await _service.updateEntry(
        entryId: entryId,
        spaceId: spaceId,
        userId: userId,
        userRole: userRole,
        updates: updates,
      );

      return jsonResponse(result);
    } on FinancesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update finance entry error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /entries/<entryId>
  ///
  /// Soft-deletes a finance entry.
  Future<Response> _deleteEntry(Request request, String entryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final membership = getMembership(request);
      final userRole = membership?.role ?? 'member';

      await _service.deleteEntry(
        entryId: entryId,
        spaceId: spaceId,
        userId: userId,
        userRole: userRole,
      );

      return noContentResponse();
    } on FinancesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete finance entry error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /entries/<entryId>/split
  ///
  /// Creates an expense split for a finance entry.
  /// Body: {
  ///   "payer_user_id": "...",
  ///   "split_type": "equal|exact|percentage",
  ///   "shares": [
  ///     { "user_id": "...", "share_amount_cents": 2500, "share_percentage": 50.0 }
  ///   ]
  /// }
  Future<Response> _createSplit(Request request, String entryId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final body = await readJsonBody(request);

      final payerUserId = body['payer_user_id'] as String?;
      final splitType = body['split_type'] as String?;

      if (payerUserId == null || splitType == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (payerUserId == null)
              {
                'field': 'payer_user_id',
                'message': 'Payer user ID is required',
              },
            if (splitType == null)
              {'field': 'split_type', 'message': 'Split type is required'},
          ],
        );
      }

      // Parse optional shares list
      List<Map<String, dynamic>>? shares;
      if (body['shares'] != null) {
        final rawShares = body['shares'] as List<dynamic>;
        shares = rawShares
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }

      final result = await _service.createSplit(
        entryId: entryId,
        spaceId: spaceId,
        userId: userId,
        payerUserId: payerUserId,
        splitType: splitType,
        shares: shares,
      );

      return createdResponse(result);
    } on FinancesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create split error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /splits/<shareId>/settle
  ///
  /// Marks a split share as settled.
  Future<Response> _settleSplitShare(Request request, String shareId) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final result = await _service.settleSplitShare(
        shareId: shareId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(result);
    } on FinancesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Settle split share error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /balances
  ///
  /// Gets balance summaries for all users in the space.
  Future<Response> _getBalances(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final balances = await _service.getBalances(
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse({'data': balances});
    } on FinancesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get balances error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /dashboard?startDate=&endDate=
  ///
  /// Gets dashboard statistics for the current space.
  Future<Response> _getDashboardStats(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);
      final params = request.url.queryParameters;

      DateTime? startDate;
      if (params['startDate'] != null) {
        startDate = DateTime.tryParse(params['startDate']!);
        if (startDate == null) {
          return validationErrorResponse(
            'Invalid startDate format. Use ISO 8601 format.',
          );
        }
      }

      DateTime? endDate;
      if (params['endDate'] != null) {
        endDate = DateTime.tryParse(params['endDate']!);
        if (endDate == null) {
          return validationErrorResponse(
            'Invalid endDate format. Use ISO 8601 format.',
          );
        }
      }

      final stats = await _service.getDashboardStats(
        spaceId: spaceId,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return jsonResponse(stats);
    } on FinancesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get dashboard stats error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /trends?months=
  ///
  /// Gets monthly income/expense trend data.
  Future<Response> _getMonthlyTrend(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = getSpaceId(request);

      final monthsStr = request.url.queryParameters['months'];
      final months = monthsStr != null ? (int.tryParse(monthsStr) ?? 12) : 12;

      final trend = await _service.getMonthlyTrend(
        spaceId: spaceId,
        userId: userId,
        months: months,
      );

      return jsonResponse({'data': trend});
    } on FinancesException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get monthly trend error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
