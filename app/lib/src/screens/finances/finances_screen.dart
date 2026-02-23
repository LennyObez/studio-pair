import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/finances_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';

/// Finance dashboard with summary, chart placeholder, and recent entries.
class FinancesScreen extends ConsumerStatefulWidget {
  const FinancesScreen({super.key});

  @override
  ConsumerState<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends ConsumerState<FinancesScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final spaceId = ref.read(currentSpaceProvider)?.id;
      if (spaceId != null) {
        ref.read(financesProvider.notifier).loadEntries(spaceId);
        ref.read(financesProvider.notifier).loadSummary(spaceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(financesProvider);
    final filteredEntries = ref.watch(financeEntriesProvider);
    final summary = ref.watch(financeSummaryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;

    if (state.isLoading && state.entries.isEmpty) {
      return Scaffold(
        appBar: SpAppBar(
          title: context.l10n.translate('finances'),
          showBackButton: true,
        ),
        body: const Center(child: SpLoading()),
      );
    }

    if (state.error != null && state.entries.isEmpty) {
      return Scaffold(
        appBar: SpAppBar(
          title: context.l10n.translate('finances'),
          showBackButton: true,
        ),
        body: SpErrorWidget(
          message: state.error!,
          onRetry: () {
            if (spaceId != null) {
              ref.read(financesProvider.notifier).loadEntries(spaceId);
              ref.read(financesProvider.notifier).loadSummary(spaceId);
            }
          },
        ),
      );
    }

    // Determine selected type filter key
    var selectedTypeKey = 'all';
    if (state.selectedType == 'income') selectedTypeKey = 'income';
    if (state.selectedType == 'expense') selectedTypeKey = 'expense';

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('finances'),
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (spaceId != null) {
            await ref.read(financesProvider.notifier).loadEntries(spaceId);
            await ref.read(financesProvider.notifier).loadSummary(spaceId);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: context.l10n.translate('income'),
                      amount: summary != null
                          ? '€${summary.totalIncome.toStringAsFixed(2)}'
                          : '€0.00',
                      icon: Icons.arrow_upward,
                      color: AppColors.success,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _SummaryCard(
                      title: context.l10n.translate('expenses'),
                      amount: summary != null
                          ? '€${summary.totalExpenses.toStringAsFixed(2)}'
                          : '€0.00',
                      icon: Icons.arrow_downward,
                      color: AppColors.error,
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.translate('balance'),
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        summary != null
                            ? '€${summary.balance.toStringAsFixed(2)}'
                            : '€0.00',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: (summary?.balance ?? 0) >= 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Income vs Expenses chart
              Text(
                'Income vs Expenses',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 200,
                child:
                    summary != null &&
                        (summary.totalIncome > 0 || summary.totalExpenses > 0)
                    ? PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 48,
                          sections: [
                            PieChartSectionData(
                              value: summary.totalIncome,
                              title: summary.totalIncome > 0
                                  ? '€${summary.totalIncome.toStringAsFixed(0)}'
                                  : '',
                              color: AppColors.success,
                              radius: 40,
                              titleStyle:
                                  theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ) ??
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                            ),
                            PieChartSectionData(
                              value: summary.totalExpenses,
                              title: summary.totalExpenses > 0
                                  ? '€${summary.totalExpenses.toStringAsFixed(0)}'
                                  : '',
                              color: AppColors.error,
                              radius: 40,
                              titleStyle:
                                  theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ) ??
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pie_chart_outline,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'No data yet',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              if (summary != null &&
                  (summary.totalIncome > 0 || summary.totalExpenses > 0))
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendDot(
                        color: AppColors.success,
                        label: context.l10n.translate('income'),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _LegendDot(
                        color: AppColors.error,
                        label: context.l10n.translate('expenses'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),

              // Type filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final filterKey in ['all', 'income', 'expense'])
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          selected: selectedTypeKey == filterKey,
                          label: Text(context.l10n.translate(filterKey)),
                          onSelected: (_) {
                            if (filterKey == 'all') {
                              ref
                                  .read(financesProvider.notifier)
                                  .setTypeFilter(null);
                            } else {
                              ref
                                  .read(financesProvider.notifier)
                                  .setTypeFilter(filterKey);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Recent entries
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Entries',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(financesProvider.notifier).setTypeFilter(null);
                    },
                    child: Text(context.l10n.translate('viewAll')),
                  ),
                ],
              ),
              if (filteredEntries.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: SpEmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: context.l10n.translate('noEntries'),
                    description: context.l10n.translate('addEntryDescription'),
                  ),
                )
              else
                ...filteredEntries.map(
                  (entry) => _EntryCard(
                    title: entry.description ?? entry.category,
                    amount: entry.type == 'expense'
                        ? '-€${entry.amount.toStringAsFixed(2)}'
                        : '+€${entry.amount.toStringAsFixed(2)}',
                    isExpense: entry.type == 'expense',
                    category: entry.category,
                    date: entry.date,
                    theme: theme,
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEntryDialog(context, spaceId),
        tooltip: 'Add finance entry',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateEntryDialog(BuildContext context, String? spaceId) {
    if (spaceId == null) return;
    final descController = TextEditingController();
    final amountController = TextEditingController();
    var selectedType = 'expense';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(context.l10n.translate('newEntry')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'income',
                    label: Text(context.l10n.translate('income')),
                  ),
                  ButtonSegment(
                    value: 'expense',
                    label: Text(context.l10n.translate('expense')),
                  ),
                ],
                selected: {selectedType},
                onSelectionChanged: (set) {
                  setDialogState(() => selectedType = set.first);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  hintText: context.l10n.translate('description'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: context.l10n.translate('amount'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(context.l10n.translate('cancel')),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text.trim());
                if (amount != null && amount > 0) {
                  ref
                      .read(financesProvider.notifier)
                      .createEntry(
                        spaceId,
                        type: selectedType,
                        category: 'general',
                        amount: amount,
                        currency: 'EUR',
                        description: descController.text.trim(),
                        isRecurring: false,
                        date: DateTime.now().toIso8601String().substring(0, 10),
                      );
                  Navigator.of(ctx).pop();
                }
              },
              child: Text(context.l10n.translate('add')),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.theme,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(title, style: theme.textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              amount,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.category,
    required this.date,
    required this.theme,
  });

  final String title;
  final String amount;
  final bool isExpense;
  final String category;
  final String date;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isExpense ? AppColors.error : AppColors.success)
              .withValues(alpha: 0.12),
          child: Icon(
            isExpense ? Icons.arrow_downward : Icons.arrow_upward,
            color: isExpense ? AppColors.error : AppColors.success,
            size: 20,
          ),
        ),
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: Text('$category - $date', style: theme.textTheme.labelSmall),
        trailing: Text(
          amount,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isExpense ? AppColors.error : AppColors.success,
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
