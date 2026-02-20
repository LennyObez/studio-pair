import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';

// ── Filter state providers ──────────────────────────────────────────────

/// When true, show only active (open) polls; when false, show all.
final showActivePollsOnly = StateProvider<bool>((ref) => true);

// ── Async notifier ──────────────────────────────────────────────────────

/// Polls notifier backed by the [PollsRepository].
///
/// The [build] method fetches polls from the repository (API + cache)
/// whenever the current space changes.
class PollsNotifier extends AutoDisposeAsyncNotifier<List<CachedPoll>> {
  @override
  Future<List<CachedPoll>> build() async {
    final repo = ref.watch(pollsRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    if (spaceId == null) return [];
    return repo.getPolls(spaceId);
  }

  /// Create a new poll and refresh the list.
  Future<bool> createPoll(
    String spaceId, {
    required String question,
    required String type,
    required List<Map<String, dynamic>> options,
    bool? isAnonymous,
    String? deadline,
  }) async {
    final repo = ref.read(pollsRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.createPoll(
        spaceId,
        question: question,
        type: type,
        options: options,
        isAnonymous: isAnonymous,
        deadline: deadline,
      );
      return repo.getPolls(spaceId);
    });
    return !state.hasError;
  }

  /// Vote on a poll and refresh the list.
  Future<bool> vote(
    String spaceId,
    String pollId,
    List<String> optionIds, {
    Map<String, int>? ranks,
  }) async {
    final repo = ref.read(pollsRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.vote(spaceId, pollId, optionIds, ranks: ranks);
      return repo.getPolls(spaceId);
    });
    return !state.hasError;
  }

  /// Close a poll and refresh the list.
  Future<bool> closePoll(String spaceId, String pollId) async {
    final repo = ref.read(pollsRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.closePoll(spaceId, pollId);
      return repo.getPolls(spaceId);
    });
    return !state.hasError;
  }

  /// Delete a poll and refresh the list.
  Future<bool> deletePoll(String spaceId, String pollId) async {
    final repo = ref.read(pollsRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deletePoll(spaceId, pollId);
      return repo.getPolls(spaceId);
    });
    return !state.hasError;
  }

  /// Randomly pick a winning option from a poll.
  Future<Map<String, dynamic>?> randomPick(
    String spaceId,
    String pollId,
  ) async {
    final repo = ref.read(pollsRepositoryProvider);
    try {
      return await repo.randomPick(spaceId, pollId);
    } catch (_) {
      return null;
    }
  }
}

/// Polls async provider.
final pollsProvider =
    AsyncNotifierProvider.autoDispose<PollsNotifier, List<CachedPoll>>(
      PollsNotifier.new,
    );

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for the filtered list of polls.
final pollListProvider = Provider<List<CachedPoll>>((ref) {
  final polls = ref.watch(pollsProvider).valueOrNull ?? [];
  final activeOnly = ref.watch(showActivePollsOnly);
  if (activeOnly) {
    return polls.where((p) => p.isActive).toList();
  }
  return polls;
});

/// Convenience provider for the count of active (open) polls.
final activePollCountProvider = Provider<int>((ref) {
  final polls = ref.watch(pollsProvider).valueOrNull ?? [];
  return polls.where((p) => p.isActive).length;
});
