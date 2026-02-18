import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for finance-related database operations.
class FinancesRepository {
  final Database _db;
  // ignore: unused_field
  final Logger _log = Logger('FinancesRepository');

  FinancesRepository(this._db);

  // ---------------------------------------------------------------------------
  // Finance Entries
  // ---------------------------------------------------------------------------

  /// Creates a new finance entry and returns the created entry row.
  Future<Map<String, dynamic>> createEntry({
    required String id,
    required String spaceId,
    required String createdBy,
    required String entryType,
    required String category,
    String? subcategory,
    String? description,
    required int amountCents,
    required String currency,
    required bool isRecurring,
    String? recurrenceRule,
    required DateTime date,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO finance_entries (
        id, space_id, created_by, entry_type, category, subcategory,
        description, amount_cents, currency, is_recurring, recurrence_rule,
        date, created_at, updated_at
      )
      VALUES (
        @id, @spaceId, @createdBy, @entryType, @category, @subcategory,
        @description, @amountCents, @currency, @isRecurring, @recurrenceRule,
        @date, NOW(), NOW()
      )
      RETURNING id, space_id, created_by, entry_type, category, subcategory,
                description, amount_cents, currency, is_recurring,
                recurrence_rule, date, created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'spaceId': spaceId,
        'createdBy': createdBy,
        'entryType': entryType,
        'category': category,
        'subcategory': subcategory,
        'description': description,
        'amountCents': amountCents,
        'currency': currency,
        'isRecurring': isRecurring,
        'recurrenceRule': recurrenceRule,
        'date': date,
      },
    );

