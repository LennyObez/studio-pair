import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/activities_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/activities_dao.dart';

/// Activity model.
class Activity {
  const Activity({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.thumbnailUrl,
    this.trailerUrl,
    required this.privacy,
    required this.status,
    required this.mode,
    this.createdBy,
    this.averageRating,
    this.voteCount,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      trailerUrl: json['trailer_url'] as String?,
      privacy: json['privacy'] as String? ?? 'shared',
      status: json['status'] as String? ?? 'active',
      mode: json['mode'] as String? ?? 'unlinked',
      createdBy: json['created_by'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
    );
  }

  final String id;
  final String title;
  final String? description;
  final String? category;
  final String? thumbnailUrl;
  final String? trailerUrl;
  final String privacy; // shared, private
  final String status; // active, completed, deleted
  final String mode; // unlinked, date_personal, date_space
  final String? createdBy;
  final double? averageRating;
  final int? voteCount;
}

/// Activities state.
class ActivitiesState {
  const ActivitiesState({
    this.activities = const [],
    this.selectedCategory = 'all',
    this.searchQuery = '',
    this.isLoading = false,
    this.isCached = false,
    this.error,
    this.cursor,
    this.hasMore = false,
  });

  final List<Activity> activities;
  final String selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final bool isCached;
  final String? error;
  final String? cursor;
  final bool hasMore;

