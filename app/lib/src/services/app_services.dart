import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/services/encryption/encryption_service.dart';

/// Centralized service initialization for the app.
///
/// Initializes the Drift database, encryption service, and checks
/// for an existing authenticated session on app startup.
class AppServices {
  AppServices._();

  static AppDatabase? _database;
  static EncryptionService? _encryptionService;

  /// The shared Drift database instance.
  static AppDatabase get database {
    if (_database == null) {
      throw StateError('AppServices not initialized. Call initialize() first.');
    }
    return _database!;
  }

  /// The shared encryption service instance.
  static EncryptionService get encryptionService {
    if (_encryptionService == null) {
      throw StateError('AppServices not initialized. Call initialize() first.');
    }
    return _encryptionService!;
  }

  /// Initializes all core app services.
  ///
  /// Must be called before [runApp] in main.dart.
  static Future<void> initialize() async {
    // Initialize the local Drift/SQLite database
    _database = AppDatabase();

    // Initialize the encryption service for vault/private capsule
    _encryptionService = EncryptionService();
  }

  /// Disposes all services (for testing or shutdown).
  static Future<void> dispose() async {
    await _database?.close();
    _database = null;
    _encryptionService = null;
  }
}
