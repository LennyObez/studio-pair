import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/activities_provider.dart';
import 'package:studio_pair/src/providers/calendar_provider.dart';
import 'package:studio_pair/src/providers/finances_provider.dart';
import 'package:studio_pair/src/providers/grocery_provider.dart';
import 'package:studio_pair/src/providers/messaging_provider.dart';
import 'package:studio_pair/src/providers/notifications_provider.dart';
import 'package:studio_pair/src/providers/polls_provider.dart';
import 'package:studio_pair/src/providers/reminders_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/providers/sync_provider.dart';
import 'package:studio_pair/src/providers/tasks_provider.dart';
import 'package:studio_pair/src/services/sync/sync_service.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sync_status_indicator.dart';

/// Dashboard screen showing a grid of module widgets.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  void _loadAllData() {
    final spaceId = ref.read(currentSpaceProvider)?.id;
    if (spaceId == null) return;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(
      now.year,
      now.month + 1,
    ).subtract(const Duration(milliseconds: 1));

    ref.read(activitiesProvider.notifier).loadActivities(spaceId);
    ref.read(tasksProvider.notifier).loadTasks(spaceId);
    ref
        .read(calendarProvider.notifier)
        .loadEvents(spaceId, monthStart, monthEnd);
    ref.read(messagingProvider.notifier).loadConversations(spaceId);
    ref.read(financesProvider.notifier).loadEntries(spaceId);
    ref.read(financesProvider.notifier).loadSummary(spaceId);
    ref.read(groceryProvider.notifier).loadLists(spaceId);
    ref.read(remindersProvider.notifier).loadReminders();
    ref.read(pollsProvider.notifier).loadPolls(spaceId);
    ref.read(notificationsProvider.notifier).loadNotifications();
  }

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return '${context.l10n.translate('goodMorning')}!';
    if (hour < 17) return '${context.l10n.translate('goodAfternoon')}!';
    return '${context.l10n.translate('goodEvening')}!';
  }

  List<_DashboardWidget> _buildDashboardWidgets(
    BuildContext context,
    WidgetRef ref,
  ) {
    final activityCount = ref.watch(activityListProvider).length;
    final taskCount = ref.watch(pendingTaskCountProvider);
    final calendarCount = ref.watch(calendarEventsProvider).length;
    final unreadMessages = ref.watch(totalUnreadMessagesProvider);
    final summary = ref.watch(financeSummaryProvider);
    final groceryUnchecked = ref.watch(uncheckedCountProvider);
    final reminderCount = ref.watch(upcomingRemindersProvider).length;
    final pollCount = ref.watch(activePollCountProvider);

    final balanceStr = summary != null
        ? '\u20ac${summary.balance.toStringAsFixed(0)}'
        : '\u20ac0';

    return [
      _DashboardWidget(
        title: context.l10n.translate('activities'),
        icon: Icons.local_activity,
        color: AppColors.moduleActivities,
        count: '$activityCount',
        subtitle: activityCount == 1
            ? context.l10n.translate('activities').toLowerCase()
            : context.l10n.translate('activities').toLowerCase(),
        route: '/activities',
      ),
      _DashboardWidget(
        title: context.l10n.translate('tasks'),
        icon: Icons.task_alt,
        color: AppColors.moduleTasks,
        count: '$taskCount',
        subtitle: context.l10n.translate('pending').toLowerCase(),
        route: '/tasks',
      ),
      _DashboardWidget(
        title: context.l10n.translate('calendar'),
        icon: Icons.calendar_month,
        color: AppColors.moduleCalendar,
        count: '$calendarCount',
        subtitle: calendarCount == 1
            ? context.l10n.translate('upcomingEvent')
            : context.l10n.translate('upcomingEvents'),
        route: '/calendar',
      ),
      _DashboardWidget(
        title: context.l10n.translate('messages'),
        icon: Icons.chat,
        color: AppColors.moduleMessaging,
        count: '$unreadMessages',
        subtitle: context.l10n.translate('unread'),
        route: '/messages',
      ),
      _DashboardWidget(
        title: context.l10n.translate('finances'),
        icon: Icons.account_balance_wallet,
        color: AppColors.moduleFinances,
        count: balanceStr,
        subtitle: context.l10n.translate('balance').toLowerCase(),
        route: '/finances',
      ),
      _DashboardWidget(
        title: context.l10n.translate('grocery'),
        icon: Icons.shopping_cart,
        color: AppColors.moduleGrocery,
        count: '$groceryUnchecked',
        subtitle: groceryUnchecked == 1
            ? context.l10n.translate('item')
            : context.l10n.translate('items'),
        route: '/grocery',
      ),
      _DashboardWidget(
        title: context.l10n.translate('reminders'),
        icon: Icons.notifications,
        color: AppColors.moduleReminders,
        count: '$reminderCount',
        subtitle: context.l10n.translate('upcoming').toLowerCase(),
        route: '/reminders',
      ),
      _DashboardWidget(
        title: context.l10n.translate('polls'),
        icon: Icons.poll,
        color: AppColors.modulePolls,
        count: '$pollCount',
        subtitle: context.l10n.translate('active').toLowerCase(),
        route: '/polls',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dashboardWidgets = _buildDashboardWidgets(context, ref);
    final notifications = ref.watch(notificationListProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    // Map SyncServiceStatus to widget SyncStatus
    SyncStatus widgetSyncStatus;
    switch (syncStatus) {
      case SyncServiceStatus.synced:
        widgetSyncStatus = SyncStatus.synced;
      case SyncServiceStatus.syncing:
        widgetSyncStatus = SyncStatus.syncing;
      case SyncServiceStatus.offline:
        widgetSyncStatus = SyncStatus.offline;
      case SyncServiceStatus.error:
        widgetSyncStatus = SyncStatus.error;
    }

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('appName'),
        showLogo: true,
        showSpaceSelector: true,
        actions: [
          SyncStatusIndicator(status: widgetSyncStatus, compact: true),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadAllData();
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: CustomScrollView(
          slivers: [
            // Greeting section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(context),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.translate('heresWhatsHappening'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Widget grid
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.md),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final widget = dashboardWidgets[index];
                  return _DashboardCard(widget: widget);
                }, childCount: dashboardWidgets.length),
              ),
            ),

            // Recent activity section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.translate('recentActivity'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (notifications.isEmpty)
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.info_outline),
                          ),
                          title: Text(
                            context.l10n.translate('noRecentActivity'),
                          ),
                          subtitle: Text(
                            context.l10n.translate('newActivityWillAppear'),
                          ),
                          trailing: Text(
                            '',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      ...notifications
                          .take(3)
                          .map(
                            (notif) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.xs,
                              ),
                              child: Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Icon(
                                      notif.isRead
                                          ? Icons.check_circle_outline
                                          : Icons.circle_notifications,
                                      semanticLabel: notif.isRead
                                          ? 'Read'
                                          : 'Unread',
                                    ),
                                  ),
                                  title: Text(notif.title),
                                  subtitle: Text(notif.body),
                                  trailing: Text(
                                    _timeAgo(notif.createdAt),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _DashboardWidget {
  const _DashboardWidget({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
    required this.subtitle,
    required this.route,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String count;
  final String subtitle;
  final String route;
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.widget});

  final _DashboardWidget widget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: '${widget.title}: ${widget.count} ${widget.subtitle}',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () => context.go(widget.route),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(widget.icon, color: widget.color, size: 24),
                    Text(
                      widget.count,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
