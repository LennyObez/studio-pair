import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/charter_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';

/// Charter screen with rich text display, version history, and acknowledgement.
class CharterScreen extends ConsumerStatefulWidget {
  const CharterScreen({super.key});

  @override
  ConsumerState<CharterScreen> createState() => _CharterScreenState();
}

class _CharterScreenState extends ConsumerState<CharterScreen> {
  @override
  void initState() {
    super.initState();
    _loadCharter();
  }

  void _loadCharter() {
    final spaceId = ref.read(spaceProvider).currentSpace?.id;
    if (spaceId != null) {
      ref.read(charterProvider.notifier).loadCharter(spaceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charterProvider);
    final spaceId = ref.watch(spaceProvider).currentSpace?.id ?? '';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('charter'),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ref.read(charterProvider.notifier).loadVersions(spaceId);
              _showVersionHistory(context, spaceId);
            },
            tooltip: context.l10n.translate('history'),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditCharterDialog(context, spaceId, state),
            tooltip: 'Edit',
          ),
        ],
      ),
      body: _buildBody(state, theme, spaceId),
    );
  }

  void _showVersionHistory(BuildContext context, String spaceId) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final state = ref.watch(charterProvider);
            if (state.isLoading) {
              return const SizedBox(
                height: 200,
                child: Center(child: SpLoading()),
              );
            }
            if (state.versions.isEmpty) {
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
              itemCount: state.versions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, index) {
                final version = state.versions[index];
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
    String spaceId,
    CharterState state,
  ) {
    final controller = TextEditingController(text: state.currentContent);

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
                '${context.l10n.translate('currentVersion')}: ${state.currentVersion}',
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

  Widget _buildBody(CharterState state, ThemeData theme, String spaceId) {
    if (state.isLoading && state.currentContent.isEmpty) {
      return const Center(child: SpLoading());
    }

    if (state.error != null) {
      return SpErrorWidget(message: state.error!, onRetry: _loadCharter);
    }

    if (state.currentContent.isEmpty) {
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
                          '${context.l10n.translate('currentVersion')} ${state.currentVersion}',
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
          ..._renderCharterContent(state.currentContent, theme),

          const SizedBox(height: AppSpacing.xl),

          // Acknowledgement section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    state.isAcknowledged ? Icons.check_circle : Icons.pending,
                    color: state.isAcknowledged
                        ? AppColors.success
                        : AppColors.warning,
                    semanticLabel: state.isAcknowledged
                        ? 'Acknowledged'
                        : 'Pending acknowledgement',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      state.isAcknowledged
                          ? 'Charter acknowledged'
                          : 'Acknowledgement pending',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: state.isAcknowledged
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

          if (!state.isAcknowledged)
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
