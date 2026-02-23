import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../services/notification_service.dart';
import '../calendar/calendar_service.dart';
import '../spaces/spaces_repository.dart';
import 'tasks_repository.dart';

/// Custom exception for task-related errors.
class TaskException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const TaskException(
    this.message, {
    this.code = 'TASK_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'TaskException($code): $message';
}

/// Service containing all task-related business logic.
class TasksService {
  final TasksRepository _repo;
  final SpacesRepository _spacesRepo;
  final NotificationService _notificationService;
  final CalendarService _calendarService;
  final Logger _log = Logger('TasksService');
  final Uuid _uuid = const Uuid();

  /// Valid task statuses.
  static const _validStatuses = ['todo', 'in_progress', 'done'];

  /// Valid task priorities.
  static const _validPriorities = ['low', 'medium', 'high', 'urgent'];

  TasksService(
    this._repo,
    this._spacesRepo,
    this._notificationService,
    this._calendarService,
  );

  // ---------------------------------------------------------------------------
  // Task CRUD
  // ---------------------------------------------------------------------------

  /// Creates a new task within a space.
  ///
  /// Optionally assigns users and creates a calendar event for the deadline.
  Future<Map<String, dynamic>> createTask({
    required String spaceId,
    required String userId,
    required String title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    List<String>? assignees,
    String? parentTaskId,
    bool isRecurring = false,
    String? recurrenceRule,
    String? sourceModule,
    String? sourceEntityId,
  }) async {
    // Validate title
    if (title.trim().isEmpty) {
      throw const TaskException(
        'Task title is required',
        code: 'INVALID_TITLE',
        statusCode: 422,
      );
    }

    if (title.trim().length > 500) {
      throw const TaskException(
        'Task title must be at most 500 characters',
        code: 'INVALID_TITLE',
        statusCode: 422,
      );
    }

    // Validate status if provided
    if (status != null && !_validStatuses.contains(status)) {
      throw TaskException(
        'Invalid status. Must be one of: ${_validStatuses.join(", ")}',
        code: 'INVALID_STATUS',
        statusCode: 422,
      );
    }

    // Validate priority if provided
    if (priority != null && !_validPriorities.contains(priority)) {
      throw TaskException(
        'Invalid priority. Must be one of: ${_validPriorities.join(", ")}',
        code: 'INVALID_PRIORITY',
        statusCode: 422,
      );
    }

    // Validate parent task if provided
    if (parentTaskId != null) {
      final parentTask = await _repo.getTaskById(parentTaskId);
      if (parentTask == null) {
        throw const TaskException(
          'Parent task not found',
          code: 'PARENT_TASK_NOT_FOUND',
          statusCode: 404,
        );
      }
      if (parentTask['space_id'] != spaceId) {
        throw const TaskException(
          'Parent task must belong to the same space',
          code: 'INVALID_PARENT_TASK',
          statusCode: 422,
        );
      }
    }

    final taskId = _uuid.v4();

    // Create the task
    final task = await _repo.createTask(
      id: taskId,
      spaceId: spaceId,
      createdBy: userId,
      title: title.trim(),
      description: description?.trim(),
      status: status,
      priority: priority,
      dueDate: dueDate,
      parentTaskId: parentTaskId,
      isRecurring: isRecurring,
      recurrenceRule: recurrenceRule,
      sourceModule: sourceModule,
      sourceEntityId: sourceEntityId,
    );

    // Assign users if provided
    if (assignees != null && assignees.isNotEmpty) {
      for (final assigneeId in assignees) {
        // Verify assignee is a space member
        final member = await _spacesRepo.getMember(spaceId, assigneeId);
        if (member != null && member['status'] == 'active') {
          await _repo.assignTask(
            taskId: taskId,
            userId: assigneeId,
            assignedBy: userId,
          );

          // Notify assignee (don't notify self)
          if (assigneeId != userId) {
            await _notificationService.notify(
              userId: assigneeId,
              type: 'task.assigned',
              title: 'New task assigned',
              body: 'You have been assigned to: ${task['title']}',
              spaceId: spaceId,
              data: {'task_id': taskId},
            );
          }
        }
      }
    }

    // Create a calendar event for the deadline if dueDate is set
    if (dueDate != null) {
      try {
        await _calendarService.createEvent(
          spaceId: spaceId,
          userId: userId,
          title: 'Due: ${title.trim()}',
          eventType: 'reminder',
          allDay: true,
          startAt: dueDate,
          endAt: dueDate,
          sourceModule: 'task',
          sourceEntityId: taskId,
        );
      } catch (e) {
        _log.warning('Failed to create calendar event for task $taskId: $e');
      }
    }

    _log.info('Task created: ${task['title']} ($taskId) in space $spaceId');

    // Return task with assignments
    return await _repo.getTaskById(taskId) ?? task;
  }

  /// Gets a task by ID, verifying space access.
  Future<Map<String, dynamic>> getTask({
    required String taskId,
    required String spaceId,
  }) async {
    final task = await _repo.getTaskById(taskId);

    if (task == null) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify task belongs to the space
    if (task['space_id'] != spaceId) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    return task;
  }

  /// Lists tasks for a space with filters and cursor-based pagination.
  Future<Map<String, dynamic>> getTasks({
    required String spaceId,
    String? status,
    String? priority,
    String? assignedTo,
    String? createdBy,
    DateTime? dueBefore,
    DateTime? dueAfter,
    String? parentTaskId,
    String? cursor,
    int limit = 25,
  }) async {
    // Validate status filter
    if (status != null && !_validStatuses.contains(status)) {
      throw TaskException(
        'Invalid status filter. Must be one of: ${_validStatuses.join(", ")}',
        code: 'INVALID_STATUS',
        statusCode: 422,
      );
    }

    // Validate priority filter
    if (priority != null && !_validPriorities.contains(priority)) {
      throw TaskException(
        'Invalid priority filter. Must be one of: ${_validPriorities.join(", ")}',
        code: 'INVALID_PRIORITY',
        statusCode: 422,
      );
    }

    // Fetch one extra to determine if there are more results
    final tasks = await _repo.getTasks(
      spaceId,
      status: status,
      priority: priority,
      assignedTo: assignedTo,
      createdBy: createdBy,
      dueBefore: dueBefore,
      dueAfter: dueAfter,
      parentTaskId: parentTaskId,
      cursor: cursor,
      limit: limit + 1,
    );

    final hasMore = tasks.length > limit;
    final resultTasks = hasMore ? tasks.sublist(0, limit) : tasks;

    String? nextCursor;
    if (hasMore && resultTasks.isNotEmpty) {
      nextCursor = resultTasks.last['created_at'] as String;
    }

    return {
      'data': resultTasks,
      'pagination': {'cursor': nextCursor, 'has_more': hasMore},
    };
  }

  /// Updates a task, verifying ownership or admin permission.
  Future<Map<String, dynamic>> updateTask({
    required String taskId,
    required String spaceId,
    required String userId,
    required String userRole,
    required Map<String, dynamic> updates,
  }) async {
    final task = await _repo.getTaskById(taskId);

    if (task == null) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify task belongs to the space
    if (task['space_id'] != spaceId) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Check permission: creator, admin, or owner
    final isCreator = task['created_by'] == userId;
    final isAdminOrOwner = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdminOrOwner) {
      throw const TaskException(
        'Only the task creator or space admins can update this task',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Validate status if provided
    if (updates.containsKey('status')) {
      final newStatus = updates['status'] as String?;
      if (newStatus != null && !_validStatuses.contains(newStatus)) {
        throw TaskException(
          'Invalid status. Must be one of: ${_validStatuses.join(", ")}',
          code: 'INVALID_STATUS',
          statusCode: 422,
        );
      }
    }

    // Validate priority if provided
    if (updates.containsKey('priority')) {
      final newPriority = updates['priority'] as String?;
      if (newPriority != null && !_validPriorities.contains(newPriority)) {
        throw TaskException(
          'Invalid priority. Must be one of: ${_validPriorities.join(", ")}',
          code: 'INVALID_PRIORITY',
          statusCode: 422,
        );
      }
    }

    // Validate title if provided
    if (updates.containsKey('title')) {
      final newTitle = updates['title'] as String?;
      if (newTitle != null && newTitle.trim().isEmpty) {
        throw const TaskException(
          'Task title cannot be empty',
          code: 'INVALID_TITLE',
          statusCode: 422,
        );
      }
    }

    final updated = await _repo.updateTask(taskId, updates);

    if (updated == null) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Update calendar event if dueDate changed
    if (updates.containsKey('due_date') || updates.containsKey('dueDate')) {
      try {
        final newDueDate = updates['due_date'] ?? updates['dueDate'];
        if (newDueDate != null) {
          // The calendar service will handle finding/updating the linked event
          await _calendarService.createEvent(
            spaceId: spaceId,
            userId: userId,
            title: 'Due: ${updated['title']}',
            eventType: 'reminder',
            allDay: true,
            startAt: newDueDate is DateTime
                ? newDueDate
                : DateTime.parse(newDueDate.toString()),
            endAt: newDueDate is DateTime
                ? newDueDate
                : DateTime.parse(newDueDate.toString()),
            sourceModule: 'task',
            sourceEntityId: taskId,
          );
        }
      } catch (e) {
        _log.warning('Failed to update calendar event for task $taskId: $e');
      }
    }

    _log.info('Task updated: $taskId by $userId');

    // Return full task with assignments
    return await _repo.getTaskById(taskId) ?? updated;
  }

  /// Deletes a task (soft delete), verifying ownership or admin permission.
  Future<void> deleteTask({
    required String taskId,
    required String spaceId,
    required String userId,
    required String userRole,
  }) async {
    final task = await _repo.getTaskById(taskId);

    if (task == null) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify task belongs to the space
    if (task['space_id'] != spaceId) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Check permission: creator, admin, or owner
    final isCreator = task['created_by'] == userId;
    final isAdminOrOwner = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdminOrOwner) {
      throw const TaskException(
        'Only the task creator or space admins can delete this task',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.softDeleteTask(taskId);

    _log.info('Task deleted: $taskId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Assignments
  // ---------------------------------------------------------------------------

  /// Assigns a user to a task, verifying both users are space members.
  Future<Map<String, dynamic>> assignTask({
    required String taskId,
    required String spaceId,
    required String userId,
    required String targetUserId,
    required String userRole,
  }) async {
    final task = await _repo.getTaskById(taskId);

    if (task == null) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify task belongs to the space
    if (task['space_id'] != spaceId) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the target user is an active space member
    final targetMember = await _spacesRepo.getMember(spaceId, targetUserId);
    if (targetMember == null || targetMember['status'] != 'active') {
      throw const TaskException(
        'Target user is not an active member of this space',
        code: 'USER_NOT_MEMBER',
        statusCode: 422,
      );
    }

    final assignment = await _repo.assignTask(
      taskId: taskId,
      userId: targetUserId,
      assignedBy: userId,
    );

    // Notify assignee (don't notify self)
    if (targetUserId != userId) {
      await _notificationService.notify(
        userId: targetUserId,
        type: 'task.assigned',
        title: 'Task assigned to you',
        body: 'You have been assigned to: ${task['title']}',
        spaceId: spaceId,
        data: {'task_id': taskId},
      );
    }

    _log.info('User $targetUserId assigned to task $taskId by $userId');

    return assignment;
  }

  /// Unassigns a user from a task, verifying permission.
  Future<void> unassignTask({
    required String taskId,
    required String spaceId,
    required String userId,
    required String targetUserId,
    required String userRole,
  }) async {
    final task = await _repo.getTaskById(taskId);

    if (task == null) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify task belongs to the space
    if (task['space_id'] != spaceId) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Permission: can unassign self, or creator/admin can unassign others
    final isSelf = userId == targetUserId;
    final isCreator = task['created_by'] == userId;
    final isAdminOrOwner = userRole == 'admin' || userRole == 'owner';
    if (!isSelf && !isCreator && !isAdminOrOwner) {
      throw const TaskException(
        'You do not have permission to unassign this user',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.unassignTask(taskId, targetUserId);

    _log.info('User $targetUserId unassigned from task $taskId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Status Changes
  // ---------------------------------------------------------------------------

  /// Marks a task as complete and notifies creator and assignees.
  Future<Map<String, dynamic>> completeTask({
    required String taskId,
    required String spaceId,
    required String userId,
  }) async {
    final task = await _repo.getTaskById(taskId);

    if (task == null) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify task belongs to the space
    if (task['space_id'] != spaceId) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (task['status'] == 'done') {
      throw const TaskException(
        'Task is already completed',
        code: 'ALREADY_COMPLETED',
        statusCode: 409,
      );
    }

    final completed = await _repo.completeTask(taskId);

    if (completed == null) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Notify creator and assignees
    final notifyUserIds = <String>{};

    final creatorId = task['created_by'] as String;
    if (creatorId != userId) {
      notifyUserIds.add(creatorId);
    }

    final assignments =
        task['assignments'] as List<Map<String, dynamic>>? ?? [];
    for (final assignment in assignments) {
      final assigneeId = assignment['user_id'] as String;
      if (assigneeId != userId) {
        notifyUserIds.add(assigneeId);
      }
    }

    for (final notifyUserId in notifyUserIds) {
      await _notificationService.notify(
        userId: notifyUserId,
        type: 'task.completed',
        title: 'Task completed',
        body: 'Task "${task['title']}" has been marked as done',
        spaceId: spaceId,
        data: {'task_id': taskId},
      );
    }

    _log.info('Task completed: $taskId by $userId');

    return await _repo.getTaskById(taskId) ?? completed;
  }

  /// Reopens a completed task, verifying permission.
  Future<Map<String, dynamic>> reopenTask({
    required String taskId,
    required String spaceId,
    required String userId,
    required String userRole,
  }) async {
    final task = await _repo.getTaskById(taskId);

    if (task == null) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify task belongs to the space
    if (task['space_id'] != spaceId) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (task['status'] != 'done') {
      throw const TaskException(
        'Task is not completed',
        code: 'NOT_COMPLETED',
        statusCode: 409,
      );
    }

    // Check permission: creator, admin, or owner
    final isCreator = task['created_by'] == userId;
    final isAdminOrOwner = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdminOrOwner) {
      throw const TaskException(
        'Only the task creator or space admins can reopen this task',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    final reopened = await _repo.reopenTask(taskId);

    if (reopened == null) {
      throw const TaskException(
        'Task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('Task reopened: $taskId by $userId');

    return await _repo.getTaskById(taskId) ?? reopened;
  }

  // ---------------------------------------------------------------------------
  // Subtasks
  // ---------------------------------------------------------------------------

  /// Gets subtasks of a parent task, verifying access.
  Future<List<Map<String, dynamic>>> getSubtasks({
    required String parentTaskId,
    required String spaceId,
  }) async {
    // Verify parent task exists and belongs to the space
    final parentTask = await _repo.getTaskById(parentTaskId);

    if (parentTask == null) {
      throw const TaskException(
        'Parent task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (parentTask['space_id'] != spaceId) {
      throw const TaskException(
        'Parent task not found',
        code: 'TASK_NOT_FOUND',
        statusCode: 404,
      );
    }

    return _repo.getSubtasks(parentTaskId);
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Gets overdue tasks for a space.
  Future<List<Map<String, dynamic>>> getOverdueTasks(String spaceId) async {
    return _repo.getOverdueTasks(spaceId);
  }

  /// Gets tasks due today for a space.
  Future<List<Map<String, dynamic>>> getTasksDueToday(String spaceId) async {
    return _repo.getTasksDueToday(spaceId);
  }
}
