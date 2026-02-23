import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../services/notification_service.dart';
import '../calendar/calendar_service.dart';
import '../tasks/tasks_repository.dart';
import 'activities_repository.dart';

/// Custom exception for activity-related errors.
class ActivityException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const ActivityException(
    this.message, {
    this.code = 'ACTIVITY_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'ActivityException($code): $message';
}

/// Service containing all activity-related business logic.
class ActivitiesService {
  final ActivitiesRepository _repo;
  final NotificationService _notificationService;
  final CalendarService? _calendarService;
  final TasksRepository? _tasksRepo;
  final Logger _log = Logger('ActivitiesService');
  final Uuid _uuid = const Uuid();

  /// Valid activity categories.
  static const _validCategories = [
    'dining',
    'movies',
    'outdoors',
    'travel',
    'games',
    'sports',
    'arts',
    'music',
    'wellness',
    'nightlife',
    'shopping',
    'cooking',
    'learning',
    'volunteering',
    'other',
  ];

  /// Valid privacy values.
  static const _validPrivacyValues = ['shared', 'private'];

  /// Valid mode values.
  static const _validModes = [
    'unlinked',
    'date_linked_personal',
    'date_linked_space',
  ];

  ActivitiesService(
    this._repo,
    this._notificationService, {
    CalendarService? calendarService,
    TasksRepository? tasksRepo,
  }) : _calendarService = calendarService,
       _tasksRepo = tasksRepo;

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  /// Creates a new activity within a space.
  Future<Map<String, dynamic>> createActivity({
    required String spaceId,
    required String userId,
    required String title,
    String? description,
    String? category,
    String? thumbnailUrl,
    String? trailerUrl,
    String? externalId,
    String? externalSource,
    String privacy = 'shared',
    String mode = 'unlinked',
    Map<String, dynamic>? metadata,
  }) async {
    // Validate title
    if (title.trim().isEmpty) {
      throw const ActivityException(
        'Activity title is required',
        code: 'TITLE_REQUIRED',
        statusCode: 422,
      );
    }

    if (title.trim().length > 200) {
      throw const ActivityException(
        'Activity title must be at most 200 characters',
        code: 'TITLE_TOO_LONG',
        statusCode: 422,
      );
    }

    // Validate category if provided
    if (category != null && !_validCategories.contains(category)) {
      throw ActivityException(
        'Invalid category. Must be one of: ${_validCategories.join(", ")}',
        code: 'INVALID_CATEGORY',
        statusCode: 422,
      );
    }

    // Validate privacy
    if (!_validPrivacyValues.contains(privacy)) {
      throw ActivityException(
        'Invalid privacy value. Must be one of: ${_validPrivacyValues.join(", ")}',
        code: 'INVALID_PRIVACY',
        statusCode: 422,
      );
    }

    // Validate mode
    if (!_validModes.contains(mode)) {
      throw ActivityException(
        'Invalid mode. Must be one of: ${_validModes.join(", ")}',
        code: 'INVALID_MODE',
        statusCode: 422,
      );
    }

    final activityId = _uuid.v4();

    final activity = await _repo.createActivity(
      id: activityId,
      spaceId: spaceId,
      createdBy: userId,
      title: title.trim(),
      description: description?.trim(),
      category: category,
      thumbnailUrl: thumbnailUrl,
      trailerUrl: trailerUrl,
      externalId: externalId,
      externalSource: externalSource,
      privacy: privacy,
      mode: mode,
      metadata: metadata,
    );

    _log.info(
      'Activity created: ${activity['title']} ($activityId) '
      'in space $spaceId by $userId',
    );

    // Cross-module integrations based on activity mode
    if (mode == 'date_linked_personal' && _tasksRepo != null) {
      try {
        await _tasksRepo.createTask(
          id: _uuid.v4(),
          spaceId: spaceId,
          createdBy: userId,
          title: 'Plan: ${title.trim()}',
          description: 'Task auto-created from activity "${title.trim()}"',
          sourceModule: 'activity',
          sourceEntityId: activityId,
        );
      } catch (e) {
        _log.warning('Failed to create task for activity $activityId: $e');
      }
    } else if (mode == 'date_linked_space' && _calendarService != null) {
      try {
        await _calendarService.createEvent(
          spaceId: spaceId,
          userId: userId,
          title: title.trim(),
          eventType: 'activity',
          allDay: true,
          startAt: DateTime.now().add(const Duration(days: 7)),
          endAt: DateTime.now().add(const Duration(days: 7)),
          sourceModule: 'activity',
          sourceEntityId: activityId,
        );
      } catch (e) {
        _log.warning(
          'Failed to create calendar event for activity $activityId: $e',
        );
      }
    }

    return activity;
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Gets a single activity by ID, verifying space access and privacy rules.
  Future<Map<String, dynamic>> getActivity({
    required String activityId,
    required String spaceId,
    required String userId,
  }) async {
    final activity = await _repo.getActivityById(activityId);

    if (activity == null || activity['space_id'] != spaceId) {
      throw const ActivityException(
        'Activity not found',
        code: 'ACTIVITY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Respect privacy: private activities only visible to their creator
    if (activity['privacy'] == 'private' && activity['created_by'] != userId) {
      throw const ActivityException(
        'Activity not found',
        code: 'ACTIVITY_NOT_FOUND',
        statusCode: 404,
      );
    }

    return activity;
  }

  /// Gets activities for a space with filtering and pagination.
  ///
  /// Private activities are filtered out for non-creators.
  Future<Map<String, dynamic>> getActivities({
    required String spaceId,
    required String userId,
    String? category,
    String? status,
    String? privacy,
    String? mode,
    String? createdBy,
    String? cursor,
    int limit = 25,
  }) async {
    // Validate category filter if provided
    if (category != null && !_validCategories.contains(category)) {
      throw ActivityException(
        'Invalid category filter. Must be one of: ${_validCategories.join(", ")}',
        code: 'INVALID_CATEGORY',
        statusCode: 422,
      );
    }

    final activities = await _repo.getActivities(
      spaceId,
      category: category,
      status: status,
      privacy: privacy,
      mode: mode,
      createdBy: createdBy,
      cursor: cursor,
      limit: limit,
    );

    // Filter out private activities that don't belong to the current user
    final filtered = activities
        .where((a) => a['privacy'] != 'private' || a['created_by'] == userId)
        .toList();

    // Determine pagination
    final hasMore = filtered.length > limit;
    final page = hasMore ? filtered.sublist(0, limit) : filtered;
    final nextCursor = hasMore ? page.last['created_at'] as String : null;

    return {'data': page, 'cursor': nextCursor, 'has_more': hasMore};
  }

  /// Gets activities created by a specific user within a space (their "column").
  ///
  /// If the requesting user is different from the column owner, private
  /// activities are excluded.
  Future<List<Map<String, dynamic>>> getActivitiesByColumn({
    required String spaceId,
    required String columnUserId,
    required String requestingUserId,
  }) async {
    final activities = await _repo.getActivitiesByColumn(spaceId, columnUserId);

    // If looking at someone else's column, filter out private activities
    if (columnUserId != requestingUserId) {
      return activities.where((a) => a['privacy'] != 'private').toList();
    }

    return activities;
  }

  /// Searches activities within a space using full-text search.
  ///
  /// Private activities belonging to other users are excluded from results.
  Future<List<Map<String, dynamic>>> searchActivities({
    required String spaceId,
    required String userId,
    required String query,
  }) async {
    if (query.trim().isEmpty) {
      throw const ActivityException(
        'Search query is required',
        code: 'QUERY_REQUIRED',
        statusCode: 422,
      );
    }

    final results = await _repo.searchActivities(spaceId, query.trim());

    // Filter out private activities from other users
    return results
        .where((a) => a['privacy'] != 'private' || a['created_by'] == userId)
        .toList();
  }

  /// Gets completed activities for a space with pagination.
  Future<Map<String, dynamic>> getCompletedActivities({
    required String spaceId,
    required String userId,
    String? cursor,
    int limit = 25,
  }) async {
    final activities = await _repo.getCompletedActivities(
      spaceId,
      cursor: cursor,
      limit: limit,
    );

    // Filter out private completed activities from other users
    final filtered = activities
        .where((a) => a['privacy'] != 'private' || a['created_by'] == userId)
        .toList();

    final hasMore = filtered.length > limit;
    final page = hasMore ? filtered.sublist(0, limit) : filtered;
    final nextCursor = hasMore ? page.last['completed_at'] as String? : null;

    return {'data': page, 'cursor': nextCursor, 'has_more': hasMore};
  }

  /// Gets per-user activity statistics (category breakdown).
  Future<Map<String, dynamic>> getStats({
    required String spaceId,
    required String userId,
  }) async {
    final stats = await _repo.getActivityStats(spaceId, userId);

    var totalActivities = 0;
    var totalCompleted = 0;
    for (final stat in stats) {
      totalActivities += stat['total'] as int;
      totalCompleted += stat['completed'] as int;
    }

    return {
      'categories': stats,
      'total_activities': totalActivities,
      'total_completed': totalCompleted,
    };
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  /// Updates an activity. Only the creator can edit.
  Future<Map<String, dynamic>> updateActivity({
    required String activityId,
    required String spaceId,
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    final activity = await _repo.getActivityById(activityId);

    if (activity == null || activity['space_id'] != spaceId) {
      throw const ActivityException(
        'Activity not found',
        code: 'ACTIVITY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Only creator can edit
    if (activity['created_by'] != userId) {
      throw const ActivityException(
        'Only the creator can edit this activity',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Cannot edit deleted activities
    if (activity['status'] == 'deleted') {
      throw const ActivityException(
        'Cannot edit a deleted activity',
        code: 'ACTIVITY_DELETED',
        statusCode: 400,
      );
    }

    // Validate title if provided
    if (updates.containsKey('title')) {
      final title = updates['title'] as String?;
      if (title == null || title.trim().isEmpty) {
        throw const ActivityException(
          'Activity title cannot be empty',
          code: 'TITLE_REQUIRED',
          statusCode: 422,
        );
      }
      if (title.trim().length > 200) {
        throw const ActivityException(
          'Activity title must be at most 200 characters',
          code: 'TITLE_TOO_LONG',
          statusCode: 422,
        );
      }
      updates['title'] = title.trim();
    }

    // Validate category if provided
    if (updates.containsKey('category')) {
      final cat = updates['category'] as String?;
      if (cat != null && !_validCategories.contains(cat)) {
        throw ActivityException(
          'Invalid category. Must be one of: ${_validCategories.join(", ")}',
          code: 'INVALID_CATEGORY',
          statusCode: 422,
        );
      }
    }

    // Validate privacy if provided
    if (updates.containsKey('privacy')) {
      final priv = updates['privacy'] as String?;
      if (priv != null && !_validPrivacyValues.contains(priv)) {
        throw ActivityException(
          'Invalid privacy value. Must be one of: ${_validPrivacyValues.join(", ")}',
          code: 'INVALID_PRIVACY',
          statusCode: 422,
        );
      }
    }

    // Validate mode if provided
    if (updates.containsKey('mode')) {
      final m = updates['mode'] as String?;
      if (m != null && !_validModes.contains(m)) {
        throw ActivityException(
          'Invalid mode. Must be one of: ${_validModes.join(", ")}',
          code: 'INVALID_MODE',
          statusCode: 422,
        );
      }
    }

    final updated = await _repo.updateActivity(activityId, updates);
    if (updated == null) {
      throw const ActivityException(
        'Activity not found or could not be updated',
        code: 'UPDATE_FAILED',
        statusCode: 404,
      );
    }

    _log.info('Activity $activityId updated by $userId');
    return updated;
  }

  // ---------------------------------------------------------------------------
  // Delete & Restore
  // ---------------------------------------------------------------------------

  /// Soft-deletes an activity. Only the creator can delete.
  ///
  /// The activity will be permanently deleted after 30 days.
  Future<void> deleteActivity({
    required String activityId,
    required String spaceId,
    required String userId,
  }) async {
    final activity = await _repo.getActivityById(activityId);

    if (activity == null || activity['space_id'] != spaceId) {
      throw const ActivityException(
        'Activity not found',
        code: 'ACTIVITY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Only creator can delete
    if (activity['created_by'] != userId) {
      throw const ActivityException(
        'Only the creator can delete this activity',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    if (activity['status'] == 'deleted') {
      throw const ActivityException(
        'Activity is already deleted',
        code: 'ALREADY_DELETED',
        statusCode: 400,
      );
    }

    final deleted = await _repo.softDeleteActivity(activityId);
    if (!deleted) {
      throw const ActivityException(
        'Failed to delete activity',
        code: 'DELETE_FAILED',
        statusCode: 500,
      );
    }

    _log.info('Activity $activityId soft-deleted by $userId');
  }

  /// Restores a soft-deleted activity. Only the creator can restore, and only
  /// within 30 days of deletion.
  Future<Map<String, dynamic>> restoreActivity({
    required String activityId,
    required String spaceId,
    required String userId,
  }) async {
    final activity = await _repo.getActivityById(activityId);

    if (activity == null || activity['space_id'] != spaceId) {
      throw const ActivityException(
        'Activity not found',
        code: 'ACTIVITY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Only creator can restore
    if (activity['created_by'] != userId) {
      throw const ActivityException(
        'Only the creator can restore this activity',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    if (activity['status'] != 'deleted') {
      throw const ActivityException(
        'Activity is not deleted',
        code: 'NOT_DELETED',
        statusCode: 400,
      );
    }

    final restored = await _repo.restoreActivity(activityId);
    if (restored == null) {
      throw const ActivityException(
        'Activity cannot be restored. The 30-day restoration window may '
        'have expired.',
        code: 'RESTORE_EXPIRED',
        statusCode: 400,
      );
    }

    _log.info('Activity $activityId restored by $userId');
    return restored;
  }

  // ---------------------------------------------------------------------------
  // Voting
  // ---------------------------------------------------------------------------

  /// Casts or updates a vote on an activity.
  ///
  /// Score must be 1-5. One vote per user per activity. Users cannot vote on
  /// their own private activities.
  Future<Map<String, dynamic>> vote({
    required String activityId,
    required String spaceId,
    required String userId,
    required int score,
  }) async {
    // Validate score
    if (score < 1 || score > 5) {
      throw const ActivityException(
        'Vote score must be between 1 and 5',
        code: 'INVALID_SCORE',
        statusCode: 422,
      );
    }

    final activity = await _repo.getActivityById(activityId);

    if (activity == null || activity['space_id'] != spaceId) {
      throw const ActivityException(
        'Activity not found',
        code: 'ACTIVITY_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (activity['status'] == 'deleted') {
      throw const ActivityException(
        'Cannot vote on a deleted activity',
        code: 'ACTIVITY_DELETED',
        statusCode: 400,
      );
    }

    // Cannot vote on own private activities
    if (activity['privacy'] == 'private' && activity['created_by'] == userId) {
      throw const ActivityException(
        'Cannot vote on your own private activity',
        code: 'CANNOT_VOTE_OWN_PRIVATE',
        statusCode: 400,
      );
    }

    // Private activities are not visible to non-creators
    if (activity['privacy'] == 'private' && activity['created_by'] != userId) {
      throw const ActivityException(
        'Activity not found',
        code: 'ACTIVITY_NOT_FOUND',
        statusCode: 404,
      );
    }

    final vote = await _repo.upsertVote(
      activityId: activityId,
      userId: userId,
      score: score,
    );

    _log.info('Vote cast on activity $activityId by $userId: $score');
    return vote;
  }

  /// Removes a user's vote from an activity.
  Future<void> removeVote({
    required String activityId,
    required String spaceId,
    required String userId,
  }) async {
    final activity = await _repo.getActivityById(activityId);

    if (activity == null || activity['space_id'] != spaceId) {
      throw const ActivityException(
        'Activity not found',
        code: 'ACTIVITY_NOT_FOUND',
        statusCode: 404,
      );
    }

    final deleted = await _repo.deleteVote(activityId, userId);
    if (!deleted) {
      throw const ActivityException(
        'Vote not found',
        code: 'VOTE_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('Vote removed from activity $activityId by $userId');
  }

  /// Gets all votes for an activity, along with aggregate data.
  Future<Map<String, dynamic>> getVotes({
    required String activityId,
    required String spaceId,
    required String userId,
  }) async {
    final activity = await _repo.getActivityById(activityId);

    if (activity == null || activity['space_id'] != spaceId) {
      throw const ActivityException(
        'Activity not found',
        code: 'ACTIVITY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Respect privacy
    if (activity['privacy'] == 'private' && activity['created_by'] != userId) {
      throw const ActivityException(
        'Activity not found',
        code: 'ACTIVITY_NOT_FOUND',
        statusCode: 404,
      );
    }

    final votes = await _repo.getVotesForActivity(activityId);
    final aggregate = await _repo.getAggregateVotes(activityId);

    return {'votes': votes, 'aggregate': aggregate};
  }

  // ---------------------------------------------------------------------------
  // Completion
  // ---------------------------------------------------------------------------

  /// Marks an activity as completed and triggers a memory creation prompt.
  Future<Map<String, dynamic>> completeActivity({
    required String activityId,
    required String spaceId,
    required String userId,
    String? notes,
  }) async {
    final activity = await _repo.getActivityById(activityId);

    if (activity == null || activity['space_id'] != spaceId) {
      throw const ActivityException(
        'Activity not found',
        code: 'ACTIVITY_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (activity['status'] != 'active') {
      throw ActivityException(
        'Activity cannot be completed (current status: ${activity['status']})',
        code: 'INVALID_STATUS',
        statusCode: 400,
      );
    }

    final completed = await _repo.completeActivity(activityId, notes: notes);

    if (completed == null) {
      throw const ActivityException(
        'Failed to complete activity',
        code: 'COMPLETE_FAILED',
        statusCode: 500,
      );
    }

    // Notify the creator (prompt memory creation)
    final createdBy = activity['created_by'] as String;
    await _notificationService.notify(
      userId: createdBy,
      type: 'activity.completed',
      title: 'Activity completed!',
      body:
          'Your activity "${activity['title']}" has been marked as '
          'completed. Would you like to create a memory?',
      spaceId: spaceId,
      data: {'activity_id': activityId, 'action': 'create_memory'},
    );

    _log.info('Activity $activityId completed by $userId');
    return completed;
  }
}
