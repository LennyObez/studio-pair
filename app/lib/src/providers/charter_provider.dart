import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';

// ── Async notifier ──────────────────────────────────────────────────────

/// Charter notifier backed by the [CharterRepository].
///
/// The [build] method fetches the current charter from the repository
/// (API + cache) whenever the current space changes. Returns null when
/// no charter exists yet.
class CharterNotifier extends AutoDisposeAsyncNotifier<CachedCharter?> {
  @override
  Future<CachedCharter?> build() async {
    final repo = ref.watch(charterRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    if (spaceId == null) return null;
    return repo.getCharter(spaceId);
  }

  /// Update the charter content and refresh.
  Future<bool> updateCharter(String spaceId, String content) async {
    final repo = ref.read(charterRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.updateCharter(spaceId, content);
      return repo.getCharter(spaceId);
    });
    return !state.hasError;
  }

  /// Acknowledge the current charter version and refresh.
  Future<bool> acknowledgeCharter(String spaceId) async {
    final repo = ref.read(charterRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.acknowledgeCharter(spaceId);
      return repo.getCharter(spaceId);
    });
    return !state.hasError;
  }
}

/// Charter async provider.
final charterProvider =
    AsyncNotifierProvider.autoDispose<CharterNotifier, CachedCharter?>(
      CharterNotifier.new,
    );

// ── Charter versions notifier ───────────────────────────────────────────

/// Charter versions notifier for version history.
class CharterVersionsNotifier
    extends AutoDisposeAsyncNotifier<List<CachedCharter>> {
  @override
  Future<List<CachedCharter>> build() async {
    final repo = ref.watch(charterRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    if (spaceId == null) return [];
    return repo.getVersions(spaceId);
  }
}

/// Charter versions async provider.
final charterVersionsProvider =
    AsyncNotifierProvider.autoDispose<
      CharterVersionsNotifier,
      List<CachedCharter>
    >(CharterVersionsNotifier.new);

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for the current charter content.
final charterContentProvider = Provider<String>((ref) {
  return ref.watch(charterProvider).valueOrNull?.content ?? '';
});

/// Convenience provider indicating whether the charter needs acknowledgement.
final charterNeedsAckProvider = Provider<bool>((ref) {
  final charter = ref.watch(charterProvider).valueOrNull;
  if (charter == null) return false;
  return charter.content.isNotEmpty && !charter.isAcknowledged;
});
