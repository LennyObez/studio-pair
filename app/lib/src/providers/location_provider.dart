import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/location_api.dart';

/// Location share model.
class LocationShare {
  const LocationShare({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.expiresAt,
    this.etaDestination,
    this.etaMinutes,
  });

  factory LocationShare.fromJson(Map<String, dynamic> json) {
    return LocationShare(
      id: json['id'],
      userId: json['user_id'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      type: json['type'],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      etaDestination: json['eta_destination'],
      etaMinutes: json['eta_minutes'],
    );
  }

  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final String type; // live, safe_ping, eta
  final DateTime? expiresAt;
  final String? etaDestination;
  final int? etaMinutes;
}

/// Location state.
class LocationState {
  const LocationState({
    this.activeShares = const [],
    this.myActiveShare,
    this.isSharing = false,
    this.isLoading = false,
    this.error,
  });

  final List<LocationShare> activeShares;
  final LocationShare? myActiveShare;
  final bool isSharing;
  final bool isLoading;
  final String? error;

  LocationState copyWith({
    List<LocationShare>? activeShares,
    LocationShare? myActiveShare,
    bool? isSharing,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearMyActiveShare = false,
  }) {
    return LocationState(
      activeShares: activeShares ?? this.activeShares,
      myActiveShare: clearMyActiveShare
          ? null
          : (myActiveShare ?? this.myActiveShare),
      isSharing: isSharing ?? this.isSharing,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Location state notifier managing location sharing.
class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier(this._api) : super(const LocationState());

  final LocationApi _api;

  /// Load active location shares for a space.
  Future<void> loadActiveShares(String spaceId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.getActiveShares(spaceId);
      final items = parseList(response.data);
      final shares = items.map(LocationShare.fromJson).toList();

      state = state.copyWith(activeShares: shares, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  /// Start sharing live location.
  Future<bool> startSharing(
    String spaceId,
    double lat,
    double lng,
    int durationMinutes, {
    String type = 'live',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.startSharing(
        spaceId,
        latitude: lat,
        longitude: lng,
        duration: durationMinutes,
        type: type,
      );

      final share = LocationShare.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        myActiveShare: share,
        isSharing: true,
        activeShares: [...state.activeShares, share],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Update the current shared location coordinates.
  Future<bool> updateLocation(
    String spaceId,
    String shareId,
    double lat,
    double lng,
  ) async {
    try {
      final response = await _api.updateLocation(spaceId, shareId, lat, lng);
      final updated = LocationShare.fromJson(
        response.data as Map<String, dynamic>,
      );

      final updatedShares = state.activeShares.map((share) {
        if (share.id == shareId) {
          return updated;
        }
        return share;
      }).toList();

      var updatedMyShare = state.myActiveShare;
      if (state.myActiveShare?.id == shareId) {
        updatedMyShare = updated;
      }

      state = state.copyWith(
        activeShares: updatedShares,
        myActiveShare: updatedMyShare,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return false;
    }
  }

  /// Stop sharing location.
  Future<bool> stopSharing(String spaceId, String shareId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.stopSharing(spaceId, shareId);

      state = state.copyWith(
        activeShares: state.activeShares.where((s) => s.id != shareId).toList(),
        isSharing: false,
        clearMyActiveShare: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Send a one-time safe ping with current location.
  Future<bool> sendSafePing(String spaceId, double lat, double lng) async {
    try {
      final response = await _api.sendSafePing(spaceId, lat, lng);
      final ping = LocationShare.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(activeShares: [...state.activeShares, ping]);
      return true;
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return false;
    }
  }

  /// Share an ETA to a destination.
  Future<bool> shareETA(
    String spaceId, {
    required double lat,
    required double lng,
    required String destination,
    required int etaMinutes,
  }) async {
    try {
      final response = await _api.shareETA(
        spaceId,
        latitude: lat,
        longitude: lng,
        destination: destination,
        destinationLat: lat,
        destinationLng: lng,
        estimatedMinutes: etaMinutes,
      );

      final etaShare = LocationShare.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(activeShares: [...state.activeShares, etaShare]);
      return true;
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return false;
    }
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Location state provider.
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) {
    return LocationNotifier(ref.watch(locationApiProvider));
  },
);

/// Convenience provider for active location shares.
final activeSharesProvider = Provider<List<LocationShare>>((ref) {
  return ref.watch(locationProvider).activeShares;
});

/// Convenience provider for whether the current user is sharing location.
final isSharingProvider = Provider<bool>((ref) {
  return ref.watch(locationProvider).isSharing;
});
