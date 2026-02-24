import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/vault_api.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

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

// ── Async notifier ──────────────────────────────────────────────────────

/// Vault notifier managing password / credential entries.
class VaultNotifier extends AsyncNotifier<List<VaultEntry>> {
  VaultApi get _api => ref.read(vaultApiProvider);

  @override
  Future<List<VaultEntry>> build() async => [];

  /// Load vault entries for a space.
  Future<void> loadEntries(String spaceId, {String? search}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _api.listEntries(spaceId, search: search);
      final items = parseList(response.data);
      return items.map(VaultEntry.fromJson).toList();
    });
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
    final previousEntries = state.valueOrNull ?? [];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _api.createEntry(
        spaceId,
        domain: domain,
        label: label,
        encryptedBlob: password,
      );

      final newEntry = VaultEntry.fromJson(
        response.data as Map<String, dynamic>,
      );

      return [...previousEntries, newEntry];
    });
    return !state.hasError;
  }

  /// Delete a vault entry.
  Future<bool> deleteEntry(String spaceId, String entryId) async {
    final previousEntries = state.valueOrNull ?? [];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _api.deleteEntry(spaceId, entryId);
      return previousEntries.where((e) => e.id != entryId).toList();
    });
    return !state.hasError;
  }

  /// Share a vault entry with specific users.
  Future<bool> shareEntry(
    String spaceId,
    String entryId,
    List<String> userIds,
  ) async {
    final previousEntries = state.valueOrNull ?? [];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _api.shareEntry(spaceId, entryId, userIds);
      return previousEntries;
    });
    return !state.hasError;
  }

  /// Fetch the decrypted password for a specific entry on demand.
  /// Returns the password string or null on failure.
  Future<String?> fetchEntryPassword(String spaceId, String entryId) async {
    try {
      final response = await _api.getEntry(spaceId, entryId);
      final data = response.data as Map<String, dynamic>;
      return data['encrypted_blob'] as String? ?? data['password'] as String?;
    } on AppFailure {
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Vault async provider.
final vaultProvider = AsyncNotifierProvider<VaultNotifier, List<VaultEntry>>(
  VaultNotifier.new,
);

// ── Filter state providers ──────────────────────────────────────────────

/// Search query for filtering vault entries locally.
final vaultSearchQueryProvider = StateProvider<String>((ref) => '');

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for filtered vault entries (by search query).
final vaultEntriesProvider = Provider<List<VaultEntry>>((ref) {
  final entries = ref.watch(vaultProvider).valueOrNull ?? [];
  final query = ref.watch(vaultSearchQueryProvider).toLowerCase();
  if (query.isEmpty) return entries;
  return entries.where((e) {
    return e.label.toLowerCase().contains(query) ||
        e.domain.toLowerCase().contains(query) ||
        (e.username?.toLowerCase().contains(query) ?? false);
  }).toList();
});

/// Convenience provider for the total vault entry count.
final vaultEntryCountProvider = Provider<int>((ref) {
  return (ref.watch(vaultProvider).valueOrNull ?? []).length;
});
