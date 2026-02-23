import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/reminders_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/reminders_dao.dart';

/// Reminder model.
class Reminder {
  const Reminder({
    required this.id,
    required this.message,
    required this.triggerAt,
    this.recurrenceRule,
    this.linkedModule,
    this.linkedEntityId,
    required this.isActive,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      message: json['message'],
      triggerAt: DateTime.parse(json['trigger_at']),
      recurrenceRule: json['recurrence_rule'],
      linkedModule: json['linked_module'],
      linkedEntityId: json['linked_entity_id'],
      isActive: json['is_active'] ?? true,
    );
  }

  final String id;
  final String message;
  final DateTime triggerAt;
  final String? recurrenceRule;
  final String? linkedModule;
  final String? linkedEntityId;
  final bool isActive;
}

/// Reminders state.
class RemindersState {
  const RemindersState({
    this.reminders = const [],
    this.isLoading = false,
    this.isCached = false,
    this.error,
  });

  final List<Reminder> reminders;
  final bool isLoading;
  final bool isCached;
  final String? error;

  RemindersState copyWith({
    List<Reminder>? reminders,
    bool? isLoading,
    bool? isCached,
    String? error,
    bool clearError = false,
  }) {
    return RemindersState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Reminders state notifier managing reminder CRUD and snooze.
class RemindersNotifier extends StateNotifier<RemindersState> {
  RemindersNotifier(this._api, this._dao) : super(const RemindersState());

  final RemindersApi _api;
  final RemindersDao _dao;

  /// Load all reminders for the current user.
  Future<void> loadReminders({String? spaceId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // 1. Load from cache first
    if (spaceId != null) {
      try {
        final cached = await _dao.getReminders(spaceId).first;
        if (cached.isNotEmpty) {
          final reminders = cached
              .map(
                (c) => Reminder(
                  id: c.id,
                  message: c.message,
                  triggerAt: c.triggerAt,
                  recurrenceRule: c.recurrenceRule,
                  linkedModule: c.linkedModule,
                  linkedEntityId: c.linkedEntityId,
                  isActive: !c.isSent,
                ),
              )
              .toList();
          state = state.copyWith(
            reminders: reminders,
            isLoading: false,
            isCached: true,
          );
        }
      } catch (_) {
        // Cache read failed, continue to API
      }
    }

    // 2. Try API in background
    try {
      final response = await _api.listReminders();
      final items = parseList(response.data);
      final reminders = items.map(Reminder.fromJson).toList();

      // Upsert into cache
      if (spaceId != null) {
        for (final item in reminders) {
          await _dao.upsertReminder(
            CachedRemindersCompanion(
              id: Value(item.id),
              spaceId: Value(spaceId),
              createdBy: const Value(''),
              message: Value(item.message),
              triggerAt: Value(item.triggerAt),
              recurrenceRule: Value(item.recurrenceRule),
              linkedModule: Value(item.linkedModule),
              linkedEntityId: Value(item.linkedEntityId),
              isSent: Value(!item.isActive),
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
              syncedAt: Value(DateTime.now()),
            ),
          );
        }
      }

      state = state.copyWith(
        reminders: reminders,
        isLoading: false,
        isCached: false,
      );
    } catch (e) {
      if (state.reminders.isEmpty) {
        state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Create a new reminder.
  Future<bool> createReminder({
    required String message,
    required DateTime triggerAt,
    String? recurrenceRule,
    String? linkedModule,
    String? linkedEntityId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.createReminder(
        message: message,
        triggerAt: triggerAt.toIso8601String(),
        recurrenceRule: recurrenceRule,
        linkedModule: linkedModule,
        linkedEntityId: linkedEntityId,
      );

      final newReminder = Reminder.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        reminders: [...state.reminders, newReminder],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Update an existing reminder.
  Future<bool> updateReminder(
    String reminderId,
    Map<String, dynamic> data,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.updateReminder(reminderId, data);
      final updated = Reminder.fromJson(response.data as Map<String, dynamic>);

      final updatedReminders = state.reminders.map((reminder) {
        if (reminder.id == reminderId) {
          return updated;
        }
        return reminder;
      }).toList();

      state = state.copyWith(reminders: updatedReminders, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Delete a reminder.
  Future<bool> deleteReminder(String reminderId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.deleteReminder(reminderId);

      state = state.copyWith(
        reminders: state.reminders.where((r) => r.id != reminderId).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Snooze a reminder by a given number of minutes.
  Future<bool> snoozeReminder(String reminderId, int minutes) async {
    try {
      final response = await _api.snoozeReminder(reminderId, minutes);
      final updated = Reminder.fromJson(response.data as Map<String, dynamic>);

      final updatedReminders = state.reminders.map((reminder) {
        if (reminder.id == reminderId) {
          return updated;
        }
        return reminder;
      }).toList();

      state = state.copyWith(reminders: updatedReminders);
      return true;
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return false;
    }
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Reminders state provider.
final remindersProvider =
    StateNotifierProvider<RemindersNotifier, RemindersState>((ref) {
      return RemindersNotifier(
        ref.watch(remindersApiProvider),
        ref.watch(remindersDaoProvider),
      );
    });

/// Convenience provider for upcoming active reminders sorted by trigger time.
final upcomingRemindersProvider = Provider<List<Reminder>>((ref) {
  final reminders = ref.watch(remindersProvider).reminders;
  final now = DateTime.now();
  final upcoming =
      reminders.where((r) => r.isActive && r.triggerAt.isAfter(now)).toList()
        ..sort((a, b) => a.triggerAt.compareTo(b.triggerAt));
  return upcoming;
});
