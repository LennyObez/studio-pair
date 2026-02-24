import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/charter_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Charter screen with rich text display, version history, and acknowledgement.
class CharterScreen extends ConsumerWidget {
  const CharterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCharter = ref.watch(charterProvider);
    final spaceId =
        ref.watch(spaceProvider).valueOrNull?.currentSpace?.id ?? '';
    final theme = Theme.of(context);

    final charter = asyncCharter.valueOrNull;
    final currentContent = charter?.content ?? '';
    final currentVersion = charter?.versionNumber ?? 0;
    final isAcknowledged = charter?.isAcknowledged ?? false;

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('charter'),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ref.invalidate(charterVersionsProvider);
              _showVersionHistory(context, ref, spaceId);
            },
            tooltip: context.l10n.translate('history'),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditCharterDialog(
              context,
              ref,
              spaceId,
              currentContent,
              currentVersion,
            ),
            tooltip: 'Edit',
          ),
        ],
      ),
      body: _buildBody(
        context,
        ref,
        asyncCharter,
        theme,
        spaceId,
        currentContent,
        currentVersion,
        isAcknowledged,
      ),
    );
  }

  void _showVersionHistory(
    BuildContext context,
    WidgetRef ref,
    String spaceId,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final asyncVersions = ref.watch(charterVersionsProvider);
            final versions = asyncVersions.valueOrNull ?? [];

            if (asyncVersions.isLoading && versions.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(child: SpLoading()),
              );
            }
            if (versions.isEmpty) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text(context.l10n.translate('noVersionHistory')),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: versions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, index) {
                final version = versions[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('v${version.versionNumber}'),
                  ),
                  title: Text(
                    '${context.l10n.translate('version')} ${version.versionNumber}',
                  ),
                  subtitle: Text(
                    '${context.l10n.translate('editedBy')} ${version.editedBy}',
                  ),
                  trailing: version.isAcknowledged
                      ? const Icon(Icons.check_circle, color: AppColors.success)
                      : const Icon(Icons.pending, color: AppColors.warning),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showEditCharterDialog(
    BuildContext context,
    WidgetRef ref,
    String spaceId,
    String currentContent,
    int currentVersion,
  ) {
    final controller = TextEditingController(text: currentContent);

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
              Text('Edit charter', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${context.l10n.translate('currentVersion')}: $currentVersion',
                style: Theme.of(ctx).textTheme.labelSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                ),
                child: TextFormField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText:
                        'Write your charter content here...\n\nUse # for headings and - for bullet points.',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final content = controller.text.trim();
                    if (content.isEmpty) return;
                    final success = await ref
                        .read(charterProvider.notifier)
                        .updateCharter(spaceId, content);
                    if (success && ctx.mounted) {
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: Text(context.l10n.translate('saveCharter')),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<CachedCharter?> asyncCharter,
    ThemeData theme,
    String spaceId,
    String currentContent,
    int currentVersion,
    bool isAcknowledged,
  ) {
    if (asyncCharter.isLoading && currentContent.isEmpty) {
      return const Center(child: SpLoading());
    }

    if (asyncCharter.hasError) {
      return SpErrorWidget(
        message: asyncCharter.error is AppFailure
            ? (asyncCharter.error as AppFailure).message
            : '${asyncCharter.error}',
        onRetry: () => ref.invalidate(charterProvider),
      );
    }

    if (currentContent.isEmpty) {
      return SpEmptyState(
        icon: Icons.description_outlined,
        title: context.l10n.translate('noCharter'),
        description: context.l10n.translate('charterWillAppear'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Charter header
          Card(
            color: AppColors.moduleCharter.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.description, color: AppColors.moduleCharter),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our space charter',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${context.l10n.translate('currentVersion')} $currentVersion',
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
          const SizedBox(height: AppSpacing.lg),

          // Charter content -- render from provider
          ..._renderCharterContent(currentContent, theme),

          const SizedBox(height: AppSpacing.xl),

          // Acknowledgement section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    isAcknowledged ? Icons.check_circle : Icons.pending,
                    color: isAcknowledged
                        ? AppColors.success
                        : AppColors.warning,
                    semanticLabel: isAcknowledged
                        ? 'Acknowledged'
                        : 'Pending acknowledgement',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      isAcknowledged
                          ? 'Charter acknowledged'
                          : 'Acknowledgement pending',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isAcknowledged
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (!isAcknowledged)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(charterProvider.notifier)
                      .acknowledgeCharter(spaceId);
                },
                icon: const Icon(Icons.handshake),
                label: Text(context.l10n.translate('acknowledgeCharter')),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// Parse simple markdown-like charter content into widgets.
  List<Widget> _renderCharterContent(String content, ThemeData theme) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: AppSpacing.sm));
        continue;
      }

      if (trimmed.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(
              trimmed.substring(2),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(
              trimmed.substring(3),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('- ')) {
        widgets.add(_CharterBullet(text: trimmed.substring(2), theme: theme));
      } else {
        widgets.add(
          Text(
            trimmed,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        );
      }
    }

    return widgets;
  }
}

class _CharterBullet extends StatelessWidget {
  const _CharterBullet({required this.text, required this.theme});

  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.moduleCharter,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
