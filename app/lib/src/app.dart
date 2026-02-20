import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/config/router.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/auth_provider.dart';
import 'package:studio_pair/src/providers/locale_provider.dart';
import 'package:studio_pair/src/providers/theme_provider.dart';
import 'package:studio_pair/src/providers/websocket_provider.dart';
import 'package:studio_pair/src/theme/app_theme.dart';

class StudioPairApp extends ConsumerWidget {
  const StudioPairApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    // Activate WebSocket connection when authenticated.
    if (isAuthenticated) {
      ref.watch(webSocketConnectionProvider);
    }

    return MaterialApp.router(
      title: 'Studio Pair',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('nl'),
        Locale('de'),
      ],
    );
  }
}
