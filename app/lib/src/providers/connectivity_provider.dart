import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity state: online or offline.
enum ConnectivityStatus { online, offline }

/// Connectivity notifier using AsyncNotifier pattern.
class ConnectivityNotifier extends AsyncNotifier<ConnectivityStatus> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  Future<ConnectivityStatus> build() async {
    final connectivity = Connectivity();

    // Check initial connectivity
    final results = await connectivity.checkConnectivity();
    final initial = _statusFromResults(results);

    // Listen for changes
    _subscription = connectivity.onConnectivityChanged.listen((results) {
      state = AsyncData(_statusFromResults(results));
    });

    ref.onDispose(() => _subscription?.cancel());

    return initial;
  }

  ConnectivityStatus _statusFromResults(List<ConnectivityResult> results) {
    final isOnline = results.any((r) => r != ConnectivityResult.none);
    return isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline;
  }
}

/// Connectivity status provider.
final connectivityProvider =
    AsyncNotifierProvider<ConnectivityNotifier, ConnectivityStatus>(
      ConnectivityNotifier.new,
    );

/// Convenience provider for checking if online.
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).valueOrNull ==
      ConnectivityStatus.online;
});
