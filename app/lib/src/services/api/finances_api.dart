import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Finances API service for income, expense tracking, splits, and balances within a space.
class FinancesApi {
  FinancesApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Create a new finance entry.
  Future<Response> createEntry(
    String spaceId, {
    required String type,
    required String category,
    required double amount,
    required String currency,
    String? description,
    bool? isRecurring,
    String? recurrenceRule,
    String? date,
  }) {
    return _client.post(
      '/spaces/$spaceId/finances/entries',
      data: {
        'type': type,
        'category': category,
        'amount': amount,
        'currency': currency,
        if (description != null) 'description': description,
        if (isRecurring != null) 'is_recurring': isRecurring,
        if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
        if (date != null) 'date': date,
      },
    );
  }

  /// List finance entries with optional filters.
  Future<Response> listEntries(
    String spaceId, {
    String? type,
    String? category,
    String? startDate,
    String? endDate,
    String? cursor,
    int? limit,
  }) {
    return _client.get(
      '/spaces/$spaceId/finances/entries',
      queryParameters: {
        if (type != null) 'type': type,
        if (category != null) 'category': category,
        if (startDate != null) 'start': startDate,
        if (endDate != null) 'end': endDate,
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
  }

  /// Get a specific finance entry by ID.
  Future<Response> getEntry(String spaceId, String entryId) {
    return _client.get('/spaces/$spaceId/finances/entries/$entryId');
  }

  /// Update a finance entry.
  Future<Response> updateEntry(
    String spaceId,
    String entryId,
    Map<String, dynamic> data,
  ) {
    return _client.patch(
      '/spaces/$spaceId/finances/entries/$entryId',
      data: data,
    );
  }

  /// Delete a finance entry.
  Future<Response> deleteEntry(String spaceId, String entryId) {
    return _client.delete('/spaces/$spaceId/finances/entries/$entryId');
  }

  /// Get a financial summary for a date range.
  Future<Response> getSummary(
    String spaceId, {
    String? startDate,
    String? endDate,
  }) {
    return _client.get(
      '/spaces/$spaceId/finances/summary',
      queryParameters: {
        if (startDate != null) 'start': startDate,
        if (endDate != null) 'end': endDate,
      },
    );
  }

  /// Create a split on a finance entry.
  Future<Response> createSplit(
    String spaceId,
    String entryId, {
    required String splitType,
    required List<Map<String, dynamic>> shares,
  }) {
    return _client.post(
      '/spaces/$spaceId/finances/entries/$entryId/split',
      data: {'split_type': splitType, 'shares': shares},
    );
  }

  /// Get balances for all members in a space.
  Future<Response> getBalances(String spaceId) {
    return _client.get('/spaces/$spaceId/finances/balances');
  }

  /// Settle a balance between two users.
  Future<Response> settleBalance(
    String spaceId, {
    required String fromUserId,
    required String toUserId,
    required double amount,
  }) {
    return _client.post(
      '/spaces/$spaceId/finances/settle',
      data: {
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'amount': amount,
      },
    );
  }
}
