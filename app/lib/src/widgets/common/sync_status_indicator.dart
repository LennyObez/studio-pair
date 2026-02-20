import 'package:flutter/material.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';

/// Sync status options.
enum SyncStatus { synced, syncing, offline, error }

/// Sync status indicator widget.
///
/// Displays the current sync status as:
/// - Synced: green check
/// - Syncing: blue spinner
/// - Offline: grey cloud
/// - Error: red warning
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({
    super.key,
    required this.status,
    this.showLabel = true,
    this.compact = false,
  });

  final SyncStatus status;
  final bool showLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(context);

    if (compact) {
      return Tooltip(message: config.label, child: config.icon);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          config.icon,
          if (showLabel) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              config.label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: config.foregroundColor),
            ),
          ],
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(BuildContext context) {
    switch (status) {
      case SyncStatus.synced:
        return _StatusConfig(
          icon: const Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.success,
          ),
          label: context.l10n.translate('synced'),
          backgroundColor: AppColors.successLight,
          foregroundColor: AppColors.successDark,
        );
      case SyncStatus.syncing:
        return _StatusConfig(
          icon: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.info),
            ),
          ),
          label: context.l10n.translate('syncing'),
          backgroundColor: AppColors.infoLight,
          foregroundColor: AppColors.infoDark,
        );
      case SyncStatus.offline:
        return _StatusConfig(
          icon: const Icon(Icons.cloud_off, size: 16, color: AppColors.grey500),
          label: context.l10n.translate('offline'),
          backgroundColor: AppColors.grey100,
          foregroundColor: AppColors.grey700,
        );
      case SyncStatus.error:
        return _StatusConfig(
          icon: const Icon(
            Icons.warning_amber,
            size: 16,
            color: AppColors.error,
          ),
          label: context.l10n.translate('syncError'),
          backgroundColor: AppColors.errorLight,
          foregroundColor: AppColors.errorDark,
        );
    }
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final Widget icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
}
