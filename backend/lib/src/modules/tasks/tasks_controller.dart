import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/request_utils.dart';
import '../../utils/response_utils.dart';
import 'tasks_service.dart';

/// Controller for shared task/chore endpoints.
class TasksController {
  final TasksService _service;
  final Logger _log = Logger('TasksController');

  TasksController(this._service);

  /// Returns the router with all task routes.
  Router get router {
    final router = Router();

    // Special query routes (must be before parameterized routes)
    router.get('/overdue', _getOverdueTasks);
    router.get('/today', _getTasksDueToday);

    // Tasks CRUD
    router.post('/', _createTask);
    router.get('/', _listTasks);
    router.get('/<taskId>', _getTask);
    router.patch('/<taskId>', _updateTask);
    router.delete('/<taskId>', _deleteTask);

    // Assignment
    router.post('/<taskId>/assign', _assignTask);
    router.delete('/<taskId>/assign/<userId>', _unassignTask);

    // Status
    router.post('/<taskId>/complete', _completeTask);
    router.post('/<taskId>/reopen', _reopenTask);

    // Subtasks
    router.get('/<taskId>/subtasks', _listSubtasks);

    return router;
  }

  /// POST /api/v1/spaces/<spaceId>/tasks
  ///
  /// Creates a new task.
  /// Body: { "title": "...", "description": "...", "priority": "...",
  ///         "due_date": "...", "assignees": [...], "parent_task_id": "...",
  ///         "source_module": "...", "source_entity_id": "..." }
  Future<Response> _createTask(Request request) async {
    try {
      final userId = getUserId(request);
      final spaceId = request.context[spaceIdKey] as String;
      final body = await readJsonBody(request);

      final title = body['title'] as String?;

      if (title == null || title.trim().isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'title', 'message': 'Title is required'},
          ],
        );
      }

      // Parse due date
      DateTime? dueDate;
      final dueDateStr = body['due_date'] as String?;
      if (dueDateStr != null && dueDateStr.isNotEmpty) {
        try {
          dueDate = DateTime.parse(dueDateStr);
        } on FormatException {
          return validationErrorResponse(
            'Invalid due_date format. Use ISO 8601.',
          );
        }
      }

      // Parse assignees list
      List<String>? assignees;
      final assigneesRaw = body['assignees'];
      if (assigneesRaw is List) {
        assignees = assigneesRaw.cast<String>();
      }

      final result = await _service.createTask(
        spaceId: spaceId,
        userId: userId,
        title: title,
        description: body['description'] as String?,
        status: body['status'] as String?,
        priority: body['priority'] as String?,
        dueDate: dueDate,
        assignees: assignees,
        parentTaskId: body['parent_task_id'] as String?,
        isRecurring: body['is_recurring'] as bool? ?? false,
        recurrenceRule: body['recurrence_rule'] as String?,
        sourceModule: body['source_module'] as String?,
        sourceEntityId: body['source_entity_id'] as String?,
      );

      return createdResponse(result);
    } on TaskException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Create task error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/tasks?status=&priority=&assignedTo=&cursor=&limit=
  ///
  /// Lists tasks with optional filters and cursor-based pagination.
  Future<Response> _listTasks(Request request) async {
    try {
      final spaceId = request.context[spaceIdKey] as String;
      final params = request.url.queryParameters;
      final pagination = getPaginationParams(request);

      // Parse optional date filters
      DateTime? dueBefore;
      final dueBeforeStr = params['due_before'];
      if (dueBeforeStr != null && dueBeforeStr.isNotEmpty) {
        try {
          dueBefore = DateTime.parse(dueBeforeStr);
        } on FormatException {
          return validationErrorResponse(
            'Invalid due_before format. Use ISO 8601.',
          );
        }
      }

      DateTime? dueAfter;
      final dueAfterStr = params['due_after'];
      if (dueAfterStr != null && dueAfterStr.isNotEmpty) {
        try {
          dueAfter = DateTime.parse(dueAfterStr);
        } on FormatException {
          return validationErrorResponse(
            'Invalid due_after format. Use ISO 8601.',
          );
        }
      }

      final result = await _service.getTasks(
        spaceId: spaceId,
        status: params['status'],
        priority: params['priority'],
        assignedTo: params['assigned_to'],
        createdBy: params['created_by'],
        dueBefore: dueBefore,
        dueAfter: dueAfter,
        parentTaskId: params['parent_task_id'],
        cursor: pagination.cursor,
        limit: pagination.limit,
      );

      return jsonResponse(result);
    } on TaskException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('List tasks error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/tasks/<taskId>
  ///
  /// Gets a single task by ID.
  Future<Response> _getTask(Request request, String taskId) async {
    try {
      final spaceId = request.context[spaceIdKey] as String;

      final task = await _service.getTask(taskId: taskId, spaceId: spaceId);

      return jsonResponse(task);
    } on TaskException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Get task error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// PATCH /api/v1/spaces/<spaceId>/tasks/<taskId>
  ///
  /// Updates a task.
  /// Body: { "title": "...", "description": "...", "status": "...",
  ///         "priority": "...", "due_date": "..." }
  Future<Response> _updateTask(Request request, String taskId) async {
    try {
      final userId = getUserId(request);
      final spaceId = request.context[spaceIdKey] as String;
      final membership = getMembership(request);
      final body = await readJsonBody(request);

      // Build updates map
      final updates = <String, dynamic>{};

      if (body.containsKey('title')) {
        updates['title'] = body['title'];
      }
      if (body.containsKey('description')) {
        updates['description'] = body['description'];
      }
      if (body.containsKey('status')) {
        updates['status'] = body['status'];
      }
      if (body.containsKey('priority')) {
        updates['priority'] = body['priority'];
      }
      if (body.containsKey('due_date')) {
        final dueDateStr = body['due_date'] as String?;
        if (dueDateStr != null && dueDateStr.isNotEmpty) {
          try {
            updates['due_date'] = DateTime.parse(dueDateStr);
          } on FormatException {
            return validationErrorResponse(
              'Invalid due_date format. Use ISO 8601.',
            );
          }
        } else {
          updates['due_date'] = null;
        }
      }
      if (body.containsKey('is_recurring')) {
        updates['is_recurring'] = body['is_recurring'];
      }
      if (body.containsKey('recurrence_rule')) {
        updates['recurrence_rule'] = body['recurrence_rule'];
      }

      final result = await _service.updateTask(
        taskId: taskId,
        spaceId: spaceId,
        userId: userId,
        userRole: membership?.role ?? 'member',
        updates: updates,
      );

      return jsonResponse(result);
    } on TaskException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Update task error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /api/v1/spaces/<spaceId>/tasks/<taskId>
  ///
  /// Soft-deletes a task.
  Future<Response> _deleteTask(Request request, String taskId) async {
    try {
      final userId = getUserId(request);
      final spaceId = request.context[spaceIdKey] as String;
      final membership = getMembership(request);

      await _service.deleteTask(
        taskId: taskId,
        spaceId: spaceId,
        userId: userId,
        userRole: membership?.role ?? 'member',
      );

      return noContentResponse();
    } on TaskException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Delete task error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/tasks/<taskId>/assign
  ///
  /// Assigns a user to a task.
  /// Body: { "user_id": "..." }
  Future<Response> _assignTask(Request request, String taskId) async {
    try {
      final userId = getUserId(request);
      final spaceId = request.context[spaceIdKey] as String;
      final membership = getMembership(request);
      final body = await readJsonBody(request);

      final targetUserId = body['user_id'] as String?;
      if (targetUserId == null || targetUserId.isEmpty) {
        return validationErrorResponse(
          'Missing required fields',
          errors: [
            {'field': 'user_id', 'message': 'User ID is required'},
          ],
        );
      }

      final result = await _service.assignTask(
        taskId: taskId,
        spaceId: spaceId,
        userId: userId,
        targetUserId: targetUserId,
        userRole: membership?.role ?? 'member',
      );

      return createdResponse(result);
    } on TaskException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } on FormatException catch (e) {
      return validationErrorResponse('Invalid request body: ${e.message}');
    } catch (e, stackTrace) {
      _log.severe('Assign task error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// DELETE /api/v1/spaces/<spaceId>/tasks/<taskId>/assign/<userId>
  ///
  /// Unassigns a user from a task.
  Future<Response> _unassignTask(
    Request request,
    String taskId,
    String userId,
  ) async {
    try {
      final actingUserId = getUserId(request);
      final spaceId = request.context[spaceIdKey] as String;
      final membership = getMembership(request);

      await _service.unassignTask(
        taskId: taskId,
        spaceId: spaceId,
        userId: actingUserId,
        targetUserId: userId,
        userRole: membership?.role ?? 'member',
      );

      return noContentResponse();
    } on TaskException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Unassign task error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/tasks/<taskId>/complete
  ///
  /// Marks a task as complete.
  Future<Response> _completeTask(Request request, String taskId) async {
    try {
      final userId = getUserId(request);
      final spaceId = request.context[spaceIdKey] as String;

      final result = await _service.completeTask(
        taskId: taskId,
        spaceId: spaceId,
        userId: userId,
      );

      return jsonResponse(result);
    } on TaskException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Complete task error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// POST /api/v1/spaces/<spaceId>/tasks/<taskId>/reopen
  ///
  /// Reopens a completed task.
  Future<Response> _reopenTask(Request request, String taskId) async {
    try {
      final userId = getUserId(request);
      final spaceId = request.context[spaceIdKey] as String;
      final membership = getMembership(request);

      final result = await _service.reopenTask(
        taskId: taskId,
        spaceId: spaceId,
        userId: userId,
        userRole: membership?.role ?? 'member',
      );

      return jsonResponse(result);
    } on TaskException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('Reopen task error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/tasks/<taskId>/subtasks
  ///
  /// Lists subtasks of a parent task.
  Future<Response> _listSubtasks(Request request, String taskId) async {
    try {
      final spaceId = request.context[spaceIdKey] as String;

      final subtasks = await _service.getSubtasks(
        parentTaskId: taskId,
        spaceId: spaceId,
      );

      return jsonResponse({'data': subtasks});
    } on TaskException catch (e) {
      return errorResponse(e.message, statusCode: e.statusCode, code: e.code);
    } catch (e, stackTrace) {
      _log.severe('List subtasks error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/tasks/overdue
  ///
  /// Gets all overdue tasks in the space.
  Future<Response> _getOverdueTasks(Request request) async {
    try {
      final spaceId = request.context[spaceIdKey] as String;

      final tasks = await _service.getOverdueTasks(spaceId);

      return jsonResponse({'data': tasks});
    } catch (e, stackTrace) {
      _log.severe('Get overdue tasks error', e, stackTrace);
      return internalErrorResponse();
    }
  }

  /// GET /api/v1/spaces/<spaceId>/tasks/today
  ///
  /// Gets all tasks due today in the space.
  Future<Response> _getTasksDueToday(Request request) async {
    try {
      final spaceId = request.context[spaceIdKey] as String;

      final tasks = await _service.getTasksDueToday(spaceId);

      return jsonResponse({'data': tasks});
    } catch (e, stackTrace) {
      _log.severe('Get tasks due today error', e, stackTrace);
      return internalErrorResponse();
    }
  }
}