    return _entryRowToMap(row!);
  }

  /// Gets an entry by ID, including its split and shares.
  Future<Map<String, dynamic>?> getEntryById(String entryId) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, created_by, entry_type, category, subcategory,
             description, amount_cents, currency, is_recurring,
             recurrence_rule, date, created_at, updated_at, deleted_at
      FROM finance_entries
      WHERE id = @entryId AND deleted_at IS NULL
      ''',
      parameters: {'entryId': entryId},
    );

    if (row == null) return null;

    final entry = _entryRowWithDeletedToMap(row);

    // Fetch split with shares
    final split = await getSplitForEntry(entryId);
    entry['split'] = split;

    return entry;
  }

  /// Gets paginated finance entries for a space with optional filters.
  Future<List<Map<String, dynamic>>> getEntries(
    String spaceId, {
    String? entryType,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? createdBy,
    bool? isRecurring,
    String? cursor,
    int limit = 25,
  }) async {
    final conditions = <String>['space_id = @spaceId', 'deleted_at IS NULL'];
    final params = <String, dynamic>{
      'spaceId': spaceId,
      'limit': limit + 1, // Fetch one extra for cursor detection
    };

    if (entryType != null) {
      conditions.add('entry_type = @entryType');
      params['entryType'] = entryType;
    }
    if (category != null) {
      conditions.add('category = @category');
      params['category'] = category;
    }
    if (startDate != null) {
      conditions.add('date >= @startDate');
      params['startDate'] = startDate;
    }
    if (endDate != null) {
      conditions.add('date <= @endDate');
      params['endDate'] = endDate;
    }
    if (createdBy != null) {
      conditions.add('created_by = @createdBy');
      params['createdBy'] = createdBy;
    }
    if (isRecurring != null) {
      conditions.add('is_recurring = @isRecurring');
      params['isRecurring'] = isRecurring;
    }
    if (cursor != null) {
      conditions.add('created_at < @cursor');
      params['cursor'] = DateTime.parse(cursor);
    }

    final whereClause = conditions.join(' AND ');

    final result = await _db.query('''
      SELECT id, space_id, created_by, entry_type, category, subcategory,
             description, amount_cents, currency, is_recurring,
             recurrence_rule, date, created_at, updated_at
      FROM finance_entries
      WHERE $whereClause
      ORDER BY date DESC, created_at DESC
      LIMIT @limit
      ''', parameters: params);

    return result.map(_entryRowToMap).toList();
  }

  /// Updates an entry with the given fields.
  Future<Map<String, dynamic>?> updateEntry(
    String entryId,
    Map<String, dynamic> updates,
  ) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'entryId': entryId};

    if (updates.containsKey('entry_type')) {
      setClauses.add('entry_type = @entryType');
      params['entryType'] = updates['entry_type'];
    }
    if (updates.containsKey('category')) {
      setClauses.add('category = @category');
      params['category'] = updates['category'];
    }
    if (updates.containsKey('subcategory')) {
      setClauses.add('subcategory = @subcategory');
      params['subcategory'] = updates['subcategory'];
    }
    if (updates.containsKey('description')) {
      setClauses.add('description = @description');
      params['description'] = updates['description'];
    }
    if (updates.containsKey('amount_cents')) {
      setClauses.add('amount_cents = @amountCents');
      params['amountCents'] = updates['amount_cents'];
    }
    if (updates.containsKey('currency')) {
      setClauses.add('currency = @currency');
      params['currency'] = updates['currency'];
    }
    if (updates.containsKey('is_recurring')) {
      setClauses.add('is_recurring = @isRecurring');
      params['isRecurring'] = updates['is_recurring'];
    }
    if (updates.containsKey('recurrence_rule')) {
      setClauses.add('recurrence_rule = @recurrenceRule');
      params['recurrenceRule'] = updates['recurrence_rule'];
    }
    if (updates.containsKey('date')) {
      setClauses.add('date = @date');
      params['date'] = updates['date'];
    }

    if (setClauses.isEmpty) return getEntryById(entryId);

    setClauses.add('updated_at = NOW()');

    final row = await _db.queryOne('''
      UPDATE finance_entries
      SET ${setClauses.join(', ')}
      WHERE id = @entryId AND deleted_at IS NULL
      RETURNING id, space_id, created_by, entry_type, category, subcategory,
                description, amount_cents, currency, is_recurring,
                recurrence_rule, date, created_at, updated_at
      ''', parameters: params);

    if (row == null) return null;
    return _entryRowToMap(row);
  }

  /// Soft-deletes a finance entry.
  Future<void> softDeleteEntry(String entryId) async {
    await _db.execute(
      '''
      UPDATE finance_entries
      SET deleted_at = NOW(), updated_at = NOW()
      WHERE id = @entryId AND deleted_at IS NULL
      ''',
      parameters: {'entryId': entryId},
    );
  }

  // ---------------------------------------------------------------------------
  // Expense Splits
  // ---------------------------------------------------------------------------

  /// Creates an expense split for a finance entry.
  Future<Map<String, dynamic>> createSplit({
    required String id,
    required String financeEntryId,
    required String payerUserId,
    required String splitType,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO expense_splits (
        id, finance_entry_id, payer_user_id, split_type, created_at
      )
      VALUES (@id, @financeEntryId, @payerUserId, @splitType, NOW())
      RETURNING id, finance_entry_id, payer_user_id, split_type, created_at
      ''',
      parameters: {
        'id': id,
        'financeEntryId': financeEntryId,
        'payerUserId': payerUserId,
        'splitType': splitType,
      },
    );

    return _splitRowToMap(row!);
  }

  /// Adds a share to an expense split.
  Future<Map<String, dynamic>> addSplitShare({
    required String id,
    required String splitId,
    required String userId,
    required int shareAmountCents,
    double? sharePercentage,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO expense_split_shares (
        id, split_id, user_id, share_amount_cents, share_percentage,
        is_settled, created_at
      )
      VALUES (@id, @splitId, @userId, @shareAmountCents, @sharePercentage,
              FALSE, NOW())
      RETURNING id, split_id, user_id, share_amount_cents, share_percentage,
                is_settled, settled_at, created_at
      ''',
      parameters: {
        'id': id,
        'splitId': splitId,
        'userId': userId,
        'shareAmountCents': shareAmountCents,
        'sharePercentage': sharePercentage,
      },
    );

    return _shareRowToMap(row!);
  }

  /// Gets the split and its shares for a finance entry.
  Future<Map<String, dynamic>?> getSplitForEntry(String entryId) async {
    final splitRow = await _db.queryOne(
      '''
      SELECT id, finance_entry_id, payer_user_id, split_type, created_at
      FROM expense_splits
      WHERE finance_entry_id = @entryId
      ''',
      parameters: {'entryId': entryId},
    );

    if (splitRow == null) return null;

    final split = _splitRowToMap(splitRow);

    // Fetch shares for this split
    final shareRows = await _db.query(
      '''
      SELECT ess.id, ess.split_id, ess.user_id, ess.share_amount_cents,
             ess.share_percentage, ess.is_settled, ess.settled_at, ess.created_at,
             u.display_name, u.email, u.avatar_url
      FROM expense_split_shares ess
      JOIN users u ON u.id = ess.user_id
      WHERE ess.split_id = @splitId
      ORDER BY ess.created_at ASC
      ''',
      parameters: {'splitId': split['id']},
    );

    split['shares'] = shareRows.map(_shareWithUserRowToMap).toList();

    return split;
  }

  /// Marks a split share as settled.
  Future<Map<String, dynamic>?> settleSplitShare(String shareId) async {
    final row = await _db.queryOne(
      '''
      UPDATE expense_split_shares
      SET is_settled = TRUE, settled_at = NOW()
      WHERE id = @shareId AND is_settled = FALSE
      RETURNING id, split_id, user_id, share_amount_cents, share_percentage,
                is_settled, settled_at, created_at
      ''',
      parameters: {'shareId': shareId},
    );

    if (row == null) return null;
    return _shareRowToMap(row);
  }

  /// Gets balance summaries for all users in a space across unsettled splits.
  Future<List<Map<String, dynamic>>> getBalances(String spaceId) async {
    final result = await _db.query(
      '''
      WITH unsettled AS (
        SELECT es.payer_user_id, ess.user_id AS debtor_user_id,
               ess.share_amount_cents
        FROM expense_split_shares ess
        JOIN expense_splits es ON es.id = ess.split_id
        JOIN finance_entries fe ON fe.id = es.finance_entry_id
        WHERE fe.space_id = @spaceId
          AND fe.deleted_at IS NULL
          AND ess.is_settled = FALSE
      ),
      total_owed AS (
        SELECT debtor_user_id AS user_id,
               COALESCE(SUM(share_amount_cents), 0) AS total_owed
        FROM unsettled
        WHERE debtor_user_id != payer_user_id
        GROUP BY debtor_user_id
      ),
      total_owing AS (
        SELECT payer_user_id AS user_id,
               COALESCE(SUM(share_amount_cents), 0) AS total_owing
        FROM unsettled
        WHERE debtor_user_id != payer_user_id
        GROUP BY payer_user_id
      )
      SELECT COALESCE(o.user_id, w.user_id) AS user_id,
             COALESCE(o.total_owed, 0) AS total_owed,
             COALESCE(w.total_owing, 0) AS total_owing
      FROM total_owed o
      FULL OUTER JOIN total_owing w ON o.user_id = w.user_id
      ORDER BY user_id
      ''',
      parameters: {'spaceId': spaceId},
    );

    return result
        .map(
          (row) => {
            'user_id': row[0] as String,
            'total_owed': row[1] as int,
            'total_owing': row[2] as int,
          },
        )
        .toList();
  }

  /// Gets dashboard statistics for a space within an optional date range.
  Future<Map<String, dynamic>> getDashboardStats(
    String spaceId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dateConditions = <String>[];
    final params = <String, dynamic>{'spaceId': spaceId};

    if (startDate != null) {
      dateConditions.add('AND date >= @startDate');
      params['startDate'] = startDate;
    }
    if (endDate != null) {
      dateConditions.add('AND date <= @endDate');
      params['endDate'] = endDate;
    }

    final dateFilter = dateConditions.join(' ');

    // Total income
    final incomeRow = await _db.queryOne('''
      SELECT COALESCE(SUM(amount_cents), 0)
      FROM finance_entries
      WHERE space_id = @spaceId AND deleted_at IS NULL
        AND entry_type = 'income' $dateFilter
      ''', parameters: params);
    final totalIncome = (incomeRow?[0] as int?) ?? 0;

    // Total expenses
    final expenseRow = await _db.queryOne('''
      SELECT COALESCE(SUM(amount_cents), 0)
      FROM finance_entries
      WHERE space_id = @spaceId AND deleted_at IS NULL
        AND entry_type = 'expense' $dateFilter
      ''', parameters: params);
    final totalExpenses = (expenseRow?[0] as int?) ?? 0;

    // By category
    final categoryRows = await _db.query('''
      SELECT category, COALESCE(SUM(amount_cents), 0) AS total
      FROM finance_entries
      WHERE space_id = @spaceId AND deleted_at IS NULL $dateFilter
      GROUP BY category
      ORDER BY total DESC
      ''', parameters: params);

    final byCategory = categoryRows
        .map((row) => {'category': row[0] as String, 'total': row[1] as int})
        .toList();

    return {
      'total_income': totalIncome,
      'total_expenses': totalExpenses,
      'by_category': byCategory,
    };
  }

  /// Gets monthly income/expense totals for a space.
  Future<List<Map<String, dynamic>>> getMonthlyTrend(
    String spaceId,
    int months,
  ) async {
    final result = await _db.query(
      '''
      SELECT
        DATE_TRUNC('month', date) AS month,
        COALESCE(SUM(CASE WHEN entry_type = 'income' THEN amount_cents ELSE 0 END), 0) AS income,
        COALESCE(SUM(CASE WHEN entry_type = 'expense' THEN amount_cents ELSE 0 END), 0) AS expenses
      FROM finance_entries
      WHERE space_id = @spaceId
        AND deleted_at IS NULL
        AND date >= DATE_TRUNC('month', NOW()) - INTERVAL '1 month' * @months
      GROUP BY DATE_TRUNC('month', date)
      ORDER BY month ASC
      ''',
      parameters: {'spaceId': spaceId, 'months': months},
    );

    return result
        .map(
          (row) => {
            'month': (row[0] as DateTime).toIso8601String(),
            'income': row[1] as int,
            'expenses': row[2] as int,
          },
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _entryRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_by': row[2] as String,
      'entry_type': row[3] as String,
      'category': row[4] as String,
      'subcategory': row[5] as String?,
      'description': row[6] as String?,
      'amount_cents': row[7] as int,
      'currency': row[8] as String,
      'is_recurring': row[9] as bool,
      'recurrence_rule': row[10] as String?,
      'date': (row[11] as DateTime).toIso8601String(),
      'created_at': (row[12] as DateTime).toIso8601String(),
      'updated_at': (row[13] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _entryRowWithDeletedToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_by': row[2] as String,
      'entry_type': row[3] as String,
      'category': row[4] as String,
      'subcategory': row[5] as String?,
      'description': row[6] as String?,
      'amount_cents': row[7] as int,
      'currency': row[8] as String,
      'is_recurring': row[9] as bool,
      'recurrence_rule': row[10] as String?,
      'date': (row[11] as DateTime).toIso8601String(),
      'created_at': (row[12] as DateTime).toIso8601String(),
      'updated_at': (row[13] as DateTime).toIso8601String(),
      'deleted_at': row[14] != null
          ? (row[14] as DateTime).toIso8601String()
          : null,
    };
  }

  Map<String, dynamic> _splitRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'finance_entry_id': row[1] as String,
      'payer_user_id': row[2] as String,
      'split_type': row[3] as String,
      'created_at': (row[4] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _shareRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'split_id': row[1] as String,
      'user_id': row[2] as String,
      'share_amount_cents': row[3] as int,
      'share_percentage': row[4] as double?,
      'is_settled': row[5] as bool,
      'settled_at': row[6] != null
          ? (row[6] as DateTime).toIso8601String()
          : null,
      'created_at': (row[7] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _shareWithUserRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'split_id': row[1] as String,
      'user_id': row[2] as String,
      'share_amount_cents': row[3] as int,
      'share_percentage': row[4] as double?,
      'is_settled': row[5] as bool,
      'settled_at': row[6] != null
          ? (row[6] as DateTime).toIso8601String()
          : null,
      'created_at': (row[7] as DateTime).toIso8601String(),
      'user': {
        'display_name': row[8] as String,
        'email': row[9] as String,
        'avatar_url': row[10] as String?,
      },
    };
  }
}
