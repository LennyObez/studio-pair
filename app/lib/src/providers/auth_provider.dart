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

/// Authentication state.
class AuthState {
  const AuthState({this.user, this.isLoading = false, this.error});

  final AppUser? user;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Auth state notifier managing login, logout, and registration.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._api, this._storage) : super(const AuthState());

  final AuthApi _api;
  final SecureStorageService _storage;

  /// Login with email and password.
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.login(email: email, password: password);
      final data = response.data as Map<String, dynamic>;

      final accessToken =
          data['accessToken'] as String? ?? data['access_token'] as String;
      final refreshToken =
          data['refreshToken'] as String? ?? data['refresh_token'] as String;
      final userData = data['user'] as Map<String, dynamic>;
      final user = AppUser.fromJson(userData);

      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await _storage.saveUserId(user.id);

      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Register a new account.
  Future<bool> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
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
      final user = AppUser.fromJson(userData);

      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await _storage.saveUserId(user.id);

      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Logout the current user.
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _api.logout();
    } finally {
      await _storage.clearAll();
      state = const AuthState();
    }
  }

  /// Update user profile.
  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    if (state.user == null) return;

    try {
      final response = await _api.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      final userData = response.data as Map<String, dynamic>;
      final updatedUser = AppUser.fromJson(userData);

      state = state.copyWith(user: updatedUser);
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
    }
  }

  /// Check if there is an existing session and restore it.
  Future<bool> checkSession() async {
    final hasTokens = await _storage.hasTokens();
    if (!hasTokens) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.getProfile();
      final userData = response.data as Map<String, dynamic>;
      final user = AppUser.fromJson(userData);

      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      await _storage.clearAll();
      state = state.copyWith(isLoading: false, clearUser: true);
      return false;
    }
  }

  /// Request a password reset email.
  /// Always returns true to prevent email enumeration.
  Future<bool> forgotPassword({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.forgotPassword(email: email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      // Don't expose errors to prevent email enumeration
      state = state.copyWith(isLoading: false);
      return true;
    }
  }

  /// Change the current user's password.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Delete the current user's account.
  Future<bool> deleteAccount({required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _api.deleteAccount(password: password);
      await _storage.clearAll();
      state = const AuthState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Dev-only: bypass API and log in with a dummy user.
  void devLogin() {
    assert(() {
      state = state.copyWith(
        user: const AppUser(
          id: 'dev-user-00000000-0000-0000-0000-000000000001',
          email: 'dev@studiopair.test',
          displayName: 'Dev User',
        ),
        isLoading: false,
        clearError: true,
      );
      return true;
    }());
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Auth state provider.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authApiProvider),
    ref.watch(secureStorageProvider),
  );
});

/// Convenience provider for the current user.
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authProvider).user;
});

/// Convenience provider for authentication status.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
