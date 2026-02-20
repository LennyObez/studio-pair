import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';

// ── Selection state ─────────────────────────────────────────────────────

/// Currently selected grocery list ID.
final currentGroceryListIdProvider = StateProvider<String?>((ref) => null);

// ── Grocery lists notifier ──────────────────────────────────────────────

/// Grocery lists notifier backed by the [GroceryRepository].
class GroceryListsNotifier
    extends AutoDisposeAsyncNotifier<List<CachedGroceryList>> {
  @override
  Future<List<CachedGroceryList>> build() async {
    final repo = ref.watch(groceryRepositoryProvider);
    final spaceId = ref.watch(currentSpaceProvider)?.id;
    if (spaceId == null) return [];
    return repo.getLists(spaceId);
  }

  /// Create a new grocery list and refresh.
  Future<bool> createList(String spaceId, String name) async {
    final repo = ref.read(groceryRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.createList(spaceId, name);
      return repo.getLists(spaceId);
    });
    return !state.hasError;
  }

  /// Delete a grocery list and refresh.
  Future<bool> deleteList(String spaceId, String listId) async {
    final repo = ref.read(groceryRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteList(spaceId, listId);
      return repo.getLists(spaceId);
    });
    return !state.hasError;
  }

  /// Update a grocery list name and refresh.
  Future<bool> updateList(String spaceId, String listId, String name) async {
    final repo = ref.read(groceryRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.updateList(spaceId, listId, name);
      return repo.getLists(spaceId);
    });
    return !state.hasError;
  }
}

/// Grocery lists async provider.
final groceryListsProvider =
    AsyncNotifierProvider.autoDispose<
      GroceryListsNotifier,
      List<CachedGroceryList>
    >(GroceryListsNotifier.new);

// ── Grocery items notifier ──────────────────────────────────────────────

/// Grocery items notifier for items within a specific list.
///
/// Re-builds when [currentGroceryListIdProvider] changes.
class GroceryItemsNotifier
    extends AutoDisposeAsyncNotifier<List<CachedGroceryItem>> {
  @override
  Future<List<CachedGroceryItem>> build() async {
    // This provider currently returns an empty list because the repository
    // does not expose a `getItems(listId)` that returns `CachedGroceryItem`.
    // Items are fetched via the grocery list detail endpoint on-demand.
    return [];
  }

  /// Add an item to a grocery list.
  Future<bool> addItem(
    String spaceId,
    String listId, {
    required String name,
    double? quantity,
    String? unit,
    String? category,
    String? note,
  }) async {
    final repo = ref.read(groceryRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.addItem(
        spaceId,
        listId,
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        note: note,
      );
      // Repository doesn't expose cached items per list, return empty.
      return <CachedGroceryItem>[];
    });
    return !state.hasError;
  }

  /// Check off a grocery item.
  Future<bool> checkItem(String spaceId, String itemId) async {
    final repo = ref.read(groceryRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.checkItem(spaceId, itemId);
      return state.valueOrNull ?? [];
    });
    return !state.hasError;
  }

  /// Uncheck a grocery item.
  Future<bool> uncheckItem(String spaceId, String itemId) async {
    final repo = ref.read(groceryRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.uncheckItem(spaceId, itemId);
      return state.valueOrNull ?? [];
    });
    return !state.hasError;
  }

  /// Delete a grocery item.
  Future<bool> deleteItem(String spaceId, String itemId) async {
    final repo = ref.read(groceryRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteItem(spaceId, itemId);
      return state.valueOrNull ?? [];
    });
    return !state.hasError;
  }

  /// Clear all checked items from a list.
  Future<bool> clearChecked(String spaceId, String listId) async {
    final repo = ref.read(groceryRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.clearChecked(spaceId, listId);
      return <CachedGroceryItem>[];
    });
    return !state.hasError;
  }
}

/// Grocery items async provider.
final groceryItemsProvider =
    AsyncNotifierProvider.autoDispose<
      GroceryItemsNotifier,
      List<CachedGroceryItem>
    >(GroceryItemsNotifier.new);

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for the grocery list collection.
final groceryProvider = Provider<List<CachedGroceryList>>((ref) {
  return ref.watch(groceryListsProvider).valueOrNull ?? [];
});
