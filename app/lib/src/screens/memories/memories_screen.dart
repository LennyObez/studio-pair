import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/memories_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Memories timeline screen with year/month grouping.
class MemoriesScreen extends ConsumerStatefulWidget {
  const MemoriesScreen({super.key});

  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen> {
  bool _showMilestonesOnly = false;

  /// Group memories by year and month, returning a sorted structure.
  Map<String, Map<String, List<CachedMemory>>> _groupMemories(
    List<CachedMemory> memories,
  ) {
    final grouped = <String, Map<String, List<CachedMemory>>>{};

    for (final memory in memories) {
      final year = memory.memoryDate.year.toString();
      final monthNum = memory.memoryDate.month;
      final monthName = _monthName(monthNum);

      grouped.putIfAbsent(year, () => <String, List<CachedMemory>>{});
      grouped[year]!.putIfAbsent(monthName, () => <CachedMemory>[]);
      grouped[year]![monthName]!.add(memory);
    }

    // Sort years descending
    final sortedYears = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final result = <String, Map<String, List<CachedMemory>>>{};
    for (final year in sortedYears) {
      result[year] = grouped[year]!;
    }

    return result;
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month.clamp(1, 12)];
  }

  String _formatDate(DateTime date) {
    final monthAbbr = _monthName(date.month).substring(0, 3);
    return '$monthAbbr ${date.day}';
  }

  Future<void> _showAddMemoryDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    var selectedDate = DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dateLabel = DateFormat('MMM d, yyyy').format(selectedDate);

            return AlertDialog(
              title: Text(context.l10n.translate('addMemory')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: '${context.l10n.translate('title')} *',
                        hintText: context.l10n.translate('beachDayExample'),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: context.l10n.translate('description'),
                        hintText: context.l10n.translate('whatHappened'),
                        prefixIcon: const Icon(Icons.notes),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date *',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(dateLabel),
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
                  child: Text(context.l10n.translate('save')),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      final title = titleController.text.trim();
      final description = descriptionController.text.trim();

      if (title.isEmpty) {
        if (!mounted) {
          titleController.dispose();
          descriptionController.dispose();
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.translate('titleRequired'))),
        );
        titleController.dispose();
        descriptionController.dispose();
        return;
      }

