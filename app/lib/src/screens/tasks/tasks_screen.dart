import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/providers/tasks_provider.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';

/// Tasks screen with filters and task list.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  static const _filters = ['All', 'To Do', 'In Progress', 'Done'];

  static const _filterToStatus = {
    'All': 'all',
    'To Do': 'todo',
    'In Progress': 'in_progress',
    'Done': 'done',
  };

  // Translation keys for each filter
  static const _filterTranslationKeys = {
    'All': 'all',
    'To Do': 'toDoFilter',
    'In Progress': 'inProgressFilter',
    'Done': 'doneFilter',
  };

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final spaceId = ref.read(currentSpaceProvider)?.id;
      if (spaceId != null) {
        ref.read(tasksProvider.notifier).loadTasks(spaceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(tasksProvider);
    final filteredTasks = ref.watch(taskListProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;

    // Map the provider filter back to display label
    final selectedFilter = _filterToStatus.entries
        .firstWhere(
          (e) => e.value == state.filter,
          orElse: () => const MapEntry('All', 'all'),
        )
        .key;

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('tasks'),
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                for (final filter in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      selected: selectedFilter == filter,
                      label: Text(
                        context.l10n.translate(
                          _filterTranslationKeys[filter] ?? 'all',
                        ),
                      ),
                      onSelected: (_) {
                        ref
                            .read(tasksProvider.notifier)
                            .setFilter(_filterToStatus[filter] ?? 'all');
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Task list with loading/error/empty states
          Expanded(
            child: _buildBody(
              theme: theme,
              state: state,
              filteredTasks: filteredTasks,
              spaceId: spaceId,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateTaskDialog(context, spaceId);
        },
        tooltip: context.l10n.translate('addTask'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody({
    required ThemeData theme,
    required TasksState state,
    required List<TaskItem> filteredTasks,
    required String? spaceId,
  }) {
    if (state.isLoading && state.tasks.isEmpty) {
      return const Center(child: SpLoading());
    }

    if (state.error != null && state.tasks.isEmpty) {
      return SpErrorWidget(
        message: state.error!,
        onRetry: () {
          if (spaceId != null) {
            ref.read(tasksProvider.notifier).loadTasks(spaceId);
          }
        },
      );
    }

    if (filteredTasks.isEmpty) {
      return SpEmptyState(
        icon: Icons.task_alt_outlined,
        title: context.l10n.translate('noTasksYet'),
        description: context.l10n.translate('addTaskDescription'),
        actionLabel: context.l10n.translate('addTask'),
        onAction: () => _showCreateTaskDialog(context, spaceId),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (spaceId != null) {
          await ref.read(tasksProvider.notifier).loadTasks(spaceId);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return Dismissible(
            key: ValueKey(task.id),
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: AppSpacing.md),
              color: AppColors.success,
              child: const Icon(Icons.check, color: Colors.white),
            ),
            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: AppSpacing.md),
              color: AppColors.error,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              if (spaceId == null) return false;
              if (direction == DismissDirection.startToEnd) {
                // Swipe right: complete
                if (task.status == 'done') {
                  await ref
                      .read(tasksProvider.notifier)
                      .reopenTask(spaceId, task.id);
                } else {
                  await ref
                      .read(tasksProvider.notifier)
                      .completeTask(spaceId, task.id);
                }
                return false; // Don't remove from list, just update status
              } else {
                // Swipe left: delete
                return await ref
                    .read(tasksProvider.notifier)
                    .deleteTask(spaceId, task.id);
              }
            },
            child: _TaskCard(
              task: task,
              onToggle: () {
                if (spaceId == null) return;
                if (task.status == 'done') {
                  ref.read(tasksProvider.notifier).reopenTask(spaceId, task.id);
                } else {
                  ref
                      .read(tasksProvider.notifier)
                      .completeTask(spaceId, task.id);
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context, String? spaceId) {
    if (spaceId == null) return;
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.translate('newTask')),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.l10n.translate('taskTitle'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.translate('cancel')),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                ref
                    .read(tasksProvider.notifier)
                    .createTask(spaceId, title: title, priority: 'medium');
                Navigator.of(ctx).pop();
              }
            },
            child: Text(context.l10n.translate('create')),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onToggle});

  final TaskItem task;
  final VoidCallback onToggle;

  Color get _priorityColor {
    switch (task.priority) {
      case 'urgent':
        return AppColors.priorityUrgent;
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      default:
        return AppColors.priorityLow;
    }
  }

  String get _dueDateLabel {
    if (task.dueDate == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );
    final diff = due.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 0) return 'In $diff days';
    return '${-diff} days ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = task.status == 'done';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Checkbox(
          value: isDone,
          onChanged: (_) => onToggle(),
          shape: const CircleBorder(),
        ),
        title: Text(
          task.title,
          style: theme.textTheme.titleSmall?.copyWith(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),
        subtitle: Row(
          children: [
            if (task.assignees.isNotEmpty) ...[
              Icon(
                Icons.person_outline,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(task.assignees.first, style: theme.textTheme.labelSmall),
              const SizedBox(width: AppSpacing.sm),
            ],
            if (task.dueDate != null) ...[
              Icon(
                Icons.calendar_today,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(_dueDateLabel, style: theme.textTheme.labelSmall),
            ],
          ],
        ),
        trailing: Semantics(
          label: '${task.priority} priority',
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _priorityColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
