import 'package:studio_pair_shared/studio_pair_shared.dart';
import 'package:test/test.dart';

void main() {
  group('AppFailure', () {
    test('NetworkFailure is an AppFailure', () {
      const failure = NetworkFailure('no internet');
      expect(failure, isA<AppFailure>());
      expect(failure, isA<Exception>());
      expect(failure.message, 'no internet');
    });

    test('AuthFailure is an AppFailure', () {
      const failure = AuthFailure('invalid token');
      expect(failure, isA<AppFailure>());
      expect(failure.message, 'invalid token');
    });

    test('ServerFailure is an AppFailure', () {
      const failure = ServerFailure('internal error');
      expect(failure, isA<AppFailure>());
      expect(failure.message, 'internal error');
    });

    test('ValidationFailure is an AppFailure', () {
      const failure = ValidationFailure('invalid email');
      expect(failure, isA<AppFailure>());
      expect(failure.message, 'invalid email');
    });

    test('NotFoundFailure is an AppFailure', () {
      const failure = NotFoundFailure('user not found');
      expect(failure, isA<AppFailure>());
      expect(failure.message, 'user not found');
    });

    test('StorageFailure is an AppFailure', () {
      const failure = StorageFailure('disk full');
      expect(failure, isA<AppFailure>());
      expect(failure.message, 'disk full');
    });

    test('UnknownFailure is an AppFailure', () {
      const failure = UnknownFailure('something went wrong');
      expect(failure, isA<AppFailure>());
      expect(failure.message, 'something went wrong');
    });

    test('pattern matching works with switch', () {
      const AppFailure failure = AuthFailure('expired');
      final result = switch (failure) {
        NetworkFailure() => 'network',
        AuthFailure() => 'auth',
        ServerFailure() => 'server',
        ValidationFailure() => 'validation',
        NotFoundFailure() => 'not_found',
        StorageFailure() => 'storage',
        UnknownFailure() => 'unknown',
      };
      expect(result, 'auth');
    });

    test('toString includes type and message', () {
      const failure = NetworkFailure('timeout');
      expect(failure.toString(), 'NetworkFailure: timeout');
    });
  });
}
