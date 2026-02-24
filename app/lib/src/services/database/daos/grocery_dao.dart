import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'grocery_dao.g.dart';

@DriftAccessor(tables: [CachedGroceryLists, CachedGroceryItems])
class GroceryDao extends DatabaseAccessor<AppDatabase> with _$GroceryDaoMixin {
  GroceryDao(super.db);

  // ==================== Grocery Lists ====================

  /// Inserts or updates a cached grocery list.
  Future<void> upsertList(CachedGroceryListsCompanion list) {
    try {
      return into(cachedGroceryLists).insertOnConflictUpdate(list);
    } catch (e) {
      throw StorageFailure('Failed to upsert grocery list: $e');
    }
  }

  /// Watches all grocery lists for a given space, ordered by most recent.
  Stream<List<CachedGroceryList>> getLists(String spaceId) {
    try {
      return (select(cachedGroceryLists)
            ..where((t) => t.spaceId.equals(spaceId))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get grocery lists: $e');
    }
  }

  /// Retrieves a single grocery list by its ID, or null if not found.
  Future<CachedGroceryList?> getList(String id) {
    try {
      return (select(
        cachedGroceryLists,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      throw StorageFailure('Failed to get grocery list: $e');
    }
  }

  /// Deletes a grocery list and all its items from the local cache.
  Future<void> deleteList(String id) async {
    try {
      await (delete(
        cachedGroceryItems,
      )..where((t) => t.listId.equals(id))).go();
      await (delete(cachedGroceryLists)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete grocery list: $e');
    }
  }

  // ==================== Grocery Items ====================

  /// Inserts or updates a cached grocery item.
  Future<void> upsertItem(CachedGroceryItemsCompanion item) {
    try {
      return into(cachedGroceryItems).insertOnConflictUpdate(item);
    } catch (e) {
      throw StorageFailure('Failed to upsert grocery item: $e');
    }
  }

  /// Watches all items in a grocery list, ordered by display order.
  Stream<List<CachedGroceryItem>> getItems(String listId) {
    try {
      return (select(cachedGroceryItems)
            ..where((t) => t.listId.equals(listId))
            ..orderBy([
              (t) => OrderingTerm.asc(t.isChecked),
              (t) => OrderingTerm.asc(t.displayOrder),
            ]))
          .watch();
    } catch (e) {
      throw StorageFailure('Failed to get grocery items: $e');
    }
  }

  /// Toggles the checked state of a grocery item.
  Future<void> toggleItem(String id, String? checkedByUserId) async {
    try {
      final item = await (select(
        cachedGroceryItems,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (item != null) {
        final nowChecked = !item.isChecked;
        await (update(cachedGroceryItems)..where((t) => t.id.equals(id))).write(
          CachedGroceryItemsCompanion(
            isChecked: Value(nowChecked),
            checkedBy: Value(nowChecked ? checkedByUserId : null),
            checkedAt: Value(nowChecked ? DateTime.now() : null),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    } catch (e) {
      throw StorageFailure('Failed to toggle grocery item: $e');
    }
  }

  /// Deletes a grocery item from the local cache.
  Future<int> deleteItem(String id) {
    try {
      return (delete(cachedGroceryItems)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete grocery item: $e');
    }
  }

  /// Returns the count of unchecked items in a grocery list.
  Future<int> getUncheckedCount(String listId) async {
    try {
      final count = cachedGroceryItems.id.count();
      final query = selectOnly(cachedGroceryItems)
        ..addColumns([count])
        ..where(
          cachedGroceryItems.listId.equals(listId) &
              cachedGroceryItems.isChecked.equals(false),
        );
      final result = await query.getSingle();
      return result.read(count) ?? 0;
    } catch (e) {
      throw StorageFailure('Failed to get unchecked count: $e');
    }
  }

  /// Batch upserts grocery lists into cache.
  Future<void> upsertLists(List<CachedGroceryListsCompanion> lists) {
    try {
      return batch((b) {
        b.insertAll(
          cachedGroceryLists,
          lists,
          mode: InsertMode.insertOrReplace,
        );
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert grocery lists: $e');
    }
  }

  /// Batch upserts grocery items into cache.
  Future<void> upsertItems(List<CachedGroceryItemsCompanion> items) {
    try {
      return batch((b) {
        b.insertAll(
          cachedGroceryItems,
          items,
          mode: InsertMode.insertOrReplace,
        );
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert grocery items: $e');
    }
  }
}
