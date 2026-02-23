import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/auth_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';

/// Onboarding wizard with multi-page setup flow.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  final _inviteEmailController = TextEditingController();

  final _selectedModules = <String>{
    'activities',
    'calendar',
    'messaging',
    'tasks',
    'finances',
  };

  String _selectedSpaceType = 'couple';
  String _spaceAction = ''; // 'create' or 'join'
  final _joinCodeController = TextEditingController();
  final _spaceNameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    _inviteEmailController.dispose();
    _joinCodeController.dispose();
    _spaceNameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final spaceNotifier = ref.read(spaceProvider.notifier);
    var success = true;

    if (_spaceAction == 'create') {
      final spaceName = _spaceNameController.text.trim().isNotEmpty
          ? _spaceNameController.text.trim()
          : 'My Space';
      success = await spaceNotifier.createSpace(
        name: spaceName,
        type: _selectedSpaceType,
        enabledModules: _selectedModules.toList(),
      );

      // Send invites if a space was created and an email was entered
      if (success && _inviteEmailController.text.trim().isNotEmpty) {
        await spaceNotifier.inviteMember(_inviteEmailController.text.trim());
      }
    } else if (_spaceAction == 'join') {
      final code = _joinCodeController.text.trim();
      if (code.isNotEmpty) {
        success = await spaceNotifier.joinSpace(code);
      }
    } else {
      // No action selected, just load existing spaces
      await spaceNotifier.loadSpaces();
    }

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      context.go('/');
    } else if (mounted) {
      final error = ref.read(spaceProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(context.l10n.translate('skip')),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _WelcomePage(theme: theme, userName: user?.displayName),
                  _CreateOrJoinPage(
                    theme: theme,
                    selectedAction: _spaceAction,
                    onActionChanged: (action) {
                      setState(() => _spaceAction = action);
                    },
                    joinCodeController: _joinCodeController,
                    spaceNameController: _spaceNameController,
                  ),
                  _SpaceTypePage(
                    theme: theme,
                    selectedType: _selectedSpaceType,
                    onTypeChanged: (type) {
                      setState(() => _selectedSpaceType = type);
                    },
                  ),
                  _InvitePage(
                    theme: theme,
                    emailController: _inviteEmailController,
                  ),
                  _TourPage(theme: theme),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text(context.l10n.translate('back')),
                    ),
                  const Spacer(),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == 4
                            ? context.l10n.translate('getStarted')
                            : context.l10n.translate('next'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.theme, this.userName});
  final ThemeData theme;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_alt_rounded,
            size: 100,
            color: theme.colorScheme.primary,
            semanticLabel: 'Studio Pair logo',
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            userName != null
                ? '${context.l10n.translate('welcome').replaceAll('!', '')}, $userName!'
                : context.l10n.translate('welcome'),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.translate('letsSetUpYourSpace'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CreateOrJoinPage extends StatelessWidget {
  const _CreateOrJoinPage({
    required this.theme,
    required this.selectedAction,
    required this.onActionChanged,
    required this.joinCodeController,
    required this.spaceNameController,
  });
  final ThemeData theme;
  final String selectedAction;
  final ValueChanged<String> onActionChanged;
  final TextEditingController joinCodeController;
  final TextEditingController spaceNameController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Get started',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Would you like to create a new space or join an existing one?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => onActionChanged('create'),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(context.l10n.translate('createSpace')),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedAction == 'create'
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                foregroundColor: selectedAction == 'create'
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (selectedAction == 'create') ...[
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: spaceNameController,
              decoration: InputDecoration(
                labelText: context.l10n.translate('spaceName'),
                hintText: context.l10n.translate('exampleSpaceName'),
                prefixIcon: const Icon(Icons.groups_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => onActionChanged('join'),
              icon: const Icon(Icons.group_add_outlined),
              label: Text(context.l10n.translate('joinSpace')),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedAction == 'join'
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                foregroundColor: selectedAction == 'join'
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (selectedAction == 'join') ...[
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: joinCodeController,
              decoration: InputDecoration(
                labelText: context.l10n.translate('spaceId'),
                hintText: context.l10n.translate('enterSpaceId'),
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpaceTypePage extends StatelessWidget {
  const _SpaceTypePage({
    required this.theme,
    required this.selectedType,
    required this.onTypeChanged,
  });
  final ThemeData theme;
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  static const _spaceTypes = [
    _SpaceType('couple', Icons.favorite, 'personal', 'Perfect for two'),
    _SpaceType(
      'family',
      Icons.family_restroom,
      'family',
      'For the whole family',
    ),
    _SpaceType(
      'roommates',
      Icons.home,
      'livingSpace',
      'Share your living space',
    ),
    _SpaceType(
      'friendGroup',
      Icons.groups,
      'friendGroup',
      'For your friend circle',
    ),
    _SpaceType('custom', Icons.tune, 'workTeam', 'Define your own space'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.translate('selectSpaceType'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'What kind of group are you?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView.separated(
              itemCount: _spaceTypes.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final type = _spaceTypes[index];
                final isSelected = selectedType == type.id;
                return Card(
                  elevation: isSelected ? 2 : 0,
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.4,
                        ),
                  child: ListTile(
                    leading: Icon(
                      type.icon,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(context.l10n.translate(type.label)),
                    subtitle: Text(type.description),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () => onTypeChanged(type.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaceType {
  const _SpaceType(this.id, this.icon, this.label, this.description);
  final String id;
  final IconData icon;
  final String label;
  final String description;
}

class _InvitePage extends ConsumerWidget {
  const _InvitePage({required this.theme, required this.emailController});
  final ThemeData theme;
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSpace = ref.watch(spaceProvider).currentSpace;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invite your people',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Share an invite link or enter their email addresses.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Invite link card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invite link', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: Text(
                            currentSpace?.id != null
                                ? 'https://studiopair.app/join/${currentSpace!.id.substring(0, 8)}'
                                : 'Create a space first to generate an invite link',
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy invite link',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.translate('linkCopied'),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Email invitations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invite by email', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter email address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        tooltip: 'Send invite',
                        onPressed: () {
                          if (emailController.text.trim().isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Invite sent to ${emailController.text.trim()}',
                                ),
                              ),
                            );
                            emailController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              'You can always invite more people later',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TourPage extends StatelessWidget {
  const _TourPage({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rocket_launch,
            size: 80,
            color: theme.colorScheme.primary,
            semanticLabel: 'Setup complete',
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            "You're all set!",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Here are some things you can do:',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          _TourHighlight(
            theme: theme,
            icon: Icons.dashboard,
            title: context.l10n.translate('dashboard'),
            description: 'See everything at a glance',
          ),
          _TourHighlight(
            theme: theme,
            icon: Icons.add_circle,
            title: context.l10n.translate('quickActions'),
            description: 'Tap the + button to quickly add items',
          ),
          _TourHighlight(
            theme: theme,
            icon: Icons.cloud_off,
            title: context.l10n.translate('offlineMode'),
            description: 'Works without internet - syncs when connected',
          ),
          _TourHighlight(
            theme: theme,
            icon: Icons.lock,
            title: context.l10n.translate('privateVault'),
            description: 'End-to-end encrypted personal space',
          ),
        ],
      ),
    );
  }
}

class _TourHighlight extends StatelessWidget {
  const _TourHighlight({
    required this.theme,
    required this.icon,
    required this.title,
    required this.description,
  });

  final ThemeData theme;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
