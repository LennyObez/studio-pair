import 'package:drift/drift.dart';
import 'package:studio_pair/src/services/api/finances_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/finances_dao.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Repository that wraps the Finances API and DAO to provide an
/// offline-first data layer with batch cache upserts.
class FinancesRepository {
  FinancesRepository(this._api, this._dao);

  final FinancesApi _api;
  final FinancesDao _dao;

  /// Returns cached finance entries, then fetches fresh from API and updates cache.
  Future<List<CachedFinanceEntry>> getEntries(
    String spaceId, {
    String? type,
  }) async {
    try {
      final response = await _api.listEntries(spaceId, type: type);
      final jsonList = _parseList(response.data);
      await _dao.db.batch((b) {
        b.insertAll(
          _dao.cachedFinanceEntries,
          jsonList
              .map(
                (json) => CachedFinanceEntriesCompanion.insert(
                  id: json['id'] as String,
                  spaceId: json['space_id'] as String? ?? spaceId,
                  createdBy: json['created_by'] as String? ?? '',
                  type: json['type'] as String? ?? 'expense',
                  category: Value(json['category'] as String?),
                  amountCents: json['amount_cents'] as int? ?? 0,
                  description: Value(json['description'] as String?),
                  recurrenceRule: Value(json['recurrence_rule'] as String?),
                  date:
                      DateTime.tryParse(json['date'] as String? ?? '') ??
                      DateTime.now(),
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
      return _dao.getEntries(spaceId, type: type).first;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getEntries(spaceId, type: type).first;
      if (cached.isNotEmpty) return cached;
      throw UnknownFailure('Failed to load finance entries: $e');
    }
  }

  /// Creates a new finance entry via the API.
  Future<Map<String, dynamic>> createEntry(
    String spaceId, {
    required String type,
    required String category,
    required double amount,
    required String currency,
    String? description,
    bool? isRecurring,
    String? recurrenceRule,
    String? date,
  }) async {
    try {
      final response = await _api.createEntry(
        spaceId,
        type: type,
        category: category,
        amount: amount,
        currency: currency,
        description: description,
        isRecurring: isRecurring,
        recurrenceRule: recurrenceRule,
        date: date,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to create finance entry: $e');
    }
  }

  /// Gets a specific finance entry by ID, with cache fallback.
  Future<Map<String, dynamic>> getEntry(String spaceId, String entryId) async {
    try {
      final response = await _api.getEntry(spaceId, entryId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = await _dao.getEntryById(entryId);
      if (cached != null) return {'id': cached.id, 'type': cached.type};
      throw UnknownFailure('Failed to get finance entry: $e');
    }
  }

  /// Updates a finance entry via the API.
  Future<Map<String, dynamic>> updateEntry(
    String spaceId,
    String entryId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _api.updateEntry(spaceId, entryId, data);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update finance entry: $e');
    }
  }

  /// Deletes a finance entry via the API and removes from cache.
  Future<void> deleteEntry(String spaceId, String entryId) async {
    try {
      await _api.deleteEntry(spaceId, entryId);
      await _dao.deleteEntry(entryId);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete finance entry: $e');
    }
  }

  /// Gets a financial summary for a date range.
  Future<Map<String, dynamic>> getSummary(
    String spaceId, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _api.getSummary(
        spaceId,
        startDate: startDate,
        endDate: endDate,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get financial summary: $e');
    }
  }

  /// Creates a split on a finance entry.
  Future<Map<String, dynamic>> createSplit(
    String spaceId,
    String entryId, {
    required String splitType,
    required List<Map<String, dynamic>> shares,
  }) async {
    try {
      final response = await _api.createSplit(
        spaceId,
        entryId,
        splitType: splitType,
        shares: shares,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to create split: $e');
    }
  }

  /// Gets balances for all members in a space.
  Future<Map<String, dynamic>> getBalances(String spaceId) async {
    try {
      final response = await _api.getBalances(spaceId);
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get balances: $e');
    }
  }

  /// Settles a balance between two users.
  Future<Map<String, dynamic>> settleBalance(
    String spaceId, {
    required String fromUserId,
    required String toUserId,
    required double amount,
  }) async {
    try {
      final response = await _api.settleBalance(
        spaceId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        amount: amount,
      );
      return response.data as Map<String, dynamic>;
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to settle balance: $e');
    }
  }

  /// Watches cached finance entries for a space (reactive stream).
  Stream<List<CachedFinanceEntry>> watchEntries(
    String spaceId, {
    String? type,
  }) {
    return _dao.getEntries(spaceId, type: type);
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
