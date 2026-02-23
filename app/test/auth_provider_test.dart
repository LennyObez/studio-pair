import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:studio_pair/src/providers/auth_provider.dart';
import 'package:studio_pair/src/services/api/auth_api.dart';
import 'package:studio_pair/src/services/storage/secure_storage_service.dart';

@GenerateNiceMocks([MockSpec<AuthApi>(), MockSpec<SecureStorageService>()])
import 'auth_provider_test.mocks.dart';

void main() {
  late MockAuthApi mockApi;
  late MockSecureStorageService mockStorage;
  late AuthNotifier notifier;

  setUp(() {
    mockApi = MockAuthApi();
    mockStorage = MockSecureStorageService();
    notifier = AuthNotifier(mockApi, mockStorage);
  });

  tearDown(() {
    notifier.dispose();
  });

  Response makeResponse(Map<String, dynamic> data, {int statusCode = 200}) {
    return Response(
      data: data,
      statusCode: statusCode,
      requestOptions: RequestOptions(),
    );
  }

  final testUserJson = {
    'id': 'user-123',
    'email': 'test@example.com',
    'display_name': 'Test User',
    'avatar_url': null,
  };

  final authResponseData = {
    'access_token': 'test-access-token',
    'refresh_token': 'test-refresh-token',
    'user': testUserJson,
  };

  group('login', () {
    test('sets isLoading to true then false on success', () async {
      when(
        mockApi.login(email: anyNamed('email'), password: anyNamed('password')),
      ).thenAnswer((_) async => makeResponse(authResponseData));
      when(
        mockStorage.saveTokens(
          accessToken: anyNamed('accessToken'),
          refreshToken: anyNamed('refreshToken'),
        ),
      ).thenAnswer((_) async {});
      when(mockStorage.saveUserId(any)).thenAnswer((_) async {});

      final result = await notifier.login(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user!.email, equals('test@example.com'));
      expect(notifier.state.user!.displayName, equals('Test User'));
      expect(notifier.state.error, isNull);
    });

    test('stores tokens and user id in secure storage on success', () async {
      when(
        mockApi.login(email: anyNamed('email'), password: anyNamed('password')),
      ).thenAnswer((_) async => makeResponse(authResponseData));
      when(
        mockStorage.saveTokens(
          accessToken: anyNamed('accessToken'),
          refreshToken: anyNamed('refreshToken'),
        ),
      ).thenAnswer((_) async {});
      when(mockStorage.saveUserId(any)).thenAnswer((_) async {});

      await notifier.login(email: 'test@example.com', password: 'password123');

      verify(
        mockStorage.saveTokens(
          accessToken: 'test-access-token',
          refreshToken: 'test-refresh-token',
        ),
      ).called(1);
      verify(mockStorage.saveUserId('user-123')).called(1);
    });

    test('returns false and sets error on API failure', () async {
      when(
        mockApi.login(email: anyNamed('email'), password: anyNamed('password')),
      ).thenThrow(Exception('Invalid credentials'));

      final result = await notifier.login(
        email: 'bad@example.com',
        password: 'wrong',
      );

      expect(result, isFalse);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.error, isNotNull);
      expect(notifier.state.error, contains('Invalid credentials'));
    });

    test('clears previous error before attempting login', () async {
      // First login fails to set an error
      when(
        mockApi.login(email: anyNamed('email'), password: anyNamed('password')),
      ).thenThrow(Exception('First failure'));
      await notifier.login(email: 'test@example.com', password: 'wrong');
      expect(notifier.state.error, isNotNull);

      // Second login succeeds; error should be cleared
      when(
        mockApi.login(email: anyNamed('email'), password: anyNamed('password')),
      ).thenAnswer((_) async => makeResponse(authResponseData));
      when(
        mockStorage.saveTokens(
          accessToken: anyNamed('accessToken'),
          refreshToken: anyNamed('refreshToken'),
        ),
      ).thenAnswer((_) async {});
      when(mockStorage.saveUserId(any)).thenAnswer((_) async {});

      await notifier.login(email: 'test@example.com', password: 'password123');
      expect(notifier.state.error, isNull);
    });
  });

  group('register', () {
    test('creates account and sets user state on success', () async {
      when(
        mockApi.register(
          displayName: anyNamed('displayName'),
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => makeResponse(authResponseData));
      when(
        mockStorage.saveTokens(
          accessToken: anyNamed('accessToken'),
          refreshToken: anyNamed('refreshToken'),
        ),
      ).thenAnswer((_) async {});
      when(mockStorage.saveUserId(any)).thenAnswer((_) async {});

      final result = await notifier.register(
        displayName: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user!.id, equals('user-123'));
      expect(notifier.state.user!.displayName, equals('Test User'));
    });

    test('returns false and sets error on registration failure', () async {
      when(
        mockApi.register(
          displayName: anyNamed('displayName'),
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(Exception('Email already in use'));

      final result = await notifier.register(
        displayName: 'Test User',
        email: 'existing@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, contains('Email already in use'));
    });
  });

  group('logout', () {
    test('clears user state and storage on logout', () async {
      // Set up authenticated state first
      when(
        mockApi.login(email: anyNamed('email'), password: anyNamed('password')),
      ).thenAnswer((_) async => makeResponse(authResponseData));
      when(
        mockStorage.saveTokens(
          accessToken: anyNamed('accessToken'),
          refreshToken: anyNamed('refreshToken'),
        ),
      ).thenAnswer((_) async {});
      when(mockStorage.saveUserId(any)).thenAnswer((_) async {});
      await notifier.login(email: 'test@example.com', password: 'password123');
      expect(notifier.state.isAuthenticated, isTrue);

      // Now logout
      when(mockApi.logout()).thenAnswer((_) async => makeResponse({}));
      when(mockStorage.clearAll()).thenAnswer((_) async {});

      await notifier.logout();

      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.user, isNull);
      expect(notifier.state.isLoading, isFalse);
      verify(mockStorage.clearAll()).called(1);
    });

    test('clears storage even if API logout fails', () async {
      when(mockApi.logout()).thenThrow(Exception('Network error'));
      when(mockStorage.clearAll()).thenAnswer((_) async {});

      await notifier.logout();

      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.user, isNull);
      verify(mockStorage.clearAll()).called(1);
    });
  });

  group('checkSession', () {
    test('restores session when valid tokens exist', () async {
      when(mockStorage.hasTokens()).thenAnswer((_) async => true);
      when(
        mockApi.getProfile(),
      ).thenAnswer((_) async => makeResponse(testUserJson));

      final result = await notifier.checkSession();

      expect(result, isTrue);
      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user!.email, equals('test@example.com'));
    });

    test('returns false when no tokens stored', () async {
      when(mockStorage.hasTokens()).thenAnswer((_) async => false);

      final result = await notifier.checkSession();

      expect(result, isFalse);
      expect(notifier.state.isAuthenticated, isFalse);
      verifyNever(mockApi.getProfile());
    });

    test('clears storage and returns false when session is invalid', () async {
      when(mockStorage.hasTokens()).thenAnswer((_) async => true);
      when(mockApi.getProfile()).thenThrow(Exception('Token expired'));
      when(mockStorage.clearAll()).thenAnswer((_) async {});

      final result = await notifier.checkSession();

      expect(result, isFalse);
      expect(notifier.state.isAuthenticated, isFalse);
      verify(mockStorage.clearAll()).called(1);
    });
  });

  group('clearError', () {
    test('clears error state without affecting other fields', () async {
      // Create an error state
      when(
        mockApi.login(email: anyNamed('email'), password: anyNamed('password')),
      ).thenThrow(Exception('Some error'));
      await notifier.login(email: 'test@example.com', password: 'wrong');
      expect(notifier.state.error, isNotNull);

      notifier.clearError();

      expect(notifier.state.error, isNull);
      expect(notifier.state.isLoading, isFalse);
    });
  });
}
