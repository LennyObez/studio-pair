import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/widgets/common/quick_action_fab.dart';

/// The selected tab index provider for the bottom navigation bar.
final selectedTabProvider = StateProvider<int>((ref) => 0);

/// Main shell widget that wraps all authenticated screens
/// with a bottom navigation bar and floating action button.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  List<_TabItem> _buildTabs(BuildContext context) => [
    _TabItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: context.l10n.translate('dashboard'),
      path: '/',
    ),
    _TabItem(
      icon: Icons.local_activity_outlined,
      activeIcon: Icons.local_activity,
      label: context.l10n.translate('activities'),
      path: '/activities',
    ),
    _TabItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: context.l10n.translate('calendar'),
      path: '/calendar',
    ),
    _TabItem(
      icon: Icons.chat_outlined,
      activeIcon: Icons.chat,
      label: context.l10n.translate('chat'),
      path: '/messages',
    ),
    _TabItem(
      icon: Icons.more_horiz_outlined,
      activeIcon: Icons.more_horiz,
      label: context.l10n.translate('more'),
      path: null,
    ),
  ];

  void _onTabTapped(BuildContext context, WidgetRef ref, int index) {
    final tabs = _buildTabs(context);
    if (index == 4) {
      // Show More menu
      _showMoreMenu(context);
      return;
    }
    ref.read(selectedTabProvider.notifier).state = index;
    final path = tabs[index].path;
    if (path != null) {
      context.go(path);
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) =>
            _MoreMenuSheet(scrollController: scrollController),
      ),
    );
  }

  /// Map the current route to a bottom nav tab index.
  int _tabIndexForRoute(String location) {
    if (location.startsWith('/activities')) return 1;
    if (location.startsWith('/calendar')) return 2;
    if (location.startsWith('/messages')) return 3;
    if (location == '/') return 0;
    // All other routes (tasks, finances, etc.) don't have a direct tab
    return -1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final routeTab = _tabIndexForRoute(location);

    // Sync the bottom nav with the current route
    if (routeTab >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(selectedTabProvider) != routeTab) {
          ref.read(selectedTabProvider.notifier).state = routeTab;
        }
      });
    }

    final selectedTab = ref.watch(selectedTabProvider);
    final tabs = _buildTabs(context);
    // Clamp to valid range for display
    final displayTab = (selectedTab >= 0 && selectedTab < tabs.length)
        ? selectedTab
        : 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: displayTab,
        onTap: (index) => _onTabTapped(context, ref, index),
        items: tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon),
                activeIcon: Icon(tab.activeIcon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
      floatingActionButton: const QuickActionFab(),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? path;
}

/// Bottom sheet showing the full module grid for the "More" tab.
class _MoreMenuSheet extends StatelessWidget {
  const _MoreMenuSheet({required this.scrollController});

  final ScrollController scrollController;

  List<_ModuleItem> _buildModules(BuildContext context) => [
    _ModuleItem(
      icon: Icons.task_alt,
      label: context.l10n.translate('tasks'),
      path: '/tasks',
      color: AppColors.moduleTasks,
    ),
    _ModuleItem(
      icon: Icons.account_balance_wallet,
      label: context.l10n.translate('finances'),
      path: '/finances',
      color: AppColors.moduleFinances,
    ),
    _ModuleItem(
      icon: Icons.credit_card,
      label: context.l10n.translate('cards'),
      path: '/cards',
      color: AppColors.moduleCards,
    ),
    _ModuleItem(
      icon: Icons.lock,
      label: context.l10n.translate('vault'),
      path: '/vault',
      color: AppColors.moduleVault,
    ),
    _ModuleItem(
      icon: Icons.favorite,
      label: context.l10n.translate('health'),
      path: '/health',
      color: AppColors.moduleHealth,
    ),
    _ModuleItem(
      icon: Icons.notifications,
      label: context.l10n.translate('reminders'),
      path: '/reminders',
      color: AppColors.moduleReminders,
    ),
    _ModuleItem(
      icon: Icons.folder,
      label: context.l10n.translate('files'),
      path: '/files',
      color: AppColors.moduleFiles,
    ),
    _ModuleItem(
      icon: Icons.photo_library,
      label: context.l10n.translate('memories'),
      path: '/memories',
      color: AppColors.moduleMemories,
    ),
    _ModuleItem(
      icon: Icons.description,
      label: context.l10n.translate('charter'),
      path: '/charter',
      color: AppColors.moduleCharter,
    ),
    _ModuleItem(
      icon: Icons.shopping_cart,
      label: context.l10n.translate('grocery'),
      path: '/grocery',
      color: AppColors.moduleGrocery,
    ),
    _ModuleItem(
      icon: Icons.poll,
      label: context.l10n.translate('polls'),
      path: '/polls',
      color: AppColors.modulePolls,
    ),
    _ModuleItem(
      icon: Icons.location_on,
      label: context.l10n.translate('location'),
      path: '/location',
      color: AppColors.moduleLocation,
    ),
    _ModuleItem(
      icon: Icons.settings,
      label: context.l10n.translate('settings'),
      path: '/settings',
      color: AppColors.grey600,
    ),
    _ModuleItem(
      icon: Icons.person,
      label: context.l10n.translate('profile'),
      path: '/profile',
      color: AppColors.grey600,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final modules = _buildModules(context);

    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            context.l10n.translate('more'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return _ModuleTile(module: module);
            },
          ),
        ),
      ],
    );
  }
}

class _ModuleItem {
  const _ModuleItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String path;
  final Color color;
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.module});

  final _ModuleItem module;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).pop();
        context.go(module.path);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: module.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(module.icon, color: module.color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            module.label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
