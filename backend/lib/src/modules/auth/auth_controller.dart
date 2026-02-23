import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'auth_service.dart';

/// Controller for authentication endpoints.
class AuthController {
  final AuthService _service;
  final Logger _log = Logger('AuthController');

  AuthController(this._service);

  /// Returns the router with all auth routes.
  Router get router {
    final router = Router();

    router.post('/register', _register);
    router.post('/login', _login);
    router.post('/refresh', _refreshToken);
    router.post('/logout', _logout);
    router.post('/forgot-password', _forgotPassword);
    router.post('/reset-password', _resetPassword);
    router.post('/2fa/setup', _setup2FA);
    router.post('/2fa/verify', _verify2FA);
    router.post('/2fa/disable', _disable2FA);
    router.get('/sessions', _listSessions);
    router.delete('/sessions/<sessionId>', _revokeSession);
    router.delete('/account', _deleteAccount);

    return router;
  }

  /// POST /api/v1/auth/register
  ///
  /// Creates a new user account.
  /// Body: { "email": "...", "password": "...", "display_name": "..." }
  Future<Response> _register(Request request) async {
    try {
      final body = await readJsonBody(request);

      final email = body['email'] as String?;
      final password = body['password'] as String?;
      final displayName = body['display_name'] as String?;

      if (email == null || password == null || displayName == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (email == null)
              {'field': 'email', 'message': 'Email is required'},
            if (password == null)
              {'field': 'password', 'message': 'Password is required'},
            if (displayName == null)
              {'field': 'display_name', 'message': 'Display name is required'},
          ],
        );
      }

      final result = await _service.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      return createdResponse(result);
    } on AuthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Registration error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/auth/login
  ///
  /// Authenticates a user with email and password.
  /// Body: { "email": "...", "password": "..." }
  Future<Response> _login(Request request) async {
    try {
      final body = await readJsonBody(request);

      final email = body['email'] as String?;
      final password = body['password'] as String?;

      if (email == null || password == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (email == null)
              {'field': 'email', 'message': 'Email is required'},
            if (password == null)
              {'field': 'password', 'message': 'Password is required'},
          ],
        );
      }

      final ipAddress =
          request.headers['x-forwarded-for']?.split(',').first.trim() ??
          request.headers['x-real-ip'];
      final userAgent = request.headers['user-agent'];

      final result = await _service.login(
        email: email,
        password: password,
        ipAddress: ipAddress,
        userAgent: userAgent,
      );

      return jsonResponse(result);
    } on AuthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Login error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/auth/refresh
  ///
  /// Refreshes an access token using a refresh token.
  /// Body: { "refresh_token": "..." }
  Future<Response> _refreshToken(Request request) async {
    try {
      final body = await readJsonBody(request);

      final refreshToken = body['refresh_token'] as String?;
      if (refreshToken == null || refreshToken.isEmpty) {
        return validationErrorResponse('Refresh token is required');
      }

      final result = await _service.refreshToken(refreshToken);

      return jsonResponse(result);
    } on AuthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Token refresh error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/auth/logout
  ///
  /// Logs out the current session.
  /// Body: { "refresh_token": "..." }
  Future<Response> _logout(Request request) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);

      final refreshToken = body['refresh_token'] as String?;
      if (refreshToken == null || refreshToken.isEmpty) {
        return validationErrorResponse('Refresh token is required');
      }

      await _service.logout(userId, refreshToken);

      return noContentResponse();
    } on AuthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Logout error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/auth/forgot-password
  ///
  /// Initiates password reset flow.
  /// Body: { "email": "..." }
  Future<Response> _forgotPassword(Request request) async {
    try {
      final body = await readJsonBody(request);

      final email = body['email'] as String?;
      if (email == null || email.isEmpty) {
        return validationErrorResponse('Email is required');
      }

      await _service.forgotPassword(email);

      // Always return success to prevent email enumeration
      return jsonResponse({
        'message':
            'If an account exists with this email, a password reset link has been sent.',
      });
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Forgot password error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/auth/reset-password
  ///
  /// Resets password using a valid reset token.
  /// Body: { "token": "...", "new_password": "..." }
  Future<Response> _resetPassword(Request request) async {
    try {
      final body = await readJsonBody(request);

      final token = body['token'] as String?;
      final newPassword = body['new_password'] as String?;

      if (token == null || newPassword == null) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            if (token == null)
              {'field': 'token', 'message': 'Reset token is required'},
            if (newPassword == null)
              {'field': 'new_password', 'message': 'New password is required'},
          ],
        );
      }

      await _service.resetPassword(token: token, newPassword: newPassword);

      return jsonResponse({
        'message': 'Password has been reset successfully. Please log in again.',
      });
    } on AuthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Reset password error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/auth/2fa/setup
  ///
  /// Sets up two-factor authentication for the current user.
  Future<Response> _setup2FA(Request request) async {
    try {
      final userId = getUserId(request);
      final result = await _service.setup2FA(userId);

      return jsonResponse(result);
    } on AuthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('2FA setup error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/auth/2fa/verify
  ///
  /// Verifies a 2FA code (for setup confirmation or login).
  /// Body: { "code": "123456", "is_setup": true/false }
  Future<Response> _verify2FA(Request request) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);

      final code = body['code'] as String?;
      if (code == null || code.isEmpty) {
        return validationErrorResponse('Verification code is required');
      }

      final isSetup = body['is_setup'] as bool? ?? false;

      final ipAddress =
          request.headers['x-forwarded-for']?.split(',').first.trim() ??
          request.headers['x-real-ip'];
      final userAgent = request.headers['user-agent'];

      final result = await _service.verify2FA(
        userId: userId,
        code: code,
        isSetup: isSetup,
        ipAddress: ipAddress,
        userAgent: userAgent,
      );

      return jsonResponse(result);
    } on AuthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('2FA verify error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/auth/2fa/disable
  ///
  /// Disables two-factor authentication.
  /// Body: { "password": "..." }
  Future<Response> _disable2FA(Request request) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);

      final password = body['password'] as String?;
      if (password == null || password.isEmpty) {
        return validationErrorResponse('Password is required to disable 2FA');
      }

      await _service.disable2FA(userId, password);

      return jsonResponse({
        'message': 'Two-factor authentication has been disabled.',
      });
    } on AuthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('2FA disable error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/auth/sessions
  ///
  /// Lists all active sessions for the current user.
  Future<Response> _listSessions(Request request) async {
    try {
      final userId = getUserId(request);
      final sessions = await _service.listSessions(userId);

      return jsonResponse({'data': sessions});
    } catch (e, stackTrace) {
      _log.severe('List sessions error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /api/v1/auth/sessions/<sessionId>
  ///
  /// Revokes a specific session.
  Future<Response> _revokeSession(Request request, String sessionId) async {
    try {
      final userId = getUserId(request);
      await _service.revokeSession(userId, sessionId);

      return noContentResponse();
    } on AuthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Revoke session error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /api/v1/auth/account
  ///
  /// Permanently deletes the user's account.
  /// Body: { "password": "..." }
  Future<Response> _deleteAccount(Request request) async {
    try {
      final userId = getUserId(request);
      final body = await readJsonBody(request);

      final password = body['password'] as String?;
      if (password == null || password.isEmpty) {
        return validationErrorResponse(
          'Password is required to delete account',
        );
      }

      await _service.deleteAccount(userId, password);

      return jsonResponse({'message': 'Account has been deleted.'});
    } on AuthException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Delete account error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
