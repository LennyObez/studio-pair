import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/auth_provider.dart';
import 'package:studio_pair/src/providers/messaging_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Messaging screen with Chat and Mail tabs.
class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spaceId = ref.watch(currentSpaceProvider)?.id;

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            tooltip: context.l10n.translate('newConversation'),
            onPressed: () => _showCreateConversationDialog(context, spaceId),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.translate('chat')),
            Tab(text: context.l10n.translate('mail')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ChatList(spaceId: spaceId),
          _MailList(spaceId: spaceId),
        ],
      ),
    );
  }

  void _showCreateConversationDialog(BuildContext context, String? spaceId) {
    if (spaceId == null) return;
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.translate('newConversation')),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.l10n.translate('conversationName'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.translate('cancel')),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final members = ref.read(spaceMembersProvider);
                final currentUserId = ref.read(currentUserProvider)?.id;
                final participantIds = members
                    .map((m) => m.userId)
                    .where((id) => id != currentUserId)
                    .toList();
                if (currentUserId != null) {
                  participantIds.insert(0, currentUserId);
                }
                ref
                    .read(conversationsProvider.notifier)
                    .createConversation(
                      spaceId,
                      title: title,
                      type: 'chat',
                      participantIds: participantIds,
                    );
                Navigator.of(ctx).pop();
              }
            },
            child: Text(context.l10n.translate('create')),
          ),
        ],
      ),
    );
  }
}

class _ChatList extends ConsumerWidget {
  const _ChatList({required this.spaceId});

  final String? spaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncConversations = ref.watch(conversationsProvider);
    final conversations = ref.watch(conversationListProvider);

    // Filter to chat-type conversations
    final chatConversations = conversations
        .where((c) => c.type == 'chat')
        .toList();

    if (asyncConversations.isLoading && conversations.isEmpty) {
      return const Center(child: SpLoading());
    }

    if (asyncConversations.hasError && conversations.isEmpty) {
      return SpErrorWidget(
        message: asyncConversations.error is AppFailure
            ? (asyncConversations.error as AppFailure).message
            : '${asyncConversations.error}',
        onRetry: () {
          ref.invalidate(conversationsProvider);
        },
      );
    }

    if (chatConversations.isEmpty) {
      return SpEmptyState(
        icon: Icons.chat_outlined,
        title: context.l10n.translate('noConversationsYet'),
        description: context.l10n.translate('startConversationDescription'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: chatConversations.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final convo = chatConversations[index];
        final title = convo.title ?? '';
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          leading: CircleAvatar(
            radius: 24,
            child: Text(title.isNotEmpty ? title[0].toUpperCase() : '?'),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (convo.lastMessageAt != null)
                Text(
                  _timeAgo(convo.lastMessageAt!),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  convo.lastMessagePreview ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            ref.read(currentConversationIdProvider.notifier).state = convo.id;
            context.go('/messages/${convo.id}');
          },
        );
      },
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}

class _MailList extends ConsumerWidget {
  const _MailList({required this.spaceId});

  final String? spaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncConversations = ref.watch(conversationsProvider);
    final conversations = ref.watch(conversationListProvider);

    // Filter to mail-type conversations
    final mailConversations = conversations
        .where((c) => c.type == 'mail')
        .toList();

    if (asyncConversations.isLoading && conversations.isEmpty) {
      return const Center(child: SpLoading());
    }

    if (asyncConversations.hasError && conversations.isEmpty) {
      return SpErrorWidget(
        message: asyncConversations.error is AppFailure
            ? (asyncConversations.error as AppFailure).message
            : '${asyncConversations.error}',
        onRetry: () {
          ref.invalidate(conversationsProvider);
        },
      );
    }

    if (mailConversations.isEmpty) {
      return SpEmptyState(
        icon: Icons.mail_outline,
        title: context.l10n.translate('noMailYet'),
        description: context.l10n.translate('sendLettersDescription'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: mailConversations.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final convo = mailConversations[index];
        final title = convo.title ?? '';
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          leading: CircleAvatar(
            radius: 24,
            child: Text(title.isNotEmpty ? title[0].toUpperCase() : '?'),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            convo.lastMessagePreview ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          onTap: () {
            ref.read(currentConversationIdProvider.notifier).state = convo.id;
            context.go('/messages/${convo.id}');
          },
        );
      },
    );
  }
}
