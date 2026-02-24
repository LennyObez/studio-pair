import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';

// ── Filter state providers ──────────────────────────────────────────────

/// Filter by entry type: 'income', 'expense', or null for all.
final financeTypeFilter = StateProvider<String?>((ref) => null);

// ── Finance summary state ───────────────────────────────────────────────

/// Finance summary (loaded separately from entries).
final financeSummaryProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

// ── Async notifier ──────────────────────────────────────────────────────

/// Finances notifier backed by the [FinancesRepository].
///
/// The [build] method fetches finance entries from the repository
/// (API + cache) whenever the current space changes.
class FinancesNotifier
    extends AutoDisposeAsyncNotifier<List<CachedFinanceEntry>> {
  @override
  Future<List<CachedFinanceEntry>> build() async {
    final repo = ref.watch(financesRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    if (spaceId == null) return [];
    return repo.getEntries(spaceId);
  }

  /// Create a new finance entry and refresh the list.
  Future<bool> createEntry(
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
    final repo = ref.read(financesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.createEntry(
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
      return repo.getEntries(spaceId);
    });
    return !state.hasError;
  }

  /// Update a finance entry and refresh the list.
  Future<bool> updateEntry(
    String spaceId,
    String entryId,
    Map<String, dynamic> data,
  ) async {
    final repo = ref.read(financesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.updateEntry(spaceId, entryId, data);
      return repo.getEntries(spaceId);
    });
    return !state.hasError;
  }

  /// Delete a finance entry and refresh the list.
  Future<bool> deleteEntry(String spaceId, String entryId) async {
    final repo = ref.read(financesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteEntry(spaceId, entryId);
      return repo.getEntries(spaceId);
    });
    return !state.hasError;
  }

  /// Load a financial summary for a date range.
  Future<void> loadSummary(
    String spaceId, {
    String? startDate,
    String? endDate,
  }) async {
    final repo = ref.read(financesRepositoryProvider);
    try {
      final summary = await repo.getSummary(
        spaceId,
        startDate: startDate,
        endDate: endDate,
      );
      ref.read(financeSummaryProvider.notifier).state = summary;
    } catch (_) {
      // Summary load failure is non-fatal; entries still available.
    }
  }
}

/// Finances async provider.
final financesProvider =
    AsyncNotifierProvider.autoDispose<
      FinancesNotifier,
      List<CachedFinanceEntry>
    >(FinancesNotifier.new);

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for the filtered list of finance entries.
final financeEntriesProvider = Provider<List<CachedFinanceEntry>>((ref) {
  final entries = ref.watch(financesProvider).valueOrNull ?? [];
  final typeFilter = ref.watch(financeTypeFilter);
  if (typeFilter == null) return entries;
  return entries.where((e) => e.type == typeFilter).toList();
});
