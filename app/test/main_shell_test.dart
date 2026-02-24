import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/widgets/common/main_shell.dart';

void main() {
  /// Wraps the MainShell in the providers, GoRouter, i18n, and MaterialApp
  /// needed for widget testing.
  Widget buildTestableShell({Widget? child}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) =>
                  child ?? const Center(child: Text('Test Content')),
            ),
            GoRoute(
              path: '/activities',
              builder: (context, state) =>
                  const Center(child: Text('Activities')),
            ),
            GoRoute(
              path: '/calendar',
              builder: (context, state) =>
                  const Center(child: Text('Calendar')),
            ),
            GoRoute(
              path: '/messages',
              builder: (context, state) =>
                  const Center(child: Text('Messages')),
            ),
          ],
        ),
      ],
    );

    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('fr')],
        localizationsDelegates: const [AppLocalizations.delegate],
      ),
    );
  }

  group('MainShell bottom navigation bar', () {
    testWidgets('renders five bottom navigation bar items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableShell());
      await tester.pumpAndSettle();

      // Verify the BottomNavigationBar is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Verify all five tab labels
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Activities'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('renders the correct icons for each tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableShell());
      await tester.pumpAndSettle();

      // Dashboard tab has its active icon since it starts selected at index 0
      expect(find.byIcon(Icons.dashboard), findsOneWidget);

      // Other tabs show their inactive icon variants
      expect(find.byIcon(Icons.local_activity_outlined), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
      expect(find.byIcon(Icons.chat_outlined), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_outlined), findsOneWidget);
    });

    testWidgets('renders the child content inside the Scaffold body', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableShell(child: const Text('My Page Content')),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Page Content'), findsOneWidget);
    });

    testWidgets('renders the floating action button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableShell());
      await tester.pumpAndSettle();

      // The QuickActionFab contains a main FloatingActionButton with an add icon
      expect(find.byType(FloatingActionButton), findsWidgets);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping More tab opens a bottom sheet', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableShell());
      await tester.pumpAndSettle();

      // Tap the "More" tab (last item, index 4)
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      // The bottom sheet should contain module labels from the _MoreMenuSheet.
      // Only check items near the top of the grid that are visible in the
      // test viewport (the grid has 14 items in 4 columns).
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Finances'), findsOneWidget);
      expect(find.text('Cards'), findsOneWidget);
      expect(find.text('Vault'), findsOneWidget);
    });
  });
}
