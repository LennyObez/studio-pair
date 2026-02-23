import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../spaces/spaces_repository.dart';
import 'memories_repository.dart';

/// Custom exception for memories-related errors.
class MemoriesException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const MemoriesException(
    this.message, {
    this.code = 'MEMORIES_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'MemoriesException($code): $message';
}

/// Service containing all memories-related business logic.
class MemoriesService {
  final MemoriesRepository _repo;
  final SpacesRepository _spacesRepo;
  final Logger _log = Logger('MemoriesService');
  final Uuid _uuid = const Uuid();

  MemoriesService(this._repo, this._spacesRepo);

  // ---------------------------------------------------------------------------
  // Memory CRUD
  // ---------------------------------------------------------------------------

  /// Creates a new memory.
  ///
  /// Validates inputs and checks space membership.
  Future<Map<String, dynamic>> createMemory({
    required String spaceId,
    required String userId,
    required String title,
    required DateTime date,
    String? location,
    double? locationLat,
    double? locationLng,
    String? description,
    String? linkedActivityId,
    bool isMilestone = false,
    String? milestoneType,
  }) async {
    // Validate title
    if (title.trim().isEmpty) {
      throw const MemoriesException(
        'Memory title is required',
        code: 'INVALID_TITLE',
        statusCode: 422,
      );
    }

    if (title.trim().length > 200) {
      throw const MemoriesException(
        'Memory title must be at most 200 characters',
        code: 'INVALID_TITLE',
        statusCode: 422,
      );
    }

    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    final memory = await _repo.createMemory(
      id: _uuid.v4(),
      spaceId: spaceId,
      createdBy: userId,
      title: title.trim(),
      date: date,
      location: location?.trim(),
      locationLat: locationLat,
      locationLng: locationLng,
      description: description?.trim(),
      linkedActivityId: linkedActivityId,
      isMilestone: isMilestone,
      milestoneType: milestoneType,
    );

    _log.info(
      'Memory created: ${memory['title']} (${memory['id']}) in space $spaceId',
    );

    return memory;
  }

  /// Gets a single memory by ID with all associated data.
  ///
  /// Verifies the requesting user has access to the memory's space.
  Future<Map<String, dynamic>> getMemory({
    required String memoryId,
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final memory = await _repo.getMemoryById(memoryId);
    if (memory == null) {
      throw const MemoriesException(
        'Memory not found',
        code: 'MEMORY_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (memory['space_id'] != spaceId) {
      throw const MemoriesException(
        'Memory not found',
        code: 'MEMORY_NOT_FOUND',
        statusCode: 404,
      );
    }

    return memory;
  }

  /// Gets a paginated timeline of memories for a space.
  Future<List<Map<String, dynamic>>> getTimeline({
    required String spaceId,
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isMilestone,
    String? cursor,
    int limit = 25,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final clampedLimit = limit.clamp(1, 100);

    return _repo.getMemories(
      spaceId,
      startDate: startDate,
      endDate: endDate,
      isMilestone: isMilestone,
      cursor: cursor,
      limit: clampedLimit,
    );
  }

  /// Updates an existing memory.
  Future<Map<String, dynamic>> updateMemory({
    required String memoryId,
    required String spaceId,
    required String userId,
    required String userRole,
    required Map<String, dynamic> updates,
  }) async {
    final existing = await _repo.getMemoryById(memoryId);
    if (existing == null) {
      throw const MemoriesException(
        'Memory not found',
        code: 'MEMORY_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (existing['space_id'] != spaceId) {
      throw const MemoriesException(
        'Memory not found',
        code: 'MEMORY_NOT_FOUND',
        statusCode: 404,
      );
    }

    final isCreator = existing['created_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdmin) {
      throw const MemoriesException(
        'Only the memory creator or a space admin can update this memory',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Validate title if provided
    if (updates.containsKey('title')) {
      final title = updates['title'] as String?;
      if (title == null || title.trim().isEmpty) {
        throw const MemoriesException(
          'Memory title cannot be empty',
          code: 'INVALID_TITLE',
          statusCode: 422,
        );
      }
      updates['title'] = title.trim();
    }

    final updated = await _repo.updateMemory(memoryId, updates);
    if (updated == null) {
      throw const MemoriesException(
        'Memory not found',
        code: 'MEMORY_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('Memory updated: $memoryId in space $spaceId by $userId');

    return updated;
  }

  /// Soft-deletes a memory.
  Future<void> deleteMemory({
    required String memoryId,
    required String spaceId,
    required String userId,
    required String userRole,
  }) async {
    final existing = await _repo.getMemoryById(memoryId);
    if (existing == null) {
      throw const MemoriesException(
        'Memory not found',
        code: 'MEMORY_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (existing['space_id'] != spaceId) {
      throw const MemoriesException(
        'Memory not found',
        code: 'MEMORY_NOT_FOUND',
        statusCode: 404,
      );
    }

    final isCreator = existing['created_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdmin) {
      throw const MemoriesException(
        'Only the memory creator or a space admin can delete this memory',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.softDeleteMemory(memoryId);

    _log.info('Memory deleted: $memoryId in space $spaceId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Media
  // ---------------------------------------------------------------------------

  /// Adds a media item to a memory.
  ///
  /// Verifies the file exists and belongs to the same space.
  Future<Map<String, dynamic>> addMedia({
    required String memoryId,
    required String spaceId,
    required String userId,
    required String fileId,
    String? caption,
    bool isCover = false,
    bool isPrivate = false,
    int displayOrder = 0,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    // Verify memory exists and belongs to the space
    final memory = await _repo.getMemoryById(memoryId);
    if (memory == null || memory['space_id'] != spaceId) {
      throw const MemoriesException(
        'Memory not found',
        code: 'MEMORY_NOT_FOUND',
        statusCode: 404,
      );
    }

    final media = await _repo.addMedia(
      id: _uuid.v4(),
      memoryId: memoryId,
      fileId: fileId,
      caption: caption?.trim(),
      isCover: isCover,
      isPrivate: isPrivate,
      displayOrder: displayOrder,
    );

    _log.info('Media added to memory $memoryId: ${media['id']}');

    return media;
  }

  /// Removes a media item from a memory.
  Future<void> removeMedia({
    required String mediaId,
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    await _repo.removeMedia(mediaId);

    _log.info('Media removed: $mediaId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Comments
  // ---------------------------------------------------------------------------

  /// Adds a comment to a memory.
  Future<Map<String, dynamic>> addComment({
    required String memoryId,
    required String spaceId,
    required String userId,
    required String content,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    if (content.trim().isEmpty) {
      throw const MemoriesException(
        'Comment content is required',
        code: 'INVALID_CONTENT',
        statusCode: 422,
      );
    }

    // Verify memory exists and belongs to the space
    final memory = await _repo.getMemoryById(memoryId);
    if (memory == null || memory['space_id'] != spaceId) {
      throw const MemoriesException(
        'Memory not found',
        code: 'MEMORY_NOT_FOUND',
        statusCode: 404,
      );
    }

    final comment = await _repo.addComment(
      id: _uuid.v4(),
      memoryId: memoryId,
      userId: userId,
      content: content.trim(),
    );

    _log.info('Comment added to memory $memoryId by $userId');

    return comment;
  }

  // ---------------------------------------------------------------------------
  // Reactions
  // ---------------------------------------------------------------------------

  /// Adds or updates a reaction on a memory.
  Future<Map<String, dynamic>> addReaction({
    required String memoryId,
    required String spaceId,
    required String userId,
    required String emoji,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    if (emoji.trim().isEmpty) {
      throw const MemoriesException(
        'Emoji is required',
        code: 'INVALID_EMOJI',
        statusCode: 422,
      );
    }

    // Verify memory exists and belongs to the space
    final memory = await _repo.getMemoryById(memoryId);
    if (memory == null || memory['space_id'] != spaceId) {
      throw const MemoriesException(
        'Memory not found',
        code: 'MEMORY_NOT_FOUND',
        statusCode: 404,
      );
    }

    final reaction = await _repo.addReaction(
      id: _uuid.v4(),
      memoryId: memoryId,
      userId: userId,
      emoji: emoji.trim(),
    );

    _log.info('Reaction added to memory $memoryId by $userId: $emoji');

    return reaction;
  }

  // ---------------------------------------------------------------------------
  // On This Day
  // ---------------------------------------------------------------------------

  /// Gets memories from the same date in previous years.
  Future<List<Map<String, dynamic>>> getOnThisDay({
    required String spaceId,
    required String userId,
    required int month,
    required int day,
  }) async {
    await _verifySpaceMembership(spaceId, userId);
    return _repo.getOnThisDay(spaceId, month, day);
  }

  /// Gets all milestone memories for a space.
  Future<List<Map<String, dynamic>>> getMilestones({
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);
    return _repo.getMilestones(spaceId);
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Verifies that a user is an active member of a space.
  Future<Map<String, dynamic>> _verifySpaceMembership(
    String spaceId,
    String userId,
  ) async {
    final membership = await _spacesRepo.getMember(spaceId, userId);
    if (membership == null || membership['status'] != 'active') {
      throw const MemoriesException(
        'You do not have access to this space',
        code: 'SPACE_ACCESS_DENIED',
        statusCode: 403,
      );
    }
    return membership;
  }
}
