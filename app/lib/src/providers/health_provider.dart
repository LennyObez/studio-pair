import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/health_api.dart';
import 'package:studio_pair/src/services/health/health_bridge_service.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

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

/// Composite data class for health state.
class HealthData {
  const HealthData({this.profile, this.measurements = const []});

  final HealthProfile? profile;
  final List<HealthMeasurement> measurements;

  HealthData copyWith({
    HealthProfile? profile,
    List<HealthMeasurement>? measurements,
    bool clearProfile = false,
  }) {
    return HealthData(
      profile: clearProfile ? null : (profile ?? this.profile),
      measurements: measurements ?? this.measurements,
    );
  }
}

// ── Async notifier ──────────────────────────────────────────────────────

/// Health notifier managing health profiles and measurements.
class HealthNotifier extends AsyncNotifier<HealthData> {
  HealthApi get _api => ref.read(healthApiProvider);
  HealthBridgeService? _bridgeService;

  @override
  Future<HealthData> build() async => const HealthData();

  /// Load the user's health profile.
  Future<void> loadProfile() async {
    final previous = state.valueOrNull ?? const HealthData();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _api.getProfile();
      final data = response.data as Map<String, dynamic>;
      final profile = HealthProfile.fromJson(data);
      return previous.copyWith(profile: profile);
    });
  }

  /// Update the health profile.
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final previous = state.valueOrNull ?? const HealthData();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _api.updateProfile(data);
      final responseData = response.data as Map<String, dynamic>;
      final updatedProfile = HealthProfile.fromJson(responseData);
      return previous.copyWith(profile: updatedProfile);
    });
    return !state.hasError;
  }

  /// Load health measurements, optionally filtered by type and date range.
  Future<void> loadMeasurements({
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    final previous = state.valueOrNull ?? const HealthData();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _api.getMeasurements(
        type: type,
        startDate: startDate,
        endDate: endDate,
      );
      final items = parseList(response.data);
      final measurements = items.map(HealthMeasurement.fromJson).toList();
      return previous.copyWith(measurements: measurements);
    });
  }

  /// Add a new health measurement.
  Future<bool> addMeasurement({
    required String type,
    required double value,
    required String unit,
    String? source,
  }) async {
    final previous = state.valueOrNull ?? const HealthData();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _api.addMeasurement(
        type: type,
        value: value,
        unit: unit,
        source: source,
      );

      final newMeasurement = HealthMeasurement.fromJson(
        response.data as Map<String, dynamic>,
      );

      return previous.copyWith(
        measurements: [newMeasurement, ...previous.measurements],
      );
    });
    return !state.hasError;
  }

  /// Sync health data from the device's native health platform
  /// (HealthKit / Google Fit / Samsung Health).
  Future<bool> syncFromDevice() async {
    final previous = state.valueOrNull ?? const HealthData();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _bridgeService ??= HealthBridgeService();
      final bridge = _bridgeService!;

      // Request permissions
      final hasPermission = await bridge.requestPermissions();
      if (!hasPermission) {
        throw const ValidationFailure('Health data permission denied');
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
      final response = await _api.getMeasurements();
      final items = parseList(response.data);
      final measurements = items.map(HealthMeasurement.fromJson).toList();
      return previous.copyWith(measurements: measurements);
    });
    return !state.hasError;
  }
}

/// Health async provider.
final healthProvider = AsyncNotifierProvider<HealthNotifier, HealthData>(
  HealthNotifier.new,
);

// ── Convenience providers ───────────────────────────────────────────────

/// Convenience provider for the health profile.
final healthProfileProvider = Provider<HealthProfile?>((ref) {
  return ref.watch(healthProvider).valueOrNull?.profile;
});

/// Convenience provider for health measurements.
final healthMeasurementsProvider = Provider<List<HealthMeasurement>>((ref) {
  return ref.watch(healthProvider).valueOrNull?.measurements ?? [];
});
