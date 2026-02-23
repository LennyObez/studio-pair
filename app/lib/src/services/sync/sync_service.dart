import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:studio_pair/src/services/api/api_client.dart';
import 'package:studio_pair/src/services/sync/sync_queue.dart';

/// Sync status enum for the offline-first sync engine.
enum SyncServiceStatus { synced, syncing, offline, error }

/// Route mapping from entity types to API path prefixes.
///
/// Space-scoped entities include `{spaceId}` which is replaced at runtime.
/// Route mapping from entity types to API path prefixes.
///
/// Paths are relative to the Dio baseUrl (which already includes /v1).
/// Space-scoped entities include `{spaceId}` which is replaced at runtime.
const _entityRoutes = <String, String>{
  'activity': '/spaces/{spaceId}/activities',
  'calendar_event': '/spaces/{spaceId}/calendar',
  'task': '/spaces/{spaceId}/tasks',
  'grocery_list': '/spaces/{spaceId}/grocery/lists',
  'grocery_item': '/spaces/{spaceId}/grocery/items',
  'message': '/spaces/{spaceId}/messaging/messages',
  'conversation': '/spaces/{spaceId}/messaging/conversations',
  'reminder': '/reminders',
  'finance_entry': '/spaces/{spaceId}/finances',
  'card': '/cards',
  'vault_entry': '/spaces/{spaceId}/vault',
  'file': '/spaces/{spaceId}/files',
  'memory': '/spaces/{spaceId}/memories',
  'poll': '/spaces/{spaceId}/polls',
  'location_share': '/spaces/{spaceId}/location',
  'charter': '/spaces/{spaceId}/charter',
  'health_profile': '/health-wellness',
};

/// Offline sync service that queues operations locally and syncs
/// when connectivity is available.
class SyncService {
  SyncService({
    required ApiClient apiClient,
    required SyncQueue syncQueue,
    required Connectivity connectivity,
  }) : _apiClient = apiClient,
       _syncQueue = syncQueue,
       _connectivity = connectivity;

  final ApiClient _apiClient;
  final SyncQueue _syncQueue;
  final Connectivity _connectivity;

  final _statusController = StreamController<SyncServiceStatus>.broadcast();
  Stream<SyncServiceStatus> get statusStream => _statusController.stream;
  SyncServiceStatus _currentStatus = SyncServiceStatus.synced;
  SyncServiceStatus get currentStatus => _currentStatus;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;
  bool _isInitialized = false;

  /// Initialize the sync service: listen for connectivity changes and
  /// start periodic sync. Safe to call multiple times (idempotent).
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      result,
    ) {
      if (result != ConnectivityResult.none) {
        _sync();
      } else {
        _updateStatus(SyncServiceStatus.offline);
      }
    });

    // Periodic sync every 30 seconds when online
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) => _sync());
  }

  /// Queue a create operation for offline-first processing.
  Future<void> queueCreate({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    String spaceId = '',
  }) async {
    await _syncQueue.enqueue(
      SyncOperation(
        type: SyncOperationType.create,
        entityType: entityType,
        entityId: entityId,
        data: data,
        timestamp: DateTime.now(),
        spaceId: spaceId,
      ),
    );
    unawaited(_sync());
  }

  /// Queue an update operation.
  Future<void> queueUpdate({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    String spaceId = '',
  }) async {
    await _syncQueue.enqueue(
      SyncOperation(
        type: SyncOperationType.update,
        entityType: entityType,
        entityId: entityId,
        data: data,
        timestamp: DateTime.now(),
        spaceId: spaceId,
      ),
    );
    unawaited(_sync());
  }

  /// Queue a delete operation.
  Future<void> queueDelete({
    required String entityType,
    required String entityId,
    String spaceId = '',
  }) async {
    await _syncQueue.enqueue(
      SyncOperation(
        type: SyncOperationType.delete,
        entityType: entityType,
        entityId: entityId,
        data: const {},
        timestamp: DateTime.now(),
        spaceId: spaceId,
      ),
    );
    unawaited(_sync());
  }

  /// Attempt to process the sync queue.
  Future<void> _sync() async {
    if (_isSyncing) return;

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _updateStatus(SyncServiceStatus.offline);
      return;
    }

    _isSyncing = true;
    _updateStatus(SyncServiceStatus.syncing);

    try {
      final pendingOps = await _syncQueue.getPending();

      for (final op in pendingOps) {
        try {
          await _processOperation(op);
          await _syncQueue.markCompleted(op.dbId?.toString() ?? op.id);
        } catch (e) {
          await _syncQueue.markFailed(op.dbId?.toString() ?? op.id);
        }
      }

      final remainingOps = await _syncQueue.getPending();
      if (remainingOps.isEmpty) {
        _updateStatus(SyncServiceStatus.synced);
      } else {
        _updateStatus(SyncServiceStatus.error);
      }
    } catch (e) {
      _updateStatus(SyncServiceStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  /// Resolves the API path for a given entity type and space ID.
  String _resolvePath(SyncOperation op) {
    final template = _entityRoutes[op.entityType];
    if (template == null) {
      // Fallback for unknown entity types
      return '/${op.entityType}';
    }
    return template.replaceAll('{spaceId}', op.spaceId);
  }

  /// Process a single sync operation against the API.
  Future<void> _processOperation(SyncOperation op) async {
    final path = _resolvePath(op);

    switch (op.type) {
      case SyncOperationType.create:
        await _apiClient.post(path, data: op.data);
        break;
      case SyncOperationType.update:
        await _apiClient.put('$path/${op.entityId}', data: op.data);
        break;
      case SyncOperationType.delete:
        await _apiClient.delete('$path/${op.entityId}');
        break;
    }
  }

  void _updateStatus(SyncServiceStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// Force a manual sync.
  Future<void> forceSync() => _sync();

  /// Dispose of resources.
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _statusController.close();
  }
}
