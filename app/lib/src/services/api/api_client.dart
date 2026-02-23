import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:studio_pair/src/config/api_config.dart';
import 'package:studio_pair/src/services/storage/secure_storage_service.dart';

/// Dio-based API client with auth token management, error handling,
/// logging, and retry logic.
class ApiClient {
  ApiClient({required SecureStorageService secureStorage, String? baseUrl})
    : _secureStorage = secureStorage,
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? ApiConfig.effectiveBaseUrl,
          connectTimeout: const Duration(
            milliseconds: ApiConfig.connectTimeout,
          ),
          receiveTimeout: const Duration(
            milliseconds: ApiConfig.receiveTimeout,
          ),
          sendTimeout: const Duration(milliseconds: ApiConfig.sendTimeout),
          headers: ApiConfig.defaultHeaders,
        ),
      ) {
    _setupInterceptors();
  }

  final Dio _dio;
  final SecureStorageService _secureStorage;

  Dio get dio => _dio;

  void _setupInterceptors() {
    // Auth token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Attempt token refresh
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request with new token
              final token = await _secureStorage.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              } on DioException catch (e) {
                handler.reject(e);
                return;
              }
            }
          }
          handler.next(error);
        },
      ),
    );

    // Error handling interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final apiError = _parseError(error);
          handler.next(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: apiError,
              message: apiError.message,
            ),
          );
        },
      ),
    );

    // Request/response logging in debug mode
    assert(() {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (msg) => log(msg.toString(), name: 'ApiClient'),
        ),
      );
      return true;
    }());

    // Retry interceptor
    _dio.interceptors.add(_RetryInterceptor(dio: _dio));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio(
        BaseOptions(
          baseUrl: ApiConfig.effectiveBaseUrl,
          headers: ApiConfig.defaultHeaders,
        ),
      ).post('/auth/refresh', data: {'refreshToken': refreshToken});

      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;

      await _secureStorage.saveAccessToken(newAccessToken);
      await _secureStorage.saveRefreshToken(newRefreshToken);

      return true;
    } catch (e) {
      // Refresh failed - user needs to re-authenticate
      await _secureStorage.clearTokens();
      return false;
    }
  }

  ApiError _parseError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiError(
          message: 'Connection timed out. Please try again.',
          code: 'TIMEOUT',
        );
      case DioExceptionType.connectionError:
        return const ApiError(
          message: 'No internet connection.',
          code: 'NO_CONNECTION',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final data = error.response?.data;
        final message = data is Map ? data['message'] as String? : null;
        return ApiError(
          message: message ?? 'Server error ($statusCode)',
          code: 'HTTP_$statusCode',
          statusCode: statusCode,
        );
      default:
        return ApiError(
          message: error.message ?? 'An unexpected error occurred.',
          code: 'UNKNOWN',
        );
    }
  }

  // Convenience methods

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

/// Structured API error.
class ApiError {
  const ApiError({required this.message, required this.code, this.statusCode});

  final String message;
  final String code;
  final int? statusCode;

  @override
  String toString() => 'ApiError($code): $message';
}

/// Retry interceptor with exponential backoff.
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor({required this.dio});

  final Dio dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = _shouldRetry(err);
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (shouldRetry && retryCount < ApiConfig.maxRetries) {
      final delay = ApiConfig.retryDelay * (retryCount + 1);
      await Future.delayed(Duration(milliseconds: delay));

      err.requestOptions.extra['retryCount'] = retryCount + 1;

      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } on DioException catch (e) {
        handler.next(e);
        return;
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
