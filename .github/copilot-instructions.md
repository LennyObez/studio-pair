# Copilot review instructions for Studio Pair

## Project context

Studio Pair is a Dart/Flutter monorepo with four packages: `app/` (Flutter mobile), `backend/` (Dart Shelf API), `shared/` (models, enums, validators), and `database/` (PostgreSQL migrations). It targets small groups (couples, roommates, families) for collaborative life management.

## Architecture rules to enforce

### Shared package (`shared/`)
- Models MUST use `@freezed` (Freezed 3.x), not Equatable or manual classes.
- Errors MUST extend the `sealed class AppFailure` hierarchy — never throw raw strings or generic `Exception`.
- All public API must be exported from `shared/lib/studio_pair_shared.dart`.
- Changes here affect both `app/` and `backend/` — flag if tests in the other package might break.

### Backend (`backend/`)
- Every module follows Controller → Service → Repository layering.
- Password hashing MUST use Argon2id (not PBKDF2, bcrypt, or SHA-based). Check `password_utils.dart`.
- JWT tokens must have the TTLs defined in `ApiConstants` (15 min access, 30 day refresh).
- All endpoints must validate input. Flag unvalidated request body access.
- Rate limiting must be applied on auth endpoints.

### Flutter app (`app/`)
- State management: Riverpod v2 `AsyncNotifier` (not `StateNotifier`, not `ChangeNotifier`).
- Data access: Repository pattern — providers delegate to repositories, never call API or DAO directly.
- Database: Drift with batch upserts via `db.batch()` — flag individual INSERT loops.
- Screens must use `asyncValue.when(loading:, error:, data:)` — flag manual `isLoading`/`error` field checks.
- Navigation: GoRouter. No `Navigator.push` except in dialogs/modals.
- i18n: All user-visible strings must use `context.l10n.translate('key')`. Flag hardcoded English strings in widgets.
- Both `en.json` and `fr.json` must be updated together.

### Database (`database/`)
- Migrations are numbered sequentially (001-025). New migrations must continue the sequence.
- Never modify existing migration files — always create new ones.
- All tables must use UUID primary keys.
- Soft delete (deleted_at column) on most entities except health/location data (hard delete for privacy).

## Code style

- `dart format .` compliance is mandatory.
- `dart analyze` must pass with zero issues.
- File names: `snake_case`. Classes: `PascalCase`. Variables/functions: `camelCase`.
- Sentence case for all UI text (not Title Case).
- Conventional Commits: `<type>(<scope>): <subject>` — types: feat, fix, refactor, perf, test, chore, docs, ci.
- No `Co-Authored-By` trailers in commits.

## Security review checklist

- No hardcoded secrets, API keys, or credentials.
- Sensitive data (vault, health, finance) must be encrypted at rest.
- SQL queries must use parameterized queries — flag string interpolation in SQL.
- API endpoints must validate and sanitize all input.
- Auth tokens must not be logged or exposed in error messages.
- CORS, rate limiting, and auth middleware must be applied correctly.

## Testing requirements

- Backend tests: use `@GenerateNiceMocks` for Mockito (not manual `Mock` classes).
- App widget tests: must provide `GoRouter` + `MaterialApp.router` + `AppLocalizations.delegate`.
- Shared tests: unit tests for all public API surfaces.
- Flag PRs that add code without corresponding tests.

## Common issues to flag

- `extractErrorMessage()` usage — this was removed; use `AppFailure` pattern matching instead.
- `StateNotifier` in providers — should be `AsyncNotifier` (except theme, locale, websocket).
- Missing `ref.invalidate()` or `ref.invalidateSelf()` after mutations.
- `connectivity_plus` must use `List<ConnectivityResult>` API (v6+).
- Drift tables without indexes on foreign-key columns.
- `print()` or `debugPrint()` in production code — use `Logger` instead.
