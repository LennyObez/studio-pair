import 'package:health/health.dart';
import 'package:logging/logging.dart';

/// Data class for a health data point normalized from HealthKit/Google Fit.
class HealthDataPoint {
  final String type;
  final double value;
  final String unit;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String source;

  const HealthDataPoint({
    required this.type,
    required this.value,
    required this.unit,
    required this.dateFrom,
    required this.dateTo,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'value': value,
    'unit': unit,
    'date_from': dateFrom.toIso8601String(),
    'date_to': dateTo.toIso8601String(),
    'source': source,
  };
}

/// Service that bridges native health data from HealthKit (iOS),
/// Google Fit (Android), and Samsung Health into the app.
class HealthBridgeService {
  final Logger _log = Logger('HealthBridgeService');

  final Health _health = Health();

  /// Health data types we want to read.
  static const _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.WEIGHT,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
  ];

  /// Request permissions from the user to access health data.
  Future<bool> requestPermissions() async {
    try {
      final permissions = _dataTypes.map((_) => HealthDataAccess.READ).toList();
      final granted = await _health.requestAuthorization(
        _dataTypes,
        permissions: permissions,
      );
      _log.info('Health permissions granted: $granted');
      return granted;
    } catch (e) {
      _log.severe('Failed to request health permissions', e);
      return false;
    }
  }

  /// Check if we have permissions to read health data.
  Future<bool> hasPermissions() async {
    try {
      final result = await _health.hasPermissions(
        _dataTypes,
        permissions: _dataTypes.map((_) => HealthDataAccess.READ).toList(),
      );
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Fetch health data for the last [days] days.
  Future<List<HealthDataPoint>> fetchHealthData({int days = 7}) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));

    try {
      final data = await _health.getHealthDataFromTypes(
        types: _dataTypes,
        startTime: start,
        endTime: now,
      );

      // Remove duplicates
      final unique = _health.removeDuplicates(data);

      return unique.map((point) {
        return HealthDataPoint(
          type: _mapHealthType(point.type),
          value: point.value is NumericHealthValue
              ? (point.value as NumericHealthValue).numericValue.toDouble()
              : 0.0,
          unit: point.unitString,
          dateFrom: point.dateFrom,
          dateTo: point.dateTo,
          source: _mapSource(point.sourceName),
        );
      }).toList();
    } catch (e) {
      _log.severe('Failed to fetch health data', e);
      return [];
    }
  }

  /// Fetch step count for the last [days] days, aggregated daily.
  Future<List<HealthDataPoint>> fetchSteps({int days = 7}) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));

    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: start,
        endTime: now,
      );

      final unique = _health.removeDuplicates(data);

      return unique.map((point) {
        return HealthDataPoint(
          type: 'steps',
          value: point.value is NumericHealthValue
              ? (point.value as NumericHealthValue).numericValue.toDouble()
              : 0.0,
          unit: 'count',
          dateFrom: point.dateFrom,
          dateTo: point.dateTo,
          source: _mapSource(point.sourceName),
        );
      }).toList();
    } catch (e) {
      _log.severe('Failed to fetch step data', e);
      return [];
    }
  }

  /// Maps a HealthDataType to our internal string identifier.
  String _mapHealthType(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return 'steps';
      case HealthDataType.HEART_RATE:
        return 'heart_rate';
      case HealthDataType.SLEEP_ASLEEP:
        return 'sleep';
      case HealthDataType.WEIGHT:
        return 'weight';
      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
        return 'blood_pressure_systolic';
      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
        return 'blood_pressure_diastolic';
      default:
        return type.name.toLowerCase();
    }
  }

  /// Maps a source name to our HealthSource enum value.
  String _mapSource(String sourceName) {
    final lower = sourceName.toLowerCase();
    if (lower.contains('apple') || lower.contains('healthkit')) {
      return 'apple_health';
    }
    if (lower.contains('google') || lower.contains('fit')) {
      return 'google_fit';
    }
    if (lower.contains('samsung')) {
      return 'samsung_health';
    }
    return 'device';
  }
}
