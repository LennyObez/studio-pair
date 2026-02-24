import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';

/// Custom app bar widget with optional space selector.
class SpAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SpAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = false,
    this.showLogo = false,
    this.showSpaceSelector = false,
    this.actions,
    this.bottom,
    this.elevation,
    this.backgroundColor,
  });

  final String? title;
  final Widget? titleWidget;
  final bool showBackButton;
  final bool showLogo;
  final bool showSpaceSelector;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final Color? backgroundColor;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      elevation: elevation,
      backgroundColor: backgroundColor,
      bottom: bottom,
      title: _buildTitle(context),
      actions: [
        if (showSpaceSelector) ...[
          _SpaceSelector(),
          const SizedBox(width: AppSpacing.sm),
        ],
        ...?actions,
      ],
    );
  }

  Widget? _buildTitle(BuildContext context) {
    if (titleWidget != null) return titleWidget;
    if (showLogo) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_alt_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title ?? context.l10n.translate('appName'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      );
    }
    if (title != null) return Text(title!);
    return null;
  }
}

/// Space selector dropdown for switching between spaces.
class _SpaceSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaceData = ref.watch(spaceProvider).valueOrNull;
    final currentSpace = spaceData?.currentSpace;
    return PopupMenuButton<String>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.group,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 20),
        ],
      ),
      onSelected: (value) {
        if (value == 'create') {
          _showCreateSpaceDialog(context, ref);
        } else if (value == 'join') {
          _showJoinSpaceDialog(context, ref);
        } else {
          // Switch to a specific space
          ref.read(spaceProvider.notifier).switchSpace(value);
        }
      },
      itemBuilder: (context) => [
        // List existing spaces
        ...(spaceData?.spaces ?? []).map(
          (space) => PopupMenuItem(
            value: space.id,
            child: Row(
              children: [
                Icon(
                  space.id == currentSpace?.id
                      ? Icons.check
                      : Icons.circle_outlined,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(space.name)),
              ],
            ),
          ),
        ),
        if (spaceData == null || spaceData.spaces.isEmpty)
          PopupMenuItem(
            enabled: false,
            value: '_none',
            child: Text(
              context.l10n.translate('noSpacesYet'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'create',
          child: Row(
            children: [
              const Icon(Icons.add, size: 18),
              const SizedBox(width: 8),
              Text(context.l10n.translate('createASpace')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'join',
          child: Row(
            children: [
              const Icon(Icons.group_add, size: 18),
              const SizedBox(width: 8),
              Text(context.l10n.translate('joinASpace')),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateSpaceDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    var selectedType = 'couple';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.translate('createASpace')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: context.l10n.translate('spaceName'),
                    hintText: context.l10n.translate('exampleSpaceName'),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    labelText: context.l10n.translate('spaceType'),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'couple',
                      child: Text(context.l10n.translate('couple')),
                    ),
                    DropdownMenuItem(
                      value: 'family',
                      child: Text(context.l10n.translate('family')),
                    ),
                    DropdownMenuItem(
                      value: 'roommates',
                      child: Text(context.l10n.translate('roommates')),
                    ),
                    DropdownMenuItem(
                      value: 'team',
                      child: Text(context.l10n.translate('team')),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => selectedType = value!);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: context.l10n.translate('descriptionOptional'),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.translate('cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final success = await ref
                    .read(spaceProvider.notifier)
                    .createSpace(
                      name: name,
                      type: selectedType,
                      description: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Space "$name" created')),
                    );
                  }
                }
              },
              child: Text(context.l10n.translate('create')),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinSpaceDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.translate('joinASpace')),
        content: TextField(
          controller: codeController,
          decoration: InputDecoration(
            labelText: context.l10n.translate('inviteCode'),
            hintText: context.l10n.translate('enterInviteCode'),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.translate('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.isEmpty) return;

              final success = await ref
                  .read(spaceProvider.notifier)
                  .joinSpace(code);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? context.l10n.translate('joinedSpaceSuccessfully')
                          : context.l10n.translate('invalidInviteCode'),
                    ),
                  ),
                );
              }
            },
            child: Text(context.l10n.translate('join')),
          ),
        ],
      ),
    );
  }
}
