import 'dart:convert';

import 'package:shelf/shelf.dart';

/// Standard JSON content type header.
const _jsonHeaders = {'Content-Type': 'application/json; charset=utf-8'};

/// Creates a JSON response with the given data and status code.
Response jsonResponse(
  dynamic data, {
  int statusCode = 200,
  Map<String, String>? headers,
}) {
  final allHeaders = {..._jsonHeaders, ...?headers};
  return Response(statusCode, body: jsonEncode(data), headers: allHeaders);
}

/// Creates a standard error response.
///
/// Format:
/// ```json
/// {
///   "error": {
///     "message": "Human-readable message",
///     "code": "MACHINE_READABLE_CODE",
///     "details": [...]
///   }
/// }
/// ```
Response errorResponse(
  String message, {
  int statusCode = 400,
  String? code,
  List<Map<String, dynamic>>? details,
}) {
  final error = <String, dynamic>{'message': message};

  if (code != null) {
    error['code'] = code;
  }

  if (details != null && details.isNotEmpty) {
    error['details'] = details;
  }

  return Response(
    statusCode,
    body: jsonEncode({'error': error}),
    headers: _jsonHeaders,
  );
}

/// Creates a paginated response with cursor-based pagination.
Response paginatedResponse(
  List<dynamic> data, {
  String? cursor,
  required bool hasMore,
  Map<String, dynamic>? meta,
}) {
  final body = <String, dynamic>{
    'data': data,
    'pagination': {'cursor': cursor, 'has_more': hasMore},
  };

  if (meta != null) {
    body['meta'] = meta;
  }

  return Response.ok(jsonEncode(body), headers: _jsonHeaders);
}

/// Creates a 204 No Content response.
Response noContentResponse() {
  return Response(204);
}

/// Creates a 201 Created response with the given data.
Response createdResponse(dynamic data) {
  return jsonResponse(data, statusCode: 201);
}

/// Creates a 401 Unauthorized response.
Response unauthorizedResponse([String message = 'Unauthorized']) {
  return errorResponse(message, statusCode: 401, code: 'UNAUTHORIZED');
}

/// Creates a 403 Forbidden response.
Response forbiddenResponse([String message = 'Forbidden']) {
  return errorResponse(message, statusCode: 403, code: 'FORBIDDEN');
}

/// Creates a 404 Not Found response.
Response notFoundResponse([String message = 'Not found']) {
  return errorResponse(message, statusCode: 404, code: 'NOT_FOUND');
}

/// Creates a 409 Conflict response.
Response conflictResponse([String message = 'Conflict']) {
  return errorResponse(message, statusCode: 409, code: 'CONFLICT');
}

/// Creates a 422 Unprocessable Entity response with validation errors.
Response validationErrorResponse(
  String message, {
  List<Map<String, dynamic>>? errors,
}) {
  return errorResponse(
    message,
    statusCode: 422,
    code: 'VALIDATION_ERROR',
    details: errors,
  );
}

/// Creates a 429 Too Many Requests response.
Response rateLimitResponse([String message = 'Too many requests']) {
  return errorResponse(message, statusCode: 429, code: 'RATE_LIMIT_EXCEEDED');
}

/// Creates a 500 Internal Server Error response.
Response internalErrorResponse([String message = 'Internal server error']) {
  return errorResponse(message, statusCode: 500, code: 'INTERNAL_ERROR');
}
