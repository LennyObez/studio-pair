import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/finances_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/finances_dao.dart';

/// Finance entry model.
class FinanceEntry {
  const FinanceEntry({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.currency,
    this.description,
    required this.isRecurring,
    this.recurrenceRule,
    required this.date,
    this.createdBy,
  });

  factory FinanceEntry.fromJson(Map<String, dynamic> json) {
    return FinanceEntry(
      id: json['id'],
      type: json['type'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'EUR',
      description: json['description'],
      isRecurring: json['is_recurring'] ?? false,
      recurrenceRule: json['recurrence_rule'],
      date: json['date'] ?? '',
      createdBy: json['created_by'],
    );
  }

  /// Entry type: 'income' or 'expense'.
  final String id;
  final String type;
  final String category;
  final double amount;
  final String currency;
  final String? description;
  final bool isRecurring;
  final String? recurrenceRule;
  final String date;
  final String? createdBy;
}

/// Finance summary model.
class FinanceSummary {
  const FinanceSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.byCategory,
  });

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    return FinanceSummary(
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpenses: (json['total_expenses'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      byCategory:
          (json['by_category'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
    );
  }

  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final Map<String, double> byCategory;
}

/// Finances state.
class FinancesState {
  const FinancesState({
    this.entries = const [],
    this.summary,
    this.selectedType,
    this.isLoading = false,
    this.isCached = false,
    this.error,
  });

  final List<FinanceEntry> entries;
  final FinanceSummary? summary;

  /// Filter by type: 'income', 'expense', or null for all.
  final String? selectedType;
  final bool isLoading;
  final bool isCached;
  final String? error;

  FinancesState copyWith({
    List<FinanceEntry>? entries,
    FinanceSummary? summary,
    String? selectedType,
    bool? isLoading,
    bool? isCached,
    String? error,
    bool clearError = false,
    bool clearSelectedType = false,
    bool clearSummary = false,
  }) {
    return FinancesState(
      entries: entries ?? this.entries,
      summary: clearSummary ? null : (summary ?? this.summary),
      selectedType: clearSelectedType
          ? null
          : (selectedType ?? this.selectedType),
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Finances state notifier managing income and expense entries.
class FinancesNotifier extends StateNotifier<FinancesState> {
  FinancesNotifier(this._api, this._dao) : super(const FinancesState());

  final FinancesApi _api;
  final FinancesDao _dao;

  /// Load finance entries for a space.
  Future<void> loadEntries(
    String spaceId, {
    String? type,
    String? category,
    String? startDate,
    String? endDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // 1. Load from cache first
    try {
      final cached = await _dao.getEntries(spaceId, type: type).first;
      if (cached.isNotEmpty) {
        final entries = cached
            .map(
              (c) => FinanceEntry(
                id: c.id,
                type: c.type,
                category: c.category ?? '',
                amount: c.amountCents / 100.0,
                currency: c.currency,
                description: c.description,
                isRecurring: c.isRecurring,
                recurrenceRule: c.recurrenceRule,
                date: c.date.toIso8601String().split('T').first,
                createdBy: c.createdBy,
              ),
            )
            .toList();
        state = state.copyWith(
          entries: entries,
          isLoading: false,
          isCached: true,
        );
      }
    } catch (_) {
      // Cache read failed, continue to API
    }

    // 2. Try API in background
    try {
      final response = await _api.listEntries(
        spaceId,
        type: type,
        category: category,
        startDate: startDate,
        endDate: endDate,
      );
      final items = parseList(response.data);
      final entries = items.map(FinanceEntry.fromJson).toList();

      // Upsert into cache
      for (final item in entries) {
        await _dao.upsertEntry(
          CachedFinanceEntriesCompanion(
            id: Value(item.id),
            spaceId: Value(spaceId),
            createdBy: Value(item.createdBy ?? ''),
            type: Value(item.type),
            category: Value(item.category),
            amountCents: Value((item.amount * 100).round()),
            currency: Value(item.currency),
            description: Value(item.description),
            isRecurring: Value(item.isRecurring),
            recurrenceRule: Value(item.recurrenceRule),
            date: Value(DateTime.tryParse(item.date) ?? DateTime.now()),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
            syncedAt: Value(DateTime.now()),
          ),
        );
      }

      state = state.copyWith(
        entries: entries,
        isLoading: false,
        isCached: false,
      );
    } catch (e) {
      if (state.entries.isEmpty) {
        state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Create a new finance entry.
  Future<bool> createEntry(
    String spaceId, {
    required String type,
    required String category,
    required double amount,
    required String currency,
    String? description,
    required bool isRecurring,
    String? recurrenceRule,
    required String date,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

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

      final newEntry = FinanceEntry.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        entries: [...state.entries, newEntry],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Update an existing finance entry.
  Future<bool> updateEntry(
    String spaceId,
    String entryId,
    Map<String, dynamic> data,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.updateEntry(spaceId, entryId, data);
      final updated = FinanceEntry.fromJson(
        response.data as Map<String, dynamic>,
      );

      final updatedEntries = state.entries.map((entry) {
        if (entry.id == entryId) {
          return updated;
        }
        return entry;
      }).toList();

      state = state.copyWith(entries: updatedEntries, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Delete a finance entry.
  Future<bool> deleteEntry(String spaceId, String entryId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.deleteEntry(spaceId, entryId);

      state = state.copyWith(
        entries: state.entries.where((e) => e.id != entryId).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Load a financial summary for the space.
  Future<void> loadSummary(
    String spaceId, {
    String? startDate,
    String? endDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.getSummary(
        spaceId,
        startDate: startDate,
        endDate: endDate,
      );

      final summary = FinanceSummary.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(summary: summary, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  /// Set the type filter (income / expense / null for all).
  void setTypeFilter(String? type) {
    if (type == null) {
      state = state.copyWith(clearSelectedType: true);
    } else {
      state = state.copyWith(selectedType: type);
    }
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Finances state provider.
final financesProvider = StateNotifierProvider<FinancesNotifier, FinancesState>(
  (ref) {
    return FinancesNotifier(
      ref.watch(financesApiProvider),
      ref.watch(financesDaoProvider),
    );
  },
);

/// Convenience provider for the list of finance entries.
final financeEntriesProvider = Provider<List<FinanceEntry>>((ref) {
  final financesState = ref.watch(financesProvider);
  if (financesState.selectedType == null) {
    return financesState.entries;
  }
  return financesState.entries
      .where((e) => e.type == financesState.selectedType)
      .toList();
});

/// Convenience provider for the finance summary.
final financeSummaryProvider = Provider<FinanceSummary?>((ref) {
  return ref.watch(financesProvider).summary;
});
