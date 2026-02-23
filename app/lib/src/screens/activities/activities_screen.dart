import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/activities_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';
import 'package:studio_pair/src/widgets/common/sp_search_bar.dart';

/// Activities list screen with category filters and search.
class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  final _searchController = TextEditingController();

  static const _categories = [
    'All',
    'Movie',
    'TV Show',
    'Restaurant',
    'Recipe',
    'Game',
    'Book',
    'Travel',
    'DIY',
    'Other',
  ];

  // Translation keys for each category
  static const _categoryTranslationKeys = {
    'All': 'all',
    'Movie': 'movie',
    'TV Show': 'tvShow',
    'Restaurant': 'restaurant',
    'Recipe': 'recipe',
    'Game': 'game',
    'Book': 'book',
    'Travel': 'travel',
    'DIY': 'diy',
    'Other': 'other',
  };

  static const _categoryIcons = {
    'All': Icons.grid_view,
    'Movie': Icons.movie,
    'TV Show': Icons.tv,
    'Restaurant': Icons.restaurant,
    'Recipe': Icons.restaurant_menu,
    'Game': Icons.sports_esports,
    'Book': Icons.menu_book,
    'Travel': Icons.flight,
    'DIY': Icons.build,
    'Other': Icons.category,
  };

  static const _categoryColors = {
    'All': AppColors.primary,
    'Movie': AppColors.categoryMovie,
    'TV Show': AppColors.categoryTvShow,
    'Restaurant': AppColors.categoryRestaurant,
    'Recipe': AppColors.categoryRecipe,
    'Game': AppColors.categoryGame,
    'Book': AppColors.categoryBook,
    'Travel': AppColors.categoryTravel,
    'DIY': AppColors.categoryDiy,
    'Other': AppColors.categoryOther,
  };

  // Map display categories to provider category values
  static const _categoryToValue = {
    'All': 'all',
    'Movie': 'movie',
    'TV Show': 'tv_show',
    'Restaurant': 'restaurant',
    'Recipe': 'recipe',
    'Game': 'game',
    'Book': 'book',
    'Travel': 'travel',
    'DIY': 'diy',
    'Other': 'other',
  };

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final spaceId = ref.read(currentSpaceProvider)?.id;
      if (spaceId != null) {
        ref.read(activitiesProvider.notifier).loadActivities(spaceId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(activitiesProvider);
    final filteredActivities = ref.watch(activityListProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;

    // Determine which display category matches the current provider filter
    final selectedCategory = _categoryToValue.entries
        .firstWhere(
          (e) => e.value == state.selectedCategory,
          orElse: () => const MapEntry('All', 'all'),
        )
        .key;

    return Scaffold(
      appBar: SpAppBar(title: context.l10n.translate('activities')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: SpSearchBar(
              controller: _searchController,
              hintText: context.l10n.translate('searchActivities'),
              onChanged: (query) {
                ref.read(activitiesProvider.notifier).setSearchQuery(query);
              },
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = selectedCategory == category;
                final translationKey =
                    _categoryTranslationKeys[category] ?? category;
                return FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _categoryIcons[category],
                        size: 16,
                        color: isSelected
                            ? _categoryColors[category]
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(context.l10n.translate(translationKey)),
                    ],
                  ),
                  onSelected: (_) {
                    ref
                        .read(activitiesProvider.notifier)
                        .setCategory(_categoryToValue[category] ?? 'all');
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Activities list with loading/error/empty states
          Expanded(
            child: _buildBody(
              theme: theme,
              state: state,
              filteredActivities: filteredActivities,
              spaceId: spaceId,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateActivityDialog(context, spaceId),
        tooltip: context.l10n.translate('addActivity'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody({
    required ThemeData theme,
    required ActivitiesState state,
    required List<Activity> filteredActivities,
    required String? spaceId,
  }) {
    if (state.isLoading && state.activities.isEmpty) {
      return const Center(child: SpLoading());
    }

    if (state.error != null && state.activities.isEmpty) {
      return SpErrorWidget(
        message: state.error!,
        onRetry: () {
          if (spaceId != null) {
            ref.read(activitiesProvider.notifier).loadActivities(spaceId);
          }
        },
      );
    }

    if (filteredActivities.isEmpty) {
      return SpEmptyState(
        icon: Icons.local_activity_outlined,
        title: context.l10n.translate('noActivitiesYet'),
        description: context.l10n.translate('addActivityDescription'),
        actionLabel: context.l10n.translate('addActivity'),
        onAction: () => _showCreateActivityDialog(context, spaceId),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (spaceId != null) {
          await ref.read(activitiesProvider.notifier).loadActivities(spaceId);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: filteredActivities.length,
        itemBuilder: (context, index) {
          final activity = filteredActivities[index];
          return _ActivityCard(
            activity: activity,
            onVote: (score) {
              if (spaceId != null) {
                ref
                    .read(activitiesProvider.notifier)
                    .vote(spaceId, activity.id, score);
              }
            },
          );
        },
      ),
    );
  }

  void _showCreateActivityDialog(BuildContext context, String? spaceId) {
    if (spaceId == null) return;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    var selectedCategory = 'movie';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.l10n.translate('newActivity')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: '${context.l10n.translate('title')} *',
                    hintText: context.l10n.translate('activityTitle'),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    labelText: context.l10n.translate('category'),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'movie',
                      child: Text(context.l10n.translate('movie')),
                    ),
                    DropdownMenuItem(
                      value: 'tv_show',
                      child: Text(context.l10n.translate('tvShow')),
                    ),
                    DropdownMenuItem(
                      value: 'restaurant',
                      child: Text(context.l10n.translate('restaurant')),
                    ),
                    DropdownMenuItem(
                      value: 'recipe',
                      child: Text(context.l10n.translate('recipe')),
                    ),
                    DropdownMenuItem(
                      value: 'game',
                      child: Text(context.l10n.translate('game')),
                    ),
                    DropdownMenuItem(
                      value: 'book',
                      child: Text(context.l10n.translate('book')),
                    ),
                    DropdownMenuItem(
                      value: 'travel',
                      child: Text(context.l10n.translate('travel')),
                    ),
                    DropdownMenuItem(
                      value: 'diy',
                      child: Text(context.l10n.translate('diy')),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text(context.l10n.translate('other')),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: context.l10n.translate('description'),
                    hintText: context.l10n.translate('optionalDescription'),
                    prefixIcon: const Icon(Icons.notes),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                titleController.dispose();
                descriptionController.dispose();
              },
              child: Text(context.l10n.translate('cancel')),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  ref
                      .read(activitiesProvider.notifier)
                      .createActivity(
                        spaceId,
                        title: title,
                        category: selectedCategory,
                        description:
                            descriptionController.text.trim().isNotEmpty
                            ? descriptionController.text.trim()
                            : null,
                        privacy: 'shared',
                        mode: 'unlinked',
                      );
                  Navigator.of(ctx).pop();
                }
                titleController.dispose();
                descriptionController.dispose();
              },
              child: Text(context.l10n.translate('create')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, required this.onVote});

  final Activity activity;
  final void Function(int score) onVote;

  Color get _statusColor {
    switch (activity.status) {
      case 'completed':
        return AppColors.success;
      case 'active':
        return AppColors.info;
      default:
        return AppColors.grey500;
    }
  }

  String _statusLabel(BuildContext context) {
    switch (activity.status) {
      case 'completed':
        return context.l10n.translate('completed');
      case 'active':
        return context.l10n.translate('active');
      default:
        return context.l10n.translate('deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: activity.thumbnailUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Image.network(
                  activity.thumbnailUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  semanticLabel: 'Thumbnail for ${activity.title}',
                  errorBuilder: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: const Icon(Icons.image, color: AppColors.grey400),
                  ),
                ),
              )
            : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(Icons.image, color: AppColors.grey400),
              ),
        title: Text(
          activity.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(activity.category ?? context.l10n.translate('uncategorized')),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                  ),
                  child: Text(
                    _statusLabel(context),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _statusColor,
                    ),
                  ),
                ),
                if (activity.averageRating != null &&
                    activity.averageRating! > 0) ...[
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label:
                        'Rate activity, current rating ${activity.averageRating!.toStringAsFixed(1)}',
                    child: GestureDetector(
                      onTap: () => onVote(5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber[600]),
                          const SizedBox(width: 2),
                          Text(
                            activity.averageRating!.toStringAsFixed(1),
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          semanticLabel: 'View details',
        ),
        onTap: () {
          context.go('/activities/${activity.id}');
        },
      ),
    );
  }
}
