import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/grocery_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Grocery list screen with checkable items and category grouping.
class GroceryScreen extends ConsumerStatefulWidget {
  const GroceryScreen({super.key});

  @override
  ConsumerState<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends ConsumerState<GroceryScreen> {
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _addItem(String spaceId) {
    final name = _addController.text.trim();
    if (name.isEmpty) return;

    final currentListId = ref.read(currentGroceryListIdProvider);
    if (currentListId == null) return;

    ref
        .read(groceryItemsProvider.notifier)
        .addItem(spaceId, currentListId, name: name);
    _addController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncLists = ref.watch(groceryListsProvider);
    final asyncItems = ref.watch(groceryItemsProvider);
    final lists = asyncLists.valueOrNull ?? [];
    final items = asyncItems.valueOrNull ?? [];
    final currentListId = ref.watch(currentGroceryListIdProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('groceryList'),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              if (spaceId != null && currentListId != null) {
                ref
                    .read(groceryItemsProvider.notifier)
                    .clearChecked(spaceId, currentListId);
              }
            },
            tooltip: 'Clear completed',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share list',
            onPressed: () {
              final unchecked = items.where((i) => !i.isChecked).toList();
              if (unchecked.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.translate('noItemsToShare')),
                  ),
                );
                return;
              }
              final text = unchecked
                  .map((i) {
                    final qty = i.quantity != null ? ' x${i.quantity}' : '';
                    return '- ${i.name}$qty';
                  })
                  .join('\n');
              Share.share('Grocery List:\n$text');
            },
          ),
        ],
      ),
      body: _buildBody(
        theme,
        asyncLists,
        lists,
        items,
        currentListId,
        spaceId,
        asyncItems.isLoading,
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    AsyncValue<List<CachedGroceryList>> asyncLists,
    List<CachedGroceryList> lists,
    List<CachedGroceryItem> items,
    String? currentListId,
    String? spaceId,
    bool itemsLoading,
  ) {
    if (asyncLists.isLoading && lists.isEmpty && items.isEmpty) {
      return const Center(child: SpLoading());
    }

    if (asyncLists.hasError && lists.isEmpty) {
      return SpErrorWidget(
        message: asyncLists.error is AppFailure
            ? (asyncLists.error as AppFailure).message
            : '${asyncLists.error}',
        onRetry: () {
          ref.invalidate(groceryListsProvider);
        },
      );
    }

    return Column(
      children: [
        // List selector
        if (lists.isNotEmpty)
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final list = lists[index];
                final isSelected = currentListId == list.id;
                return FilterChip(
                  selected: isSelected,
                  label: Text(list.name),
                  onSelected: (_) {
                    ref.read(currentGroceryListIdProvider.notifier).state =
                        list.id;
                  },
                );
              },
            ),
          ),
        const SizedBox(height: AppSpacing.sm),

        // Quick add input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: TextField(
            controller: _addController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (spaceId != null) _addItem(spaceId);
            },
            decoration: InputDecoration(
              hintText: 'Add item...',
              prefixIcon: const Icon(Icons.add),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                tooltip: 'Add item',
                onPressed: () {
                  if (spaceId != null) _addItem(spaceId);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Items list
        Expanded(
          child: _buildItemsList(
            theme,
            items,
            currentListId,
            spaceId,
            itemsLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(
    ThemeData theme,
    List<CachedGroceryItem> items,
    String? currentListId,
    String? spaceId,
    bool isLoading,
  ) {
    if (currentListId == null) {
      return SpEmptyState(
        icon: Icons.list_alt,
        title: context.l10n.translate('selectAList'),
        description: 'Choose a grocery list from above to view items',
      );
    }

    if (isLoading && items.isEmpty) {
      return const Center(child: SpLoading());
    }

    if (items.isEmpty) {
      return SpEmptyState(
        icon: Icons.shopping_cart_outlined,
        title: context.l10n.translate('noItems'),
        description: context.l10n.translate('addItemsDescription'),
      );
    }

    // Group items by category
    final grouped = <String, List<CachedGroceryItem>>{};
    for (final item in items) {
      final category = item.category ?? 'Other';
      grouped.putIfAbsent(category, () => []).add(item);
    }

    final categories = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryItems = grouped[category]!;
        final uncheckedCount = categoryItems.where((e) => !e.isChecked).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Text(
                    category,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.moduleGrocery,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.moduleGrocery.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusRound,
                      ),
                    ),
                    child: Text(
                      '$uncheckedCount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.moduleGrocery,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...categoryItems.map(
              (item) => Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  color: AppColors.error,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  if (spaceId != null) {
                    ref
                        .read(groceryItemsProvider.notifier)
                        .deleteItem(spaceId, item.id);
                  }
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    dense: true,
                    leading: Checkbox(
                      value: item.isChecked,
                      onChanged: (_) {
                        if (spaceId == null) return;
                        if (item.isChecked) {
                          ref
                              .read(groceryItemsProvider.notifier)
                              .uncheckItem(spaceId, item.id);
                        } else {
                          ref
                              .read(groceryItemsProvider.notifier)
                              .checkItem(spaceId, item.id);
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        decoration: item.isChecked
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.isChecked
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    subtitle: item.quantity != null
                        ? Text(
                            '${item.quantity}${item.unit != null ? ' ${item.unit}' : ''}',
                            style: theme.textTheme.labelSmall,
                          )
                        : null,
                    trailing: item.checkedBy != null
                        ? Text(
                            item.checkedBy!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        );
      },
    );
  }
}
