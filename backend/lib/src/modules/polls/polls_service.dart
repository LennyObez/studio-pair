import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../spaces/spaces_repository.dart';
import 'polls_repository.dart';

/// Custom exception for polls-related errors.
class PollsException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const PollsException(
    this.message, {
    this.code = 'POLLS_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'PollsException($code): $message';
}

/// Service containing all polls-related business logic.
class PollsService {
  final PollsRepository _repo;
  final SpacesRepository _spacesRepo;
  final Logger _log = Logger('PollsService');
  final Uuid _uuid = const Uuid();

  /// Valid poll types.
  static const _validPollTypes = ['single', 'multiple', 'ranked'];

  PollsService(this._repo, this._spacesRepo);

  // ---------------------------------------------------------------------------
  // Poll CRUD
  // ---------------------------------------------------------------------------

  /// Creates a new poll with options.
  ///
  /// Validates the question, poll type, and options (2-10 required).
  Future<Map<String, dynamic>> createPoll({
    required String spaceId,
    required String userId,
    required String question,
    required String pollType,
    required List<Map<String, dynamic>> options,
    bool isAnonymous = false,
    DateTime? deadline,
  }) async {
    // Validate question
    if (question.trim().isEmpty) {
      throw const PollsException(
        'Poll question is required',
        code: 'INVALID_QUESTION',
        statusCode: 422,
      );
    }

    if (question.trim().length > 500) {
      throw const PollsException(
        'Poll question must be at most 500 characters',
        code: 'INVALID_QUESTION',
        statusCode: 422,
      );
    }

    // Validate poll type
    if (!_validPollTypes.contains(pollType)) {
      throw PollsException(
        'Invalid poll type. Must be one of: ${_validPollTypes.join(", ")}',
        code: 'INVALID_POLL_TYPE',
        statusCode: 422,
      );
    }

    // Validate options count
    if (options.length < 2) {
      throw const PollsException(
        'At least 2 options are required',
        code: 'INSUFFICIENT_OPTIONS',
        statusCode: 422,
      );
    }

    if (options.length > 10) {
      throw const PollsException(
        'A maximum of 10 options is allowed',
        code: 'TOO_MANY_OPTIONS',
        statusCode: 422,
      );
    }

    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Create the poll
    final pollId = _uuid.v4();
    final poll = await _repo.createPoll(
      id: pollId,
      spaceId: spaceId,
      createdBy: userId,
      question: question.trim(),
      pollType: pollType,
      isAnonymous: isAnonymous,
      deadline: deadline,
    );

    // Create options
    final createdOptions = <Map<String, dynamic>>[];
    for (var i = 0; i < options.length; i++) {
      final opt = options[i];
      final label = opt['label'] as String? ?? '';
      if (label.trim().isEmpty) continue;

      final option = await _repo.addOption(
        id: _uuid.v4(),
        pollId: pollId,
        label: label.trim(),
        imageUrl: opt['image_url'] as String?,
        displayOrder: i,
      );
      createdOptions.add(option);
    }
    poll['options'] = createdOptions;

    _log.info('Poll created: ${poll['question']} ($pollId) in space $spaceId');

    return poll;
  }

  /// Gets a poll by ID with options and vote counts.
  Future<Map<String, dynamic>> getPoll({
    required String pollId,
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final poll = await _repo.getPollById(pollId);
    if (poll == null) {
      throw const PollsException(
        'Poll not found',
        code: 'POLL_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (poll['space_id'] != spaceId) {
      throw const PollsException(
        'Poll not found',
        code: 'POLL_NOT_FOUND',
        statusCode: 404,
      );
    }

    return poll;
  }

  /// Gets polls for a space with optional active filter and pagination.
  Future<List<Map<String, dynamic>>> getPolls({
    required String spaceId,
    required String userId,
    bool? isActive,
    String? cursor,
    int limit = 25,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final clampedLimit = limit.clamp(1, 100);

    return _repo.getPolls(
      spaceId,
      isActive: isActive,
      cursor: cursor,
      limit: clampedLimit,
    );
  }

  // ---------------------------------------------------------------------------
  // Voting
  // ---------------------------------------------------------------------------

  /// Casts a vote on a poll.
  ///
  /// Validates the poll is not closed and enforces poll type rules:
  /// - single: exactly 1 vote
  /// - multiple: any number of votes
  /// - ranked: ordered votes with rank
  Future<Map<String, dynamic>> vote({
    required String pollId,
    required String spaceId,
    required String userId,
    required String optionId,
    int? rank,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final poll = await _repo.getPollById(pollId);
    if (poll == null || poll['space_id'] != spaceId) {
      throw const PollsException(
        'Poll not found',
        code: 'POLL_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Check if poll is closed
    if (poll['is_closed'] == true) {
      throw const PollsException(
        'This poll is closed',
        code: 'POLL_CLOSED',
        statusCode: 422,
      );
    }

    // Check if deadline has passed
    if (poll['deadline'] != null) {
      final deadline = DateTime.parse(poll['deadline'] as String);
      if (DateTime.now().toUtc().isAfter(deadline)) {
        throw const PollsException(
          'The deadline for this poll has passed',
          code: 'POLL_DEADLINE_PASSED',
          statusCode: 422,
        );
      }
    }

    // Validate option belongs to this poll
    final options = poll['options'] as List<dynamic>;
    final optionBelongsToPoll = options.any(
      (o) => (o as Map)['id'] == optionId,
    );
    if (!optionBelongsToPoll) {
      throw const PollsException(
        'Option does not belong to this poll',
        code: 'INVALID_OPTION',
        statusCode: 422,
      );
    }

    // Enforce poll type rules
    final pollType = poll['poll_type'] as String;
    final existingVotes = await _repo.getUserVotes(pollId, userId);

    if (pollType == 'single' && existingVotes.isNotEmpty) {
      // For single choice, remove previous vote first
      for (final vote in existingVotes) {
        await _repo.removeVote(vote['option_id'] as String, userId);
      }
    }

    final vote = await _repo.castVote(
      id: _uuid.v4(),
      optionId: optionId,
      userId: userId,
      rank: pollType == 'ranked' ? rank : null,
    );

    _log.info('Vote cast on poll $pollId by $userId for option $optionId');

    return vote;
  }

  /// Removes a vote from a poll option.
  Future<void> removeVote({
    required String pollId,
    required String spaceId,
    required String userId,
    required String optionId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final poll = await _repo.getPollById(pollId);
    if (poll == null || poll['space_id'] != spaceId) {
      throw const PollsException(
        'Poll not found',
        code: 'POLL_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (poll['is_closed'] == true) {
      throw const PollsException(
        'This poll is closed',
        code: 'POLL_CLOSED',
        statusCode: 422,
      );
    }

    await _repo.removeVote(optionId, userId);

    _log.info('Vote removed on poll $pollId by $userId for option $optionId');
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Closes a poll.
  ///
  /// Only the poll creator or a space admin can close a poll.
  Future<void> closePoll({
    required String pollId,
    required String spaceId,
    required String userId,
    required String userRole,
  }) async {
    final poll = await _repo.getPollById(pollId);
    if (poll == null || poll['space_id'] != spaceId) {
      throw const PollsException(
        'Poll not found',
        code: 'POLL_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (poll['is_closed'] == true) {
      throw const PollsException(
        'This poll is already closed',
        code: 'POLL_ALREADY_CLOSED',
        statusCode: 422,
      );
    }

    final isCreator = poll['created_by'] == userId;
    final isAdmin = userRole == 'admin' || userRole == 'owner';
    if (!isCreator && !isAdmin) {
      throw const PollsException(
        'Only the poll creator or a space admin can close this poll',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.closePoll(pollId);

    _log.info('Poll closed: $pollId in space $spaceId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Results
  // ---------------------------------------------------------------------------

  /// Gets the results for a poll.
  Future<Map<String, dynamic>> getResults({
    required String pollId,
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final poll = await _repo.getPollById(pollId);
    if (poll == null || poll['space_id'] != spaceId) {
      throw const PollsException(
        'Poll not found',
        code: 'POLL_NOT_FOUND',
        statusCode: 404,
      );
    }

    return _repo.getResults(pollId);
  }

  // ---------------------------------------------------------------------------
  // Random Pick
  // ---------------------------------------------------------------------------

  /// Selects a random option from the poll (for deadlocked decisions).
  Future<Map<String, dynamic>> getRandomPick({
    required String pollId,
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final poll = await _repo.getPollById(pollId);
    if (poll == null || poll['space_id'] != spaceId) {
      throw const PollsException(
        'Poll not found',
        code: 'POLL_NOT_FOUND',
        statusCode: 404,
      );
    }

    final option = await _repo.getRandomOption(pollId);
    if (option == null) {
      throw const PollsException(
        'Poll has no options',
        code: 'NO_OPTIONS',
        statusCode: 422,
      );
    }

    _log.info('Random pick for poll $pollId: ${option['label']}');

    return option;
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
      throw const PollsException(
        'You do not have access to this space',
        code: 'SPACE_ACCESS_DENIED',
        statusCode: 403,
      );
    }
    return membership;
  }
}
