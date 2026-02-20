import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';

// ── Filter state providers ──────────────────────────────────────────────

/// Filter by activity category ('all' = no filter).
final activityCategoryFilter = StateProvider<String>((ref) => 'all');

/// Search query for activities.
final activitySearchQuery = StateProvider<String>((ref) => '');

// ── Async notifier ──────────────────────────────────────────────────────

/// Activities notifier backed by the [ActivitiesRepository].
///
/// The [build] method fetches activities from the repository (API + cache)
/// whenever the current space changes. Mutation methods delegate to the
/// repository and re-fetch the full list so the UI stays in sync.
class ActivitiesNotifier
    extends AutoDisposeAsyncNotifier<List<CachedActivity>> {
  @override
  Future<List<CachedActivity>> build() async {
    final repo = ref.watch(activitiesRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    if (spaceId == null) return [];
    return repo.getActivities(spaceId);
  }

  /// Create a new activity and refresh the list.
  Future<bool> createActivity(
    String spaceId, {
    required String title,
    String? description,
    String? category,
    String? thumbnailUrl,
    String? trailerUrl,
    String? privacy,
    String? mode,
  }) async {
    final repo = ref.read(activitiesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.createActivity(
        spaceId,
        title: title,
        description: description,
        category: category,
        thumbnailUrl: thumbnailUrl,
        trailerUrl: trailerUrl,
        privacy: privacy,
        mode: mode,
      );
      return repo.getActivities(spaceId);
    });
    return !state.hasError;
  }

  /// Update an activity and refresh the list.
  Future<bool> updateActivity(
    String spaceId,
    String activityId,
    Map<String, dynamic> data,
  ) async {
    final repo = ref.read(activitiesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.updateActivity(spaceId, activityId, data);
      return repo.getActivities(spaceId);
    });
    return !state.hasError;
  }

  /// Delete an activity and refresh the list.
  Future<bool> deleteActivity(String spaceId, String activityId) async {
    final repo = ref.read(activitiesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteActivity(spaceId, activityId);
      return repo.getActivities(spaceId);
    });
    return !state.hasError;
  }

  /// Vote on an activity and refresh the list.
  Future<bool> vote(String spaceId, String activityId, int score) async {
    final repo = ref.read(activitiesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.vote(spaceId, activityId, score);
      return repo.getActivities(spaceId);
    });
    return !state.hasError;
  }

  /// Mark an activity as completed and refresh the list.
  Future<bool> completeActivity(
    String spaceId,
    String activityId, {
    String? notes,
  }) async {
    final repo = ref.read(activitiesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.completeActivity(spaceId, activityId, notes: notes);
      return repo.getActivities(spaceId);
    });
    return !state.hasError;
  }

  /// Search activities by query and replace the list with results.
  Future<void> searchActivities(String spaceId, String query) async {
    final repo = ref.read(activitiesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.searchActivities(spaceId, query));
  }
}

/// Activities async provider.
final activitiesProvider =
    AsyncNotifierProvider.autoDispose<ActivitiesNotifier, List<CachedActivity>>(
      ActivitiesNotifier.new,
    );

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for the filtered activity list.
final activityListProvider = Provider<List<CachedActivity>>((ref) {
  final activities = ref.watch(activitiesProvider).valueOrNull ?? [];
  final category = ref.watch(activityCategoryFilter);
  final query = ref.watch(activitySearchQuery);

  var list = activities;

  if (category != 'all') {
    list = list.where((a) => a.category == category).toList();
  }

  if (query.isNotEmpty) {
    list = list
        .where((a) => a.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  return list;
});

/// Convenience provider for distinct activity categories.
final activityCategoriesProvider = Provider<List<String>>((ref) {
  final activities = ref.watch(activitiesProvider).valueOrNull ?? [];
  final categories = activities
      .map((a) => a.category)
      .where((c) => c.isNotEmpty)
      .toSet()
      .toList();
  categories.sort();
  return categories;
});
