import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity state: online or offline.
enum ConnectivityStatus { online, offline }

/// Connectivity state notifier that tracks network availability.
class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityNotifier({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      super(ConnectivityStatus.online) {
    _init();
  }

  final Connectivity _connectivity;
  StreamSubscription<ConnectivityResult>? _subscription;

  void _init() {
    // Check initial connectivity
    _connectivity.checkConnectivity().then(_updateFromResult);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateFromResult,
    );
  }

  void _updateFromResult(ConnectivityResult result) {
    final isOnline = result != ConnectivityResult.none;
    state = isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Connectivity status provider.
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
      return ConnectivityNotifier();
    });

/// Convenience provider for checking if online.
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider) == ConnectivityStatus.online;
});
