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

/// Composite data class for location state.
class LocationData {
  const LocationData({
    this.activeShares = const [],
    this.myActiveShare,
    this.isSharing = false,
  });

  final List<LocationShare> activeShares;
  final LocationShare? myActiveShare;
  final bool isSharing;

  LocationData copyWith({
    List<LocationShare>? activeShares,
    LocationShare? myActiveShare,
    bool? isSharing,
    bool clearMyActiveShare = false,
  }) {
    return LocationData(
      activeShares: activeShares ?? this.activeShares,
      myActiveShare: clearMyActiveShare
          ? null
          : (myActiveShare ?? this.myActiveShare),
      isSharing: isSharing ?? this.isSharing,
    );
  }
}

// ── Async notifier ──────────────────────────────────────────────────────

/// Location notifier managing location sharing.
class LocationNotifier extends AsyncNotifier<LocationData> {
  LocationApi get _api => ref.read(locationApiProvider);

  @override
  Future<LocationData> build() async => const LocationData();

  /// Load active location shares for a space.
  Future<void> loadActiveShares(String spaceId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _api.getActiveShares(spaceId);
      final items = parseList(response.data);
      final shares = items.map(LocationShare.fromJson).toList();
      return const LocationData().copyWith(activeShares: shares);
    });
  }

  /// Start sharing live location.
  Future<bool> startSharing(
    String spaceId,
    double lat,
    double lng,
    int durationMinutes, {
    String type = 'live',
  }) async {
    final previous = state.valueOrNull ?? const LocationData();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
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

      return previous.copyWith(
        myActiveShare: share,
        isSharing: true,
        activeShares: [...previous.activeShares, share],
      );
    });
    return !state.hasError;
  }

  /// Update the current shared location coordinates.
  Future<bool> updateLocation(
    String spaceId,
    String shareId,
    double lat,
    double lng,
  ) async {
    final previous = state.valueOrNull ?? const LocationData();
    state = await AsyncValue.guard(() async {
      final response = await _api.updateLocation(spaceId, shareId, lat, lng);
      final updated = LocationShare.fromJson(
        response.data as Map<String, dynamic>,
      );

      final updatedShares = previous.activeShares.map((share) {
        if (share.id == shareId) return updated;
        return share;
      }).toList();

      var updatedMyShare = previous.myActiveShare;
      if (previous.myActiveShare?.id == shareId) {
        updatedMyShare = updated;
      }

      return previous.copyWith(
        activeShares: updatedShares,
        myActiveShare: updatedMyShare,
      );
    });
    return !state.hasError;
  }

  /// Stop sharing location.
  Future<bool> stopSharing(String spaceId, String shareId) async {
    final previous = state.valueOrNull ?? const LocationData();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _api.stopSharing(spaceId, shareId);
      return previous.copyWith(
        activeShares: previous.activeShares
            .where((s) => s.id != shareId)
            .toList(),
        isSharing: false,
        clearMyActiveShare: true,
      );
    });
    return !state.hasError;
  }

  /// Send a one-time safe ping with current location.
  Future<bool> sendSafePing(String spaceId, double lat, double lng) async {
    final previous = state.valueOrNull ?? const LocationData();
    state = await AsyncValue.guard(() async {
      final response = await _api.sendSafePing(spaceId, lat, lng);
      final ping = LocationShare.fromJson(
        response.data as Map<String, dynamic>,
      );
      return previous.copyWith(activeShares: [...previous.activeShares, ping]);
    });
    return !state.hasError;
  }

  /// Share an ETA to a destination.
  Future<bool> shareETA(
    String spaceId, {
    required double lat,
    required double lng,
    required String destination,
    required int etaMinutes,
  }) async {
    final previous = state.valueOrNull ?? const LocationData();
    state = await AsyncValue.guard(() async {
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

      return previous.copyWith(
        activeShares: [...previous.activeShares, etaShare],
      );
    });
    return !state.hasError;
  }
}

/// Location async provider.
final locationProvider = AsyncNotifierProvider<LocationNotifier, LocationData>(
  LocationNotifier.new,
);

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for active location shares.
final activeSharesProvider = Provider<List<LocationShare>>((ref) {
  return ref.watch(locationProvider).valueOrNull?.activeShares ?? [];
});

/// Convenience provider for whether the current user is sharing location.
final isSharingProvider = Provider<bool>((ref) {
  return ref.watch(locationProvider).valueOrNull?.isSharing ?? false;
});