      final spaceId = ref.read(spaceProvider).valueOrNull?.currentSpace?.id;
      if (spaceId == null) {
        titleController.dispose();
        descriptionController.dispose();
        return;
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

      final success = await ref
          .read(memoriesProvider.notifier)
          .createMemory(
            spaceId,
            title: title,
            date: dateStr,
            description: description.isNotEmpty ? description : null,
          );

      if (!mounted) {
        titleController.dispose();
        descriptionController.dispose();
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.translate('memoryAdded'))),
        );
      } else {
        final asyncState = ref.read(memoriesProvider);
        final error = asyncState.error is AppFailure
            ? (asyncState.error as AppFailure).message
            : null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? context.l10n.translate('failedToAddMemory')),
          ),
        );
      }
    }

    titleController.dispose();
    descriptionController.dispose();
  }

  void _showMemoryDetail(CachedMemory memory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: AppSpacing.sm),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Placeholder image area
                  Container(
                    height: 160,
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.moduleMemories.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppSpacing.radiusXl),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        memory.isMilestone ? Icons.emoji_events : Icons.photo,
                        size: 64,
                        color: AppColors.moduleMemories.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                memory.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (memory.isMilestone)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusRound,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: AppColors.warning,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      context.l10n.translate('milestone'),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: AppColors.warning,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              _formatDate(memory.memoryDate),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (memory.description != null &&
                            memory.description!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            memory.description!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncMemories = ref.watch(memoriesProvider);
    final theme = Theme.of(context);
    final memories = ref.watch(memoryListProvider);

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('memories'),
        showBackButton: true,
        actions: [
          if (memories.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.slideshow),
              tooltip: context.l10n.translate('slideshow'),
              onPressed: () => _openSlideshow(memories),
            ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _showMilestonesOnly
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            tooltip: context.l10n.translate('filterMemories'),
            onPressed: () {
              setState(() => _showMilestonesOnly = !_showMilestonesOnly);
            },
          ),
        ],
      ),
      body: _buildBody(asyncMemories, memories, theme),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemoryDialog,
        tooltip: 'Add memory',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  void _openSlideshow(List<CachedMemory> memories) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _MemoriesSlideshow(memories: memories),
      ),
    );
  }

  Widget _buildBody(
    AsyncValue<List<CachedMemory>> asyncMemories,
    List<CachedMemory> memories,
    ThemeData theme,
  ) {
    if (asyncMemories.isLoading && memories.isEmpty) {
      return const Center(child: SpLoading());
    }

    if (asyncMemories.hasError && memories.isEmpty) {
      return SpErrorWidget(
        message: asyncMemories.error is AppFailure
            ? (asyncMemories.error as AppFailure).message
            : '${asyncMemories.error}',
        onRetry: () => ref.invalidate(memoriesProvider),
      );
    }

    if (memories.isEmpty) {
      return SpEmptyState(
        icon: Icons.photo_library_outlined,
        title: context.l10n.translate('noMemoriesYet'),
        description: context.l10n.translate('startCapturingMoments'),
      );
    }

    final filteredMemories = _showMilestonesOnly
        ? memories.where((m) => m.isMilestone).toList()
        : memories;

    if (filteredMemories.isEmpty && _showMilestonesOnly) {
      return SpEmptyState(
        icon: Icons.star_outline,
        title: context.l10n.translate('noMilestonesYet'),
        description: context.l10n.translate('markMilestonesDescription'),
      );
    }

    final grouped = _groupMemories(filteredMemories);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        for (final yearEntry in grouped.entries) ...[
          Text(
            yearEntry.key,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final monthEntry in yearEntry.value.entries)
            _MonthSection(
              month: monthEntry.key,
              theme: theme,
              memories: monthEntry.value,
              formatDate: _formatDate,
              onMemoryTap: _showMemoryDetail,
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

/// Full-screen slideshow of memories with auto-advance and Ken Burns effect.
class _MemoriesSlideshow extends StatefulWidget {
  const _MemoriesSlideshow({required this.memories});

  final List<CachedMemory> memories;

  @override
  State<_MemoriesSlideshow> createState() => _MemoriesSlideshowState();
}

class _MemoriesSlideshowState extends State<_MemoriesSlideshow>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _kenBurnsController;
  Timer? _autoAdvanceTimer;
  int _currentPage = 0;
  bool _isPlaying = true;

  /// Duration each slide is displayed.
  static const _slideDuration = Duration(seconds: 5);

  /// Ken Burns animation duration (matches slide duration).
  static const _kenBurnsDuration = Duration(seconds: 6);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _kenBurnsController = AnimationController(
      vsync: this,
      duration: _kenBurnsDuration,
    )..repeat(reverse: true);
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    _kenBurnsController.dispose();
    super.dispose();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(_slideDuration, (_) {
      if (!_isPlaying || !mounted) return;
      final nextPage = (_currentPage + 1) % widget.memories.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _kenBurnsController.repeat(reverse: true);
        _startAutoAdvance();
      } else {
        _kenBurnsController.stop();
        _autoAdvanceTimer?.cancel();
      }
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Slideshow pages
          PageView.builder(
            controller: _pageController,
            itemCount: widget.memories.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final memory = widget.memories[index];
              return _KenBurnsSlide(
                memory: memory,
                animation: _kenBurnsController,
              );
            },
          ),

          // Gradient overlay at bottom for text readability
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),

          // Memory info overlay
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.xxl + 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.memories[_currentPage].title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatDate(widget.memories[_currentPage].memoryDate),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Page indicator
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.xxl,
            child: Row(
              children: List.generate(
                widget.memories.length,
                (i) => Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: i == _currentPage
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Controls overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: 'Close slideshow',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      tooltip: _isPlaying ? 'Pause' : 'Play',
                      onPressed: _togglePlayPause,
                    ),
                    Text(
                      '${_currentPage + 1} / ${widget.memories.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single slide with Ken Burns (slow zoom + pan) effect.
class _KenBurnsSlide extends StatelessWidget {
  const _KenBurnsSlide({required this.memory, required this.animation});

  final CachedMemory memory;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Animate scale from 1.0 to 1.15 and slight translate
        final scale = 1.0 + (animation.value * 0.15);
        final dx = animation.value * 20.0;
        final dy = animation.value * -10.0;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            // ignore: deprecated_member_use
            ..translate(dx, dy)
            // ignore: deprecated_member_use
            ..scale(scale),
          child: child,
        );
      },
      child: Container(
        color: AppColors.moduleMemories.withValues(alpha: 0.2),
        child: Center(
          child: Icon(
            memory.isMilestone ? Icons.emoji_events : Icons.photo,
            size: 80,
            color: AppColors.moduleMemories.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _MonthSection extends StatelessWidget {
  const _MonthSection({
    required this.month,
    required this.theme,
    required this.memories,
    required this.formatDate,
    required this.onMemoryTap,
  });

  final String month;
  final ThemeData theme;
  final List<CachedMemory> memories;
  final String Function(DateTime) formatDate;
  final void Function(CachedMemory) onMemoryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            month,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.moduleMemories,
            ),
          ),
        ),
        ...memories.map(
          (memory) => GestureDetector(
            onTap: () => onMemoryTap(memory),
            child: Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder image area
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.moduleMemories.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppSpacing.radiusLg),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        memory.isMilestone ? Icons.emoji_events : Icons.photo,
                        size: 48,
                        color: AppColors.moduleMemories.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                memory.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (memory.isMilestone)
                              const Icon(
                                Icons.star,
                                size: 18,
                                color: AppColors.warning,
                                semanticLabel: 'Milestone memory',
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDate(memory.memoryDate),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
