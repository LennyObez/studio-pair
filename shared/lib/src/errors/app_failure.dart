/// Typed exception hierarchy for Studio Pair.
///
/// Use pattern matching on [AppFailure] subtypes to handle errors:
/// ```dart
/// try { ... } on AppFailure catch (e) {
///   switch (e) {
///     case NetworkFailure(): ...
///     case AuthFailure(): ...
///   }
/// }
/// ```
sealed class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Network is unreachable or the request timed out.
class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

/// Authentication or authorization error (401 / 403).
class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

/// Server returned a 5xx status code.
class ServerFailure extends AppFailure {
  const ServerFailure(super.message);
}

/// Input validation failed (400 / 422).
class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

/// Requested resource was not found (404).
class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message);
}

/// Local storage (Drift / SQLite) operation failed.
class StorageFailure extends AppFailure {
  const StorageFailure(super.message);
}

/// Catch-all for unexpected errors.
class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message);
}
