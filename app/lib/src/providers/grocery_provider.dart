import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/grocery_api.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/grocery_dao.dart';

/// Grocery list model.
class GroceryList {
  const GroceryList({
    required this.id,
    required this.name,
    this.itemCount = 0,
    this.uncheckedCount = 0,
  });

  factory GroceryList.fromJson(Map<String, dynamic> json) {
    return GroceryList(
      id: json['id'] as String,
      name: json['name'] as String,
      itemCount: json['item_count'] as int? ?? 0,
      uncheckedCount: json['unchecked_count'] as int? ?? 0,
    );
  }

  final String id;
  final String name;
  final int itemCount;
  final int uncheckedCount;
}

/// Grocery item model.
class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    this.quantity,
    this.unit,
    this.category,
    this.note,
    required this.isChecked,
    this.checkedBy,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      category: json['category'] as String?,
      note: json['note'] as String?,
      isChecked: json['is_checked'] as bool? ?? false,
      checkedBy: json['checked_by'] as String?,
    );
  }

  final String id;
  final String name;
  final double? quantity;
  final String? unit;
  final String? category;
  final String? note;
  final bool isChecked;
  final String? checkedBy;
}

/// Grocery state.
class GroceryState {
  const GroceryState({
    this.lists = const [],
    this.currentList,
    this.items = const [],
    this.isLoading = false,
    this.isCached = false,
    this.error,
  });

  final List<GroceryList> lists;
  final GroceryList? currentList;
  final List<GroceryItem> items;
  final bool isLoading;
  final bool isCached;
  final String? error;

  GroceryState copyWith({
    List<GroceryList>? lists,
    GroceryList? currentList,
    List<GroceryItem>? items,
    bool? isLoading,
    bool? isCached,
    String? error,
    bool clearError = false,
    bool clearCurrentList = false,
  }) {
    return GroceryState(
      lists: lists ?? this.lists,
      currentList: clearCurrentList ? null : (currentList ?? this.currentList),
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Grocery state notifier managing lists and items.
class GroceryNotifier extends StateNotifier<GroceryState> {
  GroceryNotifier(this._api, this._dao) : super(const GroceryState());

  final GroceryApi _api;
  final GroceryDao _dao;

  /// Load all grocery lists for a space.
  Future<void> loadLists(String spaceId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // 1. Load from cache first
    try {
      final cached = await _dao.getLists(spaceId).first;
      if (cached.isNotEmpty) {
        final lists = cached
            .map((c) => GroceryList(id: c.id, name: c.name))
            .toList();
        state = state.copyWith(lists: lists, isLoading: false, isCached: true);
      }
    } catch (_) {
      // Cache read failed, continue to API
    }

    // 2. Try API in background
    try {
      final response = await _api.getLists(spaceId);
      final jsonList = parseList(response.data);
      final lists = jsonList.map(GroceryList.fromJson).toList();

      // Upsert into cache
      for (final item in lists) {
        await _dao.upsertList(
          CachedGroceryListsCompanion(
            id: Value(item.id),
            spaceId: Value(spaceId),
            name: Value(item.name),
            createdBy: const Value(''),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
            syncedAt: Value(DateTime.now()),
          ),
        );
      }

      state = state.copyWith(lists: lists, isLoading: false, isCached: false);
    } catch (e) {
      if (state.lists.isEmpty) {
        state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Select a grocery list and load its items.
  Future<void> selectList(String listId) async {
    final list = state.lists.firstWhere(
      (l) => l.id == listId,
      orElse: () => state.lists.first,
    );
    state = state.copyWith(currentList: list);
  }

  /// Create a new grocery list.
  Future<bool> createList(String spaceId, String name) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.createList(spaceId, name);
      final newList = GroceryList.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        lists: [...state.lists, newList],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Delete a grocery list.
  Future<bool> deleteList(String spaceId, String listId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.deleteList(spaceId, listId);

      state = state.copyWith(
        lists: state.lists.where((l) => l.id != listId).toList(),
        currentList: state.currentList?.id == listId ? null : state.currentList,
        clearCurrentList: state.currentList?.id == listId,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Load items for a specific grocery list.
  Future<void> loadItems(String spaceId, String listId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.getList(spaceId, listId);
      final data = response.data;

      List<GroceryItem> items;
      if (data is Map<String, dynamic> && data.containsKey('items')) {
        items = (data['items'] as List)
            .cast<Map<String, dynamic>>()
            .map(GroceryItem.fromJson)
            .toList();
      } else {
        final jsonList = parseList(data);
        items = jsonList.map(GroceryItem.fromJson).toList();
      }

      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
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
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.addItem(
        spaceId,
        listId,
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        note: note,
      );
      final newItem = GroceryItem.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        items: [...state.items, newItem],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Check off a grocery item.
  Future<bool> checkItem(String spaceId, String itemId) async {
    try {
      await _api.checkItem(spaceId, itemId);

      final updatedItems = state.items.map((item) {
        if (item.id == itemId) {
          return GroceryItem(
            id: item.id,
            name: item.name,
            quantity: item.quantity,
            unit: item.unit,
            category: item.category,
            note: item.note,
            isChecked: true,
            checkedBy: item.checkedBy,
          );
        }
        return item;
      }).toList();

      state = state.copyWith(items: updatedItems);
      return true;
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return false;
    }
  }

  /// Uncheck a grocery item.
  Future<bool> uncheckItem(String spaceId, String itemId) async {
    try {
      await _api.uncheckItem(spaceId, itemId);

      final updatedItems = state.items.map((item) {
        if (item.id == itemId) {
          return GroceryItem(
            id: item.id,
            name: item.name,
            quantity: item.quantity,
            unit: item.unit,
            category: item.category,
            note: item.note,
            isChecked: false,
          );
        }
        return item;
      }).toList();

      state = state.copyWith(items: updatedItems);
      return true;
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return false;
    }
  }

  /// Delete a grocery item.
  Future<bool> deleteItem(String spaceId, String itemId) async {
    try {
      await _api.deleteItem(spaceId, itemId);

      state = state.copyWith(
        items: state.items.where((i) => i.id != itemId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return false;
    }
  }

  /// Clear all checked items from a list.
  Future<bool> clearChecked(String spaceId, String listId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.clearChecked(spaceId, listId);

      state = state.copyWith(
        items: state.items.where((i) => !i.isChecked).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Grocery state provider.
final groceryProvider = StateNotifierProvider<GroceryNotifier, GroceryState>((
  ref,
) {
  return GroceryNotifier(
    ref.watch(groceryApiProvider),
    ref.watch(groceryDaoProvider),
  );
});

/// Convenience provider for grocery lists.
final groceryListsProvider = Provider<List<GroceryList>>((ref) {
  return ref.watch(groceryProvider).lists;
});

/// Convenience provider for items in the current grocery list.
final groceryItemsProvider = Provider<List<GroceryItem>>((ref) {
  return ref.watch(groceryProvider).items;
});

/// Convenience provider for the count of unchecked items.
final uncheckedCountProvider = Provider<int>((ref) {
  return ref.watch(groceryProvider).items.where((i) => !i.isChecked).length;
});
