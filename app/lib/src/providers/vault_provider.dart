import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/vault_api.dart';

/// Vault entry model.
/// Note: password is never stored in state; always fetched and decrypted on demand.
class VaultEntry {
  const VaultEntry({
    required this.id,
    required this.domain,
    this.faviconUrl,
    required this.label,
    this.username,
    required this.isShared,
    this.sharedWith = const [],
    required this.createdAt,
  });

  factory VaultEntry.fromJson(Map<String, dynamic> json) {
    return VaultEntry(
      id: json['id'],
      domain: json['domain'],
      faviconUrl: json['favicon_url'],
      label: json['label'],
      username: json['username'],
      isShared: json['is_shared'] ?? false,
      sharedWith: (json['shared_with'] as List?)?.cast<String>() ?? [],
      createdAt: json['created_at'] ?? '',
    );
  }

  final String id;
  final String domain;
  final String? faviconUrl;
  final String label;
  final String? username;
  final bool isShared;

  /// List of user display names this entry is shared with.
  final List<String> sharedWith;
  final String createdAt;
}

/// Vault state.
class VaultState {
  const VaultState({
    this.entries = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  final List<VaultEntry> entries;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  VaultState copyWith({
    List<VaultEntry>? entries,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return VaultState(
      entries: entries ?? this.entries,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Vault state notifier managing password / credential entries.
class VaultNotifier extends StateNotifier<VaultState> {
  VaultNotifier(this._api) : super(const VaultState());

  final VaultApi _api;

  /// Load vault entries for a space.
  Future<void> loadEntries(String spaceId, {String? search}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.listEntries(spaceId, search: search);
      final items = parseList(response.data);
      final entries = items.map(VaultEntry.fromJson).toList();

      state = state.copyWith(entries: entries, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  /// Create a new vault entry.
  Future<bool> createEntry(
    String spaceId, {
    required String domain,
    required String label,
    String? username,
    required String password,
    bool isShared = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.createEntry(
        spaceId,
        domain: domain,
        label: label,
        encryptedBlob: password,
      );

      final newEntry = VaultEntry.fromJson(
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

  /// Delete a vault entry.
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

  /// Share a vault entry with specific users.
  Future<bool> shareEntry(
    String spaceId,
    String entryId,
    List<String> userIds,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.shareEntry(spaceId, entryId, userIds);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Fetch the decrypted password for a specific entry on demand.
  /// Returns the password string or null on failure.
  Future<String?> fetchEntryPassword(String spaceId, String entryId) async {
    try {
      final response = await _api.getEntry(spaceId, entryId);
      final data = response.data as Map<String, dynamic>;
      return data['encrypted_blob'] as String? ?? data['password'] as String?;
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return null;
    }
  }

  /// Set the search query for filtering entries locally.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Vault state provider.
final vaultProvider = StateNotifierProvider<VaultNotifier, VaultState>((ref) {
  return VaultNotifier(ref.watch(vaultApiProvider));
});

/// Convenience provider for filtered vault entries (by search query).
final vaultEntriesProvider = Provider<List<VaultEntry>>((ref) {
  final vaultState = ref.watch(vaultProvider);
  final query = vaultState.searchQuery.toLowerCase();
  if (query.isEmpty) {
    return vaultState.entries;
  }
  return vaultState.entries.where((e) {
    return e.label.toLowerCase().contains(query) ||
        e.domain.toLowerCase().contains(query) ||
        (e.username?.toLowerCase().contains(query) ?? false);
  }).toList();
});

/// Convenience provider for the total vault entry count.
final vaultEntryCountProvider = Provider<int>((ref) {
  return ref.watch(vaultProvider).entries.length;
});
