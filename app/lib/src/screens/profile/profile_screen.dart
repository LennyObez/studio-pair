import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/auth_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';

/// Profile screen with avatar, display name, email, and account settings.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;
  bool _controllersInitialized = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initControllers(AppUser? user) {
    if (!_controllersInitialized && user != null) {
      _displayNameController.text = user.displayName;
      _emailController.text = user.email;
      _controllersInitialized = true;
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.translate('changePassword')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
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
            onPressed: () async {
              if (newController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.translate('passwordsDoNotMatch'),
                    ),
                  ),
                );
                return;
              }
              if (newController.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.translate('passwordMinLength')),
                  ),
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
                          ? 'Password changed'
                          : 'Failed to change password',
                    ),
                  ),
                );
              }
            },
            child: Text(context.l10n.translate('change')),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    final trimmedName = _displayNameController.text.trim();
    if (trimmedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.translate('displayNameRequired'))),
      );
      return;
    }

    ref.read(authProvider.notifier).updateProfile(displayName: trimmedName);

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.translate('profileUpdated'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final currentSpace = ref.watch(currentSpaceProvider);
    final members = ref.watch(spaceMembersProvider);

    // Initialize controllers with user data on first build
    _initControllers(currentUser);

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('profile'),
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: () {
              if (_isEditing) {
                _handleSave();
              } else {
                setState(() => _isEditing = true);
              }
            },
            child: Text(
              _isEditing
                  ? context.l10n.translate('save')
                  : context.l10n.translate('edit'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Avatar
            const SizedBox(height: AppSpacing.md),
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: currentUser?.avatarUrl != null
                      ? NetworkImage(currentUser!.avatarUrl!)
                      : null,
                  child: currentUser?.avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 48,
                          color: theme.colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Semantics(
                      button: true,
                      label: context.l10n.translate('changeAvatar'),
                      child: GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 512,
                            maxHeight: 512,
                          );
                          if (pickedFile != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.l10n.translate('uploadingAvatar'),
                                ),
                              ),
                            );
                            // Upload via auth provider which calls the API
                            await ref
                                .read(authProvider.notifier)
                                .updateProfile(avatarUrl: pickedFile.path);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.l10n.translate('avatarUpdated'),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primary,
                          child: Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Display name
            TextFormField(
              controller: _displayNameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: context.l10n.translate('editDisplayName'),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Email
            TextFormField(
              controller: _emailController,
              enabled: false, // Email can't be changed directly
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Space membership
            if (currentSpace != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.l10n.translate('spaces'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.group,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(currentSpace.name),
                      subtitle: Text(
                        'Type: ${currentSpace.type} - ${currentSpace.memberCount} members',
                      ),
                    ),
                    if (members.isNotEmpty) ...[
                      const Divider(height: 1),
                      ...members.map(
                        (member) => ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundImage: member.avatarUrl != null
                                ? NetworkImage(member.avatarUrl!)
                                : null,
                            child: member.avatarUrl == null
                                ? Text(
                                    member.displayName.isNotEmpty
                                        ? member.displayName[0].toUpperCase()
                                        : '?',
                                  )
                                : null,
                          ),
                          title: Text(member.displayName),
                          trailing: Chip(
                            label: Text(
                              member.role,
                              style: theme.textTheme.labelSmall,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Security section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.l10n.translate('settings'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(context.l10n.translate('changePassword')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: Text(context.l10n.translate('twoFactor')),
                    subtitle: Text(context.l10n.translate('notEnabled')),
                    trailing: Switch(
                      value: false,
                      onChanged: (enabled) {
                        if (enabled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '2FA setup: scan the QR code in your authenticator app',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Active sessions
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Active sessions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: ListTile(
                leading: Icon(
                  Platform.isIOS ? Icons.phone_iphone : Icons.phone_android,
                  color: AppColors.success,
                ),
                title: Text(
                  '${Platform.isIOS ? 'iPhone' : 'Android'} - ${Platform.operatingSystemVersion}',
                ),
                subtitle: Text(context.l10n.translate('lastActiveNow')),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                  ),
                  child: Text(
                    'Current',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
