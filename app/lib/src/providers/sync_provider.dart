import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/sync/sync_service.dart';

/// Sync status state for the UI.
class SyncState {
  const SyncState({
    this.status = SyncServiceStatus.synced,
    this.pendingCount = 0,
    this.lastSyncTime,
  });

  final SyncServiceStatus status;
  final int pendingCount;
  final DateTime? lastSyncTime;

  SyncState copyWith({
    SyncServiceStatus? status,
    int? pendingCount,
    DateTime? lastSyncTime,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  /// Human-readable description of the sync status.
  String get statusText {
    switch (status) {
      case SyncServiceStatus.synced:
        return 'All changes synced';
      case SyncServiceStatus.syncing:
        return 'Syncing $pendingCount changes...';
      case SyncServiceStatus.offline:
        return 'Offline - $pendingCount changes pending';
      case SyncServiceStatus.error:
        return 'Sync error - $pendingCount changes pending';
    }
  }
}

/// Sync state notifier wrapping the SyncService.
class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier({SyncService? syncService})
    : _syncService = syncService,
      super(const SyncState());

  final SyncService? _syncService;
  StreamSubscription<SyncServiceStatus>? _statusSubscription;

  /// Initialize and start listening to sync status changes.
  void initialize() {
    if (_syncService == null) return;

    _statusSubscription = _syncService.statusStream.listen((status) {
      state = state.copyWith(
        status: status,
        lastSyncTime: status == SyncServiceStatus.synced
            ? DateTime.now()
            : null,
      );
    });
  }

  /// Force a manual sync.
  Future<void> forceSync() async {
    await _syncService?.forceSync();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _syncService?.dispose();
    super.dispose();
  }
}

/// Sync state provider.
final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final notifier = SyncNotifier(syncService: ref.watch(syncServiceProvider));
  notifier.initialize();
  return notifier;
});

/// Convenience provider for sync status.
final syncStatusProvider = Provider<SyncServiceStatus>((ref) {
  return ref.watch(syncProvider).status;
});
