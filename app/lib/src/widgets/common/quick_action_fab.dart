import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';

/// Floating action button with expandable quick action menu.
class QuickActionFab extends StatefulWidget {
  const QuickActionFab({super.key});

  @override
  State<QuickActionFab> createState() => _QuickActionFabState();
}

class _QuickActionFabState extends State<QuickActionFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _isOpen = false;

  List<_QuickAction> _buildActions(BuildContext context) => [
    _QuickAction(
      icon: Icons.local_activity,
      label: context.l10n.translate('addActivity'),
      color: AppColors.moduleActivities,
      route: '/activities',
    ),
    _QuickAction(
      icon: Icons.task_alt,
      label: context.l10n.translate('addTask'),
      color: AppColors.moduleTasks,
      route: '/tasks',
    ),
    _QuickAction(
      icon: Icons.event,
      label: context.l10n.translate('addEvent'),
      color: AppColors.moduleCalendar,
      route: '/calendar',
    ),
    _QuickAction(
      icon: Icons.euro,
      label: context.l10n.translate('addExpense'),
      color: AppColors.moduleFinances,
      route: '/finances',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return FadeTransition(
            opacity: _expandAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, (actions.length - index) * 0.3),
                end: Offset.zero,
              ).animate(_expandAnimation),
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      color: Theme.of(context).colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        child: Text(
                          action.label,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FloatingActionButton.small(
                      heroTag: 'quick_action_$index',
                      onPressed: () {
                        _toggle();
                        context.go(action.route);
                      },
                      backgroundColor: action.color,
                      foregroundColor: Colors.white,
                      child: Icon(action.icon),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggle,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 250),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String route;
}
