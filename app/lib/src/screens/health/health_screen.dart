import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/health_provider.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';

import 'package:studio_pair/src/widgets/common/sp_loading.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart' hide HealthProfile;

/// Health dashboard with body measurements, graphs, and sleep tracking.
class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    ref.read(healthProvider.notifier).loadProfile();
    ref.read(healthProvider.notifier).loadMeasurements();
  }

  double? _calculateBMI(HealthProfile? profile) {
    if (profile == null || profile.height == null || profile.weight == null) {
      return null;
    }
    final heightM = profile.height! / 100.0;
    if (heightM <= 0) return null;
    return profile.weight! / (heightM * heightM);
  }

  HealthMeasurement? _latestOfType(
    List<HealthMeasurement> measurements,
    String type,
  ) {
    final filtered = measurements.where((m) => m.type == type).toList();
    if (filtered.isEmpty) return null;
    return filtered.first;
  }

  void _showLogEntryDialog(BuildContext context) {
    final valueController = TextEditingController();
    final notesController = TextEditingController();
    var selectedType = 'weight';

    // Metric type to unit mapping
    const typeUnits = {
      'weight': 'kg',
      'blood_pressure': 'mmHg',
      'heart_rate': 'bpm',
      'steps': 'steps',
      'sleep': 'hours',
      'mood': 'score',
    };

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(context.l10n.translate('logHealthEntry')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Metric type',
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'weight',
                          child: Text(context.l10n.translate('weight')),
                        ),
                        DropdownMenuItem(
                          value: 'blood_pressure',
                          child: Text(context.l10n.translate('bloodPressure')),
                        ),
                        DropdownMenuItem(
                          value: 'heart_rate',
                          child: Text(context.l10n.translate('heartRate')),
                        ),
                        DropdownMenuItem(
                          value: 'steps',
                          child: Text(context.l10n.translate('steps')),
                        ),
                        DropdownMenuItem(
                          value: 'sleep',
                          child: Text(context.l10n.translate('sleep')),
                        ),
                        DropdownMenuItem(
                          value: 'mood',
                          child: Text(context.l10n.translate('mood')),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedType = value ?? 'weight';
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: valueController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Value',
                        suffixText: typeUnits[selectedType] ?? '',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    valueController.dispose();
                    notesController.dispose();
                    Navigator.of(ctx).pop();
                  },
                  child: Text(context.l10n.translate('cancel')),
                ),
                FilledButton(
                  onPressed: () async {
                    final valueText = valueController.text.trim();
                    final parsedValue = double.tryParse(valueText);
                    if (parsedValue == null) return;

                    final unit = typeUnits[selectedType] ?? '';
                    final messenger = ScaffoldMessenger.of(context);

                    final success = await ref
                        .read(healthProvider.notifier)
                        .addMeasurement(
                          type: selectedType,
                          value: parsedValue,
                          unit: unit,
                          source: 'manual',
                        );

                    if (!ctx.mounted) {
                      valueController.dispose();
                      notesController.dispose();
                      return;
                    }

                    if (success) {
                      valueController.dispose();
                      notesController.dispose();
                      Navigator.of(ctx).pop();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            context.l10n.translate('healthEntryLogged'),
                          ),
                        ),
                      );
                    } else {
                      final asyncState = ref.read(healthProvider);
                      final error = asyncState.error is AppFailure
                          ? (asyncState.error as AppFailure).message
                          : 'Failed to log entry';
                      messenger.showSnackBar(SnackBar(content: Text(error)));
                    }
                  },
                  child: Text(context.l10n.translate('log')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMetricDetailSheet(
    BuildContext context,
    String metricType,
    List<HealthMeasurement> allMeasurements,
    ThemeData theme,
  ) {
    final history = allMeasurements.where((m) => m.type == metricType).toList();

    // Readable label for the metric type
    final typeLabels = {
      'weight': 'Weight',
      'blood_pressure': 'Blood Pressure',
      'heart_rate': 'Heart Rate',
      'steps': 'Steps',
      'sleep': 'Sleep',
      'mood': 'Mood',
    };

    final label = typeLabels[metricType] ?? metricType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '$label History',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (history.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: Center(
                        child: Text(
                          'No $label data recorded yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: history.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, index) {
                          final m = history[index];
                          String formattedDate;
                          try {
                            final date = DateTime.parse(m.measuredAt);
                            formattedDate = DateFormat(
                              'MMM d, yyyy - h:mm a',
                            ).format(date);
                          } catch (_) {
                            formattedDate = m.measuredAt;
                          }

                          return ListTile(
                            title: Text(
                              '${m.value.toStringAsFixed(1)} ${m.unit}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(formattedDate),
                            trailing: m.source != null
                                ? Chip(
                                    label: Text(
                                      m.source!,
                                      style: theme.textTheme.labelSmall,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  )
                                : null,
                          );
                        },
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
    final asyncHealth = ref.watch(healthProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('health'),
        showBackButton: true,
      ),
      body: _buildBody(asyncHealth, theme),
    );
  }

  Widget _buildBody(AsyncValue<HealthData> asyncHealth, ThemeData theme) {
    final data = asyncHealth.valueOrNull ?? const HealthData();

    if (asyncHealth.isLoading &&
        data.profile == null &&
        data.measurements.isEmpty) {
      return const Center(child: SpLoading());
    }

    if (asyncHealth.hasError &&
        data.profile == null &&
        data.measurements.isEmpty) {
      // Show empty dashboard instead of error when offline/no backend
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Body measurements',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: context.l10n.translate('weight'),
                    value: '--',
                    icon: Icons.monitor_weight,
                    color: AppColors.moduleHealth,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricCard(
                    label: context.l10n.translate('height'),
                    value: '--',
                    icon: Icons.height,
                    color: AppColors.info,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricCard(
                    label: 'BMI',
                    value: '--',
                    icon: Icons.speed,
                    color: AppColors.success,
                    theme: theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _showLogEntryDialog(context),
                icon: const Icon(Icons.add),
                label: Text(context.l10n.translate('logHealthEntry')),
              ),
            ),
          ],
        ),
      );
    }

    final profile = data.profile;
    final bmi = _calculateBMI(profile);
    final latestWeight = _latestOfType(data.measurements, 'weight');
    final latestSleep = _latestOfType(data.measurements, 'sleep');

    // Use measurement weight if available, otherwise use profile weight
    final displayWeight = latestWeight?.value ?? profile?.weight;
    final displayHeight = profile?.height;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Body measurements
          Text(
            'Body measurements',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showMetricDetailSheet(
                    context,
                    'weight',
                    data.measurements,
                    theme,
                  ),
                  child: _MetricCard(
                    label: context.l10n.translate('weight'),
                    value: displayWeight != null
                        ? '${displayWeight.toStringAsFixed(1)} kg'
                        : '--',
                    icon: Icons.monitor_weight,
                    color: AppColors.moduleHealth,
                    theme: theme,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricCard(
                  label: context.l10n.translate('height'),
                  value: displayHeight != null
                      ? '${displayHeight.toStringAsFixed(0)} cm'
                      : '--',
                  icon: Icons.height,
                  color: AppColors.info,
                  theme: theme,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricCard(
                  label: 'BMI',
                  value: bmi != null ? bmi.toStringAsFixed(1) : '--',
                  icon: Icons.speed,
                  color: AppColors.success,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Weight graph placeholder
          Text(
            'Weight trend',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: _buildWeightTrend(data.measurements, theme),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Sleep section
          Text(
            context.l10n.translate('sleep'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () => _showMetricDetailSheet(
              context,
              'sleep',
              data.measurements,
              theme,
            ),
            child: _buildSleepCard(latestSleep, theme),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Sync from device
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: asyncHealth.isLoading
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final success = await ref
                          .read(healthProvider.notifier)
                          .syncFromDevice();
                      if (success) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              context.l10n.translate('healthDataSynced'),
                            ),
                          ),
                        );
                      } else {
                        if (!mounted) return;
                        final asyncState = ref.read(healthProvider);
                        final error = asyncState.error is AppFailure
                            ? (asyncState.error as AppFailure).message
                            : 'Failed to sync health data';
                        messenger.showSnackBar(SnackBar(content: Text(error)));
                      }
                    },
              icon: const Icon(Icons.sync),
              label: Text(
                asyncHealth.isLoading ? 'Syncing...' : 'Sync from device',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Log entry button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showLogEntryDialog(context),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.translate('logHealthEntry')),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildWeightTrend(
    List<HealthMeasurement> measurements,
    ThemeData theme,
  ) {
    final weightMeasurements = measurements
        .where((m) => m.type == 'weight')
        .toList();

    if (weightMeasurements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              semanticLabel: 'Weight trend chart',
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No weight data yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Sort measurements chronologically (oldest first) for the chart.
    final sorted = List<HealthMeasurement>.from(weightMeasurements)
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a.measuredAt) ?? DateTime(2000);
        final dateB = DateTime.tryParse(b.measuredAt) ?? DateTime(2000);
        return dateA.compareTo(dateB);
      });

    // Build FlSpot list using millisecondsSinceEpoch as X values.
    final spots = <FlSpot>[];
    for (final m in sorted) {
      final date = DateTime.tryParse(m.measuredAt);
      if (date == null) continue;
      spots.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), m.value));
    }

    // If all parsed dates failed, fall back to empty state.
    if (spots.isEmpty) {
      return Center(
        child: Text(
          'No weight data yet',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Compute Y-axis bounds with padding.
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final yPadding = (maxY - minY) * 0.15;
    final chartMinY = (minY - yPadding).clamp(0.0, double.infinity);
    final chartMaxY = maxY + yPadding;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      child: LineChart(
        LineChartData(
          minY: minY == maxY ? chartMinY - 1 : chartMinY,
          maxY: minY == maxY ? chartMaxY + 1 : chartMaxY,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: minY == maxY ? 1 : null,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.1,
                ),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  // Hide min/max boundary labels to avoid clipping.
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    value.toStringAsFixed(1),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  // Hide min/max boundary labels to avoid clipping.
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    value.toInt(),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      DateFormat('M/d').format(date),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    spot.x.toInt(),
                  );
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(1)} kg\n${DateFormat('MMM d').format(date)}',
                    TextStyle(
                      color: theme.colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              color: AppColors.moduleHealth,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: spots.length <= 30,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.moduleHealth,
                    strokeWidth: 1.5,
                    strokeColor: theme.colorScheme.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.moduleHealth.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepCard(HealthMeasurement? latestSleep, ThemeData theme) {
    if (latestSleep == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: Text(
              'No sleep data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    final sleepHours = latestSleep.value;
    final wholeHours = sleepHours.floor();
    final minutes = ((sleepHours - wholeHours) * 60).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.translate('lastNight'),
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      '${wholeHours}h ${minutes}m',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.moduleHealth,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.l10n.translate('source'),
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      latestSleep.source ?? 'manual',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(
                  Icons.bedtime,
                  size: 16,
                  color: AppColors.info,
                  semanticLabel: 'Sleep duration',
                ),
                const SizedBox(width: 4),
                Text(
                  '${latestSleep.value.toStringAsFixed(1)} ${latestSleep.unit}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
