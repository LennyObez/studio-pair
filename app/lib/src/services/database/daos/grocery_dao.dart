import 'package:drift/drift.dart';
import '../app_database.dart';

part 'grocery_dao.g.dart';

@DriftAccessor(tables: [CachedGroceryLists, CachedGroceryItems])
class GroceryDao extends DatabaseAccessor<AppDatabase> with _$GroceryDaoMixin {
  GroceryDao(super.db);

  // ==================== Grocery Lists ====================

  /// Inserts or updates a cached grocery list.
  Future<void> upsertList(CachedGroceryListsCompanion list) {
    return into(cachedGroceryLists).insertOnConflictUpdate(list);
  }

  /// Watches all grocery lists for a given space, ordered by most recent.
  Stream<List<CachedGroceryList>> getLists(String spaceId) {
    return (select(cachedGroceryLists)
          ..where((t) => t.spaceId.equals(spaceId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// Retrieves a single grocery list by its ID, or null if not found.
  Future<CachedGroceryList?> getList(String id) {
    return (select(
      cachedGroceryLists,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Deletes a grocery list and all its items from the local cache.
  Future<void> deleteList(String id) async {
    await (delete(cachedGroceryItems)..where((t) => t.listId.equals(id))).go();
    await (delete(cachedGroceryLists)..where((t) => t.id.equals(id))).go();
  }

  // ==================== Grocery Items ====================

  /// Inserts or updates a cached grocery item.
  Future<void> upsertItem(CachedGroceryItemsCompanion item) {
    return into(cachedGroceryItems).insertOnConflictUpdate(item);
  }

  /// Watches all items in a grocery list, ordered by display order.
  Stream<List<CachedGroceryItem>> getItems(String listId) {
    return (select(cachedGroceryItems)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.isChecked),
            (t) => OrderingTerm.asc(t.displayOrder),
          ]))
        .watch();
  }

  /// Toggles the checked state of a grocery item.
  Future<void> toggleItem(String id, String? checkedByUserId) async {
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
  }

  /// Deletes a grocery item from the local cache.
  Future<int> deleteItem(String id) {
    return (delete(cachedGroceryItems)..where((t) => t.id.equals(id))).go();
  }

  /// Returns the count of unchecked items in a grocery list.
  Future<int> getUncheckedCount(String listId) async {
    final count = cachedGroceryItems.id.count();
    final query = selectOnly(cachedGroceryItems)
      ..addColumns([count])
      ..where(
        cachedGroceryItems.listId.equals(listId) &
            cachedGroceryItems.isChecked.equals(false),
      );
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
