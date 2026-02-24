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
class SyncNotifier extends AsyncNotifier<SyncState> {
  StreamSubscription<SyncServiceStatus>? _statusSubscription;

  @override
  Future<SyncState> build() async {
    final syncService = ref.watch(syncServiceProvider);

    _statusSubscription = syncService.statusStream.listen((status) {
      state = AsyncData(
        SyncState(
          status: status,
          lastSyncTime: status == SyncServiceStatus.synced
              ? DateTime.now()
              : state.valueOrNull?.lastSyncTime,
        ),
      );
    });

    ref.onDispose(() {
      _statusSubscription?.cancel();
    });

    return const SyncState();
  }

  /// Force a manual sync.
  Future<void> forceSync() async {
    final syncService = ref.read(syncServiceProvider);
    await syncService.forceSync();
  }
}

/// Sync state provider.
final syncProvider = AsyncNotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);

/// Convenience provider for sync status.
final syncStatusProvider = Provider<SyncServiceStatus>((ref) {
  return ref.watch(syncProvider).valueOrNull?.status ??
      SyncServiceStatus.synced;
});
