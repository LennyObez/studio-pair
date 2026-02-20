# Studio Pair mobile app

The Flutter mobile client for Studio Pair. This is the user-facing application that provides offline-first access to all shared life-management features.

## Requirements

- Flutter 3.29+ (stable channel)
- Dart 3.8+
- A running backend instance (see `../backend/`) or offline mode for local-only use

## Getting started

```bash
# Install dependencies
flutter pub get

# Generate code (Drift tables, Freezed models)
dart run build_runner build --delete-conflicting-outputs

# Run on a connected device or emulator
flutter run
```

## Key dependencies

| Package | Purpose |
|---------|---------|
| flutter_riverpod | State management (AsyncNotifier) |
| go_router | Declarative navigation |
| drift | Local SQLite database (offline-first) |
| dio | HTTP client for backend API |
| flutter_secure_storage | Encrypted token and key storage |
| firebase_messaging | Push notifications |
| web_socket_channel | Real-time sync |

## Feature structure

The app is organized by feature under `lib/src/screens/`:

```
activities/    calendar/     cards/       charter/
dashboard/     files/        finances/    grocery/
health/        location/     memories/    messaging/
onboarding/    polls/        profile/     reminders/
settings/      tasks/        vault/       auth/
```

Each feature typically contains a screen widget, a Riverpod provider, and a repository that reads from the local Drift database and syncs with the backend.

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run a specific test file
flutter test test/src/some_test.dart
```

Tests use `ProviderScope` overrides for dependency injection and `GoRouter` test helpers for navigation.
