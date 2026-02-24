import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/auth_api.dart';
import 'package:studio_pair/src/services/storage/secure_storage_service.dart';

/// User model for authentication state.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: (json['display_name'] ?? json['displayName']) as String,
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl']) as String?,
    );
  }

  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;

  AppUser copyWith({
    String? displayName,
    String? avatarUrl,
    bool clearAvatarUrl = false,
  }) {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
    );
  }
}

/// Auth notifier managing login, logout, and registration.
class AuthNotifier extends AsyncNotifier<AppUser?> {
  AuthApi get _api => ref.read(authApiProvider);
  SecureStorageService get _storage => ref.read(secureStorageProvider);

  @override
  Future<AppUser?> build() async {
    final api = ref.watch(authApiProvider);
    final storage = ref.watch(secureStorageProvider);

    // Check for existing session
    final hasTokens = await storage.hasTokens();
    if (!hasTokens) return null;

    try {
      final response = await api.getProfile();
      final userData = response.data as Map<String, dynamic>;
      return AppUser.fromJson(userData);
    } catch (_) {
      await storage.clearAll();
      return null;
    }
  }

  /// Login with email and password.
  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _api.login(email: email, password: password);
      final data = response.data as Map<String, dynamic>;

      final accessToken =
          data['accessToken'] as String? ?? data['access_token'] as String;
      final refreshToken =
          data['refreshToken'] as String? ?? data['refresh_token'] as String;
      final userData = data['user'] as Map<String, dynamic>;

      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      final user = AppUser.fromJson(userData);
      await _storage.saveUserId(user.id);
      return user;
    });

    return !state.hasError;
  }

  /// Register a new account.
  Future<bool> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _api.register(
        displayName: displayName,
        email: email,
        password: password,
      );
      final data = response.data as Map<String, dynamic>;

      final accessToken =
          data['accessToken'] as String? ?? data['access_token'] as String;
      final refreshToken =
          data['refreshToken'] as String? ?? data['refresh_token'] as String;
      final userData = data['user'] as Map<String, dynamic>;

      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      final user = AppUser.fromJson(userData);
      await _storage.saveUserId(user.id);
      return user;
    });

    return !state.hasError;
  }

  /// Logout the current user.
  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      await _storage.clearAll();
      state = const AsyncData(null);
    }
  }

  /// Update user profile.
  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    final currentUser = state.valueOrNull;
    if (currentUser == null) return;

    state = await AsyncValue.guard(() async {
      final response = await _api.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      final userData = response.data as Map<String, dynamic>;
      return AppUser.fromJson(userData);
    });
  }

  /// Request a password reset email.
  /// Always returns true to prevent email enumeration.
  Future<bool> forgotPassword({required String email}) async {
    final previousState = state;
    state = const AsyncLoading();

    try {
      await _api.forgotPassword(email: email);
    } catch (_) {
      // Don't expose errors to prevent email enumeration
    }

    state = previousState;
    return true;
  }

  /// Change the current user's password.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final currentUser = state.valueOrNull;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _api.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return currentUser;
    });

    return !state.hasError;
  }

  /// Delete the current user's account.
  Future<bool> deleteAccount({required String password}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _api.deleteAccount(password: password);
      await _storage.clearAll();
      return null;
    });

    return !state.hasError;
  }

  /// Dev-only: bypass API and log in with a dummy user.
  void devLogin() {
    assert(() {
      state = const AsyncData(
        AppUser(
          id: 'dev-user-00000000-0000-0000-0000-000000000001',
          email: 'dev@studiopair.test',
          displayName: 'Dev User',
        ),
      );
      return true;
    }());
  }
}

/// Auth state provider.
final authProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(
  AuthNotifier.new,
);

/// Convenience provider for the current user.
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authProvider).valueOrNull;
});

/// Convenience provider for authentication status.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull != null;
});
