import 'package:drift/drift.dart';
import '../app_database.dart';

part 'cards_dao.g.dart';

@DriftAccessor(tables: [CachedCards])
class CardsDao extends DatabaseAccessor<AppDatabase> with _$CardsDaoMixin {
  CardsDao(super.db);

  /// Inserts or updates a cached card.
  Future<void> upsertCard(CachedCardsCompanion card) {
    return into(cachedCards).insertOnConflictUpdate(card);
  }

  /// Watches cards for a given space with an optional type filter,
  /// ordered by most recently updated.
  Stream<List<CachedCard>> getCards(String spaceId, {String? type}) {
    return (select(cachedCards)
          ..where((t) {
            var condition = t.spaceId.equals(spaceId);
            if (type != null) {
              condition = condition & t.type.equals(type);
            }
            return condition;
          })
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// Retrieves a single card by its ID, or null if not found.
  Future<CachedCard?> getCardById(String id) {
    return (select(
      cachedCards,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Deletes a card from the local cache.
  Future<int> deleteCard(String id) {
    return (delete(cachedCards)..where((t) => t.id.equals(id))).go();
  }
}
