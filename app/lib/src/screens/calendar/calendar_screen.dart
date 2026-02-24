import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/calendar_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';

/// Calendar screen with day/week/month toggle.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _viewModes = ['day', 'week', 'month'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      ref.read(calendarViewModeProvider.notifier).state =
          _viewModes[_tabController.index];
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncCalendar = ref.watch(calendarProvider);
    final events = ref.watch(calendarEventsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('calendar'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = DateTime.now();
            },
            child: Text(context.l10n.translate('today')),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.translate('day')),
            Tab(text: context.l10n.translate('week')),
            Tab(text: context.l10n.translate('month')),
          ],
        ),
      ),
      body: _buildBody(
        theme: theme,
        asyncCalendar: asyncCalendar,
        events: events,
        selectedDate: selectedDate,
        spaceId: spaceId,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEventDialog(context, spaceId),
        tooltip: context.l10n.translate('addEvent'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody({
    required ThemeData theme,
    required AsyncValue<List<CachedCalendarEvent>> asyncCalendar,
    required List<CachedCalendarEvent> events,
    required DateTime selectedDate,
    required String? spaceId,
  }) {
    if (asyncCalendar.isLoading &&
        (asyncCalendar.valueOrNull?.isEmpty ?? true)) {
      return const Center(child: SpLoading());
    }

    if (asyncCalendar.hasError &&
        (asyncCalendar.valueOrNull?.isEmpty ?? true)) {
      return SpErrorWidget(
        message: asyncCalendar.error.toString(),
        failure: asyncCalendar.error,
        onRetry: () => ref.invalidate(calendarProvider),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _DayView(
          theme: theme,
          events: events,
          selectedDate: selectedDate,
          onEventTap: (event) => _showEventDetailSheet(context, event, spaceId),
        ),
        _WeekView(
          theme: theme,
          events: events,
          onEventTap: (event) => _showEventDetailSheet(context, event, spaceId),
        ),
        _MonthView(
          theme: theme,
          events: events,
          selectedDate: selectedDate,
          onDateSelected: (date) {
            ref.read(selectedDateProvider.notifier).state = date;
          },
          onEventTap: (event) => _showEventDetailSheet(context, event, spaceId),
        ),
      ],
    );
  }

  void _showCreateEventDialog(BuildContext context, String? spaceId) {
    if (spaceId == null) return;

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final selectedDate = ref.read(selectedDateProvider);
    var startAt = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      DateTime.now().hour + 1,
    );
    var endAt = startAt.add(const Duration(hours: 1));
    var eventType = 'general';
    var allDay = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(context.l10n.translate('newEvent')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.translate('title'),
                        hintText: context.l10n.translate('eventTitle'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: eventType,
                      decoration: InputDecoration(
                        labelText: context.l10n.translate('eventType'),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'general',
                          child: Text(context.l10n.translate('general')),
                        ),
                        DropdownMenuItem(
                          value: 'date',
                          child: Text(context.l10n.translate('dateEvent')),
                        ),
                        DropdownMenuItem(
                          value: 'errand',
                          child: Text(context.l10n.translate('errand')),
                        ),
                        DropdownMenuItem(
                          value: 'health',
                          child: Text(context.l10n.translate('health')),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          eventType = value ?? 'general';
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SwitchListTile(
                      title: Text(context.l10n.translate('allDay')),
                      value: allDay,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setDialogState(() => allDay = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.translate('start')),
                      subtitle: Text(
                        allDay
                            ? DateFormat('MMM d, yyyy').format(startAt)
                            : DateFormat(
                                'MMM d, yyyy - h:mm a',
                              ).format(startAt),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: startAt,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date == null) return;

                        if (allDay) {
                          setDialogState(() {
                            startAt = DateTime(date.year, date.month, date.day);
                            if (endAt.isBefore(startAt)) {
                              endAt = startAt;
                            }
                          });
                          return;
                        }

                        if (!ctx.mounted) return;
                        final time = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(startAt),
                        );
                        if (time == null) return;

                        setDialogState(() {
                          startAt = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                          if (endAt.isBefore(startAt)) {
                            endAt = startAt.add(const Duration(hours: 1));
                          }
                        });
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.translate('end')),
                      subtitle: Text(
                        allDay
                            ? DateFormat('MMM d, yyyy').format(endAt)
                            : DateFormat('MMM d, yyyy - h:mm a').format(endAt),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: endAt,
                          firstDate: startAt,
                          lastDate: DateTime(2100),
                        );
                        if (date == null) return;

                        if (allDay) {
                          setDialogState(() {
                            endAt = DateTime(date.year, date.month, date.day);
                          });
                          return;
                        }

                        if (!ctx.mounted) return;
                        final time = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(endAt),
                        );
                        if (time == null) return;

                        setDialogState(() {
                          endAt = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: context.l10n.translate(
                          'descriptionOptionalLabel',
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    titleController.dispose();
                    descriptionController.dispose();
                    Navigator.of(ctx).pop();
                  },
                  child: Text(context.l10n.translate('cancel')),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    final messenger = ScaffoldMessenger.of(context);

                    final success = await ref
                        .read(calendarProvider.notifier)
                        .createEvent(
                          spaceId,
                          title: title,
                          eventType: eventType,
                          allDay: allDay,
                          startAt: startAt,
                          endAt: endAt,
                        );

                    if (!ctx.mounted) {
                      titleController.dispose();
                      descriptionController.dispose();
                      return;
                    }

                    titleController.dispose();
                    descriptionController.dispose();
                    Navigator.of(ctx).pop();

                    if (success) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.translate('eventCreated')),
                        ),
                      );
                    } else {
                      final error = ref.read(calendarProvider).error;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            error?.toString() ??
                                context.l10n.translate('failedToCreateEvent'),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(context.l10n.translate('create')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEventDetailSheet(
    BuildContext context,
    CachedCalendarEvent event,
    String? spaceId,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _eventColor(event.eventType),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      event.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    event.allDay
                        ? '${context.l10n.translate('allDay')} - ${DateFormat('MMM d, yyyy').format(event.startAt)}'
                        : '${DateFormat('MMM d, yyyy - h:mm a').format(event.startAt)} to ${DateFormat('h:mm a').format(event.endAt)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.label_outline, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Chip(
                    label: Text(event.eventType),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              if (event.location != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
              if (event.recurrenceRule != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.repeat, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      event.recurrenceRule!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      if (spaceId == null) return;

                      final navigator = Navigator.of(ctx);
                      final messenger = ScaffoldMessenger.of(context);

                      final confirmed = await showDialog<bool>(
                        context: ctx,
                        builder: (dCtx) => AlertDialog(
                          title: Text(context.l10n.translate('deleteEvent')),
                          content: Text(
                            'Are you sure you want to delete "${event.title}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dCtx).pop(false),
                              child: Text(context.l10n.translate('cancel')),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(dCtx).pop(true),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: Text(context.l10n.translate('delete')),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true) return;

                      final success = await ref
                          .read(calendarProvider.notifier)
                          .deleteEvent(spaceId, event.id);

                      if (!ctx.mounted) return;
                      navigator.pop();

                      if (success) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              context.l10n.translate('eventDeleted'),
                            ),
                          ),
                        );
                      } else {
                        final error = ref.read(calendarProvider).error;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              error?.toString() ??
                                  context.l10n.translate('failedToDeleteEvent'),
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    label: Text(context.l10n.translate('delete')),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _showEditEventDialog(context, event, spaceId);
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(context.l10n.translate('edit')),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  void _showEditEventDialog(
    BuildContext context,
    CachedCalendarEvent event,
    String? spaceId,
  ) {
    if (spaceId == null) return;

    final titleController = TextEditingController(text: event.title);
    var startAt = event.startAt;
    var endAt = event.endAt;
    var eventType = event.eventType;
    var allDay = event.allDay;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(context.l10n.translate('editEvent')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.translate('title'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: eventType,
                      decoration: InputDecoration(
                        labelText: context.l10n.translate('eventType'),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'general',
                          child: Text(context.l10n.translate('general')),
                        ),
                        DropdownMenuItem(
                          value: 'date',
                          child: Text(context.l10n.translate('dateEvent')),
                        ),
                        DropdownMenuItem(
                          value: 'errand',
                          child: Text(context.l10n.translate('errand')),
                        ),
                        DropdownMenuItem(
                          value: 'health',
                          child: Text(context.l10n.translate('health')),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          eventType = value ?? 'general';
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SwitchListTile(
                      title: Text(context.l10n.translate('allDay')),
                      value: allDay,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setDialogState(() => allDay = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.translate('start')),
                      subtitle: Text(
                        allDay
                            ? DateFormat('MMM d, yyyy').format(startAt)
                            : DateFormat(
                                'MMM d, yyyy - h:mm a',
                              ).format(startAt),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: startAt,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date == null) return;

                        if (allDay) {
                          setDialogState(() {
                            startAt = DateTime(date.year, date.month, date.day);
                            if (endAt.isBefore(startAt)) {
                              endAt = startAt;
                            }
                          });
                          return;
                        }

                        if (!ctx.mounted) return;
                        final time = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(startAt),
                        );
                        if (time == null) return;

                        setDialogState(() {
                          startAt = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                          if (endAt.isBefore(startAt)) {
                            endAt = startAt.add(const Duration(hours: 1));
                          }
                        });
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.translate('end')),
                      subtitle: Text(
                        allDay
                            ? DateFormat('MMM d, yyyy').format(endAt)
                            : DateFormat('MMM d, yyyy - h:mm a').format(endAt),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: endAt,
                          firstDate: startAt,
                          lastDate: DateTime(2100),
                        );
                        if (date == null) return;

                        if (allDay) {
                          setDialogState(() {
                            endAt = DateTime(date.year, date.month, date.day);
                          });
                          return;
                        }

                        if (!ctx.mounted) return;
                        final time = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(endAt),
                        );
                        if (time == null) return;

                        setDialogState(() {
                          endAt = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    titleController.dispose();
                    Navigator.of(ctx).pop();
                  },
                  child: Text(context.l10n.translate('cancel')),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    final messenger = ScaffoldMessenger.of(context);

                    final success = await ref
                        .read(calendarProvider.notifier)
                        .updateEvent(spaceId, event.id, {
                          'title': title,
                          'event_type': eventType,
                          'all_day': allDay,
                          'start_at': startAt.toIso8601String(),
                          'end_at': endAt.toIso8601String(),
                        });

                    if (!ctx.mounted) {
                      titleController.dispose();
                      return;
                    }

                    titleController.dispose();
                    Navigator.of(ctx).pop();

                    if (success) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.translate('eventUpdated')),
                        ),
                      );
                    } else {
                      final error = ref.read(calendarProvider).error;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            error?.toString() ??
                                context.l10n.translate('failedToUpdateEvent'),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(context.l10n.translate('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _DayView extends StatelessWidget {
  const _DayView({
    required this.theme,
    required this.events,
    required this.selectedDate,
    required this.onEventTap,
  });

  final ThemeData theme;
  final List<CachedCalendarEvent> events;
  final DateTime selectedDate;
  final void Function(CachedCalendarEvent) onEventTap;

  @override
  Widget build(BuildContext context) {
    final dayEvents = events.where((e) {
      return e.startAt.year == selectedDate.year &&
          e.startAt.month == selectedDate.month &&
          e.startAt.day == selectedDate.day;
    }).toList()..sort((a, b) => a.startAt.compareTo(b.startAt));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          '${context.l10n.translate('today')} - ${DateFormat('MMMM d, yyyy').format(selectedDate)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (dayEvents.isEmpty)
          SpEmptyState(
            icon: Icons.event_busy,
            title: context.l10n.translate('noEventsToday'),
            description: context.l10n.translate('enjoyYourFreeDay'),
          )
        else
          ...dayEvents.map(
            (event) => _EventCard(
              time: DateFormat('h:mm a').format(event.startAt),
              title: event.title,
              color: _eventColor(event.eventType),
              onTap: () => onEventTap(event),
            ),
          ),
      ],
    );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({
    required this.theme,
    required this.events,
    required this.onEventTap,
  });

  final ThemeData theme;
  final List<CachedCalendarEvent> events;
  final void Function(CachedCalendarEvent) onEventTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: List.generate(7, (i) {
        final date = weekStart.add(Duration(days: i));
        final dayEvents = events.where((e) {
          return e.startAt.year == date.year &&
              e.startAt.month == date.month &&
              e.startAt.day == date.day;
        }).toList();

        final isToday =
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                '${DateFormat('EEEE, MMM d').format(date)}${isToday ? ' (${context.l10n.translate('today')})' : ''}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isToday ? theme.colorScheme.primary : null,
                ),
              ),
            ),
            if (dayEvents.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  context.l10n.translate('noEvents'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...dayEvents.map(
                (event) => _EventCard(
                  time: DateFormat('h:mm a').format(event.startAt),
                  title: event.title,
                  color: _eventColor(event.eventType),
                  onTap: () => onEventTap(event),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.theme,
    required this.events,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onEventTap,
  });

  final ThemeData theme;
  final List<CachedCalendarEvent> events;
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;
  final void Function(CachedCalendarEvent) onEventTap;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(selectedDate.year, selectedDate.month);
    final daysInMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;
    final startWeekday = firstOfMonth.weekday; // 1 = Monday
    final now = DateTime.now();

    // Events for the selected date
    final selectedDayEvents = events.where((e) {
      return e.startAt.year == selectedDate.year &&
          e.startAt.month == selectedDate.month &&
          e.startAt.day == selectedDate.day;
    }).toList()..sort((a, b) => a.startAt.compareTo(b.startAt));

    return Column(
      children: [
        // Month calendar grid
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous month',
                    onPressed: () {
                      onDateSelected(
                        DateTime(selectedDate.year, selectedDate.month - 1),
                      );
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(selectedDate),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next month',
                    onPressed: () {
                      onDateSelected(
                        DateTime(selectedDate.year, selectedDate.month + 1),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Day headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .map(
                      (day) => SizedBox(
                        width: 40,
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Calendar grid
              ...List.generate(6, (weekIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (dayIndex) {
                      final dayNum =
                          weekIndex * 7 + dayIndex - (startWeekday - 1) + 1;
                      final isValid = dayNum >= 1 && dayNum <= daysInMonth;
                      final isToday =
                          isValid &&
                          now.year == selectedDate.year &&
                          now.month == selectedDate.month &&
                          now.day == dayNum;
                      final isSelected = isValid && selectedDate.day == dayNum;

                      // Check if this day has events
                      final hasEvents =
                          isValid &&
                          events.any(
                            (e) =>
                                e.startAt.year == selectedDate.year &&
                                e.startAt.month == selectedDate.month &&
                                e.startAt.day == dayNum,
                          );

                      return Semantics(
                        button: isValid,
                        label: isValid
                            ? 'Select day $dayNum${hasEvents ? ', has events' : ''}${isToday ? ', today' : ''}'
                            : null,
                        selected: isSelected,
                        child: GestureDetector(
                          onTap: isValid
                              ? () {
                                  onDateSelected(
                                    DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      dayNum,
                                    ),
                                  );
                                }
                              : null,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : isToday
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isValid ? '$dayNum' : '',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : isToday
                                        ? theme.colorScheme.primary
                                        : null,
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                ),
                                if (hasEvents && !isSelected)
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ],
          ),
        ),
        const Divider(),
        // Events for selected day
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                'Events for ${DateFormat('MMMM d').format(selectedDate)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (selectedDayEvents.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: SpEmptyState(
                    icon: Icons.event_busy,
                    title: context.l10n.translate('noEvents'),
                    description: context.l10n.translate('noEventsScheduled'),
                  ),
                )
              else
                ...selectedDayEvents.map(
                  (event) => _EventCard(
                    time: DateFormat('h:mm a').format(event.startAt),
                    title: event.title,
                    color: _eventColor(event.eventType),
                    onTap: () => onEventTap(event),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

Color _eventColor(String eventType) {
  switch (eventType) {
    case 'date':
      return AppColors.moduleActivities;
    case 'errand':
      return AppColors.moduleGrocery;
    case 'health':
      return AppColors.moduleHealth;
    default:
      return AppColors.moduleCalendar;
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.time,
    required this.title,
    required this.color,
    this.onTap,
  });

  final String time;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$title at $time',
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusLg),
                    bottomLeft: Radius.circular(AppSpacing.radiusLg),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Text(
                        time,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(title, style: theme.textTheme.titleSmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
