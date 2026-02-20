import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/activities_provider.dart';
import 'package:studio_pair/src/providers/auth_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Activity detail screen showing full activity information.
class ActivityDetailScreen extends ConsumerStatefulWidget {
  const ActivityDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ActivityDetailScreen> createState() =>
      _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  int _userRating = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncActivities = ref.watch(activitiesProvider);
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    final members = ref.watch(spaceMembersProvider);

    final activities = asyncActivities.valueOrNull ?? [];

    // Find the activity by ID
    final activityOrNull = activities.cast<CachedActivity?>().firstWhere(
      (a) => a?.id == widget.id,
      orElse: () => null,
    );

    // Show error snackbar on async errors
    ref.listen<AsyncValue<List<CachedActivity>>>(activitiesProvider, (
      previous,
      next,
    ) {
      if (next.hasError && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    if (activityOrNull == null) {
      return Scaffold(
        appBar: SpAppBar(
          title: context.l10n.translate('activityDetail'),
          showBackButton: true,
        ),
        body: Center(child: Text(context.l10n.translate('activityNotFound'))),
      );
    }

    final activity = activityOrNull;
    final isCreator = activity.createdBy == currentUserId;
    final isCompleted = activity.status == 'completed';

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('activityDetail'),
        showBackButton: true,
        actions: [
          if (isCreator)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: context.l10n.translate('editActivity'),
              onPressed: () =>
                  _showEditActivityDialog(context, ref, activity, spaceId),
            ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: context.l10n.translate('shareActivity'),
            onPressed: () {
              final text = StringBuffer('Check out: ${activity.title}');
              if (activity.description != null) {
                text.write('\n${activity.description}');
              }
              if (activity.trailerUrl != null) {
                text.write('\n${activity.trailerUrl}');
              }
              Share.share(text.toString());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail / cover image
            Container(
              height: 200,
              width: double.infinity,
              color: AppColors.grey200,
              child: activity.thumbnailUrl != null
                  ? Image.network(
                      activity.thumbnailUrl!,
                      fit: BoxFit.cover,
                      semanticLabel: 'Cover image for ${activity.title}',
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.image,
                              size: 64,
                              color: AppColors.grey400,
                            ),
                          ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.image,
                        size: 64,
                        color: AppColors.grey400,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    activity.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Category and status
                  Row(
                    children: [
                      if (activity.category.isNotEmpty)
                        Chip(
                          avatar: Icon(
                            _categoryIcon(activity.category),
                            size: 16,
                          ),
                          label: Text(_capitalizeFirst(activity.category)),
                          backgroundColor: _categoryColor(
                            activity.category,
                          ).withValues(alpha: 0.12),
                        ),
                      if (activity.category.isNotEmpty)
                        const SizedBox(width: AppSpacing.sm),
                      Chip(
                        label: Text(_capitalizeFirst(activity.status)),
                        backgroundColor: isCompleted
                            ? AppColors.success.withValues(alpha: 0.12)
                            : theme.colorScheme.primaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Description
                  if (activity.description != null) ...[
                    Text(
                      context.l10n.translate('description'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      activity.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Trailer placeholder
                  if (activity.trailerUrl != null) ...[
                    Text(
                      context.l10n.translate('trailer'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Semantics(
                      button: true,
                      label: context.l10n.translate('watchTrailer'),
                      child: GestureDetector(
                        onTap: () async {
                          final uri = Uri.tryParse(activity.trailerUrl!);
                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.l10n.translate('couldNotOpenTrailer'),
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.grey200,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              size: 64,
                              color: AppColors.grey400,
                              semanticLabel: context.l10n.translate(
                                'playTrailer',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Voting / Rating
                  Text(
                    context.l10n.translate('yourRating'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _StarRatingBar(
                    rating: _userRating,
                    onRatingChanged: (score) {
                      setState(() => _userRating = score);
                      if (spaceId != null) {
                        ref
                            .read(activitiesProvider.notifier)
                            .vote(spaceId, activity.id, score);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Rated ${_ratingLabel(context, score)} ($score/5)',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _userRating > 0
                        ? '$_userRating / 5 - ${_ratingLabel(context, _userRating)}'
                        : context.l10n.translate('tapStarToRate'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Member votes (placeholder)
                  Text(
                    context.l10n.translate('memberVotes'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    child: Column(
                      children: members.isEmpty
                          ? [
                              ListTile(
                                title: Text(
                                  context.l10n.translate('noVotesYet'),
                                ),
                                subtitle: Text(
                                  context.l10n.translate('beFirstToRate'),
                                ),
                              ),
                            ]
                          : members.asMap().entries.map((entry) {
                              final index = entry.key;
                              final member = entry.value;
                              final isCurrentUser =
                                  member.userId == currentUserId;
                              final memberRating = isCurrentUser
                                  ? _userRating
                                  : 0;
                              return Column(
                                children: [
                                  if (index > 0) const Divider(height: 1),
                                  ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        member.displayName.isNotEmpty
                                            ? member.displayName[0]
                                                  .toUpperCase()
                                            : '?',
                                      ),
                                    ),
                                    title: Text(
                                      isCurrentUser
                                          ? context.l10n.translate('you')
                                          : member.displayName,
                                    ),
                                    trailing: memberRating > 0
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(
                                              5,
                                              (i) => Icon(
                                                i < memberRating
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                size: 18,
                                                color: Colors.amber[600],
                                              ),
                                            ),
                                          )
                                        : Text(
                                            isCurrentUser
                                                ? context.l10n.translate(
                                                    'tapToRate',
                                                  )
                                                : context.l10n.translate(
                                                    'notRated',
                                                  ),
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                  ),
                                ],
                              );
                            }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Complete button
                  if (!isCompleted)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: asyncActivities.isLoading
                            ? null
                            : () async {
                                if (spaceId == null) return;
                                final success = await ref
                                    .read(activitiesProvider.notifier)
                                    .completeActivity(spaceId, activity.id);
                                if (context.mounted && success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.l10n.translate(
                                          'activityMarkedComplete',
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                        icon: asyncActivities.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle),
                        label: Text(context.l10n.translate('markAsComplete')),
                      ),
                    ),

                  if (isCompleted)
                    Container(
                      width: double.infinity,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            semanticLabel: 'Completed',
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            context.l10n.translate('completed'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Delete button (only if creator)
                  if (isCreator) ...[
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: asyncActivities.isLoading
                            ? null
                            : () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(
                                      context.l10n.translate(
                                        'deleteActivityQuestion',
                                      ),
                                    ),
                                    content: Text(
                                      context.l10n.translate(
                                        'deleteActivityWarning',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: Text(
                                          context.l10n.translate('cancel'),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: Text(
                                          context.l10n.translate('delete'),
                                          style: const TextStyle(
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true &&
                                    spaceId != null &&
                                    context.mounted) {
                                  final success = await ref
                                      .read(activitiesProvider.notifier)
                                      .deleteActivity(spaceId, activity.id);
                                  if (context.mounted && success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.l10n.translate(
                                            'activityDeleted',
                                          ),
                                        ),
                                      ),
                                    );
                                    if (context.mounted) {
                                      context.pop();
                                    }
                                  }
                                }
                              },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        label: Text(context.l10n.translate('deleteActivity')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditActivityDialog(
    BuildContext context,
    WidgetRef ref,
    CachedActivity activity,
    String? spaceId,
  ) {
    if (spaceId == null) return;
    final titleController = TextEditingController(text: activity.title);
    final descController = TextEditingController(
      text: activity.description ?? '',
    );
    final trailerController = TextEditingController(
      text: activity.trailerUrl ?? '',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.translate('editActivity'),
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: context.l10n.translate('title'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: context.l10n.translate('description'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: trailerController,
                decoration: InputDecoration(
                  labelText: context.l10n.translate('trailerUrl'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    final data = <String, dynamic>{
                      'title': title,
                      'description': descController.text.trim().isNotEmpty
                          ? descController.text.trim()
                          : null,
                      'trailer_url': trailerController.text.trim().isNotEmpty
                          ? trailerController.text.trim()
                          : null,
                    };
                    final success = await ref
                        .read(activitiesProvider.notifier)
                        .updateActivity(spaceId, activity.id, data);
                    if (success && ctx.mounted) {
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: Text(context.l10n.translate('saveChanges')),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  String _ratingLabel(BuildContext context, int score) {
    switch (score) {
      case 1:
        return context.l10n.translate('ratingTrash');
      case 2:
        return context.l10n.translate('ratingMeh');
      case 3:
        return context.l10n.translate('ratingOkay');
      case 4:
        return context.l10n.translate('ratingGreat');
      case 5:
        return context.l10n.translate('ratingLoveIt');
      default:
        return '';
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'movie':
      case 'entertainment':
        return Icons.movie;
      case 'tv':
      case 'tvshow':
        return Icons.tv;
      case 'restaurant':
        return Icons.restaurant;
      case 'recipe':
      case 'cooking':
        return Icons.restaurant_menu;
      case 'game':
        return Icons.sports_esports;
      case 'book':
        return Icons.menu_book;
      case 'travel':
        return Icons.flight;
      case 'outdoors':
        return Icons.terrain;
      case 'diy':
        return Icons.build;
      default:
        return Icons.local_activity;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'movie':
      case 'entertainment':
        return AppColors.categoryMovie;
      case 'tv':
      case 'tvshow':
        return AppColors.categoryTvShow;
      case 'restaurant':
        return AppColors.categoryRestaurant;
      case 'recipe':
      case 'cooking':
        return AppColors.categoryRecipe;
      case 'game':
        return AppColors.categoryGame;
      case 'book':
        return AppColors.categoryBook;
      case 'travel':
        return AppColors.categoryTravel;
      case 'outdoors':
        return AppColors.categoryTravel;
      case 'diy':
        return AppColors.categoryDiy;
      default:
        return AppColors.categoryOther;
    }
  }
}

/// Interactive star rating bar widget.
class _StarRatingBar extends StatelessWidget {
  const _StarRatingBar({required this.rating, required this.onRatingChanged});

  final int rating;
  final ValueChanged<int> onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final score = index + 1;
        final isSelected = score <= rating;
        return Semantics(
          button: true,
          label: 'Rate $score of 5 stars',
          selected: isSelected,
          child: GestureDetector(
            onTap: () => onRatingChanged(score),
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Icon(
                isSelected ? Icons.star : Icons.star_border,
                color: isSelected ? Colors.amber[600] : Colors.grey[400],
                size: 36,
              ),
            ),
          ),
        );
      }),
    );
  }
}
