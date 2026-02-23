import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/auth_provider.dart';
import 'package:studio_pair/src/providers/locale_provider.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/sync_provider.dart';
import 'package:studio_pair/src/providers/theme_provider.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Notification preference state providers.
final _pushNotificationsEnabledProvider = StateProvider<bool>((_) => true);
final _emailNotificationsEnabledProvider = StateProvider<bool>((_) => false);
final _quietHoursEnabledProvider = StateProvider<bool>((_) => false);

/// Settings screen with grouped settings options.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final syncState = ref.watch(syncProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: SpAppBar(title: l10n.translate('settings'), showBackButton: true),
      body: ListView(
        children: [
          // Profile section
          Card(
            margin: const EdgeInsets.all(AppSpacing.md),
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              leading: CircleAvatar(
                radius: 28,
                backgroundImage: currentUser?.avatarUrl != null
                    ? NetworkImage(currentUser!.avatarUrl!)
                    : null,
                child: currentUser?.avatarUrl == null
                    ? const Icon(Icons.person, size: 32)
                    : null,
              ),
              title: Text(
                currentUser?.displayName ?? l10n.translate('guest'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(currentUser?.email ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/profile'),
            ),
          ),

          // Subscription
          _SettingsGroup(
            title: l10n.translate('subscription'),
            theme: theme,
            children: [
              _SettingsTile(
                icon: Icons.workspace_premium,
                title: l10n.translate('subscription'),
                subtitle: ref.watch(purchaseProvider).isPremium
                    ? l10n.translate('premium')
                    : l10n.translate('freePlan'),
                onTap: () => context.go('/settings/premium'),
              ),
            ],
          ),

          // Appearance settings
          _SettingsGroup(
            title: l10n.translate('appearance'),
            theme: theme,
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: l10n.translate('theme'),
                subtitle: _themeModeLabel(themeMode, context),
                onTap: () {},
                trailing: DropdownButton<ThemeMode>(
                  value: themeMode,
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(l10n.translate('light')),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(l10n.translate('dark')),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(l10n.translate('system')),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(themeModeProvider.notifier).setThemeMode(mode);
                    }
                  },
                ),
              ),
            ],
          ),

          // Language settings
          _SettingsGroup(
            title: l10n.translate('language'),
            theme: theme,
            children: [
              _SettingsTile(
                icon: Icons.language,
                title: l10n.translate('language'),
                subtitle: _localeLabel(locale),
                onTap: () {},
                trailing: DropdownButton<String>(
                  value: locale.languageCode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'fr', child: Text('Fran\u00E7ais')),
                    DropdownMenuItem(value: 'nl', child: Text('Nederlands')),
                    DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                  ],
                  onChanged: (code) {
                    if (code != null) {
                      ref.read(localeProvider.notifier).setLanguageCode(code);
                    }
                  },
                ),
              ),
            ],
          ),

          // Notifications settings
          _SettingsGroup(
            title: l10n.translate('notifications'),
            theme: theme,
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: l10n.translate('pushNotifications'),
                subtitle: l10n.translate('receivePushNotifications'),
                onTap: () {},
                trailing: Switch(
                  value: ref.watch(_pushNotificationsEnabledProvider),
                  onChanged: (enabled) {
                    ref.read(_pushNotificationsEnabledProvider.notifier).state =
                        enabled;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          enabled
                              ? l10n.translate('pushNotificationsEnabled')
                              : l10n.translate('pushNotificationsDisabled'),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.email_outlined,
                title: l10n.translate('emailNotifications'),
                subtitle: l10n.translate('receiveEmailUpdates'),
                onTap: () {},
                trailing: Switch(
                  value: ref.watch(_emailNotificationsEnabledProvider),
                  onChanged: (enabled) {
                    ref
                            .read(_emailNotificationsEnabledProvider.notifier)
                            .state =
                        enabled;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          enabled
                              ? l10n.translate('emailNotificationsEnabled')
                              : l10n.translate('emailNotificationsDisabled'),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.do_not_disturb_on_outlined,
                title: l10n.translate('quietHours'),
                subtitle: l10n.translate('muteNotifications'),
                onTap: () {},
                trailing: Switch(
                  value: ref.watch(_quietHoursEnabledProvider),
                  onChanged: (enabled) {
                    ref.read(_quietHoursEnabledProvider.notifier).state =
                        enabled;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          enabled
                              ? l10n.translate('quietHoursEnabled')
                              : l10n.translate('quietHoursDisabled'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Storage settings
          _SettingsGroup(
            title: l10n.translate('storage'),
            theme: theme,
            children: [
              _SettingsTile(
                icon: Icons.storage_outlined,
                title: l10n.translate('storageUsage'),
                subtitle: ref.watch(purchaseProvider).isPremium
                    ? 'Premium: 1 GB available'
                    : 'Free plan: 10 MB available',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.translate('storageUsage')),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: 0.024,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            ref.read(purchaseProvider).isPremium
                                ? '24 MB of 1 GB used'
                                : '2.4 MB of 10 MB used',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text('Files: 18 MB'),
                          const Text('Photos: 4 MB'),
                          const Text('Messages: 2 MB'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(l10n.translate('close')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          // Data settings
          _SettingsGroup(
            title: l10n.translate('data'),
            theme: theme,
            children: [
              _SettingsTile(
                icon: Icons.download_outlined,
                title: l10n.translate('dataExport'),
                subtitle: l10n.translate('downloadYourData'),
                onTap: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.translate('preparingDataExport')),
                    ),
                  );
                  try {
                    final apiClient = ref.read(apiClientProvider);
                    await apiClient.dio.get('/export/my-data');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.l10n.translate('dataExportReady'),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.translate('exportFailed')),
                        ),
                      );
                    }
                  }
                },
              ),
              _SettingsTile(
                icon: Icons.sync,
                title: l10n.translate('sync'),
                subtitle: syncState.statusText,
                onTap: () {
                  ref.read(syncProvider.notifier).forceSync();
                },
              ),
            ],
          ),

          // Account settings
          _SettingsGroup(
            title: l10n.translate('account'),
            theme: theme,
            children: [
              _SettingsTile(
                icon: Icons.lock_outline,
                title: l10n.translate('changePassword'),
                subtitle: l10n.translate('updateYourPassword'),
                onTap: () => _showChangePasswordDialog(context, ref),
              ),
              _SettingsTile(
                icon: Icons.security,
                title: l10n.translate('twoFactor'),
                subtitle: l10n.translate('notEnabled'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.translate('twoFactorSetupInProfile')),
                    ),
                  );
                  context.go('/profile');
                },
              ),
              _SettingsTile(
                icon: Icons.devices,
                title: l10n.translate('deviceManagement'),
                subtitle: l10n.translate('manageActiveSessions'),
                onTap: () {
                  context.go('/profile');
                },
              ),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: l10n.translate('deleteAccount'),
                subtitle: l10n.translate('permanentlyDeleteAccount'),
                iconColor: AppColors.error,
                titleColor: AppColors.error,
                onTap: () => _showDeleteAccountDialog(context, ref),
              ),
            ],
          ),

          // About
          _SettingsGroup(
            title: l10n.translate('about'),
            theme: theme,
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: l10n.translate('aboutStudioPair'),
                subtitle: 'Version 0.1.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Studio Pair',
                    applicationVersion: '0.1.0',
                    applicationIcon: Icon(
                      Icons.people_alt_rounded,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: l10n.translate('termsOfService'),
                onTap: () async {
                  final uri = Uri.parse('https://studiopair.app/terms');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: l10n.translate('privacyPolicy'),
                onTap: () async {
                  final uri = Uri.parse('https://studiopair.app/privacy');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              _SettingsTile(
                icon: Icons.article_outlined,
                title: l10n.translate('licenses'),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'Studio Pair',
                    applicationVersion: '0.1.0',
                  );
                },
              ),
            ],
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text(l10n.translate('logout')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translate('changePassword')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.translate('currentPassword'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.translate('newPassword'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.translate('confirmNewPassword'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.translate('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              if (newController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.translate('passwordsDoNotMatch')),
                  ),
                );
                return;
              }
              if (newController.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.translate('passwordMinLength'))),
                );
                return;
              }
              final success = await ref
                  .read(authProvider.notifier)
                  .changePassword(
                    currentPassword: currentController.text,
                    newPassword: newController.text,
                  );
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? context.l10n.translate(
                              'passwordChangedSuccessfully',
                            )
                          : context.l10n.translate('failedToChangePassword'),
                    ),
                  ),
                );
              }
            },
            child: Text(l10n.translate('change')),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translate('deleteAccountQuestion')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.translate('deleteAccountWarning')),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.translate('enterPasswordToConfirm'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.translate('cancel')),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.translate('passwordRequired'))),
                );
                return;
              }
              final success = await ref
                  .read(authProvider.notifier)
                  .deleteAccount(password: passwordController.text);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (success && context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              l10n.translate('delete'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode, BuildContext context) {
    final l10n = context.l10n;
    switch (mode) {
      case ThemeMode.light:
        return l10n.translate('light');
      case ThemeMode.dark:
        return l10n.translate('dark');
      case ThemeMode.system:
        return l10n.translate('systemDefault');
    }
  }

  String _localeLabel(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Fran\u00E7ais';
      case 'nl':
        return 'Nederlands';
      case 'de':
        return 'Deutsch';
      default:
        return locale.languageCode;
    }
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.title,
    required this.theme,
    required this.children,
  });

  final String title;
  final ThemeData theme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children:
                children
                    .expand((child) => [child, const Divider(height: 1)])
                    .toList()
                  ..removeLast(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(color: titleColor),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: theme.textTheme.labelSmall)
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
