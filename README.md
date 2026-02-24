# Studio Pair

**A collaborative life-management app for small groups.**

Studio Pair helps couples, roommates, families, and small teams coordinate the daily logistics of shared life -- from grocery lists and chore schedules to budgets, calendars, and goal tracking -- all in one private, offline-capable app.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | Flutter (Dart) |
| Backend API | Dart with Pulsar Framework |
| Database | PostgreSQL (server), SQLite via Drift (client) |
| Shared Logic | Pure Dart package (`/shared`) |

## Project Structure

```
studio-pair/
├── app/              # Flutter mobile application
├── backend/          # Dart backend API (Pulsar Framework)
├── shared/           # Shared Dart package (models, DTOs, utilities)
├── database/         # PostgreSQL migration scripts
├── .github/          # GitHub templates, CI/CD, and config
├── CHANGELOG.md      # Release history
├── CONTRIBUTING.md   # Contribution guidelines
├── CODE_OF_CONDUCT.md
├── SECURITY.md       # Security policy and reporting
└── LICENSE           # Proprietary license
```

## Prerequisites

Before you begin, make sure you have the following installed:

- **Flutter SDK** (stable channel, >= 3.x)
- **Dart SDK** (>= 3.x, bundled with Flutter)
- **PostgreSQL** (>= 15)
- **Git**

Verify your setup:

```bash
flutter doctor
dart --version
psql --version
```

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/LennyObez/studio-pair.git
cd studio-pair
```

### 2. Install Dependencies

```bash
# Shared package
cd shared
dart pub get

# Backend
cd ../backend
dart pub get

# Mobile app
cd ../app
flutter pub get
```

### 3. Database Setup

Create a PostgreSQL database and apply migrations:

```bash
createdb studio_pair_dev
cd database
# Apply migrations in order
psql -d studio_pair_dev -f migrations/001_initial.sql
```

Copy the environment template and configure your database connection:

```bash
cd ../backend
cp .env.example .env
# Edit .env with your database credentials
```

### 4. Run the Backend

```bash
cd backend
dart run bin/server.dart
```

The API server will start on `http://localhost:8080` by default.

### 5. Run the Mobile App

```bash
cd app
flutter run
```

## Development

### Backend Development

```bash
cd backend
# Run with hot-reload
dart run --enable-vm-service bin/server.dart

# Run tests
dart test

# Generate code (if applicable)
dart run build_runner build --delete-conflicting-outputs
```

### App Development

```bash
cd app
# Run on a connected device or emulator
flutter run

# Run tests
flutter test

# Generate code (Drift, Freezed, etc.)
dart run build_runner build --delete-conflicting-outputs
```

### Shared Package

```bash
cd shared
# Run tests
dart test

# Analyze
dart analyze
```

## Architecture Overview

Studio Pair follows an **offline-first** architecture:

- **Local-first data**: The mobile app stores all data locally using SQLite (via Drift). Users can read and write data without network connectivity.
- **Background sync**: When online, the app syncs with the backend API. Conflict resolution uses a last-write-wins strategy with logical timestamps.
- **Two-tier encryption**: Sensitive data is encrypted both in transit (TLS) and at rest. Group-level encryption keys ensure that data is only readable by group members.
- **Shared package**: Core models, validation logic, and DTOs live in the `/shared` package, ensuring consistency between client and server.

### Data Flow

```
Flutter App  <-->  Local SQLite (Drift)
                        |
                   Sync Engine
                        |
                   Dart Backend (Pulsar)  <-->  PostgreSQL
```

## Testing

```bash
# Run all tests across the monorepo
cd shared && dart test && cd ..
cd backend && dart test && cd ..
cd app && flutter test && cd ..
```

## License

This project is **proprietary and confidential**. All rights reserved. See [LICENSE](LICENSE) for details.
