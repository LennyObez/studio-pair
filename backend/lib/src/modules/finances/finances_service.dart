import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../services/notification_service.dart';
import '../calendar/calendar_service.dart';
import '../spaces/spaces_repository.dart';
import 'finances_repository.dart';

/// Custom exception for finance-related errors.
class FinancesException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const FinancesException(
    this.message, {
    this.code = 'FINANCES_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'FinancesException($code): $message';
}

/// Service containing all finance-related business logic.
class FinancesService {
  final FinancesRepository _repo;
  final SpacesRepository _spacesRepo;
  final CalendarService _calendarService;
  final NotificationService _notificationService;
  final Logger _log = Logger('FinancesService');
  final Uuid _uuid = const Uuid();

  /// Valid entry types.
  static const _validEntryTypes = ['income', 'expense'];

  /// Valid categories.
  static const _validCategories = [
    'housing',
    'utilities',
    'groceries',
    'dining',
    'transport',
    'entertainment',
    'healthcare',
    'insurance',
    'subscriptions',
    'shopping',
    'travel',
    'gifts',
    'education',
    'personal',
    'salary',
    'freelance',
    'investment',
    'other',
  ];

  /// Valid split types.
  static const _validSplitTypes = ['equal', 'exact', 'percentage'];

  FinancesService(
    this._repo,
    this._spacesRepo,
    this._calendarService,
    this._notificationService,
  );

  // ---------------------------------------------------------------------------
  // Entry CRUD
  // ---------------------------------------------------------------------------

  /// Creates a new finance entry.
  ///
  /// Validates inputs, checks space membership, optionally creates a calendar
  /// event for recurring entries, and returns the complete entry.
  Future<Map<String, dynamic>> createEntry({
    required String spaceId,
    required String userId,
    required String entryType,
    required String category,
    String? subcategory,
    String? description,
    required int amountCents,
    String currency = 'EUR',
    bool isRecurring = false,
    String? recurrenceRule,
    required DateTime date,
  }) async {
    // Validate amount
    if (amountCents <= 0) {
      throw const FinancesException(
        'Amount must be greater than zero',
        code: 'INVALID_AMOUNT',
        statusCode: 422,
      );
    }

    // Validate entry type
    if (!_validEntryTypes.contains(entryType)) {
      throw FinancesException(
        'Invalid entry type. Must be one of: ${_validEntryTypes.join(", ")}',
        code: 'INVALID_ENTRY_TYPE',
        statusCode: 422,
      );
    }

    // Validate category
    if (!_validCategories.contains(category)) {
      throw FinancesException(
        'Invalid category. Must be one of: ${_validCategories.join(", ")}',
        code: 'INVALID_CATEGORY',
        statusCode: 422,
      );
    }

    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    final entryId = _uuid.v4();

    // Create the entry
    final entry = await _repo.createEntry(
      id: entryId,
      spaceId: spaceId,
      createdBy: userId,
      entryType: entryType,
      category: category,
      subcategory: subcategory?.trim(),
      description: description?.trim(),
      amountCents: amountCents,
      currency: currency,
      isRecurring: isRecurring,
      recurrenceRule: recurrenceRule,
      date: date,
    );

    // If recurring, create a calendar event
    if (isRecurring && recurrenceRule != null) {
      try {
        await _calendarService.createEvent(
          spaceId: spaceId,
          userId: userId,
          title:
              '${entryType == 'income' ? 'Income' : 'Expense'}: ${description ?? category}',
          eventType: 'finance',
          startAt: date,
          endAt: date.add(const Duration(hours: 1)),
          recurrenceRule: recurrenceRule,
          sourceModule: 'finance',
          sourceEntityId: entryId,
        );
      } catch (e) {
        _log.warning('Failed to create calendar event for recurring entry: $e');
      }
    }

    _log.info(
      'Finance entry created: $entryType/$category ($entryId) in space $spaceId',
    );

    return entry;
  }

  /// Gets a single finance entry by ID with split details.
  ///
  /// Verifies the requesting user has access to the entry's space.
  Future<Map<String, dynamic>> getEntry({
    required String entryId,
    required String spaceId,
    required String userId,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    final entry = await _repo.getEntryById(entryId);
    if (entry == null) {
      throw const FinancesException(
        'Finance entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the entry belongs to the requested space
    if (entry['space_id'] != spaceId) {
      throw const FinancesException(
        'Finance entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    return entry;
  }

  /// Gets paginated finance entries for a space with optional filters.
  Future<Map<String, dynamic>> getEntries({
    required String spaceId,
    required String userId,
    String? entryType,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? createdBy,
    bool? isRecurring,
    String? cursor,
    int limit = 25,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Validate entry type filter if provided
    if (entryType != null && !_validEntryTypes.contains(entryType)) {
      throw FinancesException(
        'Invalid entry type filter. Must be one of: ${_validEntryTypes.join(", ")}',
        code: 'INVALID_ENTRY_TYPE',
        statusCode: 422,
      );
    }

    // Clamp limit
    final clampedLimit = limit.clamp(1, 100);

    final entries = await _repo.getEntries(
      spaceId,
      entryType: entryType,
      category: category,
      startDate: startDate,
      endDate: endDate,
      createdBy: createdBy,
      isRecurring: isRecurring,
      cursor: cursor,
      limit: clampedLimit,
    );

    // Determine if there are more results
    final hasMore = entries.length > clampedLimit;
    final data = hasMore ? entries.sublist(0, clampedLimit) : entries;
    final nextCursor = hasMore ? data.last['created_at'] as String : null;

    return {'data': data, 'cursor': nextCursor, 'has_more': hasMore};
  }

  /// Updates an existing finance entry.
  ///
  /// Verifies ownership or admin role before allowing the update.
  Future<Map<String, dynamic>> updateEntry({
    required String entryId,
    required String spaceId,
    required String userId,
    required String userRole,
    required Map<String, dynamic> updates,
  }) async {
    // Fetch the existing entry
    final existing = await _repo.getEntryById(entryId);
    if (existing == null) {
      throw const FinancesException(
        'Finance entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the entry belongs to the requested space
    if (existing['space_id'] != spaceId) {
      throw const FinancesException(
        'Finance entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify ownership or admin role
    final isCreator = existing['created_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdmin) {
      throw const FinancesException(
        'Only the entry creator or a space admin can update this entry',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Validate entry type if provided
    if (updates.containsKey('entry_type')) {
      final type = updates['entry_type'] as String?;
      if (type != null && !_validEntryTypes.contains(type)) {
        throw FinancesException(
          'Invalid entry type. Must be one of: ${_validEntryTypes.join(", ")}',
          code: 'INVALID_ENTRY_TYPE',
          statusCode: 422,
        );
      }
    }

    // Validate category if provided
    if (updates.containsKey('category')) {
      final cat = updates['category'] as String?;
      if (cat != null && !_validCategories.contains(cat)) {
        throw FinancesException(
          'Invalid category. Must be one of: ${_validCategories.join(", ")}',
          code: 'INVALID_CATEGORY',
          statusCode: 422,
        );
      }
    }

    // Validate amount if provided
    if (updates.containsKey('amount_cents')) {
      final amount = updates['amount_cents'] as int?;
      if (amount != null && amount <= 0) {
        throw const FinancesException(
          'Amount must be greater than zero',
          code: 'INVALID_AMOUNT',
          statusCode: 422,
        );
      }
    }

    // Update the entry
    final updated = await _repo.updateEntry(entryId, updates);
    if (updated == null) {
      throw const FinancesException(
        'Finance entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('Finance entry updated: $entryId in space $spaceId by $userId');

    return updated;
  }

  /// Deletes a finance entry (soft delete).
  ///
  /// Verifies ownership or admin role before allowing the deletion.
  Future<void> deleteEntry({
    required String entryId,
    required String spaceId,
    required String userId,
    required String userRole,
  }) async {
    // Fetch the existing entry
    final existing = await _repo.getEntryById(entryId);
    if (existing == null) {
      throw const FinancesException(
        'Finance entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the entry belongs to the requested space
    if (existing['space_id'] != spaceId) {
      throw const FinancesException(
        'Finance entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify ownership or admin role
    final isCreator = existing['created_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdmin) {
      throw const FinancesException(
        'Only the entry creator or a space admin can delete this entry',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.softDeleteEntry(entryId);

    _log.info('Finance entry deleted: $entryId in space $spaceId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Splits
  // ---------------------------------------------------------------------------

  /// Creates an expense split for a finance entry.
  ///
  /// Validates the payer is a space member, validates split type, and if
  /// equal split, automatically calculates shares for all space members.
  Future<Map<String, dynamic>> createSplit({
    required String entryId,
    required String spaceId,
    required String userId,
    required String payerUserId,
    required String splitType,
    List<Map<String, dynamic>>? shares,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Validate split type
    if (!_validSplitTypes.contains(splitType)) {
      throw FinancesException(
        'Invalid split type. Must be one of: ${_validSplitTypes.join(", ")}',
        code: 'INVALID_SPLIT_TYPE',
        statusCode: 422,
      );
    }

    // Fetch the entry
    final entry = await _repo.getEntryById(entryId);
    if (entry == null) {
      throw const FinancesException(
        'Finance entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (entry['space_id'] != spaceId) {
      throw const FinancesException(
        'Finance entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify payer is a space member
    final payerMembership = await _spacesRepo.getMember(spaceId, payerUserId);
    if (payerMembership == null || payerMembership['status'] != 'active') {
      throw const FinancesException(
        'Payer must be an active member of the space',
        code: 'INVALID_PAYER',
        statusCode: 422,
      );
    }

    final splitId = _uuid.v4();

    // Create the split
    final split = await _repo.createSplit(
      id: splitId,
      financeEntryId: entryId,
      payerUserId: payerUserId,
      splitType: splitType,
    );

    final createdShares = <Map<String, dynamic>>[];

    if (splitType == 'equal') {
      // Auto-calculate equal shares for all active space members
      final members = await _spacesRepo.listMembers(spaceId);
      final activeMembers = members
          .where((m) => m['status'] == 'active')
          .toList();

      if (activeMembers.isNotEmpty) {
        final totalAmount = entry['amount_cents'] as int;
        final shareAmount = totalAmount ~/ activeMembers.length;
        final remainder = totalAmount - (shareAmount * activeMembers.length);
        final sharePercentage = 100.0 / activeMembers.length;

        for (var i = 0; i < activeMembers.length; i++) {
          final memberId = activeMembers[i]['user_id'] as String;
          // Give the remainder to the first share
          final amount = i == 0 ? shareAmount + remainder : shareAmount;

          final share = await _repo.addSplitShare(
            id: _uuid.v4(),
            splitId: splitId,
            userId: memberId,
            shareAmountCents: amount,
            sharePercentage: sharePercentage,
          );
          createdShares.add(share);
        }
      }
    } else if (shares != null) {
      // Use provided shares for exact or percentage split
      for (final shareData in shares) {
        final shareUserId = shareData['user_id'] as String;
        final shareAmountCents = shareData['share_amount_cents'] as int;
        final sharePercentage = shareData['share_percentage'] as double?;

        final share = await _repo.addSplitShare(
          id: _uuid.v4(),
          splitId: splitId,
          userId: shareUserId,
          shareAmountCents: shareAmountCents,
          sharePercentage: sharePercentage,
        );
        createdShares.add(share);
      }
    }

    split['shares'] = createdShares;

    _log.info('Split created: $splitId for entry $entryId (type: $splitType)');

    return split;
  }

  /// Marks a split share as settled and notifies the payer.
  Future<Map<String, dynamic>> settleSplitShare({
    required String shareId,
    required String spaceId,
    required String userId,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    final settled = await _repo.settleSplitShare(shareId);
    if (settled == null) {
      throw const FinancesException(
        'Split share not found or already settled',
        code: 'SHARE_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Notify relevant parties
    await _notificationService.notify(
      userId: settled['user_id'] as String,
      type: 'finance.settlement',
      title: 'Split share settled',
      body: 'A split share has been marked as settled',
      spaceId: spaceId,
      data: {'share_id': shareId, 'split_id': settled['split_id']},
    );

    _log.info('Split share settled: $shareId in space $spaceId by $userId');

    return settled;
  }

  // ---------------------------------------------------------------------------
  // Balances & Stats
  // ---------------------------------------------------------------------------

  /// Computes who owes whom across all unsettled splits in a space.
  Future<List<Map<String, dynamic>>> getBalances({
    required String spaceId,
    required String userId,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    return _repo.getBalances(spaceId);
  }

  /// Aggregates income/expenses by category for a space dashboard.
  Future<Map<String, dynamic>> getDashboardStats({
    required String spaceId,
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    return _repo.getDashboardStats(
      spaceId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Gets monthly income/expense trend data for a space.
  Future<List<Map<String, dynamic>>> getMonthlyTrend({
    required String spaceId,
    required String userId,
    int months = 12,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Clamp months
    final clampedMonths = months.clamp(1, 36);

    return _repo.getMonthlyTrend(spaceId, clampedMonths);
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
      throw const FinancesException(
        'You do not have access to this space',
        code: 'SPACE_ACCESS_DENIED',
        statusCode: 403,
      );
    }
    return membership;
  }
}
