import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/memories_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/memories_dao.dart';

/// Memory model.
class Memory {
  const Memory({
    required this.id,
    required this.title,
    required this.date,
    this.location,
    this.description,
    this.coverPhotoUrl,
    this.photoCount = 0,
    this.isMilestone = false,
    this.milestoneType,
    this.linkedActivityId,
    this.createdBy,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'],
      title: json['title'],
      date: json['date'] ?? '',
      location: json['location'],
      description: json['description'],
      coverPhotoUrl: json['cover_photo_url'],
      photoCount: json['photo_count'] ?? 0,
      isMilestone: json['is_milestone'] ?? false,
      milestoneType: json['milestone_type'],
      linkedActivityId: json['linked_activity_id'],
      createdBy: json['created_by'],
    );
  }

  final String id;
  final String title;
  final String date;
  final String? location;
  final String? description;
  final String? coverPhotoUrl;
  final int photoCount;
  final bool isMilestone;

  /// Milestone type if applicable: 'anniversary', 'first', 'birthday', etc.
  final String? milestoneType;
  final String? linkedActivityId;
  final String? createdBy;
}

/// Memories state.
class MemoriesState {
  const MemoriesState({
    this.memories = const [],
    this.onThisDayMemories = const [],
    this.milestones = const [],
    this.isLoading = false,
    this.isCached = false,
    this.error,
  });

  final List<Memory> memories;
  final List<Memory> onThisDayMemories;
  final List<Memory> milestones;
  final bool isLoading;
  final bool isCached;
  final String? error;

  MemoriesState copyWith({
    List<Memory>? memories,
    List<Memory>? onThisDayMemories,
    List<Memory>? milestones,
    bool? isLoading,
    bool? isCached,
    String? error,
    bool clearError = false,
  }) {
    return MemoriesState(
      memories: memories ?? this.memories,
      onThisDayMemories: onThisDayMemories ?? this.onThisDayMemories,
      milestones: milestones ?? this.milestones,
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Memories state notifier managing shared memories and milestones.
class MemoriesNotifier extends StateNotifier<MemoriesState> {
  MemoriesNotifier(this._api, this._dao) : super(const MemoriesState());

  final MemoriesApi _api;
  final MemoriesDao _dao;

  /// Load memories for a space, optionally filtered by year and month.
  Future<void> loadMemories(
    String spaceId, {
    String? year,
    String? month,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // 1. Load from cache first
    try {
      final cached = await _dao.getMemories(spaceId).first;
      if (cached.isNotEmpty) {
        final memories = cached
            .map(
              (c) => Memory(
                id: c.id,
                title: c.title,
                date: c.memoryDate.toIso8601String().split('T').first,
                description: c.description,
                isMilestone: c.isMilestone,
                createdBy: c.createdBy,
              ),
            )
            .toList();
        state = state.copyWith(
          memories: memories,
          isLoading: false,
          isCached: true,
        );
      }
    } catch (_) {
      // Cache read failed, continue to API
    }

    // 2. Try API in background
    try {
      final response = await _api.listMemories(
        spaceId,
        year: year,
        month: month,
      );
      final items = parseList(response.data);
      final memories = items.map(Memory.fromJson).toList();

      // Upsert into cache
      for (final item in memories) {
        await _dao.upsertMemory(
          CachedMemoriesCompanion(
            id: Value(item.id),
            spaceId: Value(spaceId),
            createdBy: Value(item.createdBy ?? ''),
            title: Value(item.title),
            description: Value(item.description),
            isMilestone: Value(item.isMilestone),
            memoryDate: Value(DateTime.tryParse(item.date) ?? DateTime.now()),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
            syncedAt: Value(DateTime.now()),
          ),
        );
      }

      state = state.copyWith(
        memories: memories,
        isLoading: false,
        isCached: false,
      );
    } catch (e) {
      if (state.memories.isEmpty) {
        state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Create a new memory.
  Future<bool> createMemory(
    String spaceId, {
    required String title,
    required String date,
    String? location,
    String? description,
    String? coverPhotoUrl,
    bool isMilestone = false,
    String? milestoneType,
    String? linkedActivityId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.createMemory(
        spaceId,
        title: title,
        date: date,
        location: location,
        description: description,
        linkedActivityId: linkedActivityId,
        isMilestone: isMilestone,
        milestoneType: milestoneType,
      );

      final newMemory = Memory.fromJson(response.data as Map<String, dynamic>);

      state = state.copyWith(
        memories: [...state.memories, newMemory],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Update an existing memory.
  Future<bool> updateMemory(
    String spaceId,
    String memoryId,
    Map<String, dynamic> data,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.updateMemory(spaceId, memoryId, data);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Delete a memory.
  Future<bool> deleteMemory(String spaceId, String memoryId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.deleteMemory(spaceId, memoryId);

      state = state.copyWith(
        memories: state.memories.where((m) => m.id != memoryId).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Load "On This Day" memories (same month/day from previous years).
  Future<void> loadOnThisDay(String spaceId) async {
    try {
      final response = await _api.getOnThisDay(spaceId);
      final items = parseList(response.data);
      final memories = items.map(Memory.fromJson).toList();

      state = state.copyWith(onThisDayMemories: memories);
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
    }
  }

  /// Load all milestones for the space.
  Future<void> loadMilestones(String spaceId) async {
    try {
      final response = await _api.getMilestones(spaceId);
      final items = parseList(response.data);
      final milestones = items.map(Memory.fromJson).toList();

      state = state.copyWith(milestones: milestones);
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
    }
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Memories state provider.
final memoriesProvider = StateNotifierProvider<MemoriesNotifier, MemoriesState>(
  (ref) {
    return MemoriesNotifier(
      ref.watch(memoriesApiProvider),
      ref.watch(memoriesDaoProvider),
    );
  },
);

/// Convenience provider for the list of memories.
final memoryListProvider = Provider<List<Memory>>((ref) {
  return ref.watch(memoriesProvider).memories;
});

/// Convenience provider for "On This Day" memories.
final onThisDayProvider = Provider<List<Memory>>((ref) {
  return ref.watch(memoriesProvider).onThisDayMemories;
});

/// Convenience provider for milestones only.
final milestoneListProvider = Provider<List<Memory>>((ref) {
  return ref.watch(memoriesProvider).milestones;
});
