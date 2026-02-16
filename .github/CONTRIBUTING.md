# Contributing to Studio Pair

Thank you for your interest in contributing to Studio Pair! This document provides guidelines and conventions to keep the codebase consistent and the development process smooth.

## Table of contents

- [Getting started](#getting-started)
- [Branch naming conventions](#branch-naming-conventions)
- [Commit message format](#commit-message-format)
- [Pull request process](#pull-request-process)
- [Code style](#code-style)
- [Testing requirements](#testing-requirements)
- [Reporting issues](#reporting-issues)

---

## Getting started

1. Fork the repository (if external) or create a feature branch from `develop`.
2. Set up your development environment by following the [README](../README.md).
3. Make your changes in a focused, well-scoped branch.
4. Write or update tests as needed.
5. Open a pull request.

## Branch naming conventions

Use the following prefixes for branch names:

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feat/` | New feature or enhancement | `feat/shared-grocery-list` |
| `fix/` | Bug fix (urgent or non-urgent) | `fix/sync-conflict-resolution` |
| `chore/` | Maintenance, dependencies, CI | `chore/update-flutter-sdk` |
| `docs/` | Documentation-only changes | `docs/api-endpoint-reference` |
| `refactor/` | Code refactoring (no behavior change) | `refactor/extract-sync-engine` |
| `test/` | Adding or updating tests only | `test/drift-migration-tests` |

**Rules:**
- Use lowercase and hyphens (not underscores).
- Keep names concise but descriptive.
- Include a ticket number when applicable: `feat/SP-42-shared-grocery-list`.

## Commit message format

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Structure

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation changes only |
| `style` | Formatting, semicolons, etc. (no logic change) |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `chore` | Build process, dependencies, tooling |
| `ci` | CI/CD configuration changes |

### Scopes

Use the project component as the scope: `app`, `backend`, `shared`, `database`.

### Examples

```
feat(app): add offline grocery list with local persistence

fix(backend): resolve race condition in group invitation flow

chore(shared): upgrade freezed to 3.x and regenerate models

docs: update README with new prerequisites
```

### Rules

- Use the imperative mood in the subject line ("add" not "added" or "adds").
- Do not capitalize the first letter of the subject.
- Do not end the subject line with a period.
- Limit the subject line to 72 characters.
- Use the body to explain *what* and *why*, not *how*.

## Pull request process

1. **Create a focused PR**: Each PR should address a single concern (one feature, one bug fix, etc.).
2. **Fill out the PR template**: Provide a summary, list changes, and complete the checklist.
3. **Ensure CI passes**: All automated checks (tests, linting, formatting) must pass before review.
4. **Request review**: Tag at least one maintainer for review.
5. **Address feedback**: Respond to all review comments. Push fixes as additional commits (do not force-push during review).
6. **Squash on merge**: PRs are squash-merged into `main` to keep history clean.

### PR checklist

- [ ] Code compiles without errors.
- [ ] All existing tests pass.
- [ ] New tests cover the changes.
- [ ] `dart analyze` reports no issues.
- [ ] `dart format` has been applied.
- [ ] Documentation has been updated (if applicable).

## Code style

### Dart / Flutter

- Follow the official [Dart Style Guide](https://dart.dev/effective-dart/style).
- Run `dart format .` before committing to ensure consistent formatting.
- Run `dart analyze` and resolve all warnings and errors.
- Use `dart fix --apply` to auto-apply recommended fixes.

### Linting

Each package includes an `analysis_options.yaml` file. At minimum, we use:

- `flutter_lints` for the app package.
- `lints` (or `dart_lints`) for backend and shared packages.

Do not suppress lint rules without a justifying comment.

### General conventions

- Prefer immutable data classes (use `freezed` or `const` constructors).
- Use `final` for local variables wherever possible.
- Keep functions small and focused.
- Name files using `snake_case`.
- Name classes using `PascalCase`.
- Name variables and functions using `camelCase`.

## Testing requirements

All contributions must include appropriate test coverage:

| Package | Tool | Minimum expectation |
|---------|------|---------------------|
| `shared` | `dart test` | Unit tests for all public API surfaces |
| `backend` | `dart test` | Unit tests for business logic; integration tests for API endpoints |
| `app` | `flutter test` | Widget tests for screens; unit tests for state management and repositories |
| `database` | Manual / script | Migration scripts tested against a clean database |

### Running tests

```bash
# Shared
cd shared && dart test

# Backend
cd backend && dart test

# App
cd app && flutter test
```

### Coverage

Generate coverage reports locally:

```bash
cd app
flutter test --coverage
# View with lcov or a coverage tool of your choice
```

## Reporting issues

- Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) for bugs.
- Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md) for new ideas.
- Search existing issues before creating a new one.
- Provide as much context as possible (logs, screenshots, steps to reproduce).

---

Thank you for helping make Studio Pair better!
