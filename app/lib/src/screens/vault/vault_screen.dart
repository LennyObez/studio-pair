import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/providers/vault_provider.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';
import 'package:studio_pair/src/widgets/common/sp_search_bar.dart';

/// Vault screen for password/credential storage, grouped by domain.
class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    final spaceId = ref.read(spaceProvider).currentSpace?.id;
    if (spaceId != null) {
      ref.read(vaultProvider.notifier).loadEntries(spaceId);
    }
  }

  /// Group entries by domain first letter category.
  Map<String, List<VaultEntry>> _groupEntries(List<VaultEntry> entries) {
    final grouped = <String, List<VaultEntry>>{};
    for (final entry in entries) {
      final firstChar = entry.domain.isNotEmpty
          ? entry.domain[0].toUpperCase()
          : '#';
      grouped.putIfAbsent(firstChar, () => <VaultEntry>[]);
      grouped[firstChar]!.add(entry);
    }
    // Sort keys alphabetically
    final sortedKeys = grouped.keys.toList()..sort();
    final result = <String, List<VaultEntry>>{};
    for (final key in sortedKeys) {
      result[key] = grouped[key]!;
    }
    return result;
  }

  Future<void> _showAddEntryDialog() async {
    final titleController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final websiteController = TextEditingController();
    final notesController = TextEditingController();
    var obscurePassword = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(context.l10n.translate('newVaultEntry')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: '${context.l10n.translate('websiteApp')} *',
                        hintText: 'e.g. Netflix Account',
                        prefixIcon: const Icon(Icons.label_outlined),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: context.l10n.translate('username'),
                        hintText: context.l10n.translate('yourUsername'),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: '${context.l10n.translate('password')} *',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 20,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              tooltip: obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                            ),
                            IconButton(
                              icon: const Icon(Icons.casino, size: 20),
                              onPressed: () {
                                final generated = _generateRandomPassword();
                                passwordController.text = generated;
                              },
                              tooltip: 'Generate random password',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Website URL',
                        hintText: 'e.g. netflix.com',
                        prefixIcon: Icon(Icons.language),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Optional notes...',
                        prefixIcon: Icon(Icons.notes),
                      ),

                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(context.l10n.translate('cancel')),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(context.l10n.translate('save')),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      final title = titleController.text.trim();
      final password = passwordController.text.trim();
      final username = usernameController.text.trim();
      final website = websiteController.text.trim();

      if (title.isEmpty || password.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.translate('titleAndPasswordRequired')),
          ),
        );
        titleController.dispose();
        usernameController.dispose();
        passwordController.dispose();
        websiteController.dispose();
        notesController.dispose();
        return;
      }

      final spaceId = ref.read(spaceProvider).currentSpace?.id;
      if (spaceId == null) {
        titleController.dispose();
        usernameController.dispose();
        passwordController.dispose();
        websiteController.dispose();
        notesController.dispose();
        return;
      }

      final domain = website.isNotEmpty ? website : title;

      final success = await ref
          .read(vaultProvider.notifier)
          .createEntry(
            spaceId,
            domain: domain,
            label: title,
            username: username.isNotEmpty ? username : null,
            password: password,
          );

      if (!mounted) {
        titleController.dispose();
        usernameController.dispose();
        passwordController.dispose();
        websiteController.dispose();
        notesController.dispose();
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.translate('vaultEntryAdded'))),
        );
      } else {
        final error = ref.read(vaultProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to add vault entry')),
        );
      }
    }

    titleController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    websiteController.dispose();
    notesController.dispose();
  }

  /// Generate a random password with uppercase, lowercase, digits, and symbols.
  String _generateRandomPassword({int length = 20}) {
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const digits = '0123456789';
    const symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';
    const allChars = uppercase + lowercase + digits + symbols;

    final random = Random.secure();

    // Ensure at least one character from each category
    final mandatory = [
      uppercase[random.nextInt(uppercase.length)],
      lowercase[random.nextInt(lowercase.length)],
      digits[random.nextInt(digits.length)],
      symbols[random.nextInt(symbols.length)],
    ];

    final remaining = List.generate(
      length - mandatory.length,
      (_) => allChars[random.nextInt(allChars.length)],
    );

    final chars = [...mandatory, ...remaining]..shuffle(random);
    return chars.join();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vaultProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('vault'),
        showBackButton: true,
        actions: const [
          Icon(
            Icons.lock,
            size: 20,
            color: AppColors.moduleVault,
            semanticLabel: 'Vault encrypted',
          ),
          SizedBox(width: AppSpacing.md),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SpSearchBar(
              hintText: 'Search vault entries...',
              onChanged: (query) {
                ref.read(vaultProvider.notifier).setSearchQuery(query);
              },
            ),
          ),
          Expanded(child: _buildBody(state, theme)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        tooltip: 'Add vault entry',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(VaultState state, ThemeData theme) {
    if (state.isLoading && state.entries.isEmpty) {
      return const Center(child: SpLoading());
    }

    if (state.error != null) {
      return SpErrorWidget(message: state.error!, onRetry: _loadEntries);
    }

    final filteredEntries = ref.watch(vaultEntriesProvider);

    if (filteredEntries.isEmpty) {
      if (state.searchQuery.isNotEmpty) {
        return SpEmptyState(
          icon: Icons.search_off,
          title: context.l10n.translate('noResults'),
          description: 'Try a different search term',
        );
      }
      return SpEmptyState(
        icon: Icons.lock_outlined,
        title: context.l10n.translate('noPasswords'),
        description: context.l10n.translate('addPasswordsDescription'),
      );
    }

    final grouped = _groupEntries(filteredEntries);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final groupKey = grouped.keys.elementAt(index);
        final entries = grouped[groupKey]!;
        return _VaultGroupCard(
          groupKey: groupKey,
          entries: entries,
          theme: theme,
        );
      },
    );
  }
}

