import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:studio_pair/src/providers/auth_provider.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/auth_api.dart';
import 'package:studio_pair/src/services/storage/secure_storage_service.dart';

@GenerateNiceMocks([MockSpec<AuthApi>(), MockSpec<SecureStorageService>()])
import 'auth_provider_test.mocks.dart';

void main() {
  late MockAuthApi mockApi;
  late MockSecureStorageService mockStorage;
  late ProviderContainer container;

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

  /// Creates a [ProviderContainer] with mocked [authApiProvider] and
  /// [secureStorageProvider].  The [build] callback controls what happens
  /// during the initial session-restore that [AuthNotifier.build] performs.
  ///
  /// By default, [mockStorage.hasTokens()] returns `false` (unauthenticated).
  ProviderContainer createContainer() {
    final c = ProviderContainer(
      overrides: [
        authApiProvider.overrideWithValue(mockApi),
        secureStorageProvider.overrideWithValue(mockStorage),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  /// Waits for the [authProvider] to finish its initial [build] call.
  Future<void> waitForBuild(ProviderContainer c) async {
    // Read the provider to trigger build(), then pump the event loop
    // until the future completes.
    await c.read(authProvider.future);
  }

  setUp(() {
    mockApi = MockAuthApi();
    mockStorage = MockSecureStorageService();

    // Default: no stored tokens (unauthenticated start).
    when(mockStorage.hasTokens()).thenAnswer((_) async => false);
  });

  // ── Session restore (build) ─────────────────────────────────────────────

  group('build (session restore)', () {
    test('resolves to null when no tokens are stored', () async {
      container = createContainer();
      await waitForBuild(container);

      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);
      expect(state.valueOrNull, isNull);
      expect(container.read(isAuthenticatedProvider), isFalse);
      verifyNever(mockApi.getProfile());
    });

    test('restores user when valid tokens exist', () async {
      when(mockStorage.hasTokens()).thenAnswer((_) async => true);
      when(
        mockApi.getProfile(),
      ).thenAnswer((_) async => makeResponse(testUserJson));

      container = createContainer();
      await waitForBuild(container);

      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);
      expect(state.valueOrNull, isNotNull);
      expect(state.valueOrNull!.email, equals('test@example.com'));
      expect(state.valueOrNull!.displayName, equals('Test User'));
      expect(container.read(isAuthenticatedProvider), isTrue);
      expect(container.read(currentUserProvider)?.id, equals('user-123'));
    });

    test(
      'clears storage and resolves to null when profile fetch fails',
      () async {
        when(mockStorage.hasTokens()).thenAnswer((_) async => true);
        when(mockApi.getProfile()).thenThrow(Exception('Token expired'));
        when(mockStorage.clearAll()).thenAnswer((_) async {});

        container = createContainer();
        await waitForBuild(container);

        final state = container.read(authProvider);
        expect(state.hasValue, isTrue);
        expect(state.valueOrNull, isNull);
        expect(container.read(isAuthenticatedProvider), isFalse);
        verify(mockStorage.clearAll()).called(1);
      },
    );
  });

  // ── Login ───────────────────────────────────────────────────────────────

  group('login', () {
    test('returns true and sets user on success', () async {
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

      container = createContainer();
      await waitForBuild(container);

      final result = await container
          .read(authProvider.notifier)
          .login(email: 'test@example.com', password: 'password123');

      expect(result, isTrue);

      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);
      expect(state.hasError, isFalse);
      expect(state.valueOrNull, isNotNull);
      expect(state.valueOrNull!.email, equals('test@example.com'));
      expect(state.valueOrNull!.displayName, equals('Test User'));
      expect(container.read(isAuthenticatedProvider), isTrue);
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

      container = createContainer();
      await waitForBuild(container);

      await container
          .read(authProvider.notifier)
          .login(email: 'test@example.com', password: 'password123');

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

      container = createContainer();
      await waitForBuild(container);

      final result = await container
          .read(authProvider.notifier)
          .login(email: 'bad@example.com', password: 'wrong');

      expect(result, isFalse);

      final state = container.read(authProvider);
      expect(state.hasError, isTrue);
      expect(state.valueOrNull, isNull);
      expect(container.read(isAuthenticatedProvider), isFalse);
    });

    test('clears previous error on successful login', () async {
      // First login fails to produce an error state.
      when(
        mockApi.login(email: anyNamed('email'), password: anyNamed('password')),
      ).thenThrow(Exception('First failure'));

      container = createContainer();
      await waitForBuild(container);

      await container
          .read(authProvider.notifier)
          .login(email: 'test@example.com', password: 'wrong');
      expect(container.read(authProvider).hasError, isTrue);

      // Second login succeeds; error should be replaced with data.
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

      final result = await container
          .read(authProvider.notifier)
          .login(email: 'test@example.com', password: 'password123');

      expect(result, isTrue);
      expect(container.read(authProvider).hasError, isFalse);
      expect(container.read(authProvider).hasValue, isTrue);
    });
  });

  // ── Register ────────────────────────────────────────────────────────────

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

      container = createContainer();
      await waitForBuild(container);

      final result = await container
          .read(authProvider.notifier)
          .register(
            displayName: 'Test User',
            email: 'test@example.com',
            password: 'password123',
          );

      expect(result, isTrue);

      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);
      expect(state.valueOrNull, isNotNull);
      expect(state.valueOrNull!.id, equals('user-123'));
      expect(state.valueOrNull!.displayName, equals('Test User'));
      expect(container.read(isAuthenticatedProvider), isTrue);
    });

    test('stores tokens and user id on successful registration', () async {
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

      container = createContainer();
      await waitForBuild(container);

      await container
          .read(authProvider.notifier)
          .register(
            displayName: 'Test User',
            email: 'test@example.com',
            password: 'password123',
          );

      verify(
        mockStorage.saveTokens(
          accessToken: 'test-access-token',
          refreshToken: 'test-refresh-token',
        ),
      ).called(1);
      verify(mockStorage.saveUserId('user-123')).called(1);
    });

    test('returns false and sets error on registration failure', () async {
      when(
        mockApi.register(
          displayName: anyNamed('displayName'),
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(Exception('Email already in use'));

      container = createContainer();
      await waitForBuild(container);

      final result = await container
          .read(authProvider.notifier)
          .register(
            displayName: 'Test User',
            email: 'existing@example.com',
            password: 'password123',
          );

      expect(result, isFalse);

      final state = container.read(authProvider);
      expect(state.hasError, isTrue);
      expect(container.read(isAuthenticatedProvider), isFalse);
    });
  });

  // ── Logout ──────────────────────────────────────────────────────────────

  group('logout', () {
    test('clears user state and storage on logout', () async {
      // Start authenticated via login.
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

      container = createContainer();
      await waitForBuild(container);

      await container
          .read(authProvider.notifier)
          .login(email: 'test@example.com', password: 'password123');
      expect(container.read(isAuthenticatedProvider), isTrue);

      // Now logout.
      when(mockApi.logout()).thenAnswer((_) async => makeResponse({}));
      when(mockStorage.clearAll()).thenAnswer((_) async {});

      await container.read(authProvider.notifier).logout();

      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);
      expect(state.valueOrNull, isNull);
      expect(container.read(isAuthenticatedProvider), isFalse);
      verify(mockStorage.clearAll()).called(1);
    });

    test('clears storage even if API logout fails', () async {
      container = createContainer();
      await waitForBuild(container);

      when(mockApi.logout()).thenThrow(Exception('Network error'));
      when(mockStorage.clearAll()).thenAnswer((_) async {});

      // logout() uses try/finally, so the exception propagates after cleanup.
      try {
        await container.read(authProvider.notifier).logout();
      } catch (_) {
        // Expected: the exception from _api.logout() propagates.
      }

      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);
      expect(state.valueOrNull, isNull);
      expect(container.read(isAuthenticatedProvider), isFalse);
      verify(mockStorage.clearAll()).called(1);
    });
  });

  // ── Update profile ─────────────────────────────────────────────────────

  group('updateProfile', () {
    test('updates user data on success', () async {
      // Start authenticated.
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

      container = createContainer();
      await waitForBuild(container);

      await container
          .read(authProvider.notifier)
          .login(email: 'test@example.com', password: 'password123');

      // Update profile.
      final updatedUserJson = {
        'id': 'user-123',
        'email': 'test@example.com',
        'display_name': 'Updated Name',
        'avatar_url': 'https://example.com/avatar.png',
      };
      when(
        mockApi.updateProfile(
          displayName: anyNamed('displayName'),
          avatarUrl: anyNamed('avatarUrl'),
        ),
      ).thenAnswer((_) async => makeResponse(updatedUserJson));

      await container
          .read(authProvider.notifier)
          .updateProfile(displayName: 'Updated Name');

      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);
      expect(state.valueOrNull!.displayName, equals('Updated Name'));
    });

    test('does nothing when not authenticated', () async {
      container = createContainer();
      await waitForBuild(container);

      await container
          .read(authProvider.notifier)
          .updateProfile(displayName: 'Nope');

      verifyNever(
        mockApi.updateProfile(
          displayName: anyNamed('displayName'),
          avatarUrl: anyNamed('avatarUrl'),
        ),
      );
    });
  });

  // ── Forgot password ────────────────────────────────────────────────────

  group('forgotPassword', () {
    test('always returns true to prevent email enumeration', () async {
      when(
        mockApi.forgotPassword(email: anyNamed('email')),
      ).thenAnswer((_) async => makeResponse({'message': 'sent'}));

      container = createContainer();
      await waitForBuild(container);

      final result = await container
          .read(authProvider.notifier)
          .forgotPassword(email: 'test@example.com');
      expect(result, isTrue);
    });

    test('returns true even when API throws', () async {
      when(
        mockApi.forgotPassword(email: anyNamed('email')),
      ).thenThrow(Exception('Server error'));

      container = createContainer();
      await waitForBuild(container);

      final result = await container
          .read(authProvider.notifier)
          .forgotPassword(email: 'nonexistent@example.com');
      expect(result, isTrue);

      // State should not have an error since forgotPassword suppresses it.
      final state = container.read(authProvider);
      expect(state.hasError, isFalse);
    });
  });

  // ── Change password ────────────────────────────────────────────────────

  group('changePassword', () {
    test('returns true on success and preserves user state', () async {
      // Start authenticated.
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

      container = createContainer();
      await waitForBuild(container);

      await container
          .read(authProvider.notifier)
          .login(email: 'test@example.com', password: 'password123');

      when(
        mockApi.changePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        ),
      ).thenAnswer((_) async => makeResponse({'message': 'changed'}));

      final result = await container
          .read(authProvider.notifier)
          .changePassword(
            currentPassword: 'password123',
            newPassword: 'newPassword456',
          );

      expect(result, isTrue);

      // User should still be authenticated.
      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);
      expect(state.valueOrNull, isNotNull);
      expect(container.read(isAuthenticatedProvider), isTrue);
    });

    test('returns false on failure', () async {
      // Start authenticated.
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

      container = createContainer();
      await waitForBuild(container);

      await container
          .read(authProvider.notifier)
          .login(email: 'test@example.com', password: 'password123');

      when(
        mockApi.changePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        ),
      ).thenThrow(Exception('Wrong current password'));

      final result = await container
          .read(authProvider.notifier)
          .changePassword(
            currentPassword: 'wrongPassword',
            newPassword: 'newPassword456',
          );

      expect(result, isFalse);
      expect(container.read(authProvider).hasError, isTrue);
    });
  });

  // ── Delete account ─────────────────────────────────────────────────────

  group('deleteAccount', () {
    test(
      'returns true, clears storage, and sets user to null on success',
      () async {
        // Start authenticated.
        when(
          mockApi.login(
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

        container = createContainer();
        await waitForBuild(container);

        await container
            .read(authProvider.notifier)
            .login(email: 'test@example.com', password: 'password123');
        expect(container.read(isAuthenticatedProvider), isTrue);

        when(
          mockApi.deleteAccount(password: anyNamed('password')),
        ).thenAnswer((_) async => makeResponse({'message': 'deleted'}));
        when(mockStorage.clearAll()).thenAnswer((_) async {});

        final result = await container
            .read(authProvider.notifier)
            .deleteAccount(password: 'password123');

        expect(result, isTrue);

        final state = container.read(authProvider);
        expect(state.hasValue, isTrue);
        expect(state.valueOrNull, isNull);
        expect(container.read(isAuthenticatedProvider), isFalse);
        verify(mockStorage.clearAll()).called(1);
      },
    );

    test('returns false on failure', () async {
      container = createContainer();
      await waitForBuild(container);

      when(
        mockApi.deleteAccount(password: anyNamed('password')),
      ).thenThrow(Exception('Wrong password'));

      final result = await container
          .read(authProvider.notifier)
          .deleteAccount(password: 'wrongPassword');

      expect(result, isFalse);
      expect(container.read(authProvider).hasError, isTrue);
    });
  });

  // ── Derived providers ──────────────────────────────────────────────────

  group('derived providers', () {
    test('currentUserProvider returns null when unauthenticated', () async {
      container = createContainer();
      await waitForBuild(container);

      expect(container.read(currentUserProvider), isNull);
    });

    test('currentUserProvider returns user when authenticated', () async {
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

      container = createContainer();
      await waitForBuild(container);

      await container
          .read(authProvider.notifier)
          .login(email: 'test@example.com', password: 'password123');

      final user = container.read(currentUserProvider);
      expect(user, isNotNull);
      expect(user!.email, equals('test@example.com'));
    });

    test('isAuthenticatedProvider reflects authentication state', () async {
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
      when(mockApi.logout()).thenAnswer((_) async => makeResponse({}));
      when(mockStorage.clearAll()).thenAnswer((_) async {});

      container = createContainer();
      await waitForBuild(container);

      // Initially unauthenticated.
      expect(container.read(isAuthenticatedProvider), isFalse);

      // After login.
      await container
          .read(authProvider.notifier)
          .login(email: 'test@example.com', password: 'password123');
      expect(container.read(isAuthenticatedProvider), isTrue);

      // After logout.
      await container.read(authProvider.notifier).logout();
      expect(container.read(isAuthenticatedProvider), isFalse);
    });
  });
}
