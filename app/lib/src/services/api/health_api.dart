import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Health & Wellness API service for profiles, measurements, and sleep tracking.
class HealthApi {
  HealthApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Get the current user's health & wellness profile.
  Future<Response> getProfile() {
    return _client.get('/health-wellness/profile');
  }

  /// Update the current user's health & wellness profile.
  Future<Response> updateProfile(Map<String, dynamic> data) {
    return _client.patch('/health-wellness/profile', data: data);
  }

  /// Add a new measurement entry.
  Future<Response> addMeasurement({
    required String type,
    required double value,
    required String unit,
    String? source,
    String? measuredAt,
  }) {
    return _client.post(
      '/health-wellness/measurements',
      data: {
        'type': type,
        'value': value,
        'unit': unit,
        if (source != null) 'source': source,
        if (measuredAt != null) 'measured_at': measuredAt,
      },
    );
  }

  /// Get measurements with optional filters.
  Future<Response> getMeasurements({
    String? type,
    String? startDate,
    String? endDate,
  }) {
    return _client.get(
      '/health-wellness/measurements',
      queryParameters: {
        if (type != null) 'type': type,
        if (startDate != null) 'start': startDate,
        if (endDate != null) 'end': endDate,
      },
    );
  }

  /// Get sleep data with optional date range.
  Future<Response> getSleepData({String? startDate, String? endDate}) {
    return _client.get(
      '/health-wellness/sleep',
      queryParameters: {
        if (startDate != null) 'start': startDate,
        if (endDate != null) 'end': endDate,
      },
    );
  }

  /// Update the sleep goal.
  Future<Response> updateSleepGoal({
    required String targetBedtime,
    required String targetWakeTime,
    List<String>? days,
  }) {
    return _client.put(
      '/health-wellness/sleep/goal',
      data: {
        'target_bedtime': targetBedtime,
        'target_wake_time': targetWakeTime,
        if (days != null) 'days': days,
      },
    );
  }
}
