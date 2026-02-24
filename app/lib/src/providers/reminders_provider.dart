import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';

// ── Async notifier ──────────────────────────────────────────────────────

/// Reminders notifier backed by the [RemindersRepository].
///
/// The [build] method fetches reminders from the repository (API + cache)
/// whenever the current space changes.
class RemindersNotifier extends AutoDisposeAsyncNotifier<List<CachedReminder>> {
  @override
  Future<List<CachedReminder>> build() async {
    final repo = ref.watch(remindersRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    if (spaceId == null) return [];
    return repo.getReminders(spaceId);
  }

  /// Create a new reminder and refresh the list.
  Future<bool> createReminder({
    required String message,
    required DateTime triggerAt,
    String? recurrenceRule,
    String? linkedModule,
    String? linkedEntityId,
  }) async {
    final repo = ref.read(remindersRepositoryProvider);
    final spaceId = ref.read(currentSpaceProvider)?.id;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.createReminder(
        message: message,
        triggerAt: triggerAt.toIso8601String(),
        recurrenceRule: recurrenceRule,
        linkedModule: linkedModule,
        linkedEntityId: linkedEntityId,
      );
      if (spaceId == null) return <CachedReminder>[];
      return repo.getReminders(spaceId);
    });
    return !state.hasError;
  }

  /// Update a reminder and refresh the list.
  Future<bool> updateReminder(
    String reminderId,
    Map<String, dynamic> data,
  ) async {
    final repo = ref.read(remindersRepositoryProvider);
    final spaceId = ref.read(currentSpaceProvider)?.id;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.updateReminder(reminderId, data);
      if (spaceId == null) return <CachedReminder>[];
      return repo.getReminders(spaceId);
    });
    return !state.hasError;
  }

  /// Delete a reminder and refresh the list.
  Future<bool> deleteReminder(String reminderId) async {
    final repo = ref.read(remindersRepositoryProvider);
    final spaceId = ref.read(currentSpaceProvider)?.id;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteReminder(reminderId);
      if (spaceId == null) return <CachedReminder>[];
      return repo.getReminders(spaceId);
    });
    return !state.hasError;
  }

  /// Snooze a reminder and refresh the list.
  Future<bool> snoozeReminder(String reminderId, int minutes) async {
    final repo = ref.read(remindersRepositoryProvider);
    final spaceId = ref.read(currentSpaceProvider)?.id;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.snoozeReminder(reminderId, minutes);
      if (spaceId == null) return <CachedReminder>[];
      return repo.getReminders(spaceId);
    });
    return !state.hasError;
  }
}

/// Reminders async provider.
final remindersProvider =
    AsyncNotifierProvider.autoDispose<RemindersNotifier, List<CachedReminder>>(
      RemindersNotifier.new,
    );

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for upcoming active reminders sorted by trigger time.
final upcomingRemindersProvider = Provider<List<CachedReminder>>((ref) {
  final reminders = ref.watch(remindersProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final upcoming =
      reminders.where((r) => !r.isSent && r.triggerAt.isAfter(now)).toList()
        ..sort((a, b) => a.triggerAt.compareTo(b.triggerAt));
  return upcoming;
});
