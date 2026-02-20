import 'dart:convert';

import 'package:studio_pair/src/services/database/daos/sync_queue_dao.dart';

/// Sync operation type.
enum SyncOperationType { create, update, delete }

/// Sync operation status.
enum SyncOperationStatus { pending, processing, completed, failed }

/// A single sync operation to be queued and processed.
class SyncOperation {
  SyncOperation({
    this.dbId,
    String? id,
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.timestamp,
    this.spaceId = '',
    this.status = SyncOperationStatus.pending,
    this.retryCount = 0,
  }) : id = id ?? '${DateTime.now().millisecondsSinceEpoch}_$entityId';

  /// Database auto-increment ID (from Drift SyncQueue table).
  final int? dbId;
  final String id;
  final SyncOperationType type;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String spaceId;
  final SyncOperationStatus status;
  final int retryCount;

  SyncOperation copyWith({SyncOperationStatus? status, int? retryCount}) {
    return SyncOperation(
      dbId: dbId,
      id: id,
      type: type,
      entityType: entityType,
      entityId: entityId,
      data: data,
      timestamp: timestamp,
      spaceId: spaceId,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Persistent sync queue backed by the Drift SyncQueueDao.
///
/// All operations are stored in the local SQLite database so they survive
/// app restarts.
class SyncQueue {
  final SyncQueueDao _dao;

  static const int maxRetries = 3;

  SyncQueue({required SyncQueueDao dao}) : _dao = dao;

  /// Enqueue a new sync operation (persisted to SQLite).
  Future<void> enqueue(SyncOperation operation) async {
    await _dao.addToQueue(
      entityType: operation.entityType,
      entityId: operation.entityId,
      operation: operation.type.name,
      payload: jsonEncode(operation.data),
      spaceId: operation.spaceId,
    );
  }

  /// Get all pending operations from the database, sorted FIFO.
  Future<List<SyncOperation>> getPending() async {
    final rows = await _dao.getPendingOperations();
    return rows
        .where((row) => row.retryCount < maxRetries)
        .map(
          (row) => SyncOperation(
            dbId: row.id,
            type: SyncOperationType.values.byName(row.operation),
            entityType: row.entityType,
            entityId: row.entityId,
            data: jsonDecode(row.payload) as Map<String, dynamic>,
            timestamp: row.createdAt,
            spaceId: row.spaceId,
            retryCount: row.retryCount,
          ),
        )
        .toList();
  }

  /// Mark an operation as completed and remove it from the queue.
  Future<void> markCompleted(String operationId) async {
    final dbId = int.tryParse(operationId);
    if (dbId != null) {
      await _dao.removeFromQueue(dbId);
    }
  }

  /// Mark an operation as failed and increment retry count.
  Future<void> markFailed(String operationId) async {
    final dbId = int.tryParse(operationId);
    if (dbId != null) {
      await _dao.markAttempted(dbId);
    }
  }

  /// Get the count of pending operations.
  Future<int> pendingCount() async {
    return _dao.getQueueCount();
  }

  /// Clear all operations from the queue.
  Future<void> clear() async {
    await _dao.clearQueue();
  }
}
