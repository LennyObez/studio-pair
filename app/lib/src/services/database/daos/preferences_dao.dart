import 'package:drift/drift.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';
import '../app_database.dart';

part 'preferences_dao.g.dart';

/// Common preference key constants for type-safe access.
abstract class PreferenceKeys {
  static const String currentSpaceId = 'current_space_id';
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String lastSyncAt = 'last_sync_at';
  static const String onboardingComplete = 'onboarding_complete';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String biometricEnabled = 'biometric_enabled';
  static const String lastActiveUserId = 'last_active_user_id';
}

@DriftAccessor(tables: [AppPreferences])
class PreferencesDao extends DatabaseAccessor<AppDatabase>
    with _$PreferencesDaoMixin {
  PreferencesDao(super.db);

  /// Sets a preference value. Inserts if the key does not exist,
  /// or updates the existing value.
  Future<void> setPreference(String key, String value) {
    try {
      return into(appPreferences).insertOnConflictUpdate(
        AppPreferencesCompanion.insert(key: key, value: value),
      );
    } catch (e) {
      throw StorageFailure('Failed to set preference: $e');
    }
  }

  /// Retrieves a preference value by key, or null if not found.
  Future<String?> getPreference(String key) async {
    try {
      final result = await (select(
        appPreferences,
      )..where((t) => t.key.equals(key))).getSingleOrNull();
      return result?.value;
    } catch (e) {
      throw StorageFailure('Failed to get preference: $e');
    }
  }

  /// Deletes a preference by key.
  Future<int> deletePreference(String key) {
    try {
      return (delete(appPreferences)..where((t) => t.key.equals(key))).go();
    } catch (e) {
      throw StorageFailure('Failed to delete preference: $e');
    }
  }

  /// Watches a preference value for reactive updates.
  Stream<String?> watchPreference(String key) {
    try {
      return (select(appPreferences)..where((t) => t.key.equals(key)))
          .watchSingleOrNull()
          .map((pref) => pref?.value);
    } catch (e) {
      throw StorageFailure('Failed to watch preference: $e');
    }
  }

  /// Retrieves all stored preferences as a map.
  Future<Map<String, String>> getAllPreferences() async {
    try {
      final results = await select(appPreferences).get();
      return {for (final pref in results) pref.key: pref.value};
    } catch (e) {
      throw StorageFailure('Failed to get all preferences: $e');
    }
  }

  /// Clears all stored preferences.
  Future<int> clearAll() {
    try {
      return delete(appPreferences).go();
    } catch (e) {
      throw StorageFailure('Failed to clear all preferences: $e');
    }
  }
}
