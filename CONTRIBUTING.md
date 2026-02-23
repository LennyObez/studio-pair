# Contributing to Studio Pair

Thank you for your interest in contributing to Studio Pair! This document provides guidelines and conventions to keep the codebase consistent and the development process smooth.

## Table of Contents

- [Getting Started](#getting-started)
- [Branch Naming Conventions](#branch-naming-conventions)
- [Commit Message Format](#commit-message-format)
- [Pull Request Process](#pull-request-process)
- [Code Style](#code-style)
- [Testing Requirements](#testing-requirements)
- [Reporting Issues](#reporting-issues)

---

## Getting Started

1. Fork the repository (if external) or create a feature branch from `main`.
2. Set up your development environment by following the [README](README.md).
3. Make your changes in a focused, well-scoped branch.
4. Write or update tests as needed.
5. Open a pull request.

## Branch Naming Conventions

Use the following prefixes for branch names:

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feature/` | New feature or enhancement | `feature/shared-grocery-list` |
| `bugfix/` | Non-urgent bug fix | `bugfix/sync-conflict-resolution` |
| `hotfix/` | Urgent production fix | `hotfix/auth-token-expiry` |
| `chore/` | Maintenance, dependencies, CI | `chore/update-flutter-sdk` |
| `docs/` | Documentation-only changes | `docs/api-endpoint-reference` |
| `refactor/` | Code refactoring (no behavior change) | `refactor/extract-sync-engine` |
| `test/` | Adding or updating tests only | `test/drift-migration-tests` |

**Rules:**
- Use lowercase and hyphens (not underscores).
- Keep names concise but descriptive.
- Include a ticket number when applicable: `feature/SP-42-shared-grocery-list`.

## Commit Message Format

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

## Pull Request Process

1. **Create a focused PR**: Each PR should address a single concern (one feature, one bug fix, etc.).
2. **Fill out the PR template**: Provide a summary, list changes, and complete the checklist.
3. **Ensure CI passes**: All automated checks (tests, linting, formatting) must pass before review.
4. **Request review**: Tag at least one maintainer for review.
5. **Address feedback**: Respond to all review comments. Push fixes as additional commits (do not force-push during review).
6. **Squash on merge**: PRs are squash-merged into `main` to keep history clean.

### PR Checklist

- [ ] Code compiles without errors.
- [ ] All existing tests pass.
- [ ] New tests cover the changes.
- [ ] `dart analyze` reports no issues.
- [ ] `dart format` has been applied.
- [ ] Documentation has been updated (if applicable).

## Code Style

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

### General Conventions

- Prefer immutable data classes (use `freezed` or `const` constructors).
- Use `final` for local variables wherever possible.
- Keep functions small and focused.
- Name files using `snake_case`.
- Name classes using `PascalCase`.
- Name variables and functions using `camelCase`.

## Testing Requirements

All contributions must include appropriate test coverage:

| Package | Tool | Minimum Expectation |
|---------|------|---------------------|
| `shared` | `dart test` | Unit tests for all public API surfaces |
| `backend` | `dart test` | Unit tests for business logic; integration tests for API endpoints |
| `app` | `flutter test` | Widget tests for screens; unit tests for state management and repositories |
| `database` | Manual / script | Migration scripts tested against a clean database |

### Running Tests

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

## Reporting Issues

- Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) for bugs.
- Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md) for new ideas.
- Search existing issues before creating a new one.
- Provide as much context as possible (logs, screenshots, steps to reproduce).

---

Thank you for helping make Studio Pair better!
