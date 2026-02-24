import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studio_pair/src/providers/auth_provider.dart';
import 'package:studio_pair/src/screens/activities/activities_screen.dart';
import 'package:studio_pair/src/screens/activities/activity_detail_screen.dart';
import 'package:studio_pair/src/screens/auth/forgot_password_screen.dart';
import 'package:studio_pair/src/screens/auth/login_screen.dart';
import 'package:studio_pair/src/screens/auth/register_screen.dart';
import 'package:studio_pair/src/screens/calendar/calendar_screen.dart';
import 'package:studio_pair/src/screens/cards/cards_screen.dart';
import 'package:studio_pair/src/screens/charter/charter_screen.dart';
import 'package:studio_pair/src/screens/dashboard/dashboard_screen.dart';
import 'package:studio_pair/src/screens/files/files_screen.dart';
import 'package:studio_pair/src/screens/finances/finances_screen.dart';
import 'package:studio_pair/src/screens/grocery/grocery_screen.dart';
import 'package:studio_pair/src/screens/health/health_screen.dart';
import 'package:studio_pair/src/screens/location/location_screen.dart';
import 'package:studio_pair/src/screens/memories/memories_screen.dart';
import 'package:studio_pair/src/screens/messaging/conversation_screen.dart';
import 'package:studio_pair/src/screens/messaging/messaging_screen.dart';
import 'package:studio_pair/src/screens/onboarding/onboarding_screen.dart';
import 'package:studio_pair/src/screens/polls/polls_screen.dart';
import 'package:studio_pair/src/screens/profile/profile_screen.dart';
import 'package:studio_pair/src/screens/reminders/reminders_screen.dart';
import 'package:studio_pair/src/screens/settings/premium_screen.dart';
import 'package:studio_pair/src/screens/settings/settings_screen.dart';
import 'package:studio_pair/src/screens/tasks/tasks_screen.dart';
import 'package:studio_pair/src/screens/vault/vault_screen.dart';
import 'package:studio_pair/src/widgets/common/main_shell.dart';

/// Routes that do not require authentication.
const _publicRoutes = {'/login', '/register', '/forgot-password'};

/// Listenable that notifies GoRouter when auth state changes,
/// without causing a full router rebuild.
class _AuthNotifierListenable extends ChangeNotifier {
  _AuthNotifierListenable(this._ref) {
    _ref.listen<AsyncValue<AppUser?>>(authProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
}

/// GoRouter configuration with all application routes.
///
/// Uses [refreshListenable] so auth state changes trigger a redirect
/// evaluation without recreating the entire router instance.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _AuthNotifierListenable(ref);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final isAuthenticated = ref.read(authProvider).valueOrNull != null;
      final currentPath = state.uri.path;
      final isPublicRoute = _publicRoutes.contains(currentPath);
      final isOnboarding = currentPath == '/onboarding';

      // Not authenticated → redirect to login (unless already on a public route)
      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      // Authenticated but on a public route (except onboarding) → go to dashboard
      if (isAuthenticated && isPublicRoute && !isOnboarding) {
        return '/';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app with bottom navigation shell
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Dashboard (home)
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Activities
          GoRoute(
            path: '/activities',
            builder: (context, state) => const ActivitiesScreen(),
          ),
          GoRoute(
            path: '/activities/:id',
            builder: (context, state) =>
                ActivityDetailScreen(id: state.pathParameters['id']!),
          ),

          // Calendar
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarScreen(),
          ),

          // Messaging
          GoRoute(
            path: '/messages',
            builder: (context, state) => const MessagingScreen(),
          ),
          GoRoute(
            path: '/messages/:id',
            builder: (context, state) =>
                ConversationScreen(id: state.pathParameters['id']!),
          ),

          // Tasks
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksScreen(),
          ),

          // Finances
          GoRoute(
            path: '/finances',
            builder: (context, state) => const FinancesScreen(),
          ),

          // Cards
          GoRoute(
            path: '/cards',
            builder: (context, state) => const CardsScreen(),
          ),

          // Vault
          GoRoute(
            path: '/vault',
            builder: (context, state) => const VaultScreen(),
          ),

          // Health
          GoRoute(
            path: '/health',
            builder: (context, state) => const HealthScreen(),
          ),

          // Reminders
          GoRoute(
            path: '/reminders',
            builder: (context, state) => const RemindersScreen(),
          ),

          // Files
          GoRoute(
            path: '/files',
            builder: (context, state) => const FilesScreen(),
          ),

          // Memories
          GoRoute(
            path: '/memories',
            builder: (context, state) => const MemoriesScreen(),
          ),

          // Charter
          GoRoute(
            path: '/charter',
            builder: (context, state) => const CharterScreen(),
          ),

          // Grocery
          GoRoute(
            path: '/grocery',
            builder: (context, state) => const GroceryScreen(),
          ),

          // Polls
          GoRoute(
            path: '/polls',
            builder: (context, state) => const PollsScreen(),
          ),

          // Location
          GoRoute(
            path: '/location',
            builder: (context, state) => const LocationScreen(),
          ),

          // Settings
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),

          // Premium / Subscription
          GoRoute(
            path: '/settings/premium',
            builder: (context, state) => const PremiumScreen(),
          ),

          // Profile
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade700),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
