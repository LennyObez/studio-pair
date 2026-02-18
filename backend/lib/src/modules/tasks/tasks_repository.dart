import 'package:logging/logging.dart';

import '../../config/database.dart';

/// Repository for task-related database operations.
class TasksRepository {
  final Database _db;
  // ignore: unused_field
  final Logger _log = Logger('TasksRepository');

  TasksRepository(this._db);

  // ---------------------------------------------------------------------------
  // Tasks
  // ---------------------------------------------------------------------------

  /// Creates a new task and returns the created task row.
  Future<Map<String, dynamic>> createTask({
    required String id,
    required String spaceId,
    required String createdBy,
    required String title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    String? parentTaskId,
    bool isRecurring = false,
    String? recurrenceRule,
    String? sourceModule,
    String? sourceEntityId,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO tasks (
        id, space_id, created_by, title, description, status, priority,
        due_date, parent_task_id, is_recurring, recurrence_rule,
        source_module, source_entity_id, created_at, updated_at
      )
      VALUES (
        @id, @spaceId, @createdBy, @title, @description,
        COALESCE(@status, 'todo'), COALESCE(@priority, 'medium'),
        @dueDate, @parentTaskId, @isRecurring, @recurrenceRule,
        @sourceModule, @sourceEntityId, NOW(), NOW()
      )
      RETURNING id, space_id, created_by, title, description, status, priority,
                due_date, parent_task_id, is_recurring, recurrence_rule,
                source_module, source_entity_id, completed_at,
                created_at, updated_at
      ''',
      parameters: {
        'id': id,
        'spaceId': spaceId,
        'createdBy': createdBy,
        'title': title,
        'description': description,
        'status': status,
        'priority': priority,
        'dueDate': dueDate,
        'parentTaskId': parentTaskId,
        'isRecurring': isRecurring,
        'recurrenceRule': recurrenceRule,
        'sourceModule': sourceModule,
        'sourceEntityId': sourceEntityId,
      },
    );

    return _taskRowToMap(row!);
  }

  /// Finds a task by ID, including assignment information.
  Future<Map<String, dynamic>?> getTaskById(String taskId) async {
    final row = await _db.queryOne(
      '''
      SELECT t.id, t.space_id, t.created_by, t.title, t.description,
             t.status, t.priority, t.due_date, t.parent_task_id,
             t.is_recurring, t.recurrence_rule, t.source_module,
             t.source_entity_id, t.completed_at, t.created_at, t.updated_at,
             t.deleted_at,
             u.display_name AS creator_name, u.avatar_url AS creator_avatar
      FROM tasks t
      JOIN users u ON u.id = t.created_by
      WHERE t.id = @taskId AND t.deleted_at IS NULL
      ''',
      parameters: {'taskId': taskId},
    );

    if (row == null) return null;

    final task = _taskRowWithCreatorToMap(row);

    // Fetch assignments
    final assignments = await getAssignments(taskId);
    task['assignments'] = assignments;

    return task;
  }

  /// Lists tasks for a space with optional filters and cursor-based pagination.
  Future<List<Map<String, dynamic>>> getTasks(
    String spaceId, {
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
    final conditions = <String>[
      't.space_id = @spaceId',
      't.deleted_at IS NULL',
    ];
    final params = <String, dynamic>{'spaceId': spaceId, 'limit': limit};

    if (status != null) {
      conditions.add('t.status = @status');
      params['status'] = status;
    }

    if (priority != null) {
      conditions.add('t.priority = @priority');
      params['priority'] = priority;
    }

    if (assignedTo != null) {
      conditions.add('''
        EXISTS (
          SELECT 1 FROM task_assignments ta
          WHERE ta.task_id = t.id AND ta.user_id = @assignedTo
        )
      ''');
      params['assignedTo'] = assignedTo;
    }

    if (createdBy != null) {
      conditions.add('t.created_by = @createdBy');
      params['createdBy'] = createdBy;
    }

    if (dueBefore != null) {
      conditions.add('t.due_date <= @dueBefore');
      params['dueBefore'] = dueBefore;
    }

    if (dueAfter != null) {
      conditions.add('t.due_date >= @dueAfter');
      params['dueAfter'] = dueAfter;
    }

    if (parentTaskId != null) {
      conditions.add('t.parent_task_id = @parentTaskId');
      params['parentTaskId'] = parentTaskId;
    } else {
      // By default, only return top-level tasks (no parent)
      conditions.add('t.parent_task_id IS NULL');
    }

    if (cursor != null) {
      conditions.add('t.created_at < @cursor');
      params['cursor'] = DateTime.parse(cursor);
    }

    final where = conditions.join(' AND ');

    final result = await _db.query('''
      SELECT t.id, t.space_id, t.created_by, t.title, t.description,
             t.status, t.priority, t.due_date, t.parent_task_id,
             t.is_recurring, t.recurrence_rule, t.source_module,
             t.source_entity_id, t.completed_at, t.created_at, t.updated_at
      FROM tasks t
      WHERE $where
      ORDER BY t.created_at DESC
      LIMIT @limit
      ''', parameters: params);

    return result.map(_taskRowToMap).toList();
  }

  /// Updates a task with the given fields.
  Future<Map<String, dynamic>?> updateTask(
    String taskId,
    Map<String, dynamic> updates,
  ) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'taskId': taskId};

    if (updates.containsKey('title')) {
      setClauses.add('title = @title');
      params['title'] = updates['title'];
    }
    if (updates.containsKey('description')) {
      setClauses.add('description = @description');
      params['description'] = updates['description'];
    }
    if (updates.containsKey('status')) {
      setClauses.add('status = @status');
      params['status'] = updates['status'];
    }
    if (updates.containsKey('priority')) {
      setClauses.add('priority = @priority');
      params['priority'] = updates['priority'];
    }
    if (updates.containsKey('due_date')) {
      setClauses.add('due_date = @dueDate');
      params['dueDate'] = updates['due_date'];
    }
    if (updates.containsKey('is_recurring')) {
      setClauses.add('is_recurring = @isRecurring');
      params['isRecurring'] = updates['is_recurring'];
    }
    if (updates.containsKey('recurrence_rule')) {
      setClauses.add('recurrence_rule = @recurrenceRule');
      params['recurrenceRule'] = updates['recurrence_rule'];
    }

    if (setClauses.isEmpty) return getTaskById(taskId);

    setClauses.add('updated_at = NOW()');

    final row = await _db.queryOne('''
      UPDATE tasks
      SET ${setClauses.join(', ')}
      WHERE id = @taskId AND deleted_at IS NULL
      RETURNING id, space_id, created_by, title, description, status, priority,
                due_date, parent_task_id, is_recurring, recurrence_rule,
                source_module, source_entity_id, completed_at,
                created_at, updated_at
      ''', parameters: params);

    if (row == null) return null;
    return _taskRowToMap(row);
  }

  /// Soft-deletes a task.
  Future<void> softDeleteTask(String taskId) async {
    await _db.execute(
      '''
      UPDATE tasks
      SET deleted_at = NOW(), updated_at = NOW()
      WHERE id = @taskId AND deleted_at IS NULL
      ''',
      parameters: {'taskId': taskId},
    );
  }

  /// Marks a task as complete.
  Future<Map<String, dynamic>?> completeTask(String taskId) async {
    final row = await _db.queryOne(
      '''
      UPDATE tasks
      SET status = 'done', completed_at = NOW(), updated_at = NOW()
      WHERE id = @taskId AND deleted_at IS NULL
      RETURNING id, space_id, created_by, title, description, status, priority,
                due_date, parent_task_id, is_recurring, recurrence_rule,
                source_module, source_entity_id, completed_at,
                created_at, updated_at
      ''',
      parameters: {'taskId': taskId},
    );

    if (row == null) return null;
    return _taskRowToMap(row);
  }

  /// Reopens a completed task.
  Future<Map<String, dynamic>?> reopenTask(String taskId) async {
    final row = await _db.queryOne(
      '''
      UPDATE tasks
      SET status = 'todo', completed_at = NULL, updated_at = NOW()
      WHERE id = @taskId AND deleted_at IS NULL
      RETURNING id, space_id, created_by, title, description, status, priority,
                due_date, parent_task_id, is_recurring, recurrence_rule,
                source_module, source_entity_id, completed_at,
                created_at, updated_at
      ''',
      parameters: {'taskId': taskId},
    );

    if (row == null) return null;
    return _taskRowToMap(row);
  }

  /// Gets subtasks of a parent task.
  Future<List<Map<String, dynamic>>> getSubtasks(String parentTaskId) async {
    final result = await _db.query(
      '''
      SELECT t.id, t.space_id, t.created_by, t.title, t.description,
             t.status, t.priority, t.due_date, t.parent_task_id,
             t.is_recurring, t.recurrence_rule, t.source_module,
             t.source_entity_id, t.completed_at, t.created_at, t.updated_at
      FROM tasks t
      WHERE t.parent_task_id = @parentTaskId AND t.deleted_at IS NULL
      ORDER BY t.created_at ASC
      ''',
      parameters: {'parentTaskId': parentTaskId},
    );

    return result.map(_taskRowToMap).toList();
  }

  /// Gets overdue tasks (due_date < now and status != done).
  Future<List<Map<String, dynamic>>> getOverdueTasks(String spaceId) async {
    final result = await _db.query(
      '''
      SELECT t.id, t.space_id, t.created_by, t.title, t.description,
             t.status, t.priority, t.due_date, t.parent_task_id,
             t.is_recurring, t.recurrence_rule, t.source_module,
             t.source_entity_id, t.completed_at, t.created_at, t.updated_at
      FROM tasks t
      WHERE t.space_id = @spaceId
        AND t.deleted_at IS NULL
        AND t.due_date < NOW()
        AND t.status != 'done'
      ORDER BY t.due_date ASC
      ''',
      parameters: {'spaceId': spaceId},
    );

    return result.map(_taskRowToMap).toList();
  }

  /// Gets tasks due today.
  Future<List<Map<String, dynamic>>> getTasksDueToday(String spaceId) async {
    final result = await _db.query(
      '''
      SELECT t.id, t.space_id, t.created_by, t.title, t.description,
             t.status, t.priority, t.due_date, t.parent_task_id,
             t.is_recurring, t.recurrence_rule, t.source_module,
             t.source_entity_id, t.completed_at, t.created_at, t.updated_at
      FROM tasks t
      WHERE t.space_id = @spaceId
        AND t.deleted_at IS NULL
        AND t.due_date >= CURRENT_DATE
        AND t.due_date < CURRENT_DATE + INTERVAL '1 day'
      ORDER BY t.due_date ASC
      ''',
      parameters: {'spaceId': spaceId},
    );

    return result.map(_taskRowToMap).toList();
  }

  /// Counts tasks in a space, optionally filtered by status.
  Future<int> countTasks(String spaceId, {String? status}) async {
    final conditions = <String>['space_id = @spaceId', 'deleted_at IS NULL'];
    final params = <String, dynamic>{'spaceId': spaceId};

    if (status != null) {
      conditions.add('status = @status');
      params['status'] = status;
    }

    final where = conditions.join(' AND ');

    final row = await _db.queryOne(
      'SELECT COUNT(*) FROM tasks WHERE $where',
      parameters: params,
    );

    return (row?[0] as int?) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Task Assignments
  // ---------------------------------------------------------------------------

  /// Assigns a user to a task.
  Future<Map<String, dynamic>> assignTask({
    required String taskId,
    required String userId,
    required String assignedBy,
  }) async {
    final row = await _db.queryOne(
      '''
      INSERT INTO task_assignments (task_id, user_id, assigned_by, assigned_at)
      VALUES (@taskId, @userId, @assignedBy, NOW())
      ON CONFLICT (task_id, user_id) DO NOTHING
      RETURNING task_id, user_id, assigned_by, assigned_at
      ''',
      parameters: {
        'taskId': taskId,
        'userId': userId,
        'assignedBy': assignedBy,
      },
    );

    if (row == null) {
      // Already assigned, fetch existing
      final existing = await _db.queryOne(
        '''
        SELECT task_id, user_id, assigned_by, assigned_at
        FROM task_assignments
        WHERE task_id = @taskId AND user_id = @userId
        ''',
        parameters: {'taskId': taskId, 'userId': userId},
      );
      return _assignmentRowToMap(existing!);
    }

    return _assignmentRowToMap(row);
  }

  /// Unassigns a user from a task.
  Future<void> unassignTask(String taskId, String userId) async {
    await _db.execute(
      '''
      DELETE FROM task_assignments
      WHERE task_id = @taskId AND user_id = @userId
      ''',
      parameters: {'taskId': taskId, 'userId': userId},
    );
  }

  /// Gets all assignments for a task, including user info.
  Future<List<Map<String, dynamic>>> getAssignments(String taskId) async {
    final result = await _db.query(
      '''
      SELECT ta.task_id, ta.user_id, ta.assigned_by, ta.assigned_at,
             u.display_name, u.email, u.avatar_url
      FROM task_assignments ta
      JOIN users u ON u.id = ta.user_id
      WHERE ta.task_id = @taskId
      ORDER BY ta.assigned_at ASC
      ''',
      parameters: {'taskId': taskId},
    );

    return result
        .map(
          (row) => {
            'task_id': row[0] as String,
            'user_id': row[1] as String,
            'assigned_by': row[2] as String,
            'assigned_at': (row[3] as DateTime).toIso8601String(),
            'user': {
              'display_name': row[4] as String,
              'email': row[5] as String,
              'avatar_url': row[6] as String?,
            },
          },
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _taskRowToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_by': row[2] as String,
      'title': row[3] as String,
      'description': row[4] as String?,
      'status': row[5] as String,
      'priority': row[6] as String,
      'due_date': row[7] != null
          ? (row[7] as DateTime).toIso8601String()
          : null,
      'parent_task_id': row[8] as String?,
      'is_recurring': row[9] as bool,
      'recurrence_rule': row[10] as String?,
      'source_module': row[11] as String?,
      'source_entity_id': row[12] as String?,
      'completed_at': row[13] != null
          ? (row[13] as DateTime).toIso8601String()
          : null,
      'created_at': (row[14] as DateTime).toIso8601String(),
      'updated_at': (row[15] as DateTime).toIso8601String(),
    };
  }

  Map<String, dynamic> _taskRowWithCreatorToMap(dynamic row) {
    return {
      'id': row[0] as String,
      'space_id': row[1] as String,
      'created_by': row[2] as String,
      'title': row[3] as String,
      'description': row[4] as String?,
      'status': row[5] as String,
      'priority': row[6] as String,
      'due_date': row[7] != null
          ? (row[7] as DateTime).toIso8601String()
          : null,
      'parent_task_id': row[8] as String?,
      'is_recurring': row[9] as bool,
      'recurrence_rule': row[10] as String?,
      'source_module': row[11] as String?,
      'source_entity_id': row[12] as String?,
      'completed_at': row[13] != null
          ? (row[13] as DateTime).toIso8601String()
          : null,
      'created_at': (row[14] as DateTime).toIso8601String(),
      'updated_at': (row[15] as DateTime).toIso8601String(),
      'deleted_at': row[16] != null
          ? (row[16] as DateTime).toIso8601String()
          : null,
      'creator': {
        'display_name': row[17] as String,
        'avatar_url': row[18] as String?,
      },
    };
  }

  Map<String, dynamic> _assignmentRowToMap(dynamic row) {
    return {
      'task_id': row[0] as String,
      'user_id': row[1] as String,
      'assigned_by': row[2] as String,
      'assigned_at': (row[3] as DateTime).toIso8601String(),
    };
  }
}
