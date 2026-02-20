import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'cards_dao.g.dart';

@DriftAccessor(tables: [CachedCards])
class CardsDao extends DatabaseAccessor<AppDatabase> with _$CardsDaoMixin {
  CardsDao(super.db);

  /// Inserts or updates a cached card.
  Future<void> upsertCard(CachedCardsCompanion card) {
    try {
      return into(cachedCards).insertOnConflictUpdate(card);
    } catch (e) {
      throw StorageFailure('Failed to upsert card: $e');
    }
  }

  /// Watches cards for a given space with an optional type filter,
  /// ordered by most recently updated.
  Stream<List<CachedCard>> getCards(String spaceId, {String? type}) {
    try {
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
    } catch (e) {
      throw StorageFailure('Failed to get cards: $e');
    }
  }

  /// Retrieves a single card by its ID, or null if not found.
  Future<CachedCard?> getCardById(String id) {
    try {
      return (select(
        cachedCards,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      throw StorageFailure('Failed to get card by id: $e');
    }
  }

  /// Deletes a card from the local cache.
  Future<int> deleteCard(String id) {
    try {
      return (delete(cachedCards)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete card: $e');
    }
  }

  /// Batch upserts cards into cache.
  Future<void> upsertCards(List<CachedCardsCompanion> cards) {
    try {
      return batch((b) {
        b.insertAll(cachedCards, cards, mode: InsertMode.insertOrReplace);
      });
    } catch (e) {
      throw StorageFailure('Failed to batch upsert cards: $e');
    }
  }
}
