import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/health_api.dart';
import 'package:studio_pair/src/services/health/health_bridge_service.dart';

/// Health profile model with body measurements.
class HealthProfile {
  const HealthProfile({
    this.height,
    this.weight,
    this.topSize,
    this.bottomSize,
    this.shoeSize,
    this.ringSize,
  });

  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      topSize: json['top_size'],
      bottomSize: json['bottom_size'],
      shoeSize: json['shoe_size'],
      ringSize: json['ring_size'],
    );
  }

  /// Height in centimeters.
  final double? height;

  /// Weight in kilograms.
  final double? weight;

  /// Top / shirt size (e.g. 'M', 'L', 'XL').
  final String? topSize;

  /// Bottom / pants size (e.g. '32', 'M').
  final String? bottomSize;

  /// Shoe size (e.g. '10', '42').
  final String? shoeSize;

  /// Ring size (e.g. '7', '17mm').
  final String? ringSize;
}

/// Health measurement model.
class HealthMeasurement {
  const HealthMeasurement({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.measuredAt,
    this.source,
  });

  factory HealthMeasurement.fromJson(Map<String, dynamic> json) {
    return HealthMeasurement(
      id: json['id'],
      type: json['type'],
      value: (json['value'] as num).toDouble(),
      unit: json['unit'],
      measuredAt: json['measured_at'] ?? '',
      source: json['source'],
    );
  }

  final String id;

  /// Measurement type: 'steps', 'heart_rate', 'weight', 'blood_pressure', 'sleep', etc.
  final String type;
  final double value;
  final String unit;
  final String measuredAt;

  /// Data source: 'apple_health', 'google_fit', 'manual'.
  final String? source;
}

/// Health state.
class HealthState {
  const HealthState({
    this.profile,
    this.measurements = const [],
    this.isLoading = false,
    this.error,
  });

  final HealthProfile? profile;
  final List<HealthMeasurement> measurements;
  final bool isLoading;
  final String? error;

  HealthState copyWith({
    HealthProfile? profile,
    List<HealthMeasurement>? measurements,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearProfile = false,
  }) {
    return HealthState(
      profile: clearProfile ? null : (profile ?? this.profile),
      measurements: measurements ?? this.measurements,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Health state notifier managing health profiles and measurements.
class HealthNotifier extends StateNotifier<HealthState> {
  HealthNotifier(this._api) : super(const HealthState());

  final HealthApi _api;
  HealthBridgeService? _bridgeService;

  /// Load the user's health profile.
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.getProfile();
      final data = response.data as Map<String, dynamic>;
      final profile = HealthProfile.fromJson(data);

      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  /// Update the health profile.
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.updateProfile(data);
      final responseData = response.data as Map<String, dynamic>;
      final updatedProfile = HealthProfile.fromJson(responseData);

      state = state.copyWith(profile: updatedProfile, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Load health measurements, optionally filtered by type and date range.
  Future<void> loadMeasurements({
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.getMeasurements(
        type: type,
        startDate: startDate,
        endDate: endDate,
      );
      final items = parseList(response.data);
      final measurements = items.map(HealthMeasurement.fromJson).toList();

      state = state.copyWith(measurements: measurements, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  /// Add a new health measurement.
  Future<bool> addMeasurement({
    required String type,
    required double value,
    required String unit,
    String? source,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.addMeasurement(
        type: type,
        value: value,
        unit: unit,
        source: source,
      );

      final newMeasurement = HealthMeasurement.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        measurements: [newMeasurement, ...state.measurements],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Sync health data from the device's native health platform
  /// (HealthKit / Google Fit / Samsung Health).
  Future<bool> syncFromDevice() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      _bridgeService ??= HealthBridgeService();
      final bridge = _bridgeService!;

      // Request permissions
      final hasPermission = await bridge.requestPermissions();
      if (!hasPermission) {
        state = state.copyWith(
          isLoading: false,
          error: 'Health data permission denied',
        );
        return false;
      }

      // Fetch last 7 days of data
      final dataPoints = await bridge.fetchHealthData();

      // Upload each data point to the API
      for (final point in dataPoints) {
        await _api.addMeasurement(
          type: point.type,
          value: point.value,
          unit: point.unit,
          source: point.source,
        );
      }

      // Reload measurements from API
      await loadMeasurements();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Health state provider.
final healthProvider = StateNotifierProvider<HealthNotifier, HealthState>((
  ref,
) {
  return HealthNotifier(ref.watch(healthApiProvider));
});

/// Convenience provider for the health profile.
final healthProfileProvider = Provider<HealthProfile?>((ref) {
  return ref.watch(healthProvider).profile;
});

/// Convenience provider for health measurements.
final healthMeasurementsProvider = Provider<List<HealthMeasurement>>((ref) {
  return ref.watch(healthProvider).measurements;
});
