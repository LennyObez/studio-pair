import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  /// Adds a new operation to the sync queue for later synchronization.
  Future<int> addToQueue({
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    required String spaceId,
  }) {
    try {
      return into(syncQueue).insert(
        SyncQueueCompanion.insert(
          entityType: entityType,
          entityId: entityId,
          operation: operation,
          payload: payload,
          spaceId: spaceId,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      throw StorageFailure('Failed to add to sync queue: $e');
    }
  }

  /// Retrieves up to 50 pending operations ordered by creation time.
  Future<List<SyncQueueData>> getPendingOperations() {
    try {
      return (select(syncQueue)
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(50))
          .get();
    } catch (e) {
      throw StorageFailure('Failed to get pending operations: $e');
    }
  }

  /// Marks an operation as attempted, incrementing the retry count
  /// and optionally recording an error message.
  Future<void> markAttempted(int id, {String? errorMessage}) async {
    try {
      final row = await (select(
        syncQueue,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) return;
      await (update(syncQueue)..where((t) => t.id.equals(id))).write(
        SyncQueueCompanion(
          retryCount: Value(row.retryCount + 1),
          lastAttemptAt: Value(DateTime.now()),
          errorMessage: Value(errorMessage),
        ),
      );
    } catch (e) {
      throw StorageFailure('Failed to mark sync operation as attempted: $e');
    }
  }

  /// Removes a successfully synced operation from the queue.
  Future<int> removeFromQueue(int id) {
    try {
      return (delete(syncQueue)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageFailure('Failed to remove from sync queue: $e');
    }
  }

  /// Returns the total number of pending operations in the queue.
  Future<int> getQueueCount() async {
    try {
      final count = syncQueue.id.count();
      final query = selectOnly(syncQueue)..addColumns([count]);
      final result = await query.getSingle();
      return result.read(count) ?? 0;
    } catch (e) {
      throw StorageFailure('Failed to get sync queue count: $e');
    }
  }

  /// Clears all entries from the sync queue.
  Future<int> clearQueue() {
    try {
      return delete(syncQueue).go();
    } catch (e) {
      throw StorageFailure('Failed to clear sync queue: $e');
    }
  }
}
