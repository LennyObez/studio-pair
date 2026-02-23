import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/services/api/activities_api.dart';
import 'package:studio_pair/src/services/api/api_client.dart';
import 'package:studio_pair/src/services/api/auth_api.dart';
import 'package:studio_pair/src/services/api/calendar_api.dart';
import 'package:studio_pair/src/services/api/cards_api.dart';
import 'package:studio_pair/src/services/api/charter_api.dart';
import 'package:studio_pair/src/services/api/entitlements_api.dart';
import 'package:studio_pair/src/services/api/files_api.dart';
import 'package:studio_pair/src/services/api/finances_api.dart';
import 'package:studio_pair/src/services/api/grocery_api.dart';
import 'package:studio_pair/src/services/api/health_api.dart';
import 'package:studio_pair/src/services/api/location_api.dart';
import 'package:studio_pair/src/services/api/memories_api.dart';
import 'package:studio_pair/src/services/api/messaging_api.dart';
import 'package:studio_pair/src/services/api/notifications_api.dart';
import 'package:studio_pair/src/services/api/polls_api.dart';
import 'package:studio_pair/src/services/api/reminders_api.dart';
import 'package:studio_pair/src/services/api/spaces_api.dart';
import 'package:studio_pair/src/services/api/tasks_api.dart';
import 'package:studio_pair/src/services/api/vault_api.dart';
import 'package:studio_pair/src/services/app_services.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/database/daos/activities_dao.dart';
import 'package:studio_pair/src/services/database/daos/calendar_dao.dart';
import 'package:studio_pair/src/services/database/daos/cards_dao.dart';
import 'package:studio_pair/src/services/database/daos/charter_dao.dart';
import 'package:studio_pair/src/services/database/daos/files_dao.dart';
import 'package:studio_pair/src/services/database/daos/finances_dao.dart';
import 'package:studio_pair/src/services/database/daos/grocery_dao.dart';
import 'package:studio_pair/src/services/database/daos/memories_dao.dart';
import 'package:studio_pair/src/services/database/daos/messages_dao.dart';
import 'package:studio_pair/src/services/database/daos/notifications_dao.dart';
import 'package:studio_pair/src/services/database/daos/polls_dao.dart';
import 'package:studio_pair/src/services/database/daos/preferences_dao.dart';
import 'package:studio_pair/src/services/database/daos/reminders_dao.dart';
import 'package:studio_pair/src/services/database/daos/sync_queue_dao.dart';
import 'package:studio_pair/src/services/database/daos/tasks_dao.dart';
import 'package:studio_pair/src/services/encryption/encryption_service.dart';
import 'package:studio_pair/src/services/purchase/purchase_service.dart';
import 'package:studio_pair/src/services/storage/secure_storage_service.dart';
import 'package:studio_pair/src/services/sync/sync_queue.dart' as sq;
import 'package:studio_pair/src/services/sync/sync_service.dart';

import 'purchase_provider.dart';

// ── Core Services ────────────────────────────────────────────────────────

/// Secure storage service provider (singleton).
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// API client provider (singleton, depends on secure storage).
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage: secureStorage);
});

// ── API Service Providers ────────────────────────────────────────────────

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(apiClient: ref.watch(apiClientProvider));
});

final spacesApiProvider = Provider<SpacesApi>((ref) {
  return SpacesApi(apiClient: ref.watch(apiClientProvider));
});

final calendarApiProvider = Provider<CalendarApi>((ref) {
  return CalendarApi(apiClient: ref.watch(apiClientProvider));
});

final tasksApiProvider = Provider<TasksApi>((ref) {
  return TasksApi(apiClient: ref.watch(apiClientProvider));
});

final activitiesApiProvider = Provider<ActivitiesApi>((ref) {
  return ActivitiesApi(apiClient: ref.watch(apiClientProvider));
});

final groceryApiProvider = Provider<GroceryApi>((ref) {
  return GroceryApi(apiClient: ref.watch(apiClientProvider));
});

final remindersApiProvider = Provider<RemindersApi>((ref) {
  return RemindersApi(apiClient: ref.watch(apiClientProvider));
});

final locationApiProvider = Provider<LocationApi>((ref) {
  return LocationApi(apiClient: ref.watch(apiClientProvider));
});

final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  return NotificationsApi(apiClient: ref.watch(apiClientProvider));
});

final messagingApiProvider = Provider<MessagingApi>((ref) {
  return MessagingApi(apiClient: ref.watch(apiClientProvider));
});

final financesApiProvider = Provider<FinancesApi>((ref) {
  return FinancesApi(apiClient: ref.watch(apiClientProvider));
});

final cardsApiProvider = Provider<CardsApi>((ref) {
  return CardsApi(apiClient: ref.watch(apiClientProvider));
});

final vaultApiProvider = Provider<VaultApi>((ref) {
  return VaultApi(apiClient: ref.watch(apiClientProvider));
});

final filesApiProvider = Provider<FilesApi>((ref) {
  return FilesApi(apiClient: ref.watch(apiClientProvider));
});

final memoriesApiProvider = Provider<MemoriesApi>((ref) {
  return MemoriesApi(apiClient: ref.watch(apiClientProvider));
});

