import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/purchase_provider.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/purchase/purchase_service.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';

/// Screen for managing the Premium subscription.
///
/// Shows the current plan, a comparison table between Free and Premium,
/// upgrade buttons, and subscription management controls.
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final spaceId = ref.read(currentSpaceProvider)?.id;
    if (spaceId != null) {
      await ref.read(purchaseProvider.notifier).initialize();
      await ref.read(purchaseProvider.notifier).loadEntitlements(spaceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final purchaseAsync = ref.watch(purchaseProvider);
    final state = purchaseAsync.valueOrNull ?? const PurchaseState();
    final isLoading = purchaseAsync.isLoading;
    final space = ref.watch(currentSpaceProvider);

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('subscription'),
        showBackButton: true,
      ),
      body: isLoading && state.entitlementSummary == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Current plan badge
                _CurrentPlanCard(
                  tier: state.tier,
                  subscription: state.activeSubscription,
                  theme: theme,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Usage stats
                if (state.entitlementSummary != null) ...[
                  _UsageSection(
                    summary: state.entitlementSummary!,
                    theme: theme,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Comparison table
                _ComparisonTable(theme: theme),
                const SizedBox(height: AppSpacing.lg),

                // Upgrade / manage buttons
                if (!state.isPremium) ...[
                  _UpgradeButtons(
                    products: state.availableProducts,
                    isLoading: isLoading,
                    spaceId: space?.id,
                    onPurchase: (productId) {
                      if (space != null) {
                        ref
                            .read(purchaseProvider.notifier)
                            .purchase(productId, space.id);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => ref.read(purchaseProvider.notifier).restore(),
                      child: Text(context.l10n.translate('restorePurchases')),
                    ),
                  ),
                ] else ...[
                  _PremiumManagement(
                    subscription: state.activeSubscription,
                    isLoading: isLoading,
                    theme: theme,
                    onCancel: () {
                      if (space != null) {
                        _showCancelDialog(context, space.id);
                      }
                    },
                  ),
                ],

                // Error message
                if (purchaseAsync.hasError) ...[
                  const SizedBox(height: AppSpacing.md),
                  Card(
                    color: AppColors.error.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        purchaseAsync.error.toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
    );
  }

  void _showCancelDialog(BuildContext context, String spaceId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.translate('cancelSubscriptionQuestion')),
        content: const Text(
          'Your Premium benefits will remain active until the end of your '
          'current billing period. After that, your space will revert to '
          'the Free plan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.translate('keepPremium')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(purchaseProvider.notifier).cancel(spaceId);
            },
            child: Text(
              context.l10n.translate('cancelSubscription'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({
    required this.tier,
    required this.subscription,
    required this.theme,
  });

  final String tier;
  final Map<String, dynamic>? subscription;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isPremium = tier == 'premium';

    return Card(
      elevation: isPremium ? 4 : 1,
      color: isPremium ? theme.colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(
              isPremium ? Icons.workspace_premium : Icons.star_outline,
              size: 48,
              color: isPremium
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isPremium
                  ? context.l10n.translate('premium')
                  : context.l10n.translate('freePlan'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPremium ? theme.colorScheme.primary : null,
              ),
            ),
            if (isPremium && subscription != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _expiryText(subscription!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _expiryText(Map<String, dynamic> sub) {
    final periodEnd = sub['period_end'] as String?;
    if (periodEnd == null) return 'Active subscription';
    final date = DateTime.tryParse(periodEnd);
    if (date == null) return 'Active subscription';
    final formatted =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final status = sub['status'] as String? ?? 'active';
    if (status == 'canceled') {
      return 'Premium until $formatted';
    }
    return 'Renews $formatted';
  }
}

class _UsageSection extends StatelessWidget {
  const _UsageSection({required this.summary, required this.theme});

  final Map<String, dynamic> summary;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final usage = summary['usage'] as Map<String, dynamic>? ?? {};
    final storage = usage['storage'] as Map<String, dynamic>?;
    final members = usage['members'] as Map<String, dynamic>?;
    final aiCredits = usage['ai_credits'] as Map<String, dynamic>?;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (storage != null)
              _UsageRow(
                label: context.l10n.translate('storage'),
                used: storage['used'] as int? ?? 0,
                limit: storage['limit'] as int? ?? 0,
                unit: 'MB',
                theme: theme,
              ),
            if (members != null)
              _UsageRow(
                label: context.l10n.translate('members'),
                used: members['used'] as int? ?? 0,
                limit: members['limit'] as int? ?? 0,
                unit: '',
                theme: theme,
              ),
            if (aiCredits != null)
              _UsageRow(
                label: 'AI credits',
                used: aiCredits['used'] as int? ?? 0,
                limit: aiCredits['limit'] as int? ?? 0,
                unit: '/mo',
                theme: theme,
              ),
          ],
        ),
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({
    required this.label,
    required this.used,
    required this.limit,
    required this.unit,
    required this.theme,
  });

  final String label;
  final int used;
  final int limit;
  final String unit;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isUnlimited = limit == -1;
    final progress = isUnlimited ? 0.0 : (limit > 0 ? used / limit : 0.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodyMedium),
              Text(
                isUnlimited ? '$used$unit (unlimited)' : '$used / $limit$unit',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (!isUnlimited)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: progress > 0.9
                    ? AppColors.error
                    : theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({required this.theme});

  final ThemeData theme;

  static const _features = [
    ('Storage', '500 MB', '50 GB'),
    ('Members', '2', '20'),
    ('AI Credits', '10/mo', '500/mo'),
    ('Calendar connections', '1', '10'),
    ('Vault entries', '20', 'Unlimited'),
    ('File uploads', '50/mo', 'Unlimited'),
    ('History', '90 days', 'Unlimited'),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compare plans',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        'Feature',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        context.l10n.translate('freePlan'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        context.l10n.translate('premium'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                for (final (feature, free, premium) in _features)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        child: Text(feature, style: theme.textTheme.bodyMedium),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        child: Text(
                          free,
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        child: Text(
                          premium,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UpgradeButtons extends StatelessWidget {
  const _UpgradeButtons({
    required this.products,
    required this.isLoading,
    required this.spaceId,
    required this.onPurchase,
  });

  final List products;
  final bool isLoading;
  final String? spaceId;
  final void Function(String productId) onPurchase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If products are loaded from the store, show them
    if (products.isNotEmpty) {
      return Column(
        children: [
          for (final product in products)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading || spaceId == null
                      ? null
                      : () => onPurchase(product.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: Text(
                    '${_productLabel(product.id)} - ${product.price}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // Fallback if products haven't loaded
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading || spaceId == null
                ? null
                : () => onPurchase(kMonthlyProductId),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text(
              'Upgrade monthly',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: isLoading || spaceId == null
                ? null
                : () => onPurchase(kYearlyProductId),
            child: const Text(
              'Upgrade yearly (save 17%)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  String _productLabel(String productId) {
    if (productId.contains('yearly')) return 'Premium yearly';
    return 'Premium monthly';
  }
}

class _PremiumManagement extends StatelessWidget {
  const _PremiumManagement({
    required this.subscription,
    required this.isLoading,
    required this.theme,
    required this.onCancel,
  });

  final Map<String, dynamic>? subscription;
  final bool isLoading;
  final ThemeData theme;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final status = subscription?['status'] as String? ?? 'active';
    final isCanceled = status == 'canceled';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage subscription',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (subscription != null) ...[
              _InfoRow(
                label: 'Plan',
                value: _planName(subscription!['product_id'] as String?),
                theme: theme,
              ),
              _InfoRow(
                label: 'Status',
                value: isCanceled
                    ? 'Canceled'
                    : context.l10n.translate('active'),
                theme: theme,
              ),
              if (subscription!['period_end'] != null)
                _InfoRow(
                  label: isCanceled ? 'Expires' : 'Next renewal',
                  value: _formatDate(subscription!['period_end'] as String),
                  theme: theme,
                ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (!isCanceled)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isLoading ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: Text(context.l10n.translate('cancelSubscription')),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _planName(String? productId) {
    if (productId == null) return 'Premium';
    if (productId.contains('yearly')) return 'Premium yearly';
    return 'Premium monthly';
  }

  String _formatDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
