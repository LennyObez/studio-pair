import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'export_service.dart';

/// Controller for GDPR data export endpoints.
class ExportController {
  final ExportService _service;

  ExportController(this._service);

  /// Returns the router with export routes.
  Router get router {
    final router = Router();

    router.get('/my-data', _exportMyData);

    return router;
  }

  /// GET /api/v1/export/my-data
  ///
  /// Exports all data belonging to the authenticated user.
  /// Rate-limited to once per 24 hours.
  Future<Response> _exportMyData(Request request) async {
    try {
      final userId = getUserId(request);
      final data = await _service.exportUserData(userId);

      return jsonResponse(
        data,
        headers: {
          'Content-Disposition':
              'attachment; filename="studio-pair-export-$userId.json"',
        },
      );
    } on ExportException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e) {
      return internalErrorResponse('An unexpected error occurred');
    }
  }
}