  ActivitiesState copyWith({
    List<Activity>? activities,
    String? selectedCategory,
    String? searchQuery,
    bool? isLoading,
    bool? isCached,
    String? error,
    String? cursor,
    bool? hasMore,
    bool clearError = false,
    bool clearCursor = false,
  }) {
    return ActivitiesState(
      activities: activities ?? this.activities,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      error: clearError ? null : (error ?? this.error),
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Activities state notifier managing activity CRUD, voting, and search.
class ActivitiesNotifier extends StateNotifier<ActivitiesState> {
  ActivitiesNotifier(this._api, this._dao) : super(const ActivitiesState());

  final ActivitiesApi _api;
  final ActivitiesDao _dao;

  /// Load activities for a space with optional filters.
  Future<void> loadActivities(
    String spaceId, {
    String? category,
    String? status,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // 1. Load from cache first
    try {
      final cached = await _dao.getActivities(spaceId).first;
      if (cached.isNotEmpty) {
        final activities = cached
            .map(
              (c) => Activity(
                id: c.id,
                title: c.title,
                description: c.description,
                category: c.category,
                thumbnailUrl: c.thumbnailUrl,
                trailerUrl: c.trailerUrl,
                privacy: c.privacy,
                status: c.status,
                mode: c.mode,
                createdBy: c.createdBy,
              ),
            )
            .toList();
        state = state.copyWith(
          activities: activities,
          isLoading: false,
          isCached: true,
        );
      }
    } catch (_) {
      // Cache read failed, continue to API
    }

    // 2. Try API in background
    try {
      final response = await _api.listActivities(
        spaceId,
        category: category,
        status: status,
      );
      final jsonList = parseList(response.data);
      final activities = jsonList.map(Activity.fromJson).toList();

      // Upsert into cache
      for (final item in activities) {
        await _dao.upsertActivity(
          CachedActivitiesCompanion(
            id: Value(item.id),
            spaceId: Value(spaceId),
            createdBy: Value(item.createdBy ?? ''),
            title: Value(item.title),
            description: Value(item.description),
            category: Value(item.category ?? ''),
            thumbnailUrl: Value(item.thumbnailUrl),
            trailerUrl: Value(item.trailerUrl),
            privacy: Value(item.privacy),
            status: Value(item.status),
            mode: Value(item.mode),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
            syncedAt: Value(DateTime.now()),
          ),
        );
      }

      state = state.copyWith(
        activities: activities,
        isLoading: false,
        isCached: false,
        hasMore: false,
      );
    } catch (e) {
      // Only show error if we have no cached data
      if (state.activities.isEmpty) {
        state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Create a new activity.
  Future<bool> createActivity(
    String spaceId, {
    required String title,
    String? description,
    String? category,
    String? thumbnailUrl,
    String? trailerUrl,
    required String privacy,
    required String mode,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.createActivity(
        spaceId,
        title: title,
        description: description,
        category: category,
        thumbnailUrl: thumbnailUrl,
        trailerUrl: trailerUrl,
        privacy: privacy,
        mode: mode,
      );
      final newActivity = Activity.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        activities: [...state.activities, newActivity],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Update an existing activity.
  Future<bool> updateActivity(
    String spaceId,
    String activityId,
    Map<String, dynamic> data,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.updateActivity(spaceId, activityId, data);
      final updatedActivity = Activity.fromJson(
        response.data as Map<String, dynamic>,
      );

      final updatedActivities = state.activities.map((activity) {
        if (activity.id == activityId) return updatedActivity;
        return activity;
      }).toList();

      state = state.copyWith(activities: updatedActivities, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Delete an activity.
  Future<bool> deleteActivity(String spaceId, String activityId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.deleteActivity(spaceId, activityId);

      state = state.copyWith(
        activities: state.activities.where((a) => a.id != activityId).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Vote on an activity.
  Future<bool> vote(String spaceId, String activityId, int score) async {
    try {
      await _api.vote(spaceId, activityId, score);

      final updatedActivities = state.activities.map((activity) {
        if (activity.id == activityId) {
          return Activity(
            id: activity.id,
            title: activity.title,
            description: activity.description,
            category: activity.category,
            thumbnailUrl: activity.thumbnailUrl,
            trailerUrl: activity.trailerUrl,
            privacy: activity.privacy,
            status: activity.status,
            mode: activity.mode,
            createdBy: activity.createdBy,
            averageRating:
                ((activity.averageRating ?? 0) * (activity.voteCount ?? 0) +
                    score) /
                ((activity.voteCount ?? 0) + 1),
            voteCount: (activity.voteCount ?? 0) + 1,
          );
        }
        return activity;
      }).toList();

      state = state.copyWith(activities: updatedActivities);
      return true;
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return false;
    }
  }

  /// Mark an activity as completed.
  Future<bool> completeActivity(
    String spaceId,
    String activityId, {
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.completeActivity(spaceId, activityId, notes: notes);

      final updatedActivities = state.activities.map((activity) {
        if (activity.id == activityId) {
          return Activity(
            id: activity.id,
            title: activity.title,
            description: activity.description,
            category: activity.category,
            thumbnailUrl: activity.thumbnailUrl,
            trailerUrl: activity.trailerUrl,
            privacy: activity.privacy,
            status: 'completed',
            mode: activity.mode,
            createdBy: activity.createdBy,
            averageRating: activity.averageRating,
            voteCount: activity.voteCount,
          );
        }
        return activity;
      }).toList();

      state = state.copyWith(activities: updatedActivities, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Set the selected category filter.
  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Set the search query.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Search activities by query.
  Future<void> searchActivities(String spaceId, String query) async {
    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      clearError: true,
    );

    try {
      final response = await _api.searchActivities(spaceId, query);
      final jsonList = parseList(response.data);
      final activities = jsonList.map(Activity.fromJson).toList();

      state = state.copyWith(activities: activities, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Activities state provider.
final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, ActivitiesState>((ref) {
      return ActivitiesNotifier(
        ref.watch(activitiesApiProvider),
        ref.watch(activitiesDaoProvider),
      );
    });

/// Convenience provider for the filtered activity list.
final activityListProvider = Provider<List<Activity>>((ref) {
  final activitiesState = ref.watch(activitiesProvider);
  var list = activitiesState.activities;

  if (activitiesState.selectedCategory != 'all') {
    list = list
        .where((a) => a.category == activitiesState.selectedCategory)
        .toList();
  }

  if (activitiesState.searchQuery.isNotEmpty) {
    list = list
        .where(
          (a) => a.title.toLowerCase().contains(
            activitiesState.searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  return list;
});

/// Convenience provider for distinct activity categories.
final activityCategoriesProvider = Provider<List<String>>((ref) {
  final activities = ref.watch(activitiesProvider).activities;
  final categories = activities
      .map((a) => a.category)
      .where((c) => c != null)
      .cast<String>()
      .toSet()
      .toList();
  categories.sort();
  return categories;
});