class _VaultGroupCard extends ConsumerStatefulWidget {
  const _VaultGroupCard({
    required this.groupKey,
    required this.entries,
    required this.theme,
  });

  final String groupKey;
  final List<VaultEntry> entries;
  final ThemeData theme;

  @override
  ConsumerState<_VaultGroupCard> createState() => _VaultGroupCardState();
}

class _VaultGroupCardState extends ConsumerState<_VaultGroupCard> {
  /// Tracks which entry IDs have their password revealed.
  final Set<String> _revealedPasswords = {};

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _togglePasswordVisibility(String entryId) {
    setState(() {
      if (_revealedPasswords.contains(entryId)) {
        _revealedPasswords.remove(entryId);
      } else {
        _revealedPasswords.add(entryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.moduleVault.withValues(alpha: 0.12),
              child: Text(
                widget.groupKey,
                style: const TextStyle(
                  color: AppColors.moduleVault,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            title: Text(
              widget.groupKey,
              style: widget.theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Text(
              '${widget.entries.length} accounts',
              style: widget.theme.textTheme.labelSmall?.copyWith(
                color: widget.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Divider(height: 1),
          ...widget.entries.map((entry) {
            final isRevealed = _revealedPasswords.contains(entry.id);
            return ListTile(
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.grey200,
                child: Text(
                  entry.label.isNotEmpty ? entry.label[0] : '?',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.label,
                      style: widget.theme.textTheme.bodyMedium,
                    ),
                  ),
                  if (entry.isShared)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.people,
                        size: 16,
                        color: widget.theme.colorScheme.onSurfaceVariant,
                        semanticLabel: 'Shared entry',
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.username ?? entry.domain,
                    style: widget.theme.textTheme.labelSmall,
                  ),
                  if (isRevealed)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '(password visible in entry)',
                        style: widget.theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.moduleVault,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (entry.username != null && entry.username!.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.alternate_email, size: 18),
                      onPressed: () =>
                          _copyToClipboard(entry.username!, 'Username'),
                      tooltip: 'Copy username',
                    ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () async {
                      final spaceId = ref.read(spaceProvider).currentSpace?.id;
                      if (spaceId == null) return;
                      try {
                        final response = await ref
                            .read(vaultProvider.notifier)
                            .fetchEntryPassword(spaceId, entry.id);
                        if (response != null && context.mounted) {
                          _copyToClipboard(response, 'Password');
                        }
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.translate('failedToFetchPassword'),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    tooltip: 'Copy password',
                  ),
                  IconButton(
                    icon: Icon(
                      isRevealed ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                    ),
                    onPressed: () => _togglePasswordVisibility(entry.id),
                    tooltip: isRevealed ? 'Hide password' : 'Show password',
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
