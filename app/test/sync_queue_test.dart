import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:studio_pair/src/services/database/app_database.dart'
    show SyncQueueData;
import 'package:studio_pair/src/services/database/daos/sync_queue_dao.dart';
import 'package:studio_pair/src/services/sync/sync_queue.dart';

@GenerateNiceMocks([MockSpec<SyncQueueDao>()])
import 'sync_queue_test.mocks.dart';

/// Helper to create a fake SyncQueueData row matching the Drift-generated class.
SyncQueueData _makeSyncQueueData({
  required int id,
  required String entityType,
  required String entityId,
  required String operation,
  required String payload,
  required String spaceId,
  int retryCount = 0,
  DateTime? createdAt,
  DateTime? lastAttemptAt,
  String? errorMessage,
}) {
  return SyncQueueData(
    id: id,
    entityType: entityType,
    entityId: entityId,
    operation: operation,
    payload: payload,
    spaceId: spaceId,
    retryCount: retryCount,
    createdAt: createdAt ?? DateTime.now(),
    lastAttemptAt: lastAttemptAt,
    errorMessage: errorMessage,
  );
}

void main() {
  late MockSyncQueueDao mockDao;
  late SyncQueue syncQueue;

  setUp(() {
    mockDao = MockSyncQueueDao();
    syncQueue = SyncQueue(dao: mockDao);
  });

  group('enqueue', () {
    test('delegates to DAO addToQueue with correct parameters', () async {
      when(
        mockDao.addToQueue(
          entityType: anyNamed('entityType'),
          entityId: anyNamed('entityId'),
          operation: anyNamed('operation'),
          payload: anyNamed('payload'),
          spaceId: anyNamed('spaceId'),
        ),
      ).thenAnswer((_) async => 1);

      final operation = SyncOperation(
        type: SyncOperationType.create,
        entityType: 'activity',
        entityId: 'act-123',
        data: {'title': 'Movie Night'},
        timestamp: DateTime.now(),
        spaceId: 'space-001',
      );

      await syncQueue.enqueue(operation);

      verify(
        mockDao.addToQueue(
          entityType: 'activity',
          entityId: 'act-123',
          operation: 'create',
          payload: jsonEncode({'title': 'Movie Night'}),
          spaceId: 'space-001',
        ),
      ).called(1);
    });

    test('encodes operation data as JSON payload', () async {
      when(
        mockDao.addToQueue(
          entityType: anyNamed('entityType'),
          entityId: anyNamed('entityId'),
          operation: anyNamed('operation'),
          payload: anyNamed('payload'),
          spaceId: anyNamed('spaceId'),
        ),
      ).thenAnswer((_) async => 2);

      final complexData = {
        'title': 'Test Task',
        'priority': 'high',
        'tags': ['urgent', 'work'],
        'nested': {'key': 'value'},
      };

      final operation = SyncOperation(
        type: SyncOperationType.update,
        entityType: 'task',
        entityId: 'task-456',
        data: complexData,
        timestamp: DateTime.now(),
        spaceId: 'space-002',
      );

      await syncQueue.enqueue(operation);

      verify(
        mockDao.addToQueue(
          entityType: 'task',
          entityId: 'task-456',
          operation: 'update',
          payload: jsonEncode(complexData),
          spaceId: 'space-002',
        ),
      ).called(1);
    });
  });

  group('getPending', () {
    test('returns parsed SyncOperations from DAO rows', () async {
      final rows = [
        _makeSyncQueueData(
          id: 1,
          entityType: 'activity',
          entityId: 'act-1',
          operation: 'create',
          payload: jsonEncode({'title': 'First'}),
          spaceId: 'space-001',
        ),
        _makeSyncQueueData(
          id: 2,
          entityType: 'task',
          entityId: 'task-1',
          operation: 'update',
          payload: jsonEncode({'status': 'done'}),
          spaceId: 'space-001',
          retryCount: 1,
        ),
      ];

      when(mockDao.getPendingOperations()).thenAnswer((_) async => rows);

      final pending = await syncQueue.getPending();

      expect(pending.length, equals(2));
      expect(pending[0].entityType, equals('activity'));
      expect(pending[0].type, equals(SyncOperationType.create));
      expect(pending[0].data, equals({'title': 'First'}));
      expect(pending[0].dbId, equals(1));
      expect(pending[1].entityType, equals('task'));
      expect(pending[1].type, equals(SyncOperationType.update));
      expect(pending[1].retryCount, equals(1));
    });

    test('filters out operations that have reached max retries', () async {
      final rows = [
        _makeSyncQueueData(
          id: 1,
          entityType: 'activity',
          entityId: 'act-1',
          operation: 'create',
          payload: jsonEncode({}),
          spaceId: 'space-001',
        ),
        _makeSyncQueueData(
          id: 2,
          entityType: 'task',
          entityId: 'task-1',
          operation: 'delete',
          payload: jsonEncode({}),
          spaceId: 'space-001',
          retryCount: 3, // maxRetries reached
        ),
        _makeSyncQueueData(
          id: 3,
          entityType: 'reminder',
          entityId: 'rem-1',
          operation: 'update',
          payload: jsonEncode({}),
          spaceId: 'space-001',
          retryCount: 5, // way past maxRetries
        ),
      ];

      when(mockDao.getPendingOperations()).thenAnswer((_) async => rows);

      final pending = await syncQueue.getPending();

      expect(pending.length, equals(1));
      expect(pending[0].entityId, equals('act-1'));
    });

    test('returns empty list when no pending operations', () async {
      when(mockDao.getPendingOperations()).thenAnswer((_) async => []);

      final pending = await syncQueue.getPending();

      expect(pending, isEmpty);
    });
  });

  group('markCompleted', () {
    test('removes operation from queue via DAO', () async {
      when(mockDao.removeFromQueue(42)).thenAnswer((_) async => 1);

      await syncQueue.markCompleted('42');

      verify(mockDao.removeFromQueue(42)).called(1);
    });

    test('does nothing for non-numeric operation ID', () async {
      await syncQueue.markCompleted('not-a-number');

      verifyNever(mockDao.removeFromQueue(any));
    });
  });

  group('markFailed', () {
    test('increments retry count via DAO markAttempted', () async {
      when(mockDao.markAttempted(7)).thenAnswer((_) async {});

      await syncQueue.markFailed('7');

      verify(mockDao.markAttempted(7)).called(1);
    });

    test('does nothing for non-numeric operation ID', () async {
      await syncQueue.markFailed('abc');

      verifyNever(mockDao.markAttempted(any));
    });
  });

  group('pendingCount', () {
    test('returns the count from DAO', () async {
      when(mockDao.getQueueCount()).thenAnswer((_) async => 5);

      final count = await syncQueue.pendingCount();

      expect(count, equals(5));
      verify(mockDao.getQueueCount()).called(1);
    });

    test('returns zero when queue is empty', () async {
      when(mockDao.getQueueCount()).thenAnswer((_) async => 0);

      final count = await syncQueue.pendingCount();

      expect(count, equals(0));
    });
  });

  group('clear', () {
    test('delegates to DAO clearQueue', () async {
      when(mockDao.clearQueue()).thenAnswer((_) async => 10);

      await syncQueue.clear();

      verify(mockDao.clearQueue()).called(1);
    });
  });

  group('SyncOperation', () {
    test(
      'generates an ID based on timestamp and entityId when not provided',
      () {
        final operation = SyncOperation(
          type: SyncOperationType.create,
          entityType: 'activity',
          entityId: 'act-999',
          data: {},
          timestamp: DateTime.now(),
        );

        expect(operation.id, contains('act-999'));
      },
    );

    test('copyWith updates status and retryCount', () {
      final operation = SyncOperation(
        type: SyncOperationType.update,
        entityType: 'task',
        entityId: 'task-1',
        data: {'title': 'Test'},
        timestamp: DateTime.now(),
      );

      final updated = operation.copyWith(
        status: SyncOperationStatus.failed,
        retryCount: 2,
      );

      expect(updated.status, equals(SyncOperationStatus.failed));
      expect(updated.retryCount, equals(2));
      // Unchanged fields remain the same
      expect(updated.entityType, equals('task'));
      expect(updated.type, equals(SyncOperationType.update));
    });
  });
}
