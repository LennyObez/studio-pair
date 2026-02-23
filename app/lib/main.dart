import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studio_pair/src/app.dart';
import 'package:studio_pair/src/config/api_config.dart';
import 'package:studio_pair/src/providers/auth_provider.dart';
import 'package:studio_pair/src/services/app_services.dart';
import 'package:studio_pair/src/services/push/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (push notifications, analytics)
  // Fails gracefully if google-services.json / GoogleService-Info.plist
  // is not yet configured.
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e) {
    debugPrint('[Firebase] Initialization skipped: $e');
  }

  // Initialize core services (database, encryption)
  await AppServices.initialize();

  // Initialize push notification service if Firebase is available
  if (firebaseReady) {
    try {
      const storage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );
      final pushService = PushNotificationService(
        dio: Dio(
          BaseOptions(
            baseUrl: ApiConfig.effectiveBaseUrl,
            headers: ApiConfig.defaultHeaders,
          ),
        ),
        baseUrl: ApiConfig.effectiveBaseUrl,
        getAuthToken: () => storage.read(key: 'access_token'),
      );
      await pushService.initialize();
    } catch (e) {
      debugPrint('[Push] Initialization skipped: $e');
    }
  }

  final container = ProviderContainer();

  // Restore existing session from stored tokens (if any).
  try {
    await container.read(authProvider.notifier).checkSession();
  } catch (e) {
    debugPrint('[Auth] Session restore skipped: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const StudioPairApp(),
    ),
  );
}
