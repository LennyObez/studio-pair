import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/reminders_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';

/// Reminders screen with upcoming and past reminders.
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncReminders = ref.watch(remindersProvider);
    final reminders = asyncReminders.valueOrNull ?? [];

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('reminders'),
        showBackButton: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.translate('upcoming')),
            Tab(text: context.l10n.translate('past')),
          ],
        ),
      ),
      body: _buildBody(asyncReminders, reminders),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateReminderDialog(context),
        tooltip: context.l10n.translate('addReminder'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
    AsyncValue<List<CachedReminder>> asyncReminders,
    List<CachedReminder> reminders,
  ) {
    if (asyncReminders.isLoading && reminders.isEmpty) {
      return const Center(child: SpLoading());
    }

    if (asyncReminders.hasError && reminders.isEmpty) {
      // Show empty state instead of error when offline/no backend
      return TabBarView(
        controller: _tabController,
        children: [
          SpEmptyState(
            icon: Icons.notifications_none,
            title: context.l10n.translate('noRemindersYet'),
            description: context.l10n.translate('addReminderDescription'),
          ),
          SpEmptyState(
            icon: Icons.history,
            title: context.l10n.translate('noPastReminders'),
            description: context.l10n.translate('completedRemindersHere'),
          ),
        ],
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _UpcomingReminders(reminders: reminders),
        _PastReminders(reminders: reminders),
      ],
    );
  }

  void _showCreateReminderDialog(BuildContext context) {
    final messageController = TextEditingController();
    var selectedDate = DateTime.now().add(const Duration(hours: 1));
    var selectedTime = TimeOfDay.fromDateTime(selectedDate);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.l10n.translate('newReminder')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: messageController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: '${context.l10n.translate('message')} *',
                    hintText: context.l10n.translate('reminderMessage'),
                    prefixIcon: const Icon(Icons.message_outlined),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    DateFormat('EEE, MMM d, yyyy').format(selectedDate),
                  ),
                  trailing: const Icon(Icons.edit, size: 18),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(
                        () => selectedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.edit, size: 18),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setDialogState(() {
                        selectedTime = time;
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                messageController.dispose();
              },
              child: Text(context.l10n.translate('cancel')),
            ),
            FilledButton(
              onPressed: () {
                final message = messageController.text.trim();
                if (message.isNotEmpty) {
                  ref
                      .read(remindersProvider.notifier)
                      .createReminder(
                        message: message,
                        triggerAt: selectedDate,
                      );
                  Navigator.of(ctx).pop();
                }
                messageController.dispose();
              },
              child: Text(context.l10n.translate('create')),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingReminders extends ConsumerWidget {
  const _UpcomingReminders({required this.reminders});

  final List<CachedReminder> reminders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final upcoming =
        reminders.where((r) => !r.isSent && r.triggerAt.isAfter(now)).toList()
          ..sort((a, b) => a.triggerAt.compareTo(b.triggerAt));

    if (upcoming.isEmpty) {
      return SpEmptyState(
        icon: Icons.notifications_none,
        title: context.l10n.translate('noUpcomingReminders'),
        description: context.l10n.translate('addReminderDescription'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: upcoming.length,
      itemBuilder: (context, index) {
        final reminder = upcoming[index];
        return _ReminderCard(
          reminder: reminder,
          isPast: false,
          onSnooze: () {
            ref
                .read(remindersProvider.notifier)
                .snoozeReminder(
                  reminder.id,
                  15, // snooze 15 minutes
                );
          },
        );
      },
    );
  }
}

class _PastReminders extends ConsumerWidget {
  const _PastReminders({required this.reminders});

  final List<CachedReminder> reminders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final past =
        reminders.where((r) => r.triggerAt.isBefore(now) || r.isSent).toList()
          ..sort((a, b) => b.triggerAt.compareTo(a.triggerAt));

    if (past.isEmpty) {
      return SpEmptyState(
        icon: Icons.history,
        title: context.l10n.translate('noPastReminders'),
        description: context.l10n.translate('completedRemindersHere'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: past.length,
      itemBuilder: (context, index) {
        final reminder = past[index];
        return _ReminderCard(reminder: reminder, isPast: true);
      },
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.isPast,
    this.onSnooze,
  });

  final CachedReminder reminder;
  final bool isPast;
  final VoidCallback? onSnooze;

  IconData get _icon {
    if (reminder.linkedModule == 'calendar') return Icons.calendar_today;
    if (reminder.linkedModule == 'tasks') return Icons.task_alt;
    if (reminder.linkedModule == 'grocery') return Icons.shopping_cart;
    return Icons.notifications;
  }

  Color get _color {
    if (isPast) return AppColors.grey500;
    // For upcoming: color based on how soon
    final hoursUntil = reminder.triggerAt.difference(DateTime.now()).inHours;
    if (hoursUntil < 1) return AppColors.priorityUrgent;
    if (hoursUntil < 24) return AppColors.priorityHigh;
    if (hoursUntil < 72) return AppColors.warning;
    return AppColors.moduleReminders;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _color.withValues(alpha: 0.12),
          child: Icon(_icon, color: _color, size: 20),
        ),
        title: Text(
          reminder.message,
          style: theme.textTheme.titleSmall?.copyWith(
            decoration: isPast ? TextDecoration.lineThrough : null,
            color: isPast ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              Icons.schedule,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              DateFormat('MMM d, yyyy - h:mm a').format(reminder.triggerAt),
              style: theme.textTheme.labelSmall,
            ),
            if (reminder.recurrenceRule != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.repeat,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
                semanticLabel: 'Recurring',
              ),
            ],
          ],
        ),
        trailing: isPast
            ? const Icon(
                Icons.check_circle,
                color: AppColors.success,
                semanticLabel: 'Completed',
              )
            : IconButton(
                icon: const Icon(Icons.snooze),
                tooltip: 'Snooze 15 minutes',
                onPressed: onSnooze,
              ),
      ),
    );
  }
}
