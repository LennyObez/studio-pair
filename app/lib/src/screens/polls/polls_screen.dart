import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/polls_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';

/// Polls screen with active polls and past results.
class PollsScreen extends ConsumerStatefulWidget {
  const PollsScreen({super.key});

  @override
  ConsumerState<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends ConsumerState<PollsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPolls();
    });
  }

  void _loadPolls() {
    final spaceId = ref.read(spaceProvider).currentSpace?.id;
    if (spaceId != null) {
      ref.read(pollsProvider.notifier).loadPolls(spaceId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showCreatePollDialog() async {
    final questionController = TextEditingController();
    final optionControllers = <TextEditingController>[
      TextEditingController(),
      TextEditingController(),
    ];

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(context.l10n.translate('createPoll')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: questionController,
                      decoration: InputDecoration(
                        labelText: '${context.l10n.translate('question')} *',
                        hintText: context.l10n.translate('whatDoYouWantToAsk'),
                        prefixIcon: const Icon(Icons.help_outline),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      context.l10n.translate('options'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...List.generate(optionControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: optionControllers[index],
                                decoration: InputDecoration(
                                  labelText:
                                      'Option ${index + 1}${index < 2 ? ' *' : ''}',
                                  hintText: context.l10n.translate(
                                    'enterOption',
                                  ),
                                  isDense: true,
                                ),
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                            if (optionControllers.length > 2)
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    optionControllers[index].dispose();
                                    optionControllers.removeAt(index);
                                  });
                                },
                                tooltip: 'Remove option',
                                color: AppColors.error,
                              ),
                          ],
                        ),
                      );
                    }),
                    if (optionControllers.length < 10)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              optionControllers.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(context.l10n.translate('addOption')),
                        ),
                      ),
                    if (optionControllers.length >= 10)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          context.l10n.translate('maxOptionsReached'),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.grey500),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(context.l10n.translate('cancel')),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(context.l10n.translate('create')),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      final question = questionController.text.trim();
      final optionLabels = optionControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (question.isEmpty || optionLabels.length < 2) {
        if (!mounted) {
          questionController.dispose();
          for (final c in optionControllers) {
            c.dispose();
          }
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.translate('enterQuestionAndOptions')),
          ),
        );
        questionController.dispose();
        for (final c in optionControllers) {
          c.dispose();
        }
        return;
      }

      final spaceId = ref.read(spaceProvider).currentSpace?.id;
      if (spaceId == null) {
        questionController.dispose();
        for (final c in optionControllers) {
          c.dispose();
        }
        return;
      }

      final success = await ref
          .read(pollsProvider.notifier)
          .createPoll(
            spaceId,
            question: question,
            type: 'single',
            isAnonymous: false,
            optionLabels: optionLabels,
          );

      if (!mounted) {
        questionController.dispose();
        for (final c in optionControllers) {
          c.dispose();
        }
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.translate('pollCreated'))),
        );
      } else {
        final error = ref.read(pollsProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ?? context.l10n.translate('failedToCreatePoll'),
            ),
          ),
        );
      }
    }

    questionController.dispose();
    for (final c in optionControllers) {
      c.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pollsProvider);
    final spaceId = ref.watch(spaceProvider).currentSpace?.id ?? '';

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('polls'),
        showBackButton: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.translate('active')),
            Tab(text: context.l10n.translate('past')),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: SpLoading())
          : state.error != null
          ? SpErrorWidget(message: state.error!, onRetry: _loadPolls)
          : TabBarView(
              controller: _tabController,
              children: [
                _PollsList(
                  polls: state.polls.where((p) => !p.isClosed).toList(),
                  spaceId: spaceId,
                  isActive: true,
                ),
                _PollsList(
                  polls: state.polls.where((p) => p.isClosed).toList(),
                  spaceId: spaceId,
                  isActive: false,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePollDialog,
        tooltip: 'Create poll',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PollsList extends ConsumerWidget {
  const _PollsList({
    required this.polls,
    required this.spaceId,
    required this.isActive,
  });

  final List<Poll> polls;
  final String spaceId;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (polls.isEmpty) {
      return SpEmptyState(
        icon: Icons.poll_outlined,
        title: isActive
            ? context.l10n.translate('noActivePolls')
            : context.l10n.translate('noPastPolls'),
        description: isActive
            ? context.l10n.translate('createPollDescription')
            : context.l10n.translate('completedPollsHere'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: polls.length,
      itemBuilder: (context, index) {
        final poll = polls[index];
        return _PollCard(poll: poll, spaceId: spaceId, theme: theme);
      },
    );
  }
}

class _PollCard extends ConsumerWidget {
  const _PollCard({
    required this.poll,
    required this.spaceId,
    required this.theme,
  });

  final Poll poll;
  final String spaceId;
  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = !poll.isClosed;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    poll.question,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (isActive ? AppColors.success : AppColors.grey500)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                  ),
                  child: Text(
                    isActive
                        ? context.l10n.translate('active')
                        : context.l10n.translate('closed'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isActive ? AppColors.success : AppColors.grey500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...poll.options.map((option) {
              final percentage = option.percentage.round();
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  onTap: isActive
                      ? () {
                          ref.read(pollsProvider.notifier).vote(
                            spaceId,
                            poll.id,
                            [option.id],
                          );
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: option.voteCount > 0
                            ? AppColors.modulePolls
                            : theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      color: option.voteCount > 0
                          ? AppColors.modulePolls.withValues(alpha: 0.08)
                          : null,
                    ),
                    child: Row(
                      children: [
                        if (option.voteCount > 0)
                          const Icon(
                            Icons.check_circle,
                            size: 18,
                            color: AppColors.modulePolls,
                          )
                        else
                          const Icon(Icons.radio_button_unchecked, size: 18),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            option.label,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${poll.totalVotes} ${context.l10n.translate('votes')}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  poll.isClosed
                      ? context.l10n.translate('closed')
                      : poll.deadline != null
                      ? 'Ends ${poll.deadline}'
                      : context.l10n.translate('noDeadline'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
