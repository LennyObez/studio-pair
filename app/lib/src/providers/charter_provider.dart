import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/charter_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/charter_dao.dart';

/// Charter version model.
class CharterVersion {
  const CharterVersion({
    required this.id,
    required this.versionNumber,
    required this.content,
    required this.editedBy,
    required this.createdAt,
    this.isAcknowledged = false,
  });

  factory CharterVersion.fromJson(Map<String, dynamic> json) {
    return CharterVersion(
      id: json['id'],
      versionNumber: json['version_number'] ?? 0,
      content: json['content'] ?? '',
      editedBy: json['edited_by'] ?? '',
      createdAt: json['created_at'] ?? '',
      isAcknowledged: json['is_acknowledged'] ?? false,
    );
  }

  final String id;
  final int versionNumber;
  final String content;
  final String editedBy;
  final String createdAt;
  final bool isAcknowledged;
}

/// Charter state.
class CharterState {
  const CharterState({
    this.currentContent = '',
    this.currentVersion = 0,
    this.versions = const [],
    this.isAcknowledged = false,
    this.isLoading = false,
    this.isCached = false,
    this.error,
  });

  final String currentContent;
  final int currentVersion;
  final List<CharterVersion> versions;
  final bool isAcknowledged;
  final bool isLoading;
  final bool isCached;
  final String? error;

  CharterState copyWith({
    String? currentContent,
    int? currentVersion,
    List<CharterVersion>? versions,
    bool? isAcknowledged,
    bool? isLoading,
    bool? isCached,
    String? error,
    bool clearError = false,
  }) {
    return CharterState(
      currentContent: currentContent ?? this.currentContent,
      currentVersion: currentVersion ?? this.currentVersion,
      versions: versions ?? this.versions,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Charter state notifier managing the relationship charter document.
class CharterNotifier extends StateNotifier<CharterState> {
  CharterNotifier(this._api, this._dao) : super(const CharterState());

  final CharterApi _api;
  final CharterDao _dao;

  /// Load the current charter for a space.
  Future<void> loadCharter(String spaceId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // 1. Load from cache first
    try {
      final cached = await _dao.getCharter(spaceId);
      if (cached != null) {
        state = state.copyWith(
          currentContent: cached.content,
          currentVersion: cached.versionNumber,
          isAcknowledged: cached.isAcknowledged,
          isLoading: false,
          isCached: true,
        );
      }
    } catch (_) {
      // Cache read failed, continue to API
    }

    // 2. Try API in background
    try {
      final response = await _api.getCharter(spaceId);
      final data = response.data as Map<String, dynamic>;

      // Upsert into cache
      await _dao.upsertCharter(
        CachedChartersCompanion(
          id: Value(data['id'] as String? ?? spaceId),
          spaceId: Value(spaceId),
          content: Value(data['content'] as String? ?? ''),
          versionNumber: Value(data['version_number'] as int? ?? 0),
          editedBy: Value(data['edited_by'] as String? ?? ''),
          isAcknowledged: Value(data['is_acknowledged'] as bool? ?? false),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
          syncedAt: Value(DateTime.now()),
        ),
      );

      state = state.copyWith(
        currentContent: data['content'] ?? '',
        currentVersion: data['version_number'] ?? 0,
        isAcknowledged: data['is_acknowledged'] ?? false,
        isLoading: false,
        isCached: false,
      );
    } catch (e) {
      if (state.currentContent.isEmpty) {
        state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Update the charter content, creating a new version.
  Future<bool> updateCharter(String spaceId, String content) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.updateCharter(spaceId, content);
      final data = response.data as Map<String, dynamic>;

      state = state.copyWith(
        currentContent: data['content'] ?? content,
        currentVersion: data['version_number'] ?? state.currentVersion + 1,
        isAcknowledged: false,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Acknowledge the current version of the charter.
  Future<bool> acknowledgeCharter(String spaceId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.acknowledgeCharter(spaceId);

      state = state.copyWith(isAcknowledged: true, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Load version history for the charter.
  Future<void> loadVersions(String spaceId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.getVersions(spaceId);
      final items = parseList(response.data);
      final versions = items.map(CharterVersion.fromJson).toList();

      state = state.copyWith(versions: versions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  /// Get a specific version of the charter.
  Future<CharterVersion?> getVersion(String spaceId, String versionId) async {
    try {
      final response = await _api.getVersion(spaceId, versionId);
      final data = response.data as Map<String, dynamic>;

      return CharterVersion.fromJson(data);
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return null;
    }
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Charter state provider.
final charterProvider = StateNotifierProvider<CharterNotifier, CharterState>((
  ref,
) {
  return CharterNotifier(
    ref.watch(charterApiProvider),
    ref.watch(charterDaoProvider),
  );
});

/// Convenience provider for the current charter content.
final charterContentProvider = Provider<String>((ref) {
  return ref.watch(charterProvider).currentContent;
});

/// Convenience provider indicating whether the charter needs acknowledgement.
final charterNeedsAckProvider = Provider<bool>((ref) {
  final charterState = ref.watch(charterProvider);
  return charterState.currentContent.isNotEmpty && !charterState.isAcknowledged;
});