final charterApiProvider = Provider<CharterApi>((ref) {
  return CharterApi(apiClient: ref.watch(apiClientProvider));
});

final pollsApiProvider = Provider<PollsApi>((ref) {
  return PollsApi(apiClient: ref.watch(apiClientProvider));
});

final healthApiProvider = Provider<HealthApi>((ref) {
  return HealthApi(apiClient: ref.watch(apiClientProvider));
});

// ── Database & DAOs ──────────────────────────────────────────────────────

/// App database provider (singleton via AppServices).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppServices.database;
});

/// DAO providers (each uses the shared database instance).
final activitiesDaoProvider = Provider<ActivitiesDao>((ref) {
  return ActivitiesDao(ref.watch(appDatabaseProvider));
});

final calendarDaoProvider = Provider<CalendarDao>((ref) {
  return CalendarDao(ref.watch(appDatabaseProvider));
});

final groceryDaoProvider = Provider<GroceryDao>((ref) {
  return GroceryDao(ref.watch(appDatabaseProvider));
});

final messagesDaoProvider = Provider<MessagesDao>((ref) {
  return MessagesDao(ref.watch(appDatabaseProvider));
});

final preferencesDaoProvider = Provider<PreferencesDao>((ref) {
  return PreferencesDao(ref.watch(appDatabaseProvider));
});

final syncQueueDaoProvider = Provider<SyncQueueDao>((ref) {
  return SyncQueueDao(ref.watch(appDatabaseProvider));
});

final tasksDaoProvider = Provider<TasksDao>((ref) {
  return TasksDao(ref.watch(appDatabaseProvider));
});

final remindersDaoProvider = Provider<RemindersDao>((ref) {
  return RemindersDao(ref.watch(appDatabaseProvider));
});

final notificationsDaoProvider = Provider<NotificationsDao>((ref) {
  return NotificationsDao(ref.watch(appDatabaseProvider));
});

final financesDaoProvider = Provider<FinancesDao>((ref) {
  return FinancesDao(ref.watch(appDatabaseProvider));
});

final charterDaoProvider = Provider<CharterDao>((ref) {
  return CharterDao(ref.watch(appDatabaseProvider));
});

final pollsDaoProvider = Provider<PollsDao>((ref) {
  return PollsDao(ref.watch(appDatabaseProvider));
});

final cardsDaoProvider = Provider<CardsDao>((ref) {
  return CardsDao(ref.watch(appDatabaseProvider));
});

final filesDaoProvider = Provider<FilesDao>((ref) {
  return FilesDao(ref.watch(appDatabaseProvider));
});

final memoriesDaoProvider = Provider<MemoriesDao>((ref) {
  return MemoriesDao(ref.watch(appDatabaseProvider));
});

// ── Encryption ───────────────────────────────────────────────────────────

/// Encryption service provider (singleton via AppServices).
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return AppServices.encryptionService;
});

// ── Sync ─────────────────────────────────────────────────────────────────

/// Persistent sync queue backed by the SyncQueueDao.
final syncQueueProvider = Provider<sq.SyncQueue>((ref) {
  return sq.SyncQueue(dao: ref.watch(syncQueueDaoProvider));
});

/// Sync service that processes the offline queue.
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    apiClient: ref.watch(apiClientProvider),
    syncQueue: ref.watch(syncQueueProvider),
    connectivity: Connectivity(),
  );
  service.initialize();
  ref.onDispose(service.dispose);
  return service;
});

// ── Purchase & Entitlements ──────────────────────────────────────────────

/// Entitlements API provider.
final entitlementsApiProvider = Provider<EntitlementsApi>((ref) {
  return EntitlementsApi(apiClient: ref.watch(apiClientProvider));
});

/// Purchase service provider.
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService(entitlementsApi: ref.watch(entitlementsApiProvider));
});

/// Purchase state provider.
final purchaseProvider = StateNotifierProvider<PurchaseNotifier, PurchaseState>(
  (ref) {
    return PurchaseNotifier(
      entitlementsApi: ref.watch(entitlementsApiProvider),
      purchaseService: ref.watch(purchaseServiceProvider),
    );
  },
);

// ── Error Extraction Helper ──────────────────────────────────────────────

/// Extract a user-friendly error message from an exception.
///
/// Works with [DioException] (extracts [ApiError.message]) and falls back
/// to [Exception.toString] for other types.
String extractErrorMessage(Object error) {
  if (error is Exception) {
    final msg = error.toString();
    // DioException wraps ApiError in its message field
    if (msg.contains('ApiError')) {
      final match = RegExp(r'ApiError\(\w+\): (.+)').firstMatch(msg);
      if (match != null) return match.group(1)!;
    }
    // Strip "Exception: " prefix if present
    if (msg.startsWith('Exception: ')) {
      return msg.substring(11);
    }
    return msg;
  }
  return error.toString();
}

// ── Response Parsing Helper ─────────────────────────────────────────────

/// Parse a response that may be a List directly or a Map with a 'data' key.
///
/// Shared across all providers to avoid duplication.
List<Map<String, dynamic>> parseList(dynamic data) {
  if (data is List) return data.cast<Map<String, dynamic>>();
  if (data is Map && data.containsKey('data')) {
    return (data['data'] as List).cast<Map<String, dynamic>>();
  }
  return [];
}
