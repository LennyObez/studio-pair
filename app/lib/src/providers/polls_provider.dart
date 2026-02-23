import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/polls_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/polls_dao.dart';

/// Poll option model.
class PollOption {
  const PollOption({
    required this.id,
    required this.label,
    this.imageUrl,
    this.voteCount = 0,
    this.percentage = 0.0,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'],
      label: json['label'],
      imageUrl: json['image_url'],
      voteCount: json['vote_count'] ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final String id;
  final String label;
  final String? imageUrl;
  final int voteCount;
  final double percentage;
}

/// Poll model.
class Poll {
  const Poll({
    required this.id,
    required this.question,
    required this.type,
    required this.isAnonymous,
    this.deadline,
    required this.isClosed,
    required this.options,
    this.createdBy,
    this.totalVotes = 0,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'],
      question: json['question'],
      type: json['type'] ?? 'single',
      isAnonymous: json['is_anonymous'] ?? false,
      deadline: json['deadline'],
      isClosed: json['is_closed'] ?? false,
      options:
          (json['options'] as List?)
              ?.map((o) => PollOption.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
      createdBy: json['created_by'],
      totalVotes: json['total_votes'] ?? 0,
    );
  }

  final String id;
  final String question;

  /// Poll type: 'single', 'multiple', or 'ranked'.
  final String type;
  final bool isAnonymous;
  final String? deadline;
  final bool isClosed;
  final List<PollOption> options;
  final String? createdBy;
  final int totalVotes;
}

/// Polls state.
class PollsState {
  const PollsState({
    this.polls = const [],
    this.showActive = true,
    this.isLoading = false,
    this.isCached = false,
    this.error,
  });

  final List<Poll> polls;

  /// When true, show only active (open) polls; when false, show all.
  final bool showActive;
  final bool isLoading;
  final bool isCached;
  final String? error;

  PollsState copyWith({
    List<Poll>? polls,
    bool? showActive,
    bool? isLoading,
    bool? isCached,
    String? error,
    bool clearError = false,
  }) {
    return PollsState(
      polls: polls ?? this.polls,
      showActive: showActive ?? this.showActive,
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Polls state notifier managing polls and voting.
class PollsNotifier extends StateNotifier<PollsState> {
  PollsNotifier(this._api, this._dao) : super(const PollsState());

  final PollsApi _api;
  final PollsDao _dao;

  /// Load polls for a space, optionally filtering by active status.
  Future<void> loadPolls(String spaceId, {bool? active}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // 1. Load from cache first
    try {
      final cached = await _dao.getPolls(spaceId, isActive: active).first;
      if (cached.isNotEmpty) {
        final polls = cached.map((c) {
          var options = <PollOption>[];
          try {
            final optionsList = jsonDecode(c.options) as List;
            options = optionsList
                .map((o) => PollOption.fromJson(o as Map<String, dynamic>))
                .toList();
          } catch (_) {}
          return Poll(
            id: c.id,
            question: c.question,
            type: 'single',
            isAnonymous: false,
            deadline: c.expiresAt?.toIso8601String(),
            isClosed: !c.isActive,
            options: options,
            createdBy: c.createdBy,
          );
        }).toList();
        state = state.copyWith(polls: polls, isLoading: false, isCached: true);
      }
    } catch (_) {
      // Cache read failed, continue to API
    }

    // 2. Try API in background
    try {
      final response = await _api.listPolls(spaceId, active: active);
      final items = parseList(response.data);
      final polls = items.map(Poll.fromJson).toList();

      // Upsert into cache
      for (final item in polls) {
        await _dao.upsertPoll(
          CachedPollsCompanion(
            id: Value(item.id),
            spaceId: Value(spaceId),
            createdBy: Value(item.createdBy ?? ''),
            question: Value(item.question),
            options: Value(
              jsonEncode(
                item.options
                    .map(
                      (o) => {
                        'id': o.id,
                        'label': o.label,
                        'image_url': o.imageUrl,
                        'vote_count': o.voteCount,
                        'percentage': o.percentage,
                      },
                    )
                    .toList(),
              ),
            ),
            isActive: Value(!item.isClosed),
            expiresAt: Value(
              item.deadline != null ? DateTime.tryParse(item.deadline!) : null,
            ),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
            syncedAt: Value(DateTime.now()),
          ),
        );
      }

      state = state.copyWith(polls: polls, isLoading: false, isCached: false);
    } catch (e) {
      if (state.polls.isEmpty) {
        state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Create a new poll.
  Future<bool> createPoll(
    String spaceId, {
    required String question,
    required String type,
    required bool isAnonymous,
    String? deadline,
    required List<String> optionLabels,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final options = optionLabels
          .map((label) => <String, dynamic>{'label': label})
          .toList();

      final response = await _api.createPoll(
        spaceId,
        question: question,
        type: type,
        options: options,
        isAnonymous: isAnonymous,
        deadline: deadline,
      );

      final newPoll = Poll.fromJson(response.data as Map<String, dynamic>);

      state = state.copyWith(
        polls: [...state.polls, newPoll],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Vote on a poll.
  Future<bool> vote(
    String spaceId,
    String pollId,
    List<String> optionIds, {
    Map<String, int>? ranks,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.vote(spaceId, pollId, optionIds, ranks: ranks);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Close a poll (stop accepting votes).
  Future<bool> closePoll(String spaceId, String pollId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.closePoll(spaceId, pollId);

      state = state.copyWith(
        polls: state.polls.map((p) {
          if (p.id == pollId) {
            return Poll(
              id: p.id,
              question: p.question,
              type: p.type,
              isAnonymous: p.isAnonymous,
              deadline: p.deadline,
              isClosed: true,
              options: p.options,
              createdBy: p.createdBy,
              totalVotes: p.totalVotes,
            );
          }
          return p;
        }).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Delete a poll.
  Future<bool> deletePoll(String spaceId, String pollId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.deletePoll(spaceId, pollId);

      state = state.copyWith(
        polls: state.polls.where((p) => p.id != pollId).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Randomly pick a winning option from a poll.
  Future<PollOption?> randomPick(String spaceId, String pollId) async {
    try {
      final response = await _api.randomPick(spaceId, pollId);
      final data = response.data as Map<String, dynamic>;

      return PollOption.fromJson(data);
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return null;
    }
  }

  /// Toggle the active filter on/off.
  void toggleActiveFilter() {
    state = state.copyWith(showActive: !state.showActive);
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Polls state provider.
final pollsProvider = StateNotifierProvider<PollsNotifier, PollsState>((ref) {
  return PollsNotifier(
    ref.watch(pollsApiProvider),
    ref.watch(pollsDaoProvider),
  );
});

/// Convenience provider for the filtered list of polls.
final pollListProvider = Provider<List<Poll>>((ref) {
  final pollsState = ref.watch(pollsProvider);
  if (pollsState.showActive) {
    return pollsState.polls.where((p) => !p.isClosed).toList();
  }
  return pollsState.polls;
});

/// Convenience provider for the count of active (open) polls.
final activePollCountProvider = Provider<int>((ref) {
  return ref.watch(pollsProvider).polls.where((p) => !p.isClosed).length;
});
