import 'package:dio/dio.dart';
import 'package:studio_pair/src/services/api/api_client.dart';

/// Auth API service for authentication-related endpoints.
class AuthApi {
  AuthApi({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// Register a new user account.
  Future<Response> register({
    required String displayName,
    required String email,
    required String password,
  }) {
    return _client.post(
      '/auth/register',
      data: {'displayName': displayName, 'email': email, 'password': password},
    );
  }

  /// Log in with email and password.
  Future<Response> login({required String email, required String password}) {
    return _client.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
  }

  /// Refresh the access token using a refresh token.
  Future<Response> refreshToken({required String refreshToken}) {
    return _client.post('/auth/refresh', data: {'refreshToken': refreshToken});
  }

  /// Log out the current user.
  Future<Response> logout() {
    return _client.post('/auth/logout');
  }

  /// Request a password reset email.
  Future<Response> forgotPassword({required String email}) {
    return _client.post('/auth/forgot-password', data: {'email': email});
  }

  /// Reset password with a token.
  Future<Response> resetPassword({
    required String token,
    required String newPassword,
  }) {
    return _client.post(
      '/auth/reset-password',
      data: {'token': token, 'newPassword': newPassword},
    );
  }

  /// Begin 2FA setup.
  Future<Response> setup2FA() {
    return _client.post('/auth/2fa/setup');
  }

  /// Verify a 2FA code.
  Future<Response> verify2FA({required String code}) {
    return _client.post('/auth/2fa/verify', data: {'code': code});
  }

  /// Change the current user's password.
  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _client.post(
      '/auth/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  /// Delete the current user's account.
  Future<Response> deleteAccount({required String password}) {
    return _client.post('/auth/delete-account', data: {'password': password});
  }

  /// Get current user profile.
  Future<Response> getProfile() {
    return _client.get('/auth/me');
  }

  /// Update current user profile.
  Future<Response> updateProfile({String? displayName, String? avatarUrl}) {
    return _client.patch(
      '/auth/me',
      data: {
        if (displayName != null) 'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
    );
  }
}
