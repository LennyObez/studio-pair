import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';

// ── Async notifier ──────────────────────────────────────────────────────

/// Memories notifier backed by the [MemoriesRepository].
///
/// The [build] method fetches memories from the repository (API + cache)
/// whenever the current space changes.
class MemoriesNotifier extends AutoDisposeAsyncNotifier<List<CachedMemory>> {
  @override
  Future<List<CachedMemory>> build() async {
    final repo = ref.watch(memoriesRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    if (spaceId == null) return [];
    return repo.getMemories(spaceId);
  }

  /// Create a new memory and refresh the list.
  Future<bool> createMemory(
    String spaceId, {
    required String title,
    required String date,
    String? location,
    String? description,
    List<String>? mediaIds,
    String? linkedActivityId,
    bool? isMilestone,
    String? milestoneType,
  }) async {
    final repo = ref.read(memoriesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.createMemory(
        spaceId,
        title: title,
        date: date,
        location: location,
        description: description,
        mediaIds: mediaIds,
        linkedActivityId: linkedActivityId,
        isMilestone: isMilestone,
        milestoneType: milestoneType,
      );
      return repo.getMemories(spaceId);
    });
    return !state.hasError;
  }

  /// Update a memory and refresh the list.
  Future<bool> updateMemory(
    String spaceId,
    String memoryId,
    Map<String, dynamic> data,
  ) async {
    final repo = ref.read(memoriesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.updateMemory(spaceId, memoryId, data);
      return repo.getMemories(spaceId);
    });
    return !state.hasError;
  }

  /// Delete a memory and refresh the list.
  Future<bool> deleteMemory(String spaceId, String memoryId) async {
    final repo = ref.read(memoriesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteMemory(spaceId, memoryId);
      return repo.getMemories(spaceId);
    });
    return !state.hasError;
  }
}

/// Memories async provider.
final memoriesProvider =
    AsyncNotifierProvider.autoDispose<MemoriesNotifier, List<CachedMemory>>(
      MemoriesNotifier.new,
    );

// ── Milestones notifier ─────────────────────────────────────────────────

/// Milestones notifier for milestone-specific queries.
class MilestonesNotifier extends AutoDisposeAsyncNotifier<List<CachedMemory>> {
  @override
  Future<List<CachedMemory>> build() async {
    final repo = ref.watch(memoriesRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    if (spaceId == null) return [];
    return repo.getMilestones(spaceId);
  }
}

/// Milestones async provider.
final milestonesProvider =
    AsyncNotifierProvider.autoDispose<MilestonesNotifier, List<CachedMemory>>(
      MilestonesNotifier.new,
    );

// ── On-this-day notifier ────────────────────────────────────────────────

/// On-this-day memories notifier.
class OnThisDayNotifier
    extends AutoDisposeAsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.watch(memoriesRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    if (spaceId == null) return [];
    return repo.getOnThisDay(spaceId);
  }
}

/// On-this-day async provider.
final onThisDayProvider =
    AsyncNotifierProvider.autoDispose<
      OnThisDayNotifier,
      List<Map<String, dynamic>>
    >(OnThisDayNotifier.new);

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for the list of memories.
final memoryListProvider = Provider<List<CachedMemory>>((ref) {
  return ref.watch(memoriesProvider).valueOrNull ?? [];
});

/// Convenience provider for milestones only.
final milestoneListProvider = Provider<List<CachedMemory>>((ref) {
  return ref.watch(milestonesProvider).valueOrNull ?? [];
});
