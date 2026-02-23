import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_pair/src/widgets/common/main_shell.dart';

void main() {
  /// Wraps the MainShell in the providers and MaterialApp needed
  /// for widget testing.
  Widget buildTestableShell({Widget? child}) {
    return ProviderScope(
      child: MaterialApp(
        home: MainShell(
          child: child ?? const Center(child: Text('Test Content')),
        ),
      ),
    );
  }

  group('MainShell bottom navigation bar', () {
    testWidgets('renders five bottom navigation bar items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableShell());

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

      expect(find.text('My Page Content'), findsOneWidget);
    });

    testWidgets('renders the floating action button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableShell());

      // The QuickActionFab contains a main FloatingActionButton with an add icon
      expect(find.byType(FloatingActionButton), findsWidgets);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping More tab opens a bottom sheet', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableShell());

      // Tap the "More" tab (last item, index 4)
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      // The bottom sheet should contain module labels from the _MoreMenuSheet
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Finances'), findsOneWidget);
      expect(find.text('Vault'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
